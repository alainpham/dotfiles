#!/bin/bash
set -euo pipefail

#####################
# TPM2 auto-unlock for LUKS2-encrypted root on openSUSE Tumbleweed
# (systemd-boot / BLS layout with sdbootutil-managed initrds in the ESP).
#
# Enrolls the TPM2 as an additional LUKS2 keyslot so the disk unlocks
# automatically at boot. The original password keyslot is kept untouched
# as a permanent fallback.
#
# Interactive: systemd-cryptenroll prompts once for the current LUKS
# passphrase to authorise adding the new TPM2 keyslot.
#
# Idempotent: re-running detects an existing TPM2 token and skips enrollment.
#####################

# Re-exec as root if needed (this script needs cryptsetup / dracut / sdbootutil)
if [ "$(id -u)" -ne 0 ]; then
    exec sudo -E bash "$0" "$@"
fi

#####################
echo "=== TPM2 LUKS auto-unlock setup ==="

# PCR binding policy. Empty = no PCR binding (most robust: survives kernel /
# firmware / Secure Boot changes, never locks you out on updates). With Secure
# Boot disabled, PCR 7 adds little, so default to none. Override by exporting
# TPM2_PCRS before running, e.g. TPM2_PCRS=7  or  TPM2_PCRS=0+7
TPM2_PCRS="${TPM2_PCRS-}"

#####################
echo "--- checking for TPM 2.0 ---"
if [ ! -e /dev/tpmrm0 ] && [ ! -e /dev/tpm0 ]; then
    echo "ERROR: no TPM device found (/dev/tpmrm0). Aborting." >&2
    exit 1
fi
if [ "$(cat /sys/class/tpm/tpm0/tpm_version_major 2>/dev/null || echo 0)" != "2" ]; then
    echo "ERROR: TPM present but not version 2.0. Aborting." >&2
    exit 1
fi
echo "TPM 2.0 present."

#####################
echo "--- ensuring dracut includes TPM2 support ---"
# Guarantees every future initrd rebuild ships the tpm2-tss module, the crypt
# module, and the libcryptsetup-token-systemd-tpm2.so token handler.
DRACUT_CONF=/etc/dracut.conf.d/99-tpm2.conf
if ! grep -qs "tpm2-tss" "$DRACUT_CONF" 2>/dev/null; then
    echo 'add_dracutmodules+=" tpm2-tss crypt "' > "$DRACUT_CONF"
    echo "wrote $DRACUT_CONF"
else
    echo "$DRACUT_CONF already configured"
fi

#####################
echo "--- enrolling TPM2 against LUKS device(s) in /etc/crypttab ---"
if [ ! -s /etc/crypttab ]; then
    echo "ERROR: /etc/crypttab is empty; no LUKS mappings to configure." >&2
    exit 1
fi

# Back up crypttab once
[ -e /etc/crypttab.bak ] || cp /etc/crypttab /etc/crypttab.bak

CHANGED=0

# Iterate crypttab entries: <name> <device> <keyfile> <options>
while read -r name device keyfile options _rest || [ -n "$name" ]; do
    case "$name" in ''|\#*) continue ;; esac
    [ -n "$device" ] || continue

    # Resolve UUID=/PARTUUID= specs to a real device node
    case "$device" in
        UUID=*)     dev="/dev/disk/by-uuid/${device#UUID=}" ;;
        PARTUUID=*) dev="/dev/disk/by-partuuid/${device#PARTUUID=}" ;;
        *)          dev="$device" ;;
    esac

    if ! cryptsetup isLuks "$dev" 2>/dev/null; then
        echo "  $name ($dev): not a LUKS device, skipping"
        continue
    fi

    echo "  device: $name -> $dev"

    # Idempotency: skip enrollment if a systemd-tpm2 token already exists
    if cryptsetup luksDump "$dev" | grep -q "systemd-tpm2"; then
        echo "    TPM2 token already enrolled, skipping enrollment"
    else
        echo "    enrolling TPM2 (you will be prompted for the current LUKS passphrase)..."
        if [ -n "$TPM2_PCRS" ]; then
            systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs="$TPM2_PCRS" "$dev"
        else
            systemd-cryptenroll --tpm2-device=auto "$dev"
        fi
        echo "    TPM2 enrolled (password keyslot kept as fallback)"
    fi

    # Ensure crypttab options contain tpm2-device=auto
    if printf '%s' "$options" | grep -q "tpm2-device=auto"; then
        echo "    crypttab already has tpm2-device=auto"
    else
        if [ -z "$options" ] || [ "$options" = "none" ]; then
            newopts="tpm2-device=auto"
        else
            newopts="tpm2-device=auto,$options"
        fi
        # Replace this exact entry's options column in place
        esc_name=$(printf '%s' "$name" | sed 's/[.[\*^$/]/\\&/g')
        sed -i -E "s|^(\s*${esc_name}\s+\S+\s+\S+\s+)\S+(.*)$|\1${newopts}\2|" /etc/crypttab
        echo "    added tpm2-device=auto to crypttab"
        CHANGED=1
    fi
done < /etc/crypttab

echo "--- resulting /etc/crypttab ---"
grep -v '^\s*#' /etc/crypttab | grep -v '^\s*$' || true

#####################
echo "--- rebuilding initrds and installing into the ESP ---"
# On this systemd-boot/BLS layout the bootloader loads hashed initrd copies
# from the ESP (per btrfs snapshot), so plain `dracut` is not enough.
# sdbootutil mkinitrd regenerates the initrds and updates the boot entries.
if command -v sdbootutil >/dev/null 2>&1; then
    sdbootutil mkinitrd
else
    echo "WARNING: sdbootutil not found; falling back to dracut --regenerate-all"
    dracut --force --regenerate-all
fi

#####################
echo
echo "=== TPM2 auto-unlock configured ==="
echo "Reboot to test. The encrypted root should unlock without a password prompt."
echo "Fallback: your original LUKS password still works at the console prompt."
if [ -z "$TPM2_PCRS" ]; then
    echo "Note: no PCR binding - any boot of THIS machine auto-unlocks (protects a"
    echo "      pulled drive, not the whole machine). Re-run with TPM2_PCRS=7 after"
    echo "      enabling Secure Boot for stronger binding."
else
    echo "Note: bound to PCR(s) $TPM2_PCRS - changing that boot state requires"
    echo "      re-enrolling (your password still unlocks in that case)."
fi
echo "To undo: systemd-cryptenroll --wipe-slot=tpm2 <device>; restore /etc/crypttab.bak; sdbootutil mkinitrd"

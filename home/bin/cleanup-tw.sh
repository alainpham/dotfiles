#!/usr/bin/env bash
#
# cleanup-os.sh — reclaim disk space on openSUSE Tumbleweed after a `zypper dup`.
#
# Safe by design:
#   * Never removes the currently running kernel.
#   * Warns (and skips kernel purge) if you haven't rebooted into the newest kernel.
#   * Prints a before/after disk summary.
#
# Usage:
#   ./cleanup-os.sh          # interactive: asks before removing packages
#   ./cleanup-os.sh -y       # non-interactive: assume yes to everything
#   ./cleanup-os.sh --dry-run  # show what would happen, change nothing

set -euo pipefail

ASSUME_YES=0
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    -y|--yes)     ASSUME_YES=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

# --- helpers ----------------------------------------------------------------

log()  { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*"; }
run()  {
  if [[ $DRY_RUN -eq 1 ]]; then
    printf '   [dry-run] %s\n' "$*"
  else
    printf '   + %s\n' "$*"
    "$@"
  fi
}

# Require root (re-exec under sudo if needed).
if [[ $EUID -ne 0 ]]; then
  log "Elevating with sudo..."
  exec sudo -- "$0" "$@"
fi

ZYP_FLAGS=""
[[ $ASSUME_YES -eq 1 ]] && ZYP_FLAGS="--non-interactive"

disk_summary() { df -h --output=source,size,used,avail,pcent / | tail -n +1; }

# --- start ------------------------------------------------------------------

log "Disk usage BEFORE cleanup:"
disk_summary

# 1. Clean the zypper package cache (cached RPMs from the dup).
log "Cleaning zypper package cache (/var/cache/zypp)..."
run zypper $ZYP_FLAGS clean --all

# 2. Purge old kernels — but only if we've rebooted into the newest one.
RUNNING_KERNEL="$(uname -r)"                       # e.g. 7.1.5-1-default
NEWEST_KERNEL="$(ls -1 /usr/lib/modules 2>/dev/null | sort -V | tail -1)"

log "Kernel check: running=$RUNNING_KERNEL  newest-installed=$NEWEST_KERNEL"

if [[ "$RUNNING_KERNEL" != "$NEWEST_KERNEL" ]]; then
  warn "You are NOT running the newest installed kernel."
  warn "Reboot first (sudo reboot), then re-run this script to purge old kernels safely."
  warn "Skipping kernel cleanup for now."
else
  # Keep only the running kernel + the latest; drop the rest.
  # Honors multiversion.kernels in zypp.conf, so set a sane policy first.
  if ! grep -q '^multiversion.kernels' /etc/zypp/zypp.conf 2>/dev/null; then
    log "Setting multiversion.kernels = latest,running in /etc/zypp/zypp.conf"
    run bash -c 'echo "multiversion.kernels = latest,running" >> /etc/zypp/zypp.conf'
  fi

  # Prefer the built-in `zypper purge-kernels` (zypper >= 1.14); fall back to
  # the standalone script (from suse-module-tools) if present.
  if zypper help purge-kernels >/dev/null 2>&1; then
    log "Purging superseded kernels via 'zypper purge-kernels' (keeps running + latest)..."
    run zypper $ZYP_FLAGS purge-kernels
  elif command -v purge-kernels >/dev/null 2>&1; then
    log "Purging superseded kernels via 'purge-kernels' (keeps running + latest)..."
    run purge-kernels
  else
    warn "No purge-kernels tool available (expected from 'suse-module-tools'); skipping."
  fi
fi

# 3. Remove orphaned / unneeded packages (no other package depends on them).
log "Checking for unneeded (orphaned) packages..."
ORPHANS="$(zypper --no-refresh packages --unneeded 2>/dev/null \
            | awk -F'|' '/^i/ {gsub(/ /,"",$3); print $3}')" || true

if [[ -n "${ORPHANS// /}" ]]; then
  echo "Orphaned packages found:"
  echo "$ORPHANS" | sed 's/^/   - /'
  if [[ $ASSUME_YES -eq 1 || $DRY_RUN -eq 1 ]]; then
    # shellcheck disable=SC2086
    run zypper $ZYP_FLAGS remove --clean-deps $ORPHANS
  else
    read -r -p "Remove these orphaned packages? [y/N] " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
      # shellcheck disable=SC2086
      zypper remove --clean-deps $ORPHANS
    else
      warn "Skipped orphan removal."
    fi
  fi
else
  log "No orphaned packages to remove."
fi

# 4. Trim rotated/journal logs (optional, quick win).
log "Vacuuming systemd journal to last 7 days / 100M..."
if command -v journalctl >/dev/null 2>&1; then
  run journalctl --vacuum-time=7d
  run journalctl --vacuum-size=100M
fi

log "Disk usage AFTER cleanup:"
disk_summary

log "Done."
[[ $DRY_RUN -eq 1 ]] && warn "This was a DRY RUN — nothing was actually changed."
exit 0

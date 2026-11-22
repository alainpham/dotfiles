ihw_cachy(){
    sudo bash <<'BASH'
fstab=$(readlink -e /etc/fstab) || exit 1
mkdir -p /media/m01 /media/m02 /media/m03 || exit 1

tmp=$(mktemp "${fstab}.XXXXXX") || exit 1
trap 'rm -f -- "$tmp"' EXIT
cp --preserve=all -- "$fstab" "$tmp" || exit 1

awk '
    /^[[:space:]]*#/ || $2 !~ /^\/media\/m0[123]$/ { print }
    END {
        print "/dev/disk/by-label/m01\t/media/m01\text4\tdefaults,nofail\t0 2"
        print "/dev/disk/by-label/m02\t/media/m02\text4\tdefaults,nofail\t0 2"
        print "/dev/disk/by-label/m03\t/media/m03\text4\tdefaults,nofail\t0 2"
    }
' "$fstab" > "$tmp" || exit 1
mv -fT -- "$tmp" "$fstab"
BASH
}

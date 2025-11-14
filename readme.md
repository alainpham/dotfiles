```sh

cfdisk

export TARGETDISK=/dev/sda

mkfs.fat -F 32 ${TARGETDISK}1
fatlabel ${TARGETDISK}1 NIXBOOT
mkfs.ext4 ${TARGETDISK}2 -L NIXROOT

mount /dev/disk/by-label/NIXROOT /mnt
mkdir -p /mnt/boot
mount -o umask=077 /dev/disk/by-label/NIXBOOT /mnt/boot

nixos-generate-config --root /mnt

nixos-install

nixos-enter --root /mnt -c 'passwd apham'


```

nix
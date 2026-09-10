

ihw_cachy(){
    sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/ {/pci=nomsi/! s/"$/ pci=nomsi"/}' /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
}
#!/bin/bash
stow --no-folding --target=/home/$USER --adopt home
git restore .


#####################
echo install all custom scripts
for dir in "/home/$TARGET_USERNAME/dotfiles/scripts/"*; do
    if [ -d "$dir" ]; then
        for file in "$dir"/*; do
            [ -e "$file" ] || continue
            sudo cp "$file" /usr/local/bin/
            echo copied file $file
        done
    fi
done

mkdir -p /usr/local/share/icons
sudo cp -r /home/$TARGET_USERNAME/dotfiles/icons/* /usr/local/share/icons


#####################
echo copy whole etc folder
echo network config dnsmasq and powersave
sudo cp -R /home/$TARGET_USERNAME/dotfiles/etc/* /etc/

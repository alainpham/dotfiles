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
echo install etc files
echo network config dnsmasq and powersave
ETC_SRC="/home/$TARGET_USERNAME/dotfiles/etc"
find "$ETC_SRC" -type f | while read -r file; do
    rel="${file#$ETC_SRC/}"
    if [[ "$file" == *.envsubst ]]; then
        dest="/etc/${rel%.envsubst}"
        sudo mkdir -p "$(dirname "$dest")"
        envsubst < "$file" | sudo tee "$dest" > /dev/null
        echo "applied envsubst and copied $file -> $dest"
    else
        dest="/etc/$rel"
        sudo mkdir -p "$(dirname "$dest")"
        sudo cp "$file" "$dest"
        echo "copied $file -> $dest"
    fi
done

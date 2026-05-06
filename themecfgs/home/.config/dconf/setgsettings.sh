dconf reset -f /

gsettings set org.gnome.desktop.interface gtk-theme-name "${GTK_THEME}"
gsettings set org.gnome.desktop.interface gtk-icon-theme-name "${GTK_ICON_THEME}"
gsettings set org.gnome.desktop.interface gtk-font-name "${GTK_FONT_NAME}"
gsettings set org.gnome.desktop.interface gtk-cursor-theme-name "${GTK_CURSOR_THEME}"
gsettings set org.gnome.desktop.interface gtk-cursor-theme-size "${GTK_CURSOR_SIZE}"
gsettings set org.gnome.desktop.interface gtk-xft-hintstyle hintmedium
gsettings set org.gnome.desktop.interface color-scheme "${GTK_COLOR_SCHEME}"

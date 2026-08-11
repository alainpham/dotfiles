
ihw(){
    sudo tee /etc/systemd/system/rt3290-shutdown.service > /dev/null <<'EOF'
[Unit]
Description=Unload RT3290 Wi-Fi driver before shutdown
DefaultDependencies=no
Before=NetworkManager.service shutdown.target
Conflicts=shutdown.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/true
ExecStop=-/usr/bin/ip link set wlan0 down
ExecStop=/usr/bin/modprobe -r rt2800pci

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable --now rt3290-shutdown.service
}

#!/bin/bash

# Replace this with your controller's Bluetooth MAC address
DS4_MAC="F3:F8:39:F8:7C:FE"

echo "[+] Resetting connection to DualShock 4 ($DS4_MAC)..."
echo "[*] Put your DualShock 4 in pairing mode (hold PS + Share until it blinks rapidly)..."
read -p "Press Enter once it's blinking rapidly..."

# Create command list for persistent session
{
    echo "remove $DS4_MAC"
    echo "scan on"
    sleep 5

    # Wait for the device to show up
    for i in {1..20}; do
        echo "devices"
        sleep 1
        if bluetoothctl devices | grep -q "$DS4_MAC"; then
            break
        fi
    done

    echo "scan off"
    echo "pair $DS4_MAC"
    sleep 2
    echo "trust $DS4_MAC"
    sleep 2
    echo "connect $DS4_MAC"
    sleep 5
} | bluetoothctl

echo "[✓] Re-pairing complete."
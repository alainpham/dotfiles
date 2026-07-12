

ihw(){
    zypper in -y --auto-agree-with-licenses openSUSE-repos-Tumbleweed-NVIDIA
    zypper ref
    zypper in -y --auto-agree-with-licenses nvidia-driver-G06-kmp-meta
    # SOF firmware for Intel Alder Lake DSP audio (internal speakers/mics)
    zypper in -y --auto-agree-with-licenses sof-firmware
}


ihw(){
    zypper in intel-media-driver intel-gpu-tools
    zypper in openSUSE-repos-Tumbleweed-NVIDIA
    zypper ref
    zypper in nvidia-driver-G06-kmp-meta
}
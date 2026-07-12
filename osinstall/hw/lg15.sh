

ihw(){
    zypper in -y --auto-agree-with-licenses openSUSE-repos-Tumbleweed-NVIDIA
    zypper ref
    zypper in -y --auto-agree-with-licenses nvidia-driver-G06-kmp-meta
}
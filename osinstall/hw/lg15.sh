

ihw(){
    zypper in -y --auto-agree-with-licenses intel-media-driver intel-gpu-tools
    zypper in -y --auto-agree-with-licenses openSUSE-repos-Tumbleweed-NVIDIA
    zypper ref
    zypper in -y --auto-agree-with-licenses nvidia-driver-G06-kmp-meta
    # SOF firmware for Intel Alder Lake DSP audio (internal speakers/mics)
    zypper in -y --auto-agree-with-licenses sof-firmware

    mkdir /tmp/cuda
    cd /tmp/cuda
    wget https://developer.download.nvidia.com/compute/cuda/13.3.1/local_installers/cuda_13.3.1_610.43.02_linux.run
    sudo sh cuda_13.3.1_610.43.02_linux.run
    echo "/usr/local/cuda/lib64" | tee /etc/ld.so.conf.d/cuda.conf
    # https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html#installing-with-zypper
}
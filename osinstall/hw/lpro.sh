

ihw(){
    fprintd-enroll
    echo "auth required pam_fprintd.so"| sudo tee /etc/pam.d/sudo
    echo "auth required pam_fprintd.so"| sudo tee /etc/pam.d/login
    echo "auth required pam_fprintd.so"| sudo tee /etc/pam.d/lightdm
}
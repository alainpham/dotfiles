

ihw(){
    fprintd-enroll
    echo "auth required pam_fprintd.so"| sudo tee /etc/pam.d/sudo
    echo "auth required pam_fprintd.so"| sudo tee /etc/pam.d/login
    echo "auth required pam_fprintd.so"| sudo tee /etc/pam.d/lightdm
    # sudo pam-config --add --fprintd


    echo '/usr/bin/ssh -i ~/ssh/id_ed25519 $@' | sudo tee /usr/local/bin/ssh
    sudo chmod 755 /usr/local/bin/ssh

    echo '/usr/bin/scp -i ~/ssh/id_ed25519 $@' | sudo tee /usr/local/bin/scp
    sudo chmod 755 /usr/local/bin/scp
    
    echo '/usr/bin/sshfs -o ssh_command=/usr/local/bin/ssh $@' | sudo tee /usr/local/bin/sshfs
    sudo chmod 755 /usr/local/bin/sshfs
    
    echo '/usr/bin/ssh-copy-id -i ~/ssh/id_ed25519 $@' | sudo tee /usr/local/bin/ssh-copy-id
    sudo chmod 755 /usr/local/bin/ssh-copy-id
}
{ config, lib, pkgs, ... }:

let
  nixversion = "25.05";
  hostname= "nxvm";
  targetUser = "apham";
  keyboardLayout = "fr";
  keyboardModel = "pc105"; # for macbook use "macbook79"
  wildcardDomain = "houze.dns.army";
  enablekubernetes = true;
in
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 1;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = nixversion;

  networking.hostName = hostname;
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "LatArCyrHeb-16";
    keyMap = keyboardLayout;
  };

  users.groups = { 
    ${targetUser} = { };
  };

  users.users = {
    ${targetUser} = {
      isNormalUser = true;
      extraGroups = [ 
        "wheel"
        "docker"
      ];
    };
  };

  ##################################################
  # passwordless sudo for users in wheel group
  ##################################################
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # small logs
  services.journald.extraConfig = ''
    SystemMaxUse=50M
    SystemMaxFileSize=10M
  '';
  
  services.openssh.enable = true;

  # enable spice agent only when running in a VM
  services.spice-vdagentd.enable = true;

  ##################################################
  # essentials
  ##################################################
  programs.git.enable = true;
  programs.tmux.enable = true;
  programs.vim.enable = true;
  programs.neovim.enable = true;
  programs.htop.enable = true;
  programs.gnupg.agent.enable = true;
  programs.bash = {
    promptInit = ''
      # Provide a nice prompt if the terminal supports it.
      if [ "$TERM" != "dumb" ] || [ -n "$INSIDE_EMACS" ]; then
        PROMPT_COLOR="1;31m"
        ((UID)) && PROMPT_COLOR="1;32m"
        if [ -n "$INSIDE_EMACS" ]; then
          # Emacs term mode doesn't support xterm title escape sequence (\e]0;)
          PS1="\[\033[$PROMPT_COLOR\][\u@\h:\w]\\$\[\033[0m\] "
        else
          PS1="\[\033[$PROMPT_COLOR\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
        fi
        if test "$TERM" = "xterm"; then
          PS1="\[\033]2;\h:\u:\w\007\]$PS1"
        fi
      fi
  '';
  };

  environment.systemPackages = with pkgs; [
    # essentials
    curl
    wget
    ncdu
    dnsutils
    bmon
    btop
    zip
    unzip
    virt-what
    wireguard-tools
    jq
    jc
    sshfs
    iotop
    wakeonlan
    cloud-utils
    iperf


    # dev environment
    ansible
    nodejs_24
    go
    maven

    # kubernetes
    k9s
    kubernetes-helm

    # GUI applications
    st
  ];

  ##################################################
  # Dev environment
  ##################################################
  programs.java.enable = true;
  programs.java.package = pkgs.jdk17_headless;


  ##################################################
  # Docker
  ##################################################
  virtualisation.docker.enable = true;

  systemd.services.dockernet = {
    description = "dockernet";
    after = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.mkForce (pkgs.writeShellScript "dockernet" ''
        /run/current-system/sw/bin/docker network create --driver=bridge --subnet=172.18.0.0/16 --gateway=172.18.0.1 primenet || true
      '');
    };
  };

  ##################################################
  # kubernetes
  ##################################################
  services.k3s = {
    enable = enablekubernetes;
    extraFlags = [ 
      "--disable=traefik" 
      "--disable=servicelb"
      "--tls-san=${wildcardDomain}"
      "--write-kubeconfig-mode=644"
    ];
  };
  # Disable k3s from starting at boot; we'll manage it manually
  systemd.services.k3s.wantedBy = lib.mkForce [ ];
  
  # GUI applications
  systemd.services.numLockOnTty = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      # /run/current-system/sw/bin/setleds -D +num < "$tty";
      ExecStart = lib.mkForce (pkgs.writeShellScript "numLockOnTty" ''
        for tty in /dev/tty{1..6}; do
            ${pkgs.kbd}/bin/setleds -D +num < "$tty";
        done
      '');
    };
  };

  ##################################################
  # gui
  ##################################################
  services.xserver = {
    enable = true;
    xkb.layout = keyboardLayout;
    xkb.model = keyboardModel;
    displayManager.startx.enable = true;
  };
}


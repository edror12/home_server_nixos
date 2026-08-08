# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix # Include the results of the hardware scan.
    ];

  # GPU and iGPU.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Experimental features.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Configure network connections interactively with nmcli or nmtui.
  networking.hostName = "nixos-server";
  networking.networkmanager.enable = true;

  # Timezone.
  time.timeZone = "Asia/Jerusalem";

  # mDNS
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  # OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  # Authorized users.
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAA------YOUR_PUBLIC_KEY------"
  ];

  # Docker.
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # Define a user account.
  users.users."username" = {
    isNormalUser = true;
    description = "Jane Doe";
    extraGroups = ["networkmanager" "wheel" "video" "render"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAA------YOUR_PUBLIC_KEY------"
    ];
    packages = with pkgs; [
      # Intel GPU / media diagnostics
      libva-utils

      # Admin / networking
      iperf
      wakeonlan
      wireguard-tools

      # Editing / config
      neovim
      nixfmt

      # Nice system info
      fastfetch
    ];
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    # Development
    git
    python3

    # Networking
    curl
    wget

    # File utilities
    file
    tree
    unzip
    zip

    # JSON/YAML
    jq
    yq

    # Searching
    ripgrep
    fd
    fzf

    # Better CLI tools
    bat
    eza

    # System monitoring
    htop
    ncdu
    pciutils

    # Debugging
    lsof
    strace
    usbutils

    # Networking tools
    dig
    host
    bind
    iproute2
    iputils
    traceroute
    nettools

    # Process utilities
    ps
    watch
    procps
    killall
    psmisc

    # Miscellaneous
    zsh
    which
    tmux

    # Binary inspection
    binutils
    util-linux
    hexdump
    mount
    umount
    vim
  ];

  # Install zsh.
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    ohMyZsh = {
      enable = true;
      plugins = ["z" "git" "fzf" "python" "man"];
      theme = "robbyrussell";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Disable the firewall altogether.
  networking.firewall.enable = false;
  # Or open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "26.05"; # Did you read the comment?
}
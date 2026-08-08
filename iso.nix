{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  # To be accessed with nixos-installer.local
  networking.hostName = "nixos-installer";

  # SSH to allow headless install
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  # Authorized keys to log in
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAA------YOUR_PUBLIC_KEY------"
  ];

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

  # Useful tools available in the live environment.
  environment.systemPackages = with pkgs; [
    git
    vim
    curl
    wget
    tmux
  ];
}

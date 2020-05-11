{ config, pkgs, lib, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/sd-image-aarch64.nix>
    (builtins.fetchGit {
      url = "https://github.com/rycee/home-manager.git";
      rev = "f487b527ec420b888c52df1c4f8c31439201edb7";
    } + "/nixos")
    ./user.nix
  ];

  boot.loader.grub.enable = false;
  #boot.loader.generic-extlinux-compatible.enable = lib.mkOverride 25 false;

  #boot.loader.raspberryPi.enable = true;
  #boot.loader.raspberryPi.version = 3;
  boot.initrd.availableKernelModules = [ "usbhid" ];
  #hardware.deviceTree.enable = true;
  #hardware.deviceTree.overlays = [ "" ];

  boot.kernelParams = lib.mkOverride 25 [
    "cma=128M"
    "console=ttyS0,115200n8" # following needed for extlinux
    "console=ttyAMA0,115200n8"
    "console=tty0"
    "loglevel=7"
  ];
  boot.kernelPackages = pkgs.linuxPackages_rpi3;
  nix.maxJobs = lib.mkDefault 4;

  fileSystems."/mnt" = {
    device = "/dev/sda1";
    fsType = "vfat";
  };
  swapDevices = [{
    device = "/swapfile";
    size = 512;
  }];

  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.hostName = "moll-iga-pi";
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;

  # revert installer options that are (not) needed
  systemd.services.sshd.wantedBy = lib.mkOverride 25 [ "multi-user.target" ];
  services.openssh.permitRootLogin = lib.mkOverride 25 "no";
  networking.wireless.enable = false;
  users.users.nixos = lib.mkOverride 25 { };
  users.users.root.initialHashedPassword = lib.mkOverride 25 null;
  services.mingetty.autologinUser = lib.mkOverride 25 "kloenk";
  services.mingetty.helpLine = lib.mkOverride 25 "";
  sdImage.compressImage = false;
  boot.postBootCommands =
    "mkdir -m 0755 -p /nix/var/nix/{profiles,gcroots}/per-user/kloenk";

  system.stateVersion = "20.03";
}

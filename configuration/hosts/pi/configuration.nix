{ lib, config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./user.nix
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.initrd.availableKernelModules = [ "usbhid" ];
  boot.kernelParams = lib.mkOverride 25 [
    "cma=128M"
    "console=ttyS0,115200n8" # following needed for extlinux
    "console=ttyAMA0,115200n8"
    "console=tty0"
    "loglevel=7"
  ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # set writeback time down
  boot.kernel.sysctl = { "vm.dirty_writeback_centisecs" = 50; };

  nix.maxJobs = lib.mkDefault 4;

  fileSystems."/var/" = {
    device = "tmpfs";
    fsType = "tmpfs";
  };

  fileSystems."/mnt" = {
    device = "/dev/sda1";
    fsType = "vfat";
    options = [ "ro" ];
  };

  #  fileSystems."/" = {
  #    options = [ "ro" ];
  #  };

  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.hostName = "moll-iga-pi"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
  networking.interfaces.wlan0.useDHCP = true;

  systemd.services.sshd.wantedBy = lib.mkOverride 25 [ "multi-user.target" ];
  services.openssh.permitRootLogin = lib.mkOverride 25 "no";
  users.users.nixos = lib.mkOverride 25 { };
  users.users.root.initialHashedPassword = lib.mkOverride 25 null;
  services.mingetty.autologinUser = lib.mkOverride 25 "kloenk";
  services.mingetty.helpLine = lib.mkOverride 25 "";
  #sdImage.compressImage = false;
  boot.postBootCommands =
    "mkdir -m 0755 -p /nix/var/nix/{profiles,gcroots}/per-user/kloenk";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}


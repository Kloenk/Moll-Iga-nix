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
  nix.maxJobs = lib.mkDefault 4;

  # TODO: /mnt
  swapDevices = [{
    device = "/swapfile";
    size = 512;
  }];

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

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   wget vim
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "gnome3";
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}


{ config, pkgs, lib, ... }:

let
  slideshow = let
    dir = "/mnt";
    seconds = 20;
  in pkgs.writeScript "slideshow.sh" ''
    #!${pkgs.bash}/bin/bash
    feh -p -FZYD ${toString seconds} ${dir}/*
  '';
in {
  services.openssh.enable = true;
  services.openssh.passwordAuthentication = false;
  security.sudo.wheelNeedsPassword = false;

  services.journald.extraConfig = "SystemMaxUse=1G";

  time.timeZone = "Europe/Berlin";

  environment.systemPackages = with pkgs; [ alacritty.terminfo tmux git htop ];

  environment.variables.EDITOR = "vim";

  users.users.kloenk = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBps9Mp/xZax8/y9fW1Gt73SkskcBux1jDAB8rv0EYUt cardno:000612029874"
    ];
    packages = with pkgs; [ vim htop feh ];
  };

  home-manager.users.kloenk = {
    programs.bash = {
      enable = true;
      initExtra = ''
        if [[ -z "$SWAYSOCK" ]] && [[ $(tty) = /dev/tty1 ]]; then
          sway
        fi
      '';
    };
  };

  # X foo
  services.xserver = {
    #  enable = true;
    displayManager.startx.enable = true;
    videoDrivers = [ "fbdev" ];
  };

  #programs.sway.enable = true;
  hardware.opengl.enable = true;

  home-manager.users.kloenk.wayland.windowManager.sway = {
    enable = true;
    config = {
      bars = [ ];
      modifier = "Mod4";
      window.titlebar = true;
      terminal = "${pkgs.alacritty}/bin/alacritty";
      keybindings = let
        mod =
          config.home-manager.users.kloenk.wayland.windowManager.sway.config.modifier;
      in {
        "${mod}+Return" =
          "exec ${config.home-manager.users.kloenk.wayland.windowManager.sway.config.terminal}";
        "${mod}+Shift+q" = "kill";
        "${mod}+Shift+e" =
          "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'";
      };
      startup = [{
        command = "${slideshow}";
        always = true;
      }];
    };
  };

  home-manager.users.kloenk.xsession = {
    #    enable = true;
    scriptPath = ".xinitrc";
    #    windowManager.i3.enable = true;
    #    windowManager.i3.config.startup = [
    #    	{ command = "${slideshow}"; always = false; notification = false; }
    #    ];
    # initExtra = ''
    #   ${pkgs.xorg.xrdb}/bin/xrdb -merge ~/.Xresources
    #   ${pkgs.feh}/bin/feh --bg-fill ~/.wallpaper-image
    #   ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr &

    #   export XDB_SESSION_TYPE=x111
    #   export KDE_FULL_SESSION=true
    #   export XDG_CURRENT_DESKTOP=KDE
    #   export GPG_TTY=$(tty)

    #   ${pkgs.notify-osd}/bin/notify-osd &

    #   ${pkgs.slstatus}/bin/slstatus &
    # '';
  };
}

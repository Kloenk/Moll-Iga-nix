{ pkgs, lib, ... }:

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
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBps9Mp/xZax8/y9fW1Gt73SkskcBux1jDAB8rv0EYUt cardno:000612029874"
    ];
    packages = with pkgs; [ vim htop feh ];
  };

  home-manager.users.kloenk = {
    programs = {
      fish = {
        #enable = true;
        shellInit = "set PAGER less";
        shellAbbrs = {
          ipa = "ip a";
          ipr = "ip r";
          s = "sudo";
          ssy = "sudo systemctl";
          sy = "systemctl";
        };
        loginShellInit = ''
          				  # Start X at login
          					if status is-login
              				if test -z "$DISPLAY" -a $XDG_VTNR = 1
                  			#exec startx -- -keeptty
              				end
          					end
          				'';
      };
    };
  };

  # X foo
  services.xserver = {
    #  enable = true;
    displayManager.startx.enable = true;
    videoDrivers = [ "fbdev" ];
  };

  programs.sway.enable = true;

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

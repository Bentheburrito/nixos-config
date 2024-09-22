# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, pkgs-unstable, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/system/base.nix
      ../../modules/nvidia.nix
      ../../modules/neovim-dev.nix
      ../../modules/tmux.nix
    ];

  # Be able to mount my 2TB external hard drive
  boot.supportedFilesystems = [ "ntfs" ];

  networking.hostName = "linuxisgood";

  # Enable networking
  networking.networkmanager = {
    enable = true;
  };

  # apply a Mutter patch via an overlay to fix the mouse-button/keyboard stuttering video output issue
  # maybe one day it will actually be merged
  nixpkgs.overlays = [ (final: prev: {
    gnome = prev.gnome.overrideScope' (gfinal: gprev: {
      mutter = gprev.mutter.overrideAttrs (oldAttrs: {
        patches = (oldAttrs.patches or []) ++ [
          # https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/3143
          (prev.fetchpatch {
            url = "https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/3143.patch";
            hash = "sha256-z89VbNPZRvKs+m76dpWKcCFhWZnX/69wnpBCMceeAI4=";
          })
        ];
      });
    });
  }) ];

  # Enable auto-upgrading, every Saturday @ 10am PT
  system.autoUpgrade = {
    enable = true;
    dates = "Sat *-*-* 10:00:00 America/Los_Angeles";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  # Disable Wayland for GNOME...Albert and Autokey won't work without this :(
  services.xserver.displayManager.gdm.wayland = false;
  services.gnome.tracker-miners.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # note: the 'authentication' config is very finicky if you don't get the 
  # syntax right - nix will time out the postgres systemd service after 2 mins 
  # even though the server itself is still functional. 
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_12;
    authentication = pkgs.lib.mkForce ''
#      local   all             postgres                                md5

      # TYPE  DATABASE        USER            ADDRESS                 METHOD

      # "local" is for Unix domain socket connections only
      local   all             all                                     peer
      # IPv4 local connections:
      host    all             all             127.0.0.1/32            md5
      # IPv6 local connections:
 #     host    all             all             ::1/128                 md5
      # Allow replication connections from localhost, by a user with the
      # replication privilege.
  #    local   replication     all                                     peer
   #   host    replication     all             127.0.0.1/32            md5
    #  host    replication     all             ::1/128                 md5
    '';
#       local all       all       trust
#    initialScript = ''
 #     ALTER USER postgres WITH PASSWORD 'postgres';
  #  '';
  };

  # Enable sound with pipewire.
  sound.enable = true;

  hardware.enableAllFirmware = true;
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Name = "BT Dongle";
        ControllerMode = "dual";
        #FastConnectable = "true";
        Enable = "Source,Sink,Media,Socket";
        Experimental = "true";
      };
      #Policy = {
      #  AutoEnable = "true";
      #};
    };
  };
  hardware.pulseaudio = {
    enable = false;
    #package = pkgs.pulseaudioFull;
  };
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  users.users.snowful = {
    isNormalUser = true;
    description = "Ben";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      # Browsers
      firefox
      librewolf
      # Communications
      thunderbird
      element-desktop
      # Productivity/Workflow
      albert
      autokey
      pass
      # Utility
      gimp
      protonvpn-gui
      # Video
      obs-studio
      ffmpeg_6-full
      libsForQt5.kdenlive
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Needed for VSCode to work with Wayland apparently
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # GNOME config
  programs.dconf.enable = true;

  # Config the server `dict` should use
  environment.etc."dict.conf".text = "server dict.org";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # dev stuff
    gnupg
    elixir-ls
    pkgs-unstable.elixir
    ## Need to install Erlang explicitly to get `epmd` for next-ls to work
    pkgs-unstable.erlang
    pkgs-unstable.elmPackages.elm # added "unstable." on 1/12 need to see after reboot if unstable version fixes this issue I was running into: https://github.com/NixOS/nixpkgs/issues/277156 
    pkgs-unstable.elmPackages.elm-format
    gnumake # cringe argon2_elixir needs `make`
    inotify-tools # for phoenix live-reload
    openssl
    gcc
    # Note: installing rust stuff using rustup means toolchains have to be 
    # installed imperatively, and after installing stable/nightly toolchains, 
    # will need to do things like 
    #`rustup component add rust-src && rustup component add rust-analyzer`
    # to install rust analyzer for nvim to pick up. more reading: 
    # - https://rust-analyzer.github.io/manual.html#installation
    # - https://nixos.wiki/wiki/Rust
    rustup
    ## Neovim stuff
    ripgrep # used by nvim telescope plugin
    xclip # used by tmux-yank
    alacritty

    # gnome stuff
    gnome3.gnome-tweaks
    gnome3.dconf-editor
    ## systray icons
    gnomeExtensions.appindicator
    gnomeExtensions.dash-to-dock
    ## why make it harder to take temp screenshots .-.
    # gnome.gnome-screenshot
    # gnomeExtensions.gnome-screenshot

    # general stuff
    libreoffice-qt
    hunspell
    dict
    pkgs-unstable.obsidian
    duplicity
    # game stuff
    steam-run    
  ];

  # Install Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = false; # Open ports in the firewall for Source Dedicated Server
  };

  # `gamemoderun` to pass to Steam game args
  programs.gamemode.enable = true;

  # "Ensure gnome-settings-daemon udev rules are enabled" https://nixos.wiki/wiki/GNOME
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  ### AUTO MOUNT STUFF ###
  # NOTE: this is commented out here, because it was generated by nixos-generate-config
  #       re: https://unix.stackexchange.com/questions/213137/how-to-auto-mount-permanently-mount-external-devices-on-nixos
  #       so, as of writing it lives in `/etc/nixos/hardware-configuration.nix`.
  #   fileSystems."/media/ubuntu_part" =
  #  { device = "/dev/disk/by-uuid/ca9e0aa9-f965-4528-a3c6-35c0776b9e43";
  #    fsType = "ext4";
  #  };

  # Auto-mount 2TB hard drive
  fileSystems."/media/storage" = {
     device = "/dev/disk/by-uuid/060E0AA77FFD6A32";
     fsType = "auto";
   };
  ### END AUTO MOUNT STUFF ###

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions. programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
  #   enableSSHSupport = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

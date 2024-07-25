# Config for old thinkpad-turned-server

{ config, pkgs, conduit, ... }: {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/system/base.nix
      ../../modules/system/remote.nix
      ../../modules/neovim-min.nix
    ];

  networking.hostName = "nixos1"; # Define your hostname.

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # === BEGIN MATRIX STUFF ===
  # Configure Conduit Matrix Homeserver
  services.matrix-conduit = {
    enable = true;

    # This causes NixOS to use the flake defined in this repository instead of
    # the build of Conduit built into nixpkgs.
    package = conduit.packages.${pkgs.system}.default;

    settings.global = {
      server_name = "nonsensical.network";
      allow_registration = false;
      address = "0.0.0.0";
    };
  };

  # still need this simple webserver to serve .well-known json.
  services.nginx = {
    enable = true;
    virtualHosts."nonsensical.network" = {
      locations."=/.well-known/matrix/server" = let
        # Build a dervation that stores the content of `${server_name}/.well-known/matrix/server`
        well_known_server = pkgs.writeText "well-known-matrix-server" ''
          {
            "m.server": "nonsensical.network:443"
          }
        '';
      in {
        # Use the contents of the derivation built previously
        alias = "${well_known_server}";

        extraConfig = ''
          # Set the header since by default NGINX thinks it's just bytes
          default_type application/json;
        '';
      };

      locations."=/.well-known/matrix/client" = let
        # Build a dervation that stores the content of `${server_name}/.well-known/matrix/client`
        well_known_client = pkgs.writeText "well-known-matrix-client" ''
          {
            "m.homeserver": {
              "base_url": "https://nonsensical.network"
            }
          }
        '';
      in {
        # Use the contents of the derivation built previously
        alias = "${well_known_client}";

        extraConfig = ''
          # Set the header since by default NGINX thinks it's just bytes
          default_type application/json;

          # https://matrix.org/docs/spec/client_server/r0.4.0#web-browser-clients
          add_header Access-Control-Allow-Origin "*";
        '';
      };
    };
  };
  # === END MATRIX STUFF ===

  # Configure the firewall
  networking.firewall = {
    # 6167 is the default port for Conduit. Cloudflare ingress rule will be needed to act as a reverse proxy
    # 80 is for the nginx server
    allowedTCPPorts = [ 22 6167 80 ];
#    allowedUDPPortRanges = [
#      { from = 4000; to = 4007; }
#      { from = 8000; to = 8010; }
#    ];
  };  

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ben = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ vim ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # !!! apparently this is not supported with flakes 🙃
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}


{
  description = "NixOS entrypoint";

  # Inputs
  # https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-flake.html#flake-inputs

  inputs = {
    # The nixpkgs entry in the flake registry.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    # The nixpkgs entry in the flake registry.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Conduit v0.8.0
    conduit.url = "gitlab:famedly/conduit/f8d7ef04e664580e882bac852877b68e7bd3ab1e";

    # The nixpkgs entry in the flake registry, overriding it to use a specific Git revision.
    # nixpkgsRegistryOverride.url = "nixpkgs/a3a3dda3bacf61e8a39258a0ed9c924eeca8e293";

    # The master branch of the NixOS/nixpkgs repository on GitHub.
    # nixpkgsGitHub.url = "github:NixOS/nixpkgs";

    # A specific revision of the NixOS/nixpkgs repository on GitHub.
    # nixpkgsGitHubRevision.url = "github:NixOS/nixpkgs/a3a3dda3bacf61e8a39258a0ed9c924eeca8e293";
  };

  # For more information about well-known outputs checked by `nix flake check`:
  # https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-flake-check.html#evaluation-checks

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs: {
    nixosConfigurations.linuxisgood = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      # pass down unstable nixpkgs to configuration.nix for 
      # elixir/obsidian/whatever else
      specialArgs = {
        pkgs-unstable = import nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        inherit self;
      };

      modules = [
        # import og non-flake config
        ./hosts/linuxisgood/configuration.nix
      ];
      # modules = [{boot.isContainer=true;}] ;
    };

    nixosConfigurations.nixos1 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        conduit = inputs.conduit;
      };

      modules = [
        ./hosts/nixos1/configuration.nix
      ];
    };

    # Used with `nixos-rebuild --flake .#<hostname>`
    # nixosConfigurations."<hostname>".config.system.build.toplevel must be a derivation

    # Utilized by `nix develop`
    # devShell.x86_64-linux = rust-web-server.devShell.x86_64-linux;

    # Utilized by `nix develop .#<name>`
    # devShells.x86_64-linux.example = self.devShell.x86_64-linux;
  };
}

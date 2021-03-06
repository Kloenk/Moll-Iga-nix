{
  description = "Moll Iga nixos configuration";

  inputs.home-manager = {
    type = "github";
    owner = "kloenk";
    repo = "home-manager";
    inputs.nixpkgs.follows = "/nixpkgs";
  };

  inputs.nixpkgs = {
    type = "github";
    owner = "nixos";
    repo = "nixpkgs";
  };

  outputs = inputs@{ self, home-manager, nixpkgs }:
    let
      systems = [ "x86-64_linux" "aarch64-linux" ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
          #overlays = [ self.overlay home-manager.overlay ];
        });

      # TODO: sd image

      # pi
      pi = nixpkgs.lib.nixosSystem rec {
        system = "aarch64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration/hosts/pi/configuration.nix
          (import ./configuration/hosts/pi/hardware-configuration.nix)
        ];
      };

      pi-image = nixpkgs.lib.nixosSystem rec {
        system = "aarch64-linux";
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration/hosts/pi/configuration.nix
          (nixpkgs + "/nixos/modules/installer/cd-dvd/sd-image-aarch64.nix")
          {
            sdImage.compressImage = false;
            sdImage.imageBaseName = "moll-iga-nix-image";

          }
        ];
      };
    in {

      nixosConfigurations = { inherit pi; };

      sdImage = { pi = pi-image.config.system.build.sdImage; };
    };
}

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-{{ VERSION_ID }}";

    disko.url = "github:nix-community/disko";

    home-manager.url = "github:nix-community/home-manager/release-{{ VERSION_ID }}";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, disko, home-manager, ... } @ inputs: {
    nixosConfigurations.starship = nixpkgs.lib.nixosSystem {
      system = "{{ CURRENT_SYSTEM }}";
      specialArgs = inputs;
      modules = [
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users."{{ USERNAME }}" = import ./home-configuration.nix;
        }
        disko.nixosModules.disko
        ./configuration.nix
      ];
    };
  };
}

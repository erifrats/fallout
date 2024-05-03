{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    disko.url = "github:nix-community/disko";
  };

  outputs = { nixpkgs, disko, ... } @ inputs: {
    nixosConfigurations.stargate = nixpkgs.lib.nixosSystem {
      system = "{{ CURRENT_SYSTEM }}";
      specialArgs = inputs;
      modules = [
        ./configuration.nix
        disko.nixosModules.disko
      ];
    };
  };
}

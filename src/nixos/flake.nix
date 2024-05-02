{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    disko.url = "github:nix-community/disko";
  };

  outputs =
    { self
    , nixpkgs
    , disko
    , ...
    }:

    {
      nixosConfigurations.stargate = nixpkgs.lib.nixosSystem {
        system = "{{ CURRENT_SYSTEM }}";
        modules = [
          ./configuration.nix
          disko.nixosModules.disko
        ];
      };
    };
}

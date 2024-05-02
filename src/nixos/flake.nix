{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    flake-utils.url = "github:numtide/flake-utils";
    disko.url = "github:nix-community/disko";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , disko
    , ...
    }:

    flake-utils.lib.eachDefaultSystem (
      system:

      {
        nixosConfigurations.stargate = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            disko.nixosModules.disko
          ];
        };
      }
    )
  ;
}

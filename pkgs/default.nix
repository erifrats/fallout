import <nixpkgs> {
  overlays = [
    (final: prev: {
      # Version v0.14.0 of Gum appears to be malfunctioning.
      # Based on https://github.com/charmbracelet/gum/releases/tag/v0.14.0,
      # it seems that recent changes to the `huh` library have caused issues with margins and paddings.
      # We'll be sticking to using v0.13.0 until a fix is available.
      gum = prev.gum.overrideAttrs (old: rec {
        pname = "gum";
        version = "0.13.0";

        src = prev.fetchFromGitHub {
          owner = "charmbracelet";
          repo = pname;
          rev = "v${version}";
          hash = "sha256-NgMEgSfHVLCEKZ3MmNV571ySMUD8wj+kq5EccGrxtZc=";
        };
      });

      # Disko isn't available on NixOS 23.11.
      disko = prev.callPackage ./disko { };
    })
  ];
}

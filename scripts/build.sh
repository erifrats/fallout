#!/bin/sh

nix-build --expr '(import <nixpkgs> {}).callPackage ./default.nix {}'

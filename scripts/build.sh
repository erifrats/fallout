#!/usr/bin/env bash

nix-build --expr "with import <nixpkgs> {}; callPackage ./default.nix {}"

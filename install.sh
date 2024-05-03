#!/usr/bin/env bash

{
    oops() {
        echo "$0:" "$@" >&2
        exit 1
    }

    git() {
        nix-shell -p git --run "git $*"
    }

    tmp="$(mktemp -d)"

    cd "$tmp"

    # Fetch and build the source code.
    git clone https://github.com/erifrats/stargate.git . 1> /dev/null || oops "fetch failed"
    nix-build || oops "build failed"

    # Install stargate.
    nix-env -i ./result || oops "install failed"

    exec stargate "$@"
}

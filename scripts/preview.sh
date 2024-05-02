#!/usr/bin/env bash

source "$(dirname "$(dirname "$0")..")/src/stargate/bpt/bpt.sh"

ROOT="$(dirname "$(dirname "$0")..")"
NIXOS_CONFIG="$ROOT/artifacts"
NIXOS_TEMPLATE="$ROOT/src/nixos"

{
    USERNAME="guest"
    PASSWORD="$(mkpasswd "$USERNAME")"
    VERSION_ID="$(nix-instantiate --eval --expr "builtins.substring 0 5 ((import <nixos> {}).lib.version)")"

    find "$NIXOS_TEMPLATE" -type f | while read -r file; do
        redirect="${file/$NIXOS_TEMPLATE/$NIXOS_CONFIG}"

        mkdir -p "$(dirname "$redirect")"
        bpt.main ge "$file" >"$redirect"

        unset redirect
    done

    echo {} >"$NIXOS_CONFIG/hardware-configuration.nix"
    echo {} >"$NIXOS_CONFIG/disk-configuration.nix"
}

nix-build \
    '<nixpkgs/nixos>' \
    -A vm \
    -I nixos-config="$NIXOS_CONFIG/configuration.nix"

exec "$ROOT/result/bin/run-stargate-vm" "$@"

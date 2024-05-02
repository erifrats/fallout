#!/usr/bin/env bash

source "$PWD/src/stargate/bpt/bpt.sh"

NIXOS_CONFIG="$PWD/artifacts/nixos"
NIXOS_TEMPLATE="$PWD/src/nixos"

# Generate from template.
{
    USERNAME="guest"
    PASSWORD="$(mkpasswd "$USERNAME")"
    VERSION_ID="$(
        nix-instantiate \
            --eval \
            --expr "builtins.substring 0 5 ((import <nixos> {}).lib.version)" |
            sed 's/"//g'
    )"

    find "$NIXOS_TEMPLATE" -type f | while read -r file; do
        redirect="${file/$NIXOS_TEMPLATE/$NIXOS_CONFIG}"

        mkdir -p "$(dirname "$redirect")"
        bpt.main ge "$file" >"$redirect"

        unset redirect
    done

    echo {} >"$NIXOS_CONFIG/hardware-configuration.nix"
    echo {} >"$NIXOS_CONFIG/disk-configuration.nix"
}

# Initialize git for flake.
{
    pushd "$NIXOS_CONFIG" || exit 1

    git init .
    git add .
    git commit -m "Initial commit"

    popd
}

nix build "${NIXOS_CONFIG}#nixosConfigurations.x86_64-linux.stargate.config.system.build.vm" &&
    exec "$PWD/result/bin/run-stargate-vm" "$@"

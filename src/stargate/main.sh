#!/usr/bin/env bash

source "/etc/os-release"
source "$(dirname "$0")/bpt/bpt.sh"

unset LUKS_SECRET
unset NIXOS_CONFIG
unset USERNAME
unset PASSWORD

ACCENT_COLOR="#bb8dfc"
DISK="$1"
LUKS_FILE="/run/keys/luks.key"
NIXOS_TEMPLATE="$(dirname "$(dirname "$0")..")/nixos"

function oops() {
    echo "$0:" "$@" >&2
    exit 1
}

function gum_confirm() {
    gum confirm \
        --prompt.margin="$(($LINES / 2)) 0 0 0" \
        --prompt.width=$COLUMNS \
        --prompt.align="center" \
        --prompt.bold \
        --selected.background="$ACCENT_COLOR" \
        --default=false \
        "$@"

    return $?
}

function gum_error() {
    gum_confirm \
        --negative="" \
        --affirmative="Ok" \
        --default=true \
        "$@"

    return $?
}

function gum_input() {
    local query="${!#}" # last element of the array
    local result

    if [ -z "$query" ]; then
        oops "$FUNCNAME: query cannot be null"
    fi

    result="$(
        gum input \
            --placeholder="$query" \
            --prompt="" \
            --width=${#query} \
            --prompt.margin="$(($LINES / 2)) 0 0 $((($COLUMNS / 2) - (${#query} / 2)))" \
            --char-limit=0 \
            --cursor.foreground="$ACCENT_COLOR" \
            "${@:1:$#-1}"
    )"

    printf "$result"
}

function gum_password() {
    gum_input \
        --password \
        "$1"
}

function get_password() {
    local query="$1"
    local password
    local confirm

    while true; do
        password="$(gum_password "$query")"
        confirm="$(gum_password "Confirm password")"

        if [ "$password" != "$confirm" ]; then
            gum_error "Passwords do not match."
        elif [ -z "$password" ] || [[ "$password" =~ ^[[:space:]]*$ ]]; then
            gum_error "Password cannot be null, empty, or consist only of whitespace."
        else
            break
        fi
    done

    printf "$password"
}

function get_username() {
    local query="$1"
    local username

    while true; do
        username="$(gum_input "$query")"

        if [ -z "$username" ] || [[ "$username" =~ ^[[:space:]]*$ ]]; then
            gum_error "Username cannot be null, empty, or consist only of whitespace."
        elif ! [[ "$username" =~ ^[a-zA-Z][a-zA-Z0-9_.-]{0,29}$ ]]; then
            gum_error "Username should start with a letter, be 30 characters or fewer and can only contain letters, numbers, dots, underscores and hyphens."
        else
            break
        fi
    done

    printf "$username"
}

function reboot() {
    local seconds=6

    for ((i = $seconds; i > 0; i--)); do
        printf 'Rebooting in %s\r' "$i"
        sleep 1
    done

    "$(which reboot)"
}

if [[ $# -eq 0 ]]; then
    oops "Usage: $0 [disk]"
fi

if [ "$VARIANT_ID" != "installer" ]; then
    oops "Stargate can only be executed from the NixOS installer environment."
fi

# Restart with root privileges.
if [ "$(id -u)" != "0" ]; then
    clear
    gum_error \
        --timeout="3000ms" \
        "Stargate requires root privileges. Restarting with sudo..."

    exec sudo stargate "$@"
fi

if [[ ! -b "$DISK" ]]; then
    oops "The disk '$DISK' is not valid or does not exist."
fi

if ! lsblk -no TYPE "$DISK" | grep -q "disk"; then
    oops "The disk cannot be a partition."
fi

DISK="/dev/disk/by-id/$(lsblk -dno ID-LINK "$DISK")"
DISK_SIZE=$(blockdev --getsize64 "$DISK")

if ((DISK_SIZE < 20 * 1024 ** 3)); then
    oops "Disk size must be at least 20GB."
fi

clear

USERNAME="$(get_username "Enter your prefered username")"
PASSWORD="$(mkpasswd "$(get_password "Enter a password")")"
LUKS_SECRET="$(get_password "Enter a LUKS password")"

# Generate the nixos configuration.
{
    NIXOS_CONFIG="$(mktemp -d)"

    find "$NIXOS_TEMPLATE" -type f | while read -r file; do
        redirect="${file/$NIXOS_TEMPLATE/$NIXOS_CONFIG}"

        mkdir -p "$(dirname "$redirect")"
        bpt.main ge "$file" >"$redirect"

        unset redirect
    done

    unset USERNAME
    unset PASSWORD
}

if gum_confirm "Perform destructive wipe on the disk?"; then
    shred -v "$DISK" || oops "Data sanitization failed."
fi

# Apply the disk configuration.
{
    # Generate the LUKS key file for disko.
    printf "$LUKS_SECRET" >"$LUKS_FILE"
    unset LUKS_SECRET

    disko --mode disko "$NIXOS_CONFIG/disk-configuration.nix" || oops "Disko failed."
}

# Move the generated nixos configuration.
{
    mkdir -p /mnt/etc/nixos
    mv -T "$NIXOS_CONFIG" "/mnt/etc/nixos"

    # Generate `hardware-configuration.nix`.
    nixos-generate-config \
        --no-filesystems \
        --show-hardware-config \
        --root /mnt \
        >"/mnt/etc/nixos/hardware-configuration.nix"
}

# if [ -t 0 ]; then
#     $EDITOR /mnt/etc/nixos/configuration.nix
# fi

nixos-install --no-root-passwd && reboot || oops "Installation failed."

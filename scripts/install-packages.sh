#!/usr/bin/env bash

set -euo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
readonly SCRIPT_PATH
REPO_DIR="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)"
readonly REPO_DIR

if (($# == 0)); then
    categories=(core desktop)
else
    categories=("$@")
fi

pacman_packages=()
aur_packages=()

for category in "${categories[@]}"; do
    package_file="$REPO_DIR/packages/$category.txt"
    if [ ! -f "$package_file" ]; then
        printf 'Unknown package category: %s\n' "$category" >&2
        printf 'Available categories: core desktop dev aur\n' >&2
        exit 2
    fi

    while IFS= read -r package_name; do
        case "$package_name" in
            "" | \#*) continue ;;
        esac
        if [ "$category" = "aur" ]; then
            aur_packages+=("$package_name")
        else
            pacman_packages+=("$package_name")
        fi
    done <"$package_file"
done

if ((${#pacman_packages[@]} == 0)) && ((${#aur_packages[@]} == 0)); then
    printf 'No packages selected.\n' >&2
    exit 2
fi

if ((${#pacman_packages[@]} > 0)); then
    printf 'Installing %d pacman packages from: %s\n' "${#pacman_packages[@]}" "${categories[*]}"
    sudo pacman -S --needed "${pacman_packages[@]}"
fi

if ((${#aur_packages[@]} > 0)); then
    helper=""
    if command -v paru >/dev/null 2>&1; then
        helper=paru
    elif command -v yay >/dev/null 2>&1; then
        helper=yay
    else
        printf 'Need paru or yay to install AUR packages: %s\n' "${aur_packages[*]}" >&2
        exit 1
    fi
    printf 'Installing %d AUR packages with %s\n' "${#aur_packages[@]}" "$helper"
    "$helper" -S --needed "${aur_packages[@]}"
fi

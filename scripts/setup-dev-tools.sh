#!/usr/bin/env bash

set -euo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
readonly SCRIPT_PATH
REPO_DIR="$(cd "$(dirname "$SCRIPT_PATH")/.." && pwd)"
readonly REPO_DIR

missing_commands=()
for command_name in atuin delta mise pre-commit watchexec; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        missing_commands+=("$command_name")
    fi
done

if ((${#missing_commands[@]} > 0)); then
    printf 'Missing developer commands: %s\n' "${missing_commands[*]}" >&2
    printf 'Run: install-dotfiles-packages dev\n' >&2
    exit 1
fi

git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global merge.conflictStyle zdiff3
git config --global rerere.enabled true
git config --global fetch.prune true

(cd "$REPO_DIR" && pre-commit install)

printf 'Configured Git Delta, zdiff3 conflicts, rerere and fetch pruning.\n'
printf "Installed this repository's pre-commit quality gate.\n"
printf 'Atuin is local-only. To import existing history, run: atuin import auto\n'
printf 'Use mise tasks in a project with: mise tasks\n'

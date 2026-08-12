#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
chromium_src="${CHROMIUM_SRC:-}"
mode="${1:-apply}"

if [[ -z "$chromium_src" || ! -d "$chromium_src/.git" ]]; then
  echo "ERROR: set CHROMIUM_SRC to a Chromium src git checkout" >&2
  exit 2
fi

shopt -s nullglob
patches=("$repo_root"/patches/*.patch)

if (( ${#patches[@]} == 0 )); then
  echo "No patch files found in $repo_root/patches"
  exit 0
fi

case "$mode" in
  --check|check)
    for patch in "${patches[@]}"; do
      echo "Checking $(basename "$patch")"
      git -C "$chromium_src" apply --check "$patch"
    done
    ;;
  apply)
    for patch in "${patches[@]}"; do
      echo "Applying $(basename "$patch")"
      git -C "$chromium_src" apply "$patch"
    done
    ;;
  *)
    echo "Usage: $0 [apply|--check]" >&2
    exit 2
    ;;
esac


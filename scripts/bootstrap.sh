#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
chromium_src="${CHROMIUM_SRC:-}"

if [[ -z "$chromium_src" ]]; then
  cat >&2 <<'EOF'
CHROMIUM_SRC is not set.

Set it to an existing Chromium src checkout, for example:
  CHROMIUM_SRC=/work/chromium/src ./scripts/bootstrap.sh
EOF
  exit 2
fi

if [[ ! -d "$chromium_src" || ! -d "$chromium_src/.git" ]]; then
  echo "ERROR: CHROMIUM_SRC is not a git checkout: $chromium_src" >&2
  exit 2
fi

if [[ ! -f "$chromium_src/build/android/envsetup.sh" ]]; then
  echo "ERROR: CHROMIUM_SRC does not look like Chromium src: $chromium_src" >&2
  exit 2
fi

echo "URSUS browser project: $repo_root"
echo "Chromium source:     $chromium_src"
echo
echo "Chromium revision:"
git -C "$chromium_src" rev-parse HEAD
echo
echo "Chromium status:"
git -C "$chromium_src" status --short
echo
echo "Tool availability:"
for tool in gn autoninja git openssl; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf '  %-10s %s\n' "$tool" "$(command -v "$tool")"
  else
    printf '  %-10s missing\n' "$tool"
  fi
done

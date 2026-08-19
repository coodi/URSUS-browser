#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
chromium_src="${CHROMIUM_SRC:-}"
out_dir="${OUT_DIR:-out/URSUS_Browser_Android_arm64}"
target="${TARGET:-chrome_public_apk}"
device_test="${DEVICE_TEST:-0}"
local_jobs="${LOCAL_JOBS:-4}"

if [[ -z "$chromium_src" || ! -d "$chromium_src/.git" ]]; then
  echo "ERROR: set CHROMIUM_SRC to a Chromium src git checkout" >&2
  exit 2
fi

if [[ ! -f "$chromium_src/build/android/envsetup.sh" ]]; then
  echo "ERROR: CHROMIUM_SRC does not look like Chromium src: $chromium_src" >&2
  exit 2
fi

if ! command -v gn >/dev/null 2>&1; then
  echo "ERROR: gn was not found. Add depot_tools to PATH." >&2
  exit 2
fi

if ! command -v autoninja >/dev/null 2>&1; then
  echo "ERROR: autoninja was not found. Add depot_tools to PATH." >&2
  exit 2
fi

mkdir -p "$chromium_src/$out_dir"
cp "$repo_root/config/android-arm64-args.gn" "$chromium_src/$out_dir/args.gn"

cd "$chromium_src"
gn gen "$out_dir"
autoninja -local_jobs="$local_jobs" -C "$out_dir" "$target"

echo
echo "APK candidates:"
find "$out_dir" -type f -name '*.apk' -print

if [[ "$device_test" == "1" ]]; then
  apk_path="$(find "$out_dir" -type f -name '*.apk' | head -n 1)"
  if [[ -z "$apk_path" ]]; then
    echo "ERROR: build finished but no APK was found under $out_dir" >&2
    exit 1
  fi
  "$repo_root/scripts/install_on_device.sh" "$chromium_src/$apk_path"
fi

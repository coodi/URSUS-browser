#!/usr/bin/env bash
set -euo pipefail

apk="${1:-}"
package="${ANDROID_PACKAGE:-com.ursus.browser}"
activity="${ANDROID_ACTIVITY:-}"

if [[ -z "$apk" ]]; then
  echo "Usage: $0 /path/to/app.apk" >&2
  exit 2
fi

if [[ ! -f "$apk" ]]; then
  echo "ERROR: APK not found: $apk" >&2
  exit 2
fi

if ! command -v adb >/dev/null 2>&1; then
  echo "ERROR: adb was not found. Install Android platform-tools or add them to PATH." >&2
  exit 2
fi

mapfile -t devices < <(adb devices | awk 'NR > 1 && $2 == "device" {print $1}')
if (( ${#devices[@]} == 0 )); then
  echo "ERROR: no authorized debug device found. Check USB debugging and adb authorization." >&2
  adb devices >&2
  exit 2
fi

if (( ${#devices[@]} > 1 )) && [[ -z "${ANDROID_SERIAL:-}" ]]; then
  echo "ERROR: more than one debug device connected. Set ANDROID_SERIAL." >&2
  adb devices >&2
  exit 2
fi

serial="${ANDROID_SERIAL:-${devices[0]}}"

echo "Installing on device $serial:"
adb -s "$serial" install -r "$apk"

if [[ -n "$activity" ]]; then
  echo "Launching $package/$activity"
  adb -s "$serial" shell am start -n "$package/$activity"
else
  echo "Launching package $package"
  adb -s "$serial" shell monkey -p "$package" -c android.intent.category.LAUNCHER 1
fi

echo "Device test launch completed."

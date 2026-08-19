# AI Agent Build Instructions

This file is for automated coding agents working on URSUS browser. It is not a
human setup guide.

## Scope

- Repository root: this repository.
- Chromium source checkout: always use `CHROMIUM_SRC`; never hardcode local
  absolute paths.
- Chromium output directory: prefer `OUT_DIR=out/URSUS_Browser_Android_arm64`.
- Android target: prefer `TARGET=chrome_public_apk`.
- Android package id: `com.ursus.browser`.

## Rules

- Keep Chromium source changes reviewable as patches under `patches/`.
- Do not vendor Chromium into this repository.
- Do not commit machine-specific paths, usernames, device serials, temporary
  paths, or private tokens.
- Do not use `--ignore-certificate-errors` or any global TLS bypass.
- Keep the Russian trusted root scoped to the application.
- Limit local build parallelism. Use `LOCAL_JOBS=8` unless the user explicitly
  requests another value.
- Do not run destructive git commands such as `git reset --hard` unless the user
  explicitly asks for that operation.

## Standard Flow

Start from this repository root:

```bash
export CHROMIUM_SRC=/path/to/chromium/src
export OUT_DIR=out/URSUS_Browser_Android_arm64
export TARGET=chrome_public_apk
export LOCAL_JOBS=8
```

Validate the Chromium checkout:

```bash
test -d "$CHROMIUM_SRC/.git"
test -f "$CHROMIUM_SRC/build/android/envsetup.sh"
```

Check patch applicability before mutating Chromium:

```bash
CHROMIUM_SRC="$CHROMIUM_SRC" ./scripts/apply_patches.sh --check
```

Apply patches:

```bash
CHROMIUM_SRC="$CHROMIUM_SRC" ./scripts/apply_patches.sh
```

Build:

```bash
CHROMIUM_SRC="$CHROMIUM_SRC" OUT_DIR="$OUT_DIR" TARGET="$TARGET" LOCAL_JOBS="$LOCAL_JOBS" ./scripts/build.sh
```

For faster compile validation before a full APK, run inside Chromium:

```bash
autoninja -local_jobs="$LOCAL_JOBS" -C "$OUT_DIR" chrome/android:chrome_java
```

Then build the APK:

```bash
autoninja -local_jobs="$LOCAL_JOBS" -C "$OUT_DIR" chrome_public_apk
```

## Device Install

Use a connected USB-debug Android device only when the user says a device is
available.

List devices:

```bash
adb devices
```

Install the built APK:

```bash
./scripts/install_on_device.sh "$CHROMIUM_SRC/$OUT_DIR/apks/ChromePublic.apk"
```

If Android returns `INSTALL_FAILED_USER_RESTRICTED`, do not loop forever. Report
that the device rejected ADB installation and ask the user to enable or confirm
Install via USB / USB debugging security settings on the device.

## Required Verification

Before finalizing changes, run:

```bash
bash -n scripts/*.sh
CHROMIUM_SRC="$CHROMIUM_SRC" ./scripts/apply_patches.sh --check
```

If Chromium was modified locally, also run at least:

```bash
autoninja -local_jobs="$LOCAL_JOBS" -C "$OUT_DIR" chrome/android:chrome_java
```

For APK-producing changes, run:

```bash
autoninja -local_jobs="$LOCAL_JOBS" -C "$OUT_DIR" chrome_public_apk
```

Run a privacy scan before committing:

```bash
rg -n "/home/|/tmp/|[[:alnum:]_-]{6,}:?device|ANDROID_SERIAL|TOKEN|SECRET|PASSWORD" \
  README.md AGENTS.md certs config docs patches scripts src tests || true
```

Review matches manually. Generic Android paths such as `/data/local/tmp` are
allowed when they are part of documented device workflows.

## Patch Refresh

When Chromium changes are ready, refresh the relevant patch from the Chromium
checkout. Keep generated patches free of local absolute paths.

```bash
git -C "$CHROMIUM_SRC" diff --binary > patches/example.patch
```

Replace `patches/example.patch` with the real patch file name. Update
`patches/README.md` when adding or changing a patch.

## Commit Hygiene

- Keep author and committer identity generic when requested by the project.
- Commit only files related to the user request.
- After commit, run `git status --short` and report whether the repository is
  clean.

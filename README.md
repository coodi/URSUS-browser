# URSUS Browser

Open-source Chromium-based Android browser with application-scoped support for Russian Trusted Root CA.

The Android application label is `URSUS browser`; Android launcher icons are
replaced with the URSUS browser artwork. Visible Android branding strings are
renamed to `URSUS browser`; the About page discloses that the browser is built
on Chromium technology. The default Android UI theme is dark and uses
logo-inspired URSUS green, blue, and orange as the primary accent palette. When
the verified certificate chain uses the bundled Russian trusted root, the
Android address bar shows a Ministry of Digital Development shield indicator.

URSUS browser is intended to be built from an upstream Chromium source checkout
as a standalone Android application. The browser must keep Chromium and
Android's normal TLS validation enabled, while adding one extra trust anchor
only inside this application.

## Security Properties

- The Russian Trusted Root CA is scoped to URSUS browser only.
- The app does not install any CA into Android system or user trust stores.
- TLS verification is not disabled.
- `--ignore-certificate-errors` is not used.
- Certificate errors are not automatically accepted.
- Hostname, expiration, signature, chain, key usage, SAN, and other Chromium checks must continue to run.
- Users must be able to disable the extra root with `russian_ca.enabled`.
- The Russian-root indicator is based on the verified certificate chain, not on
  a host allowlist.

## Current Checkout Status

This repository contains the GitHub-facing project scaffold, local validation
tooling, certificate material, and reviewable Chromium patch files. Chromium is
not vendored here; patches are generated against a separate upstream Chromium
source checkout.

Once a Chromium checkout is available, run:

```bash
CHROMIUM_SRC=/path/to/chromium/src ./scripts/bootstrap.sh
CHROMIUM_SRC=/path/to/chromium/src ./scripts/research_chromium.sh
CHROMIUM_SRC=/path/to/chromium/src ./scripts/apply_patches.sh --check
CHROMIUM_SRC=/path/to/chromium/src ./scripts/build.sh
```

## Certificate Source

Do not fetch the certificate from random mirrors. Obtain `Russian Trusted Root CA` from the official Ministry of Digital Development / Gosuslugi source, such as the official Gosuslugi certificate page:

https://www.gosuslugi.ru/crt

The checked-in Chromium patch embeds the DER copy from `certs/`, so the APK does
not require pushing a certificate into the Android profile. To refresh the
checked-in certificate files from an official source, run:

```bash
./scripts/import_certificate.sh /path/to/official/RussianTrustedRootCA.cer
```

The script verifies that OpenSSL can parse the certificate, prints its subject,
issuer, serial, validity, and SHA-256 fingerprint, converts it to DER, writes
`certs/russian_trusted_root_ca.der` and `certs/RussianTrustedRootCA.cer`, and
records the fingerprint in `certs/SHA256SUMS`.

## Threat Model

1. Compromise of Russian Trusted Root CA.

Mitigation: the additional root is scoped to this application and can be
disabled with `russian_ca.enabled`.

2. Certificate issuance for an unrelated domain.

Example: a certificate chaining to Russian Trusted Root CA is trusted only
inside this application. Other apps and Android system trust are unchanged.

3. CA replacement inside the APK.

Mitigation: open-source source code, pinned SHA-256 fingerprint, reviewable import script, and traceable builds where practical.

4. System-wide trust.

Mitigation: no Android system or user trust store installation is performed.

5. TLS bypass.

Mitigation: Chromium certificate verification remains active. The project must not use global certificate-error bypasses.

## Build

Install Chromium Android build prerequisites and depot_tools, then check out Chromium separately. This repository intentionally does not vendor Chromium.

Example:

```bash
export CHROMIUM_SRC=/work/chromium/src
./scripts/bootstrap.sh
./scripts/import_certificate.sh /path/to/official/RussianTrustedRootCA.cer
./scripts/apply_patches.sh
./scripts/build.sh
```

`scripts/build.sh` generates `out/URSUS_Browser_Android_arm64` with args based
on `config/android-arm64-args.gn`, runs `autoninja`, and prints APK candidates.

To install and launch the built APK on a connected USB-debug Android phone:

```bash
DEVICE_TEST=1 ./scripts/build.sh
```

You can also install an existing APK directly:

```bash
./scripts/install_on_device.sh /path/to/URSUSBrowser.apk
```

## Tests

Chromium-side unit tests should cover:

- normal public CA behavior;
- Russian-root chains accepted when `russian_ca.enabled` is true;
- Russian-root support disabled;
- expired Russian-root chain rejected;
- hostname mismatch rejected.

## Repository Layout

```text
URSUS-browser/
  README.md
  LICENSE
  certs/
  config/
  docs/
  patches/
  scripts/
  src/
  tests/
  .github/workflows/
```

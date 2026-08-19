#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
input=""
device_serial="${ADB_SERIAL:-}"
package_name="${PACKAGE_NAME:-com.ursus.browser}"
install_to_device=0
cert_dir="$repo_root/certs"
out_pem="$cert_dir/rootca_ssl_rsa2022.cer"
out_der="$cert_dir/russian_trusted_root_ca.der"
out_legacy_der="$cert_dir/RussianTrustedRootCA.cer"
tmp_pem="$(mktemp)"
trap 'rm -f "$tmp_pem"' EXIT

while [[ $# -gt 0 ]]; do
  case "$1" in
    --device)
      install_to_device=1
      device_serial="${2:-}"
      shift 2
      ;;
    --package)
      package_name="${2:-}"
      shift 2
      ;;
    --help|-h)
      cat <<EOF
Usage: $0 [--device SERIAL] [--package PACKAGE] /path/to/official/RussianTrustedRootCA.cer

The certificate file must come from an official source. The script normalizes it
to DER, records metadata and SHA-256, and optionally installs it into the
the Android profile as russian_trusted_root_ca.der.
EOF
      exit 0
      ;;
    *)
      if [[ -n "$input" ]]; then
        echo "ERROR: unexpected argument: $1" >&2
        exit 2
      fi
      input="$1"
      shift
      ;;
  esac
done

if [[ -z "$input" ]]; then
  echo "Usage: $0 [--device SERIAL] [--package PACKAGE] /path/to/official/RussianTrustedRootCA.cer" >&2
  exit 2
fi

if [[ ! -f "$input" ]]; then
  echo "ERROR: certificate file not found: $input" >&2
  exit 2
fi

mkdir -p "$cert_dir"

if openssl x509 -in "$input" -noout >/dev/null 2>&1; then
  openssl x509 -in "$input" -out "$tmp_pem"
elif openssl x509 -inform DER -in "$input" -noout >/dev/null 2>&1; then
  openssl x509 -inform DER -in "$input" -out "$tmp_pem"
else
  echo "ERROR: OpenSSL could not parse certificate as PEM or DER" >&2
  exit 1
fi

subject="$(openssl x509 -in "$tmp_pem" -noout -subject -nameopt RFC2253 | sed 's/^subject=//')"
issuer="$(openssl x509 -in "$tmp_pem" -noout -issuer -nameopt RFC2253 | sed 's/^issuer=//')"
serial="$(openssl x509 -in "$tmp_pem" -noout -serial | sed 's/^serial=//')"
not_before="$(openssl x509 -in "$tmp_pem" -noout -startdate | sed 's/^notBefore=//')"
not_after="$(openssl x509 -in "$tmp_pem" -noout -enddate | sed 's/^notAfter=//')"
fingerprint="$(openssl x509 -in "$tmp_pem" -noout -fingerprint -sha256 | cut -d= -f2 | tr -d ':')"

openssl x509 -in "$tmp_pem" -out "$out_pem"
openssl x509 -in "$tmp_pem" -outform DER -out "$out_der"
cp "$out_der" "$out_legacy_der"

if [[ "$install_to_device" -eq 1 ]]; then
  if [[ -z "$device_serial" ]]; then
    echo "ERROR: --device requires an adb serial" >&2
    exit 2
  fi

  tmp_device="/data/local/tmp/ursus_russian_trusted_root_ca.der"
  adb -s "$device_serial" push "$out_der" "$tmp_device" >/dev/null
  adb -s "$device_serial" shell run-as "$package_name" mkdir -p app_chrome/Default
  adb -s "$device_serial" shell run-as "$package_name" cp "$tmp_device" \
    app_chrome/Default/russian_trusted_root_ca.der
  adb -s "$device_serial" shell run-as "$package_name" chmod 600 \
    app_chrome/Default/russian_trusted_root_ca.der
  adb -s "$device_serial" shell rm -f "$tmp_device"
fi

cat > "$cert_dir/SHA256SUMS" <<EOF
$(sha256sum "$out_pem" | awk '{print $1}')  rootca_ssl_rsa2022.cer
$(sha256sum "$out_der" | awk '{print $1}')  russian_trusted_root_ca.der
$(sha256sum "$out_legacy_der" | awk '{print $1}')  RussianTrustedRootCA.cer
EOF

cat > "$cert_dir/RussianTrustedRootCA.metadata" <<EOF
Subject: $subject
Issuer: $issuer
Serial: $serial
Valid from: $not_before
Valid to: $not_after
SHA-256: $fingerprint
Source file: $input
PEM output: $out_pem
DER output: $out_der
EOF

cat <<EOF
Imported Russian Trusted Root CA
Subject: $subject
Issuer: $issuer
Serial: $serial
Valid from: $not_before
Valid to: $not_after
SHA-256: $fingerprint
PEM output: $out_pem
DER output: $out_der
EOF

if [[ "$install_to_device" -eq 1 ]]; then
  echo "Device install: $device_serial $package_name app_chrome/Default/russian_trusted_root_ca.der"
fi

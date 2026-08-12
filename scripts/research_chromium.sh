#!/usr/bin/env bash
set -euo pipefail

chromium_src="${CHROMIUM_SRC:-}"

if [[ -z "$chromium_src" || ! -d "$chromium_src/.git" ]]; then
  echo "ERROR: set CHROMIUM_SRC to a Chromium src git checkout" >&2
  exit 2
fi

cd "$chromium_src"

run_rg() {
  local pattern="$1"
  shift
  rg -n "$pattern" "$@" | head -200 || true
}

echo "== Chromium revision =="
git rev-parse HEAD
echo

echo "== Chromium status =="
git status --short
echo

echo "== CertVerifier =="
run_rg "class CertVerifier|CertVerifier::|Create.*CertVerifier" net chrome services components
echo

echo "== Chrome Root Store =="
run_rg "Chrome Root Store|ChromeRootStore|TrustStoreChrome" net chrome services components
echo

echo "== TrustStore =="
run_rg "class TrustStore|TrustStore[A-Za-z_]*::|TrustStore" net chrome services components
echo

echo "== CertVerifyProc =="
run_rg "class CertVerifyProc|CertVerifyProc[A-Za-z_]*::|Create.*CertVerifyProc" net chrome services components
echo

echo "== Android certificate verification =="
run_rg "CertVerifyProcAndroid|SystemTrustStore|android.*cert|cert.*android" net chrome services components
echo

echo "== Network service certificate verification =="
run_rg "NetworkContext|CertVerifier|SSLConfig|certificate" services/network net chrome
echo

if [[ -d out/URSUS_Browser_Android_arm64 ]]; then
  echo "== APK-like GN targets =="
  gn ls out/URSUS_Browser_Android_arm64 '//*apk*' 2>/dev/null | head -200 || true
fi

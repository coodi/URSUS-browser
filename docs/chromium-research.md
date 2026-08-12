# Chromium Research Notes

Status: blocked because the wrapper repository was empty and not a Chromium checkout.

The requested first-stage research must be run against the actual Chromium source tree before writing Chromium patches:

```bash
cd "$CHROMIUM_SRC"
git rev-parse HEAD
git status --short
rg "class CertVerifier|CertVerifier::|Create.*CertVerifier" net chrome services components
rg "Chrome Root Store|ChromeRootStore|TrustStoreChrome" net chrome services components
rg "TrustStore" net chrome services components
rg "CertVerifyProc" net chrome services components
rg "NetworkContext" services/network net chrome
rg "android.*cert|CertVerifyProcAndroid|SystemTrustStore" net chrome services components
gn ls out/Default '//*apk*' --type=executable
```

Expected research output:

1. Chromium revision.
2. Android browser APK target.
3. `CertVerifier` implementation location.
4. verifier used by Chrome Android.
5. Chrome Root Store location.
6. trust store construction location.
7. minimal injection point for an application-specific trust anchor.
8. reliable way to detect the trust anchor used by the verified chain.
9. best place to enforce the Russian CA hostname restriction.

Design preference:

- add the extra trust anchor at browser/profile/network-context scope;
- preserve standard Chromium verification;
- keep the additional root scoped to this application;
- do not affect standard public-root chains.

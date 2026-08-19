# Chromium Patches

This directory contains patches generated only after checking the target
Chromium APIs in the local checkout.

Current patch series:

```text
android_app_name.patch
android_app_icons.patch
android_branding_resources.patch
russian_ca_chromium.patch
russian_ca_indicator_android.patch
russian_ca_management_android.patch
manual_ad_blocker_android.patch
```

`android_app_name.patch` changes the Android Chromium application label and
widget labels to `URSUS browser`.

`android_app_icons.patch` replaces the Android Chromium launcher icon assets
with the URSUS browser icons from `ursus_android_icons.zip`.

`android_branding_resources.patch` replaces visible Android `Chrome` branding
strings with `URSUS browser` in the English source and Russian translations,
including BrowserUI, components, and generated Russian resource bundles. It
adds the required About-page disclosure `Built on Chromium technology.`,
replaces reusable Chrome logo resources, the first-run/sign-in product logo,
the sign-in sync logo, the tab-switcher/internal-page favicon, and the
first-run promo illustration with URSUS browser artwork. It hides the
fullscreen sign-in Lottie overlay that otherwise draws the Chromium glyph over
the product logo, sets the default Android UI theme to dark, applies the URSUS
green/blue/orange accent palette, and disables Android dynamic color overlaying
so those logo colors remain the defaults. Internal Chromium package names,
source comments, copyright notices, and resource file names are intentionally
left unchanged.

`russian_ca_chromium.patch` adds the profile pref `russian_ca.enabled`
and wires the bundled Russian trusted root into Chromium's
`AdditionalCertificates` trust-anchor path without changing Android system or
user trust stores.

The patch embeds the DER certificate as
`chrome/browser/net/russian_trusted_root_ca_der.inc`, so the APK works without
writing a certificate into the Android profile. A profile-local
`russian_trusted_root_ca.der` is still accepted for local testing and migration.

`russian_ca_indicator_android.patch` adds an Android omnibox security indicator
for pages whose visible verified certificate chain contains the bundled Russian
trusted root. It shows a small shield with the Ministry of Digital Development
logo and displays the message `Сайт использует корневой сертификат Минцифры`
when tapped. The indicator is certificate-chain based and does not use a host
allowlist.

`russian_ca_management_android.patch` adds the Android management UI for the
scoped Russian root certificate. The omnibox shield popup has a management
button. When the root is disabled and the failed certificate chain contains the
bundled Russian root, the SSL interstitial is changed to a Ministry-branded
error page with a shield watermark and a primary `Управление сертификатом`
button that opens the management page.

`manual_ad_blocker_android.patch` adds a Safari-style manual cosmetic blocker
to the Android page menu. The `Заблокировать элемент` action starts an in-page
picker, stores the generated CSS selector per origin, and reapplies stored
selectors on future page loads. This hides page elements only; it does not
block requests or change certificate validation.

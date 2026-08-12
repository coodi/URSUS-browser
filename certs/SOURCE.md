# Russian Trusted Root CA Source

The Russian Trusted Root CA certificate is obtained from an official Gosuslugi
asset host.

Official entry points:

- https://www.gosuslugi.ru/crt
- https://www.gosuslugi.ru/tls

Official download used:

- https://gu-st.ru/content/lending/RootCa_SSL_RSA.zip

Archive contents:

- `rootca_ssl_rsa2022.cer`

Certificate metadata:

```text
Subject: C = RU, O = The Ministry of Digital Development and Communications, CN = Russian Trusted Root CA
Issuer: C = RU, O = The Ministry of Digital Development and Communications, CN = Russian Trusted Root CA
Serial: 1000
Valid from: Mar  1 21:04:15 2022 GMT
Valid to: Feb 27 21:04:15 2032 GMT
SHA-256 fingerprint: D26D2D0231B7C39F92CC738512BA54103519E4405D68B5BD703E9788CA8ECF31
```

Files in this repository:

- `rootca_ssl_rsa2022.cer`: original PEM certificate from the official archive
- `russian_trusted_root_ca.der`: DER-encoded copy embedded into the Chromium patch and used by import tooling
- `RussianTrustedRootCA.cer`: legacy DER filename used by older scripts

Do not replace these files with certificates from unofficial mirrors.

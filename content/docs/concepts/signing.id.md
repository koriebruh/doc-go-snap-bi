---
weight: 3
title: "Signing"
description: "Signing request HMAC dan RSA, formula string-to-sign, dan parsing key"
---

Standar SNAP mendefinisikan dua mode signing, disepakati per partner saat
registrasi: **symmetric** (HMAC-SHA512) dan **asymmetric** (SHA256withRSA).
Package ini mengimplementasikan keduanya sebagai fungsi biasa —
`HeaderBuilder.Build()` dan `TokenManager` memanggilnya, tapi Anda juga
bisa memakainya langsung untuk testing atau untuk membuat verifier
berbasis `KeyStore`.

## Symmetric (HMAC-SHA512)

```go
func SignSymmetric(clientSecret, stringToSign string) string
func VerifySymmetric(clientSecret, stringToSign, signature string) bool
```

`SignSymmetric` menghitung signature HMAC-SHA512 dari `stringToSign`
menggunakan `clientSecret` sebagai key, mengembalikan hex huruf kecil.
`VerifySymmetric` memeriksa signature dengan cara yang sama, memakai
perbandingan constant-time.

## Asymmetric (SHA256withRSA)

```go
func SignAsymmetric(signer crypto.Signer, stringToSign string) (string, error)
func VerifyAsymmetric(pub crypto.PublicKey, stringToSign, signature string) error
```

`SignAsymmetric` menandatangani dengan SHA256withRSA (PKCS#1 v1.5),
mengembalikan hex huruf kecil. Fungsi ini menerima `crypto.Signer`, bukan
`*rsa.PrivateKey` konkret, supaya key berbasis HSM/KMS bisa dipasang tanpa
mengubah API. `VerifyAsymmetric` mengembalikan error non-nil bila `pub`
bukan key RSA, `signature` bukan hex yang valid, atau signature-nya tidak
cocok.

Kedua fungsi menolak key RSA lebih kecil dari **2048 bit** (batas minimum
standar) karena key yang lebih lemah bisa dipalsukan dalam praktik — ini
paling berpengaruh di sisi verifikasi, di mana public key berasal dari
sertifikat yang didaftarkan partner dan tidak Anda kendalikan.

```go
func ParseRSAPrivateKeyPEM(pemBytes []byte) (crypto.Signer, error)
```

Mem-parsing private key RSA berformat PEM PKCS#1 atau PKCS#8. Lewati bila
Anda sudah punya `crypto.Signer` dari sumber lain (misalnya klien HSM/KMS).

## Formula string-to-sign

```go
func BuildStringToSignAccessToken(clientID, timestamp string) string
func BuildStringToSignTransaction(method, endpointURL, accessToken string, body []byte, timestamp string, symmetric bool) string
```

Request access-token selalu memakai:

```
clientID + "|" + timestamp
```

Request transaksi memakai salah satu dari dua formula berikut, tergantung
`symmetric`:

```
symmetric:  HTTPMethod:EndpointUrl:AccessToken:HexSHA256(body):TimeStamp
asymmetric: HTTPMethod:EndpointUrl:HexSHA256(body):TimeStamp
```

`body` harus berupa **byte yang persis sama dengan yang dikirim di wire**
— `BuildStringToSignTransaction` tidak melakukan marshal JSON sendiri.
Body kosong menghasilkan digest SHA256 dari byte slice kosong, bukan
string kosong.

{{< callout type="warning" >}}
Request access-token selalu ditandatangani secara asymmetric — baik B2B
maupun B2B2C — terlepas dari mode signing yang disepakati untuk request
transaksi. Jangan pakai `ClientSecret`/`SignSymmetric` untuk pemanggilan
token meskipun integrasi Anda symmetric; `TokenManager` sudah menangani
ini dengan benar untuk Anda.
{{< /callout >}}

## Sentinel error

Sentinel error adalah nilai error tetap yang di-export (seperti
`snap.ErrWeakRSAKey`), dimaksudkan untuk dicek dengan `errors.Is`, bukan
dengan membandingkan teks error — fungsi-fungsi di atas mengembalikan ini
supaya Anda bisa bercabang berdasarkan alasan kegagalannya:

| Sentinel | Dikembalikan oleh | Arti |
|---|---|---|
| `ErrNoPEMBlock` | `ParseRSAPrivateKeyPEM` | input tidak punya PEM block |
| `ErrNotRSAKey` | `ParseRSAPrivateKeyPEM` | PEM block bukan key RSA |
| `ErrNotRSASigner` | `SignAsymmetric`, `VerifyAsymmetric` | key bukan RSA |
| `ErrWeakRSAKey` | `SignAsymmetric`, `VerifyAsymmetric` | key lebih kecil dari 2048 bit |

Semuanya dibungkus dengan `%w`, jadi cocokkan dengan `errors.Is`.

## Selanjutnya

{{< cards >}}
  {{< card title="Authentication" icon="key" link="../authentication/" subtitle="Memakai primitif-primitif ini untuk mengambil dan meng-cache access token B2B/B2B2C." >}}
  {{< card title="Verifying inbound requests" icon="shield-check" link="../webhooks/" subtitle="Rekan sisi server: `ServerVerifier` dan `KeyStore`." >}}
{{< /cards >}}

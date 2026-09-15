---
weight: 2
title: "Quickstart"
description: "Install go-snap-bi dan buat signed request pertama Anda"
---

## Instalasi

```bash
go get github.com/koriebruh/go-snap-bi
```

Membutuhkan Go 1.21 atau lebih baru.

{{% steps %}}

### Dapatkan access token

Setiap panggilan butuh bearer token terlebih dahulu. `TokenManager`
mengambil dan meng-cache-nya untuk Anda — pemanggil yang bersamaan
saat refresh berbagi satu request yang sedang berjalan, bukan
masing-masing mengirim requestnya sendiri.

```go
tm := &snap.TokenManager{
	BaseURL:   "https://partner.example.com",
	ClientKey: clientKey,
	Signer:    rsaPrivateKey, // crypto.Signer, misalnya dari snap.ParseRSAPrivateKeyPEM
}

accessToken, err := tm.AccessTokenB2B(ctx)
if err != nil {
	// tangani error
}
```

Lihat [Authentication](/id/docs/concepts/authentication/) untuk detail
B2B2C dan caching token.

### Bangun header yang sudah ditandatangani

`HeaderBuilder` menyusun kumpulan header wajib SNAP — `X-SIGNATURE`,
`X-TIMESTAMP`, `X-PARTNER-ID`, dan sisanya — sekaligus menandatangani
request untuk Anda. Pilih tepat salah satu dari `ClientSecret`
(symmetric/HMAC) atau `Signer` (asymmetric/RSA), sesuai kesepakatan
dengan partner Anda saat registrasi.

```go
hb := snap.HeaderBuilder{
	Method:       http.MethodPost,
	EndpointURL:  "https://partner.example.com/v1.0/balance-inquiry",
	AccessToken:  accessToken,
	ClientKey:    clientKey,
	PartnerID:    partnerID,
	ExternalID:   externalID,
	ChannelID:    channelID,
	Symmetric:    true,
	ClientSecret: clientSecret,
}
```

Lihat [Headers & Signing](/id/docs/concepts/headers/) untuk setiap field
dan apa yang terjadi bila salah satunya tidak diisi.

### Panggil sebuah endpoint

Setiap package domain memakai bentuk pemanggilan yang sama:
`func Endpoint(ctx, *snap.Transport, snap.HeaderBuilder, Request) (Response, error)`.

```go
transport := &snap.Transport{}

resp, err := balanceinfo.BalanceInquiry(ctx, transport, hb, balanceinfo.BalanceInquiryRequest{
	PartnerReferenceNo: "2020102900000000000001",
	AccountNo:          "1234567890",
})
if err != nil {
	// errors.Is(err, snap.ErrBadRequest), snap.ErrUnauthorized, dst. —
	// satu sentinel per kelas HTTP-status kode respons SNAP. Lihat
	// /id/concepts/errors.
}
```

Anda tidak perlu mengisi `hb.Body` sendiri — fungsi pemanggil
melakukan marshal terhadap request bertipe itu dan mengaturnya
sendiri, jadi byte yang sama persis dipakai untuk signing maupun
request di wire.

### Tangani notifikasi masuk

Beberapa alur (bulk cash-in, pembayaran QR/MPM, direct debit,
BI-FAST, RTGS, SKNBI) mengirimkan hasilnya sebagai panggilan HTTP
masuk ke layanan **Anda**, bukan sebagai response yang sinkron.
Verifikasi setiap request masuk dengan `snap.ServerVerifier` sebelum
memercayai isinya — lihat
[Verifying inbound requests](/id/docs/concepts/webhooks/). Lewati langkah
ini bila Anda hanya memanggil endpoint read/inquiry.
{{% /steps %}}

## Langkah berikutnya

{{< cards >}}
  {{< card title="Konvensi inti" icon="book" link="../concepts/conventions/" subtitle="Presence field, `json.RawMessage`, dan aturan error status-HTTP-menang." >}}
  {{< card title="API Reference" icon="square-terminal" link="../reference/registration/" subtitle="Jelajahi seluruh 79 binding endpoint berdasarkan kategori." >}}
{{< /cards >}}

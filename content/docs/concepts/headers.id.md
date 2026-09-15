---
weight: 2
title: "Headers & Signing"
description: "HeaderBuilder, Profile, dan bagaimana sebuah request mendapat kumpulan header SNAP-nya"
---

`HeaderBuilder` menyusun kumpulan header wajib SNAP untuk sebuah request
transaksi sekaligus menandatanganinya — ini satu-satunya tipe yang
dibutuhkan setiap fungsi pemanggil.

## `HeaderBuilder`

```go
type HeaderBuilder struct {
	Method      string // metode HTTP, mis. "POST"
	EndpointURL string // URL endpoint lengkap yang dipakai dalam string yang ditandatangani
	Body        []byte // byte body request yang sebenarnya

	B2B2C                 bool   // apakah ini request B2B2C
	AccessToken           string // bearer token Authorization
	AuthorizationCustomer string // bearer token Authorization-Customer; wajib bila B2B2C true
	DeviceID              string // X-DEVICE-ID; wajib bila B2B2C true

	ClientKey  string
	PartnerID  string
	ExternalID string
	ChannelID  string

	Origin    string // opsional; header dihilangkan bila kosong
	IPAddress string
	Latitude  string
	Longitude string

	Profile Profile

	Symmetric    bool
	ClientSecret string        // dipakai bila Symmetric true
	Signer       crypto.Signer // dipakai bila Symmetric false
}
```

`Symmetric` memilih fungsi signing mana yang dipakai, sesuai parameter
`BuildStringToSignTransaction` sendiri — isi tepat salah satu dari
`ClientSecret` (HMAC) atau `Signer` (RSA), sesuai kesepakatan integrasi
Anda dengan partner saat registrasi.

Fungsi pemanggil di setiap package domain mengatur `Body` sendiri, dari
byte hasil marshal request bertipe — Anda tidak perlu mengaturnya sendiri
untuk pemanggilan normal.

### `Build()`

```go
func (b HeaderBuilder) Build() (http.Header, error)
```

Menyusun `http.Header` untuk request, menandatanganinya lewat
`BuildStringToSignTransaction` dan `SignSymmetric`/`SignAsymmetric` sesuai
flag `Symmetric`. Anda biasanya tidak pernah memanggil ini langsung —
`snap.Transport.Do` yang memanggilnya untuk Anda.

## `Profile` — hook kustomisasi per-PJP

Standar ini menyerahkan dua hal ke masing-masing PJP (Penyedia Jasa
Pembayaran): format timestamp dan cara URL path dibangun. `Profile` adalah
interface yang dipakai `HeaderBuilder` dan `TokenManager` untuk keduanya:

```go
type Profile interface {
	TimestampLayout() string
	BuildPath(serviceGroup, productType string) string
}
```

`DefaultProfile` mengimplementasikan perilaku standar apa adanya:

```go
type DefaultProfile struct {
	Domain  string
	Version string
}
```

```go
func (p DefaultProfile) TimestampLayout() string
func (p DefaultProfile) BuildPath(serviceGroup, productType string) string
```

`TimestampLayout` mengembalikan `snap.DefaultTimestampLayout` (layout time
Go yang setara dengan `yyyy-MM-ddTHH:mm:ss.SSSTZD` milik standar).
`BuildPath` mengembalikan `/{domain}/{version}/{service-group}/{product-type}`,
dengan `Version` default ke `"v1.0"` bila tidak diisi.

Penyimpangan khusus suatu bank diekspresikan sebagai struct kecil yang
meng-embed `DefaultProfile` dan meng-override satu method — bukan dengan
fork dari `HeaderBuilder`.

## Selanjutnya

{{< cards >}}
  {{< card title="Signing" icon="signature" link="../signing/" subtitle="Formula signing symmetric/asymmetric yang dipanggil `Build()`." >}}
  {{< card title="Transport" icon="server" link="../transport/" subtitle="Bagaimana header yang sudah dibangun benar-benar dikirim, dan bagaimana responsnya didekode." >}}
{{< /cards >}}

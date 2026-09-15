---
weight: 4
title: "Authentication"
description: "Mengambil dan meng-cache access token SNAP B2B/B2B2C dengan TokenManager"
---

Setiap request transaksi membawa header `Authorization: Bearer <token>`.
`TokenManager` mengambil, dan untuk B2B meng-cache, token tersebut —
request akses token selalu ditandatangani secara asymmetric terlepas dari
mode signing transaksi Anda (lihat [Signing](/id/docs/concepts/signing/)).

## `TokenManager`

```go
type TokenManager struct {
	BaseURL    string
	ClientKey  string
	Signer     crypto.Signer
	HTTPClient *http.Client
	Profile    Profile
	Now        func() time.Time // opsional; nil berarti time.Now
}
```

`HTTPClient` default ke klien internal dengan timeout wajar bila
dibiarkan nil. `Profile` default ke `DefaultProfile{}`. `Now` hanya
dipakai untuk testing.

## B2B: `client_credentials`

```go
func (m *TokenManager) AccessTokenB2B(ctx context.Context) (string, error)
```

Mengembalikan access token `client_credentials` yang di-cache, mengambil
(dan meng-cache) yang baru bila belum ada cache atau cache yang ada sudah
mencapai atau melewati waktu kedaluwarsanya.

```go
tm := &snap.TokenManager{
	BaseURL:   "https://partner.example.com",
	ClientKey: clientKey,
	Signer:    rsaPrivateKey,
}
token, err := tm.AccessTokenB2B(ctx)
```

Bila beberapa goroutine memanggil ini bersamaan saat token sudah
kedaluwarsa, hanya satu request HTTP yang dikirim — yang lain menunggu dan
berbagi hasilnya. Request itu berjalan di context-nya sendiri, jadi bila
satu pemanggil membatalkan, itu tidak merusak hasil untuk yang lain yang
sedang menunggu.

Caching memakai `expiresIn` yang dilaporkan server dikurangi sedikit
margin keamanan (mengambil ulang sedikit sebelum benar-benar kedaluwarsa),
dengan batas bawah setengah dari `expiresIn` supaya nilai yang tidak
biasa kecilnya tidak membuat margin menghabiskan seluruh jendela cache.

## B2B2C: authorization code / refresh token

```go
func (m *TokenManager) AccessTokenB2B2C(ctx context.Context, grantType GrantType, code string) (Token, error)
```

Token B2B2C **tidak di-cache** — setiap pemanggilan adalah pertukaran
baru, karena grant-nya terikat ke satu customer/code tertentu, bukan ke
integrasi secara keseluruhan.

```go
type GrantType string

const (
	GrantTypeClientCredentials GrantType = "client_credentials"
	GrantTypeAuthorizationCode GrantType = "AUTHORIZATION_CODE"
	GrantTypeRefreshToken      GrantType = "REFRESH_TOKEN"
)
```

{{< callout type="default" >}}
Penulisan huruf di atas adalah format wire standar itu sendiri, bukan
typo — `client_credentials` huruf kecil-snake, sedangkan grant B2B2C
huruf besar-snake. Nilainya dikirim persis seperti dideklarasikan.
{{< /callout >}}

```go
type Token struct {
	AccessToken  string
	TokenType    string
	ExpiresIn    time.Duration
	RefreshToken string // diisi hanya untuk B2B2C
}
```

Isi `code` dengan authorization code OAuth (untuk
`GrantTypeAuthorizationCode`, biasanya didapat dari alur yang dimulai
`registration.GetOAuthURL`) atau refresh token yang sudah diterbitkan
sebelumnya (untuk `GrantTypeRefreshToken`).

## Selanjutnya

{{< cards >}}
  {{< card title="Headers & Signing" icon="key" link="/id/docs/concepts/headers/" subtitle="Memakai token yang Anda dapat di sini untuk membangun request transaksi yang ditandatangani." >}}
  {{< card title="Registration" icon="id-card" link="/id/docs/reference/registration/" subtitle="`GetOAuthURL` dan `AccountBinding` — alur onboarding B2B2C." >}}
{{< /cards >}}

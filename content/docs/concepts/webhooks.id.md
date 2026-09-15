---
weight: 7
title: "Verifying Inbound Requests"
description: "ServerVerifier dan KeyStore — memvalidasi signature sebelum memercayai request SNAP yang masuk"
---

Untuk endpoint di mana **pemanggil package ini adalah server** —
notifikasi pembayaran dan callback (lihat bagian "Inbound only" di
masing-masing halaman referensi) — pakai `ServerVerifier` untuk
memvalidasi signature pada request masuk sebelum memercayai isinya. Ini
kebalikan dari signing sisi klien di [`HeaderBuilder`](/id/docs/concepts/headers/)
dan [`TokenManager`](/id/docs/concepts/authentication/).

## `KeyStore` — Anda yang mengimplementasikan ini

```go
type KeyStore interface {
	PublicKey(clientKey string) (crypto.PublicKey, error)
	ClientSecret(clientKey string) (string, error)
}
```

Penyimpanan key/secret adalah tugas aplikasi Anda (database, vault, atau
apa pun yang Anda pakai) — package ini tidak memilikinya. Satu aturan:
untuk `clientKey` yang tidak dikenal, implementasi Anda **harus**
mengembalikan error non-nil, jangan zero value dengan `nil`. Error nil
berarti "lookup berhasil," jadi mengembalikannya untuk key yang tidak
dikenal akan muncul belakangan sebagai `ErrSignatureMismatch` yang
membingungkan, bukan kegagalan "client tidak dikenal" yang jelas.

## `SignatureMode`

```go
type SignatureMode int

const (
	SignatureModeAsymmetric SignatureMode = iota // zero value default; sesuai default HeaderBuilder{} (Symmetric: false)
	SignatureModeSymmetric                       // sesuai HeaderBuilder{Symmetric: true}
)
```

Mode signing tingkat transaksi yang disepakati dengan partner saat
registrasi — ini konfigurasi, bukan pilihan runtime per-request. Zero
value-nya adalah `SignatureModeAsymmetric`, mencerminkan zero value
`HeaderBuilder.Symmetric` sendiri (`false`) untuk konfigurasi partner yang
sama di sisi klien.

## `IncomingRequest`

```go
type IncomingRequest struct {
	Method      string // metode HTTP, mis. "POST"
	EndpointURL string // URL endpoint lengkap persis seperti dipakai dalam formula signing
	Body        []byte // byte body request seperti yang diterima
	Timestamp   string // nilai header X-TIMESTAMP
	ClientKey   string // nilai header X-CLIENT-KEY
	Signature   string // nilai header X-SIGNATURE
	AccessToken string // token dari header Authorization, tanpa "Bearer "; wajib untuk verifikasi symmetric, diabaikan selainnya
	ExternalID  string // nilai header X-EXTERNAL-ID; dibawa untuk pertahanan replay Anda sendiri, tidak dicek package ini
}
```

Anda mengambil field-field ini sendiri dari framework HTTP apa pun yang
Anda pakai — package ini tidak mem-parsing `*http.Request` langsung,
supaya tetap agnostik terhadap framework.

## `ServerVerifier`

```go
type ServerVerifier struct {
	KeyStore        KeyStore
	Mode            SignatureMode // request access-token selalu asymmetric terlepas dari ini
	TimestampWindow time.Duration // toleransi kesegaran; nol berarti DefaultTimestampWindow
	Profile         Profile       // opsional; nil berarti DefaultProfile{}
	Now             func() time.Time
}
```

```go
func (v *ServerVerifier) VerifyAccessTokenRequest(req IncomingRequest) error
func (v *ServerVerifier) VerifyTransactionRequest(req IncomingRequest) error
```

```go
verifier := &snap.ServerVerifier{
	KeyStore: myKeyStore,
	Mode:     snap.SignatureModeSymmetric,
}

if err := verifier.VerifyTransactionRequest(snap.IncomingRequest{
	Method:      r.Method,
	EndpointURL: fullURL,
	Body:        bodyBytes,
	Timestamp:   r.Header.Get("X-TIMESTAMP"),
	ClientKey:   r.Header.Get("X-CLIENT-KEY"),
	Signature:   r.Header.Get("X-SIGNATURE"),
	ExternalID:  r.Header.Get("X-EXTERNAL-ID"),
}); err != nil {
	// tolak request — jangan unmarshal Body dulu
	return
}

var notif transfercredit.NotifyBulkCashInRequest
json.Unmarshal(bodyBytes, &notif)
```

Standar mewajibkan pengecekan kesegaran timestamp, jadi membiarkan
`TimestampWindow` tidak diisi tidak melewatkan pengecekan itu — nilainya
default ke `DefaultTimestampWindow` (5 menit). Untuk mematikan pengecekan
kesegaran dengan sengaja, set `TimestampWindow` ke
`DisableTimestampFreshnessCheck` secara eksplisit; zero value selalu
berarti "pakai default," tidak pernah "dimatikan."

## Sentinel error

| Sentinel | Arti |
|---|---|
| `ErrNoKeyStore` | `ServerVerifier.KeyStore` bernilai nil |
| `ErrEmptyClientSecret` | `KeyStore.ClientSecret` berhasil tapi mengembalikan `""` — bug konfigurasi, bukan request palsu |
| `ErrSignatureMismatch` | signature gagal diverifikasi meski lookup key-nya berhasil, untuk kedua mode signing |

`ErrEmptyClientSecret` dan `ErrSignatureMismatch` dibuat berbeda dengan
sengaja supaya Anda bisa membedakan alert antara "`KeyStore` Anda ada
bug" versus "request ini dipalsukan atau dimanipulasi," lewat pengecekan
`errors.Is` yang terpisah.

## Selanjutnya

{{< cards >}}
  {{< card title="Signing" icon="signature" link="../signing/" subtitle="Primitif `VerifySymmetric`/`VerifyAsymmetric` yang mendasarinya." >}}
  {{< card title="Bulk Cash In" icon="hand-coins" link="../../reference/transfer-credit/bulk-cashin/" subtitle="Contoh nyata sebuah tipe notifikasi masuk untuk diverifikasi dan di-unmarshal." >}}
{{< /cards >}}

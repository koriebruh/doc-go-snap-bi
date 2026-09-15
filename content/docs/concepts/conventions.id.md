---
weight: 1
title: "Konvensi Inti"
description: "Bentuk yang diikuti setiap package, endpoint, dan tipe di go-snap-bi"
---

Setiap package domain (`registration`, `balanceinfo`, `transactionhistory`,
`transfercredit`, `transferdebit`) mengikuti aturan-aturan kecil yang sama
di bawah ini. Pelajari sekali, dan setiap endpoint jadi bisa ditebak —
Anda tinggal membaca tabel field, bukan mempelajari pola baru setiap kali.

## Satu package per kategori portal ASPI

Setiap package domain memetakan 1:1 ke salah satu kategori "API Services"
tingkat atas di [ASPI SNAP Developer
Site](https://apidevportal.aspi-indonesia.or.id/api-services), jadi "endpoint
ini masuk package mana" bukan hal yang perlu diperdebatkan. Package `snap`
di root hanya menyimpan apa yang dibutuhkan setiap package domain: signing,
siklus hidup token, verifikasi request masuk, penyusunan header, parsing
kode respons, dan `Money`.

## Satu bentuk per endpoint

Setiap fungsi pemanggil punya signature yang sama:

```go
func Endpoint(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req XRequest) (XResponse, error)
```

dan melakukan empat hal yang sama, secara berurutan:

1. Marshal `req` menjadi JSON.
2. Set `hb.Body` ke byte-byte tersebut, lalu sign dan kirim lewat `t.Do(ctx, hb)` — byte yang sama dipakai untuk signature maupun body di wire, jadi keduanya tidak mungkin berbeda.
3. Cek respons dengan `snap.CheckResponseStatus` — **status HTTP bersifat otoritatif dibanding body `responseCode` SNAP, tidak pernah sebaliknya.** Status HTTP non-2xx tidak pernah dianggap sukses meskipun `responseCode` yang tertanam mengklaim sebaliknya.
4. Unmarshal ke `XResponse` dan kembalikan.

Sejumlah endpoint read-only, GET, atau URL-path-parameter (`GetOAuthURL`,
`CardRegistrationInquiry`) menyimpang dari bentuk JSON-body karena
standarnya sendiri mendefinisikan mereka sebagai query string atau path
parameter — masing-masing dijelaskan eksplisit di halaman referensinya.

## Presence field: Mandatory / Optional / Conditional

Standar SNAP menandai setiap field **M**andatory, **O**ptional, atau
**C**onditional (opsional, tapi wajib bila kondisi lain terpenuhi). Package
ini menyatakannya lewat `omitempty` di Go:

- Field yang ditandai **Mandatory** oleh standar tidak punya `omitempty` —
  selalu muncul di wire, bahkan sebagai zero value.
- Semua field lainnya membawa `omitempty`.

{{< callout type="default" >}}
Optional dan Conditional sama-sama memakai tag `omitempty`, jadi kolom
"Presence" di halaman referensi menampilkan keduanya sebagai
**Optional** — Go tidak bisa membedakannya. Jika sebuah field sebenarnya
Conditional, paragraf di atas tabel akan menyebutkannya langsung
(misalnya *"OriginatorInfos is Conditional"*). Baca paragraf itu dulu
sebelum menganggap field Optional selalu aman untuk dilewati.
{{< /callout >}}

Package ini hanya memvalidasi bentuk wire, bukan aturan bisnis standar
(misalnya "harus tepat salah satu dari A atau B diisi") — itu tugas
server.

## `json.RawMessage` berarti "bentuk ambigu atau tidak dispesifikasikan"

Sebagian besar field bertipe `string`, `bool`, struct bersarang, atau
`*snap.Money`. Sebuah field bertipe `json.RawMessage` ketika Guides tab
mendokumentasikan bentuknya secara ambigu (misalnya ditampilkan sebagai
angka JSON polos di satu contoh dan string berkutip di contoh lain) —
mendekodenya sebagai tipe Go tertentu akan menolak respons server yang
sah, atau diam-diam memaksa data yang sebenarnya bukan string.
`additionalInfo` adalah kasus paling umum: standarnya sendiri
membiarkannya sepenuhnya terbuka per integrasi.

## Tipe `Money` yang dipakai bersama

```go
type Money struct {
	Value    string `json:"value"`
	Currency string `json:"currency"`
}
```

`Money` adalah bentuk `{value, currency}` yang dipakai di setiap request
atau response yang membawa nilai uang. `Value` adalah string desimal
(misalnya `"200000.00"`, selalu dua angka di belakang koma) — tidak pernah
float, untuk menghindari pembulatan floating-point biner pada uang.
`Currency` adalah ISO 4217 (misalnya `"IDR"`).

## Selanjutnya

{{< cards >}}
  {{< card title="Headers & Signing" icon="key" link="/id/docs/concepts/headers/" subtitle="Bagaimana `HeaderBuilder` menyusun dan menandatangani sebuah request." >}}
  {{< card title="Errors" icon="triangle-alert" link="/id/docs/concepts/errors/" subtitle="Kode respons, sentinel error, dan aturan status-HTTP-menang secara detail." >}}
{{< /cards >}}

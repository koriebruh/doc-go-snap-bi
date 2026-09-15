---
weight: 5
title: "Transport"
description: "Bagaimana request yang sudah ditandatangani benar-benar dikirim, dan bagaimana responsnya didekode"
---

`Transport` adalah lapisan HTTP tipis yang dipakai fungsi pemanggil di
setiap package domain untuk mengirim request hasil bangunan
`HeaderBuilder` dan mendekode responsnya.

## `Transport`

```go
type Transport struct {
	HTTPClient *http.Client
}
```

```go
func (t *Transport) Do(ctx context.Context, hb HeaderBuilder) (Envelope, error)
```

`Do` menandatangani `hb` (lewat `hb.Build()`), mengirimnya, dan mendekode
body respons menjadi `Envelope`. Fungsi ini **tidak** melakukan retry,
rate-limit, atau menafsirkan `responseCode` non-2xx sebagai error Go —
hanya kegagalan tingkat transport (error saat membangun header, error
jaringan, body bukan JSON, context dibatalkan) yang dikembalikan sebagai
`error`. Menafsirkan respons yang sudah didekode sebagai
sukses/gagal adalah tugas pemanggil, lewat `snap.CheckResponseStatus`
(lihat [Errors](/id/docs/concepts/errors/)).

Bila `HTTPClient` dibiarkan nil, `Transport` membangun satu dengan
timeout default yang **tidak pernah mengikuti redirect**. Ini penting:
klien HTTP default Go meneruskan sebagian besar header (termasuk
`X-SIGNATURE`, `X-CLIENT-KEY`, `X-PARTNER-ID` yang sudah Anda
tandatangani) — dan untuk 307/308, seluruh body — ke host manapun yang
dituju redirect. Tidak ada endpoint SNAP yang punya alasan sah untuk
melakukan redirect, jadi `Do` memperlakukan redirect seperti request gagal
lainnya, bukan mengikutinya.

Body respons dibatasi ukurannya saat dibaca, supaya server yang
bermasalah atau jahat tidak bisa memaksa pemakaian memori tak terbatas.

## `Envelope`

```go
type Envelope struct {
	StatusCode      int
	ResponseCode    string
	ResponseMessage string
	Raw             json.RawMessage
}
```

`Envelope` adalah bentuk respons generik yang sudah didekode: `StatusCode`
HTTP tingkat transport ditambah field envelope SNAP apa pun yang dibawa
body. Fungsi pemanggil di setiap package domain melakukan unmarshal `Raw`
ke tipe respons masing-masing.

`StatusCode` penting karena `ResponseCode` hanya bisa diandalkan ketika
server benar-benar mengembalikan bentuk error SNAP sendiri — body dari
proxy, WAF, atau gateway di depannya mungkin tidak membawa `ResponseCode`
sama sekali. Binding yang tidak punya `ResponseCode` untuk dijadikan
fallback sebaiknya mengacu ke `StatusCode`, pola yang sama yang dipakai
`TokenManager` secara internal.

## Selanjutnya

{{< cards >}}
  {{< card title="Errors" icon="triangle-alert" link="../errors/" subtitle="Mengubah `Envelope` menjadi sukses/gagal yang pasti dan error bertipe." >}}
  {{< card title="Verifying inbound requests" icon="shield-check" link="../webhooks/" subtitle="Sisi penerima, untuk endpoint di mana pemanggil package ini adalah server." >}}
{{< /cards >}}

---
weight: 5
title: "FAQ"
description: "Pertanyaan umum saat mengintegrasikan go-snap-bi"
aliases:
  - /docs/concepts/faq/
---

  {{< details title="Mode signing mana yang harus saya pakai — Symmetric atau Asymmetric?" >}}
Sesuai apa pun yang disepakati partner Anda (PJP di sisi lain) saat
registrasi — package ini tidak memilihkan untuk Anda. Set
`HeaderBuilder.Symmetric` sesuai: `true` dengan `ClientSecret` untuk
HMAC-SHA512, atau `false` dengan `Signer` untuk SHA256withRSA. Lihat
[Signing](/id/docs/concepts/signing/).
{{< /details >}}
  {{< details title="Apakah saya butuh database untuk memakai TokenManager?" >}}
Tidak. `TokenManager.AccessTokenB2B` meng-cache token di memori selama
umur nilai `*TokenManager` itu — tidak ada penyimpanan eksternal. Bila
Anda menjalankan beberapa proses/instance, masing-masing punya cache-nya
sendiri dan mengambil token-nya sendiri secara independen. Lihat
[Authentication](/id/docs/concepts/authentication/).
{{< /details >}}
  {{< details title="Apakah aman untuk retry sebuah panggilan yang gagal?" >}}
Cek dulu halaman referensi endpoint tersebut — sebagian besar endpoint
tulis **tidak idempotent** (retry bukan sekadar "coba lagi dengan
aman," bisa memicu transaksi dua kali). Server mendeteksi duplikat
lewat `X-EXTERNAL-ID`, jadi retry yang genuine harus memakai ulang
`X-EXTERNAL-ID` yang *sama*, jangan yang baru. Lihat
[Errors](/id/docs/concepts/errors/).
{{< /details >}}
  {{< details title="Sebuah field yang saya butuhkan bertipe json.RawMessage, bukan string — kenapa?" >}}
Standar SNAP mendokumentasikan bentuk field itu secara ambigu
(misalnya ditampilkan sebagai angka JSON polos di satu contoh dan
string berkutip di contoh lain). Mendekodenya sebagai tipe Go tertentu
akan menolak respons yang sah di salah satu bentuk itu; `json.RawMessage`
menerima keduanya tanpa kehilangan data. Lihat
[Core Conventions](/id/docs/concepts/conventions/).
{{< /details >}}
  {{< details title="Kenapa tabel request sebuah endpoint menampilkan semua field sebagai Optional padahal paragrafnya bilang ada yang Conditional?" >}}
Optional dan Conditional sama-sama dikompilasi jadi `omitempty` di Go —
tidak ada bedanya di level wire, jadi tabel tidak bisa membedakannya.
Baca paragraf di atas tabel (diambil dari doc comment sumbernya
sendiri) untuk tahu field Optional mana yang sebenarnya Conditional.
Lihat [Core Conventions](/id/docs/concepts/conventions/).
{{< /details >}}
  {{< details title="Bagaimana cara menangani notifikasi/callback pembayaran?" >}}
Verifikasi dulu dengan `snap.ServerVerifier` — jangan pernah
meng-unmarshal body masuk sebelum mengecek signature-nya. Setiap
bagian "Inbound only" di halaman referensi menyebutkan tipe
`...NotificationRequest` yang tepat untuk didekode dan bentuk
`...NotificationResponse` untuk membalasnya. Lihat
[Verifying inbound requests](/id/docs/concepts/webhooks/).
{{< /details >}}
  {{< details title="Apakah package ini melakukan retry atau rate-limit request untuk saya?" >}}
Tidak. `snap.Transport.Do` mengirim tepat satu request lalu selesai —
tidak ada retry, backoff, atau rate-limiting. Bangun sendiri di kode
pemanggil Anda bila dibutuhkan, memakai catatan idempotency setiap
endpoint untuk menentukan apa yang aman di-retry. Lihat
[Transport](/id/docs/concepts/transport/).
{{< /details >}}
  {{< details title="Versi Go berapa yang saya butuhkan?" >}}
Go 1.21 atau lebih baru, sesuai
[`go.mod`](https://github.com/koriebruh/go-snap-bi/blob/main/go.mod).
{{< /details >}}
  {{< details title="Apakah package ini punya dependensi pihak ketiga?" >}}
Tidak — semuanya standard library Go (`net/http`, `crypto/rsa`,
`crypto/hmac`, `encoding/json`, dan sejenisnya).
{{< /details >}}

---
weight: 1
title: "Pendahuluan"
description: "Implementasi Go untuk standar pembayaran SNAP milik Bank Indonesia"
---

<div style="text-align: center; padding: 1.5rem 0 0.5rem" class="hero-logo-sm">

![go-snap-bi](/images/GO-SNAP-hero.png)
  <div style="height: 3px; width: 120px; margin: 1.25rem auto 0; border-radius: 2px; background: linear-gradient(90deg, #145B91 0%, #145B91 45%, #FFFFFF 45%, #FFFFFF 55%, #F97316 55%, #F97316 100%)" />
</div>

**go-snap-bi** adalah implementasi Go untuk standar **SNAP** (Standar
Nasional Open API Pembayaran) milik Bank Indonesia — **versi dokumen 1.0.2
(September 2024)** — mencakup seluruh kategori API Service yang
dipublikasikan di
[ASPI SNAP Developer Site](https://apidevportal.aspi-indonesia.or.id/api-services).

{{< callout type="info" >}}
SDK ini menargetkan **standar SNAP versi 1.0.2**, dipublikasikan
September 2024. Jika ASPI/Bank Indonesia merilis versi dokumen yang lebih
baru, cek [repository GitHub](https://github.com/koriebruh/go-snap-bi)
sebelum mengasumsikan sebuah field atau endpoint di sini masih sesuai
dengan spesifikasi terbaru.
{{< /callout >}}

<p style="text-align: center; font-size: 0.8rem; color: var(--gray-500, #6B7280)">
  Implementasi independen dan tidak resmi dari standar yang dipublikasikan
  oleh Bank Indonesia dan <a href="https://apidevportal.aspi-indonesia.or.id/api-services">ASPI</a> —
  tidak berafiliasi dengan atau didukung oleh keduanya.
</p>

```bash
go get github.com/koriebruh/go-snap-bi
```

## Status

Seluruh 7 kategori API Service pada portal sudah tercakup — **79 binding
endpoint bertipe** di 5 package domain, ditambah inti
signing/token/transport yang dipakai bersama.

| Kategori portal | Package | Service Code | Endpoint |
|---|---|---|---|
| Registrasi | [`registration`](/id/docs/reference/registration/) | 01–10, 81 | 11 |
| Informasi Saldo | [`balanceinfo`](/id/docs/reference/balance-info/) | 11 | 1 |
| Riwayat Transaksi | [`transactionhistory`](/id/docs/reference/transaction-history/) | 12–14 | 3 |
| Transfer Kredit | [`transfercredit`](/id/docs/reference/transfer-credit/account-inquiry/) | 15–53, 75–78 | 43 |
| Transfer Debit | [`transferdebit`](/id/docs/reference/transfer-debit/auth-payment/) | 54–72, 79–80 | 21 |
| Keamanan | package `snap` di root ([Authentication](/id/docs/concepts/authentication/)) | 73–74 | — |
| Administrasi | *(tidak ada endpoint API di portal — hanya dokumen onboarding)* | — | — |

Endpoint Access Token milik Keamanan ditaruh di package root, bukan
subpackage sendiri: setiap package lain butuh endpoint ini hanya untuk
mendapatkan token, jadi sifatnya infrastruktur, bukan domain yang setara.

## Desain

{{< cards >}}
  {{< card title="Satu core, lima package domain" icon="layers" subtitle="Package `snap` di root hanya menyimpan apa yang dibutuhkan setiap package domain: signing request, siklus hidup access-token, verifikasi request masuk, penyusunan header, parsing kode respons, dan tipe `Money` yang dipakai bersama. Setiap package domain memetakan 1:1 ke satu kategori portal ASPI." >}}
  {{< card title="Satu bentuk per endpoint" icon="shapes" subtitle="Setiap fungsi pemanggil mengikuti pola yang sama: marshal request bertipe, sign lalu kirim, cek status respons (status HTTP bersifat otoritatif dibanding body `responseCode` SNAP, tidak pernah sebaliknya), lalu unmarshal ke response bertipe." >}}
  {{< card title="Kesetiaan pada bentuk wire dibanding kenyamanan" icon="file-check" subtitle="Penanda field Mandatory/Optional/Conditional dari standar dipertahankan persis sebagai presence `omitempty`; field yang bentuknya ambigu atau tidak dispesifikasikan dimodelkan sebagai `json.RawMessage`, bukan ditebak." >}}
  {{< card title="Nol dependensi pihak ketiga" icon="box" subtitle="Semuanya standard library Go — `net/http`, `crypto/rsa`, `crypto/hmac`, `encoding/json`." >}}
{{< /cards >}}

## Langkah selanjutnya

{{< cards >}}
  {{< card title="Quickstart" icon="rocket" link="../quickstart/" subtitle="Install module dan buat signed request pertama Anda." >}}
  {{< card title="Konvensi inti" icon="book" link="../concepts/conventions/" subtitle="Pola satu-bentuk-per-endpoint, presence field, dan aturan penanganan error yang dipakai bersama di setiap package." >}}
{{< /cards >}}

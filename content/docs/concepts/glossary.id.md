---
weight: 8
title: "Glossary"
description: "Istilah SNAP dan domain pembayaran yang dipakai di seluruh dokumentasi ini"
---

Istilah dari standar SNAP dan ekosistem pembayaran Indonesia, dipakai
konsisten di seluruh penamaan dan dokumentasi SDK ini.

| Istilah | Arti |
|---|---|
| **SNAP** | Standar Nasional Open API Pembayaran — standar nasional Bank Indonesia untuk open API pembayaran, standar yang diimplementasikan package ini. |
| **ASPI** | Asosiasi Sistem Pembayaran Indonesia — asosiasi industri yang menerbitkan dan mengelola SNAP Developer Portal, tempat binding endpoint package ini dibangun. |
| **PJP** | Penyedia Jasa Pembayaran — bank, e-wallet, atau entitas teregulasi lain di salah satu sisi transaksi SNAP. |
| **Penyedia Layanan** | Sisi server dari sebuah integrasi SNAP — PJP yang menerima dan menjawab request. `ServerVerifier` dibuat untuk peran ini (lihat [Verifying inbound requests](/id/docs/concepts/webhooks/)). |
| **Service Code** | Kode 2 digit yang mengidentifikasi satu endpoint SNAP tertentu dalam standar (mis. `11` untuk Balance Inquiry). [Tabel Status](/id/docs/introduction/) memetakan setiap package domain ke rentang Service Code-nya. |
| **responseCode** | Kode hasil 7 digit milik standar SNAP sendiri, tertanam di setiap body respons: `HTTPStatus(3) + ServiceCode(2) + CaseCode(2)`. Lihat [`ParseResponseCode`](/id/docs/concepts/errors/). |
| **Envelope** | Bentuk respons generik yang sudah didekode milik package ini (`snap.Envelope`): status HTTP tingkat transport ditambah field envelope SNAP apa pun yang dibawa body. Lihat [Transport](/id/docs/concepts/transport/). |
| **B2B** | Business-to-Business — grant access-token `client_credentials` yang mengidentifikasi integrasi itu sendiri, bukan satu customer akhir tertentu. Di-cache oleh [`TokenManager.AccessTokenB2B`](/id/docs/concepts/authentication/). |
| **B2B2C** | Business-to-Business-to-Consumer — grant `authorization_code`/`refresh_token` yang terikat ke satu customer akhir tertentu, didapat lewat alur bergaya OAuth (lihat [`GetOAuthURL`](/id/docs/reference/registration/)). Tidak pernah di-cache, karena setiap token milik satu customer. |
| **Symmetric / Asymmetric signing** | Dua mode signature SNAP yang disepakati dengan partner saat registrasi: symmetric (HMAC-SHA512, `ClientSecret` bersama) atau asymmetric (SHA256withRSA, keypair `crypto.Signer`). Lihat [Signing](/id/docs/concepts/signing/). |
| **Mandatory / Optional / Conditional** | Tiga kelas presence field milik standar. Package ini menyatakannya lewat `omitempty` di Go — lihat catatan di [Core Conventions](/id/docs/concepts/conventions/) soal bagaimana Optional dan Conditional menyatu jadi satu tag `omitempty`. |
| **Idempotency / X-EXTERNAL-ID** | Sebagian besar endpoint tulis **tidak** idempotent — retry dengan `X-EXTERNAL-ID` baru berisiko membuat transaksi ganda, karena deteksi duplikat di server mengacu pada header itu. Setiap halaman referensi endpoint menyebutkan ini secara eksplisit. |
| **Virtual Account (VA)** | Nomor akun sementara atau permanen yang diterbitkan PJP supaya pembayar bisa membayar ke sana; lihat grup referensi [Virtual Account](/id/docs/reference/transfer-credit/virtual-account/). |
| **MPM / CPM** | Merchant-Presented Mode dan Customer-Presented Mode — dua alur pembayaran QRIS SNAP, dibedakan berdasarkan pihak mana yang menampilkan kode QR. Lihat [QR / MPM](/id/docs/reference/transfer-credit/qr-mpm/) (sisi kredit) dan [CPM](/id/docs/reference/transfer-debit/cpm/) (sisi debit). |
| **OTT** | One-Time Token — token berumur pendek yang diterbitkan [`ApplyOTT`](/id/docs/reference/transfer-credit/qr-mpm/) untuk mengotorisasi satu pembayaran QR MPM. |
| **RTGS / SKNBI / BI-FAST** | Tiga jalur transfer antarbank Bank Indonesia: RTGS (nilai besar, langsung settle), SKNBI (kliring batch), dan BI-FAST (transfer ritel real-time). Masing-masing punya endpoint Trigger Transfer atau Direct Debit sendiri beserta tipe notifikasi masuknya. |
| **`Money`** | Tipe nilai uang `{value, currency}` milik package ini (`snap.Money`) — `value` adalah string desimal, tidak pernah float, untuk menghindari pembulatan floating-point biner pada uang. Lihat [Core Conventions](/id/docs/concepts/conventions/). |

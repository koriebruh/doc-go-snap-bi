---
weight: 4
title: "Top Up Pelanggan"
description: "Top-up akun e-money/e-wallet: cek rekening, top-up, dan cek status."
---

## Top Up Pelanggan

Top-up akun e-money/e-wallet: cek rekening, top-up, dan cek status.

```go
resp, err := transfercredit.CustomerTopUp(ctx, transport, hb, transfercredit.CustomerTopUpRequest{
	PartnerReferenceNo: "2020102900000000000001",
})
if err != nil {
	// errors.Is(err, snap.ErrBadRequest), snap.ErrUnauthorized, etc.
}
```

### `AccountInquiryCustomerTopUp`

Memanggil endpoint SNAP Account Inquiry - Customer Top Up (Service Code 37, path .../{version}/emoney/account-inquiry). `hb` harus sudah diisi semua field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body` — fungsi ini yang mengisinya sendiri agar byte yang sama persis dipakai untuk signing maupun request di wire.

```go
func AccountInquiryCustomerTopUp(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AccountInquiryCustomerTopUpRequest) (AccountInquiryCustomerTopUpResponse, error)
```

**Request &mdash; `AccountInquiryCustomerTopUpRequest`**

`Amount` satu-satunya field Wajib. `CustomerNumber` Kondisional — wajib diisi kecuali access token B2B2C sudah mengidentifikasi pelanggannya.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `customerNumber` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `snap.Money` | <span class="badge-mandatory">Wajib</span> |
| `transactionDate` | `string` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `AccountInquiryCustomerTopUpResponse`**

`customerNumber` dikembalikan dalam bentuk masked (mis. `"XXXXXXXXX1857"`). `customerMonthlyInLimit` bertipe `json.RawMessage` karena standarnya menampilkan nilai ini sebagai angka berkutip — field string biasa tidak bisa mengasumsikan semua issuer mengirimnya dengan format yang sama.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `sessionId` | `string` | <span class="badge-optional">Opsional</span> |
| `customerNumber` | `string` | <span class="badge-optional">Opsional</span> |
| `customerName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `customerMonthlyInLimit` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `minAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `maxAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `feeAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `feeType` | `string` | <span class="badge-optional">Opsional</span> |


---

### `CustomerTopUp`

Memanggil endpoint SNAP Customer Top Up (Service Code 38, path .../{version}/emoney/topup). `hb` harus sudah diisi semua field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body` — fungsi ini yang mengisinya sendiri agar byte yang sama persis dipakai untuk signing maupun request di wire.

Tidak idempoten dan tidak di-retry otomatis. Kalau me-retry request yang gagal/timeout, pakai `X-EXTERNAL-ID` yang sama — server mendeteksi duplikat lewat header ini, jadi ID baru berisiko bikin top-up ganda.

```go
func CustomerTopUp(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req CustomerTopUpRequest) (CustomerTopUpResponse, error)
```

**Request &mdash; `CustomerTopUpRequest`**

`partnerReferenceNo` satu-satunya field Wajib. `categoryId` bertipe `json.RawMessage` dengan alasan sama seperti `customerMonthlyInLimit` di atas: standarnya menampilkan nilai ini sebagai angka berkutip, bukan string yang pasti.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `customerNumber` | `string` | <span class="badge-optional">Opsional</span> |
| `customerName` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `feeAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Opsional</span> |
| `sessionId` | `string` | <span class="badge-optional">Opsional</span> |
| `categoryId` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `notes` | `string` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `CustomerTopUpResponse`**

`referenceNumber` tidak ada di tabel field standarnya, tapi muncul di contoh resminya, jadi tetap dicantumkan di sini.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `sessionId` | `string` | <span class="badge-optional">Opsional</span> |
| `customerNumber` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `referenceNumber` | `string` | <span class="badge-optional">Opsional</span> |


---

### `CustomerTopUpInquiryStatus`

Memanggil endpoint SNAP Customer Top Up Inquiry Status (Service Code 39, path .../{version}/emoney/topup-status). `hb` harus sudah diisi semua field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body` — fungsi ini yang mengisinya sendiri agar byte yang sama persis dipakai untuk signing maupun request di wire.

```go
func CustomerTopUpInquiryStatus(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req CustomerTopUpInquiryStatusRequest) (CustomerTopUpInquiryStatusResponse, error)
```

**Request &mdash; `CustomerTopUpInquiryStatusRequest`**

Bentuknya sama dengan [`TransactionStatusInquiryBankRequest`](/id/docs/reference/transfer-credit/transaction-status/), hanya beda nama tipe. `serviceCode` satu-satunya field Wajib.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Opsional</span> |
| `serviceCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `transactionDate` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `CustomerTopUpInquiryStatusResponse`**

Bentuknya sama dengan `TransactionStatusInquiryBankResponse`, hanya beda nama tipe.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Opsional</span> |
| `serviceCode` | `string` | <span class="badge-optional">Opsional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryBankCode` | `string` | <span class="badge-optional">Opsional</span> |
| `previousResponseCode` | `string` | <span class="badge-optional">Opsional</span> |
| `referenceNumber` | `string` | <span class="badge-mandatory">Wajib</span> |
| `sourceAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `transactionId` | `string` | <span class="badge-optional">Opsional</span> |
| `latestTransactionStatus` | `string` | <span class="badge-mandatory">Wajib</span> |
| `transactionStatusDesc` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

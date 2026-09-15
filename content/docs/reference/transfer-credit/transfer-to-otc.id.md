---
weight: 7
title: "Transfer to OTC"
description: "Membuat, membatalkan, dan mengecek status transfer cash-pickup over-the-counter."
---

## Transfer to OTC

Membuat, membatalkan, dan mengecek status transfer cash-pickup over-the-counter.

```go
resp, err := transfercredit.TransferToOTCCreatePayment(ctx, transport, hb, transfercredit.TransferToOTCCreatePaymentRequest{
	PartnerReferenceNo: "2020102900000000000001",
	CustomerNumber: "2020102900000000000001",
	OTP: "...",
	Amount: snap.Money{Value: "500000.00", Currency: "IDR"},
})
if err != nil {
	// errors.Is(err, snap.ErrBadRequest), snap.ErrUnauthorized, etc.
}
```

### `TransferToOTCCreatePayment`

Memanggil endpoint SNAP Transfer To OTC - Create Payment (Service Code 44, path .../{version}/emoney/otc-cashout, HTTP POST — tanpa override method). `hb` harus sudah membawa setiap field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body`, yang diatur sendiri oleh `TransferToOTCCreatePayment` agar byte hasil marshal yang sama persis dipakai untuk signing dan wire body.

Tidak idempotent dan package ini tidak melakukan retry. Bila memanggil ulang setelah gagal/timeout, gunakan `X-EXTERNAL-ID` yang sama — deteksi duplikat di server mengacu pada header ini.

```go
func TransferToOTCCreatePayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req TransferToOTCCreatePaymentRequest) (TransferToOTCCreatePaymentResponse, error)
```

**Request &mdash; `TransferToOTCCreatePaymentRequest`**

`PartnerReferenceNo`, `CustomerNumber`, `OTP`, dan `Amount` wajib.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `customerNumber` | `string` | <span class="badge-mandatory">Wajib</span> |
| `otp` | `string` | <span class="badge-mandatory">Wajib</span> |
| `amount` | `snap.Money` | <span class="badge-mandatory">Wajib</span> |
| `feeType` | `string` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `TransferToOTCCreatePaymentResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Opsional</span> |


---

### `TransferToOTCCancelPayment`

Memanggil endpoint SNAP Transfer To OTC - Cancel Payment (Service Code 46, HTTP POST). Dokumentasi standar sendiri tidak konsisten soal path pastinya (`.../emoney/otc-cancel` vs `.../otc/cashout/cancel`) — package ini tidak berasumsi, selalu memakai `EndpointURL` yang Anda berikan di `hb`. `Body` diatur sendiri agar byte hasil marshal yang sama persis dipakai untuk signing dan wire body.

Tidak idempotent dan package ini tidak melakukan retry. Bila memanggil ulang setelah gagal/timeout, gunakan `X-EXTERNAL-ID` yang sama — deteksi duplikat di server mengacu pada header ini.

```go
func TransferToOTCCancelPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req TransferToOTCCancelPaymentRequest) (TransferToOTCCancelPaymentResponse, error)
```

**Request &mdash; `TransferToOTCCancelPaymentRequest`**

`OriginalPartnerReferenceNo`, `CustomerNumber`, dan `Reason` wajib; `OriginalReferenceNo` Kondisional di sini (berubah jadi Wajib pada response — lihat doc `TransferToOTCCancelPaymentResponse`).

| Field | Type | Presence |
|---|---|---|
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Opsional</span> |
| `customerNumber` | `string` | <span class="badge-mandatory">Wajib</span> |
| `reason` | `string` | <span class="badge-mandatory">Wajib</span> |

**Response &mdash; `TransferToOTCCancelPaymentResponse`**

`OriginalReferenceNo` wajib di sini (Kondisional pada request). `CancelTime` Kondisional — wajib hanya jika pembatalan berhasil — sehingga dimodelkan Opsional.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originalReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `cancelTime` | `string` | <span class="badge-optional">Opsional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Opsional</span> |


---

### `TransferToOTCTransferStatus`

Memanggil endpoint SNAP Transfer To OTC - Transfer Status (Service Code 45, path .../{version}/emoney/otc-status, HTTP POST — tanpa override method). `hb` harus sudah membawa setiap field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body`, yang diatur sendiri oleh `TransferToOTCTransferStatus` agar byte hasil marshal yang sama persis dipakai untuk signing dan wire body.

```go
func TransferToOTCTransferStatus(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req TransferToOTCTransferStatusRequest) (TransferToOTCTransferStatusResponse, error)
```

**Request &mdash; `TransferToOTCTransferStatusRequest`**

Mengikuti bentuk yang sama dengan [`TransactionStatusInquiryBankRequest`](/id/docs/reference/transfer-credit/transaction-status/), ditambah `CustomerNumber` dan `Amount` yang Wajib (bukan Opsional). `ServiceCode` dan `CustomerNumber` wajib.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Opsional</span> |
| `serviceCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `transactionDate` | `string` | <span class="badge-optional">Opsional</span> |
| `customerNumber` | `string` | <span class="badge-mandatory">Wajib</span> |
| `amount` | `snap.Money` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `TransferToOTCTransferStatusResponse`**

Identik field dengan [`TransactionStatusInquiryBankResponse`](/id/docs/reference/transfer-credit/transaction-status/), dimodelkan sebagai tipe sendiri karena setiap service code SNAP mendapat tipe berbeda meski bentuknya sama.

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

---
weight: 6
title: "Transfer to Bank"
description: "Inquiry dan pembayaran untuk transfer yang dirutekan ke bank eksternal."
---

## Transfer to Bank

Inquiry dan pembayaran untuk transfer yang dirutekan ke bank eksternal.

```go
resp, err := transfercredit.TransferToBankPayment(ctx, transport, hb, transfercredit.TransferToBankPaymentRequest{
	PartnerReferenceNo: "2020102900000000000001",
	CustomerNumber: "2020102900000000000001",
	BeneficiaryAccountNumber: "...",
	Amount: snap.Money{Value: "500000.00", Currency: "IDR"},
})
if err != nil {
	// errors.Is(err, snap.ErrBadRequest), snap.ErrUnauthorized, etc.
}
```

### `TransferToBankAccountInquiry`

Memanggil endpoint SNAP Transfer To Bank - Account Inquiry (Service Code 42, path .../{version}/emoney/bank-account-inquiry, HTTP POST — tanpa override method). `hb` harus sudah membawa setiap field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body`, yang diatur sendiri oleh `TransferToBankAccountInquiry` agar byte hasil marshal yang sama persis dipakai untuk signing dan wire body.

```go
func TransferToBankAccountInquiry(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req TransferToBankAccountInquiryRequest) (TransferToBankAccountInquiryResponse, error)
```

**Request &mdash; `TransferToBankAccountInquiryRequest`**

`CustomerNumber` dan `Amount` wajib. Perhatikan field wire-nya `CustomerNumber` (C besar) di sini — endpoint lain memakai `customerNumber` huruf kecil. Kemungkinan salah ketik dokumentasi, tapi package ini mengikuti casing yang terdokumentasi apa adanya.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `CustomerNumber` | `string` | <span class="badge-mandatory">Wajib</span> |
| `amount` | `snap.Money` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryAccountNumber` | `string` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `TransferToBankAccountInquiryResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `accountType` | `string` | <span class="badge-optional">Opsional</span> |
| `beneficiaryAccountNumber` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryAccountName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryBankCode` | `string` | <span class="badge-optional">Opsional</span> |
| `beneficiaryBankShortName` | `string` | <span class="badge-optional">Opsional</span> |
| `beneficiaryBankName` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `snap.Money` | <span class="badge-mandatory">Wajib</span> |
| `sessionId` | `string` | <span class="badge-optional">Opsional</span> |


---

### `TransferToBankPayment`

Memanggil endpoint SNAP Transfer To Bank - Payment Transaction (Service Code 43, path .../{version}/emoney/transfer-bank, HTTP POST — tanpa override method). `hb` harus sudah membawa setiap field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body`, yang diatur sendiri oleh `TransferToBankPayment` agar byte hasil marshal yang sama persis dipakai untuk signing dan wire body.

Tidak idempotent dan package ini tidak melakukan retry. Bila memanggil ulang setelah gagal/timeout, gunakan `X-EXTERNAL-ID` yang sama — deteksi duplikat di server mengacu pada header ini.

```go
func TransferToBankPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req TransferToBankPaymentRequest) (TransferToBankPaymentResponse, error)
```

**Request &mdash; `TransferToBankPaymentRequest`**

`PartnerReferenceNo`, `CustomerNumber`, `BeneficiaryAccountNumber`, dan `Amount` wajib. Berbeda dari Account Inquiry di atas, `customerNumber` di sini memakai casing lowercase normal.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `customerNumber` | `string` | <span class="badge-mandatory">Wajib</span> |
| `accountType` | `string` | <span class="badge-optional">Opsional</span> |
| `beneficiaryAccountNumber` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryBankCode` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `snap.Money` | <span class="badge-mandatory">Wajib</span> |
| `sessionId` | `string` | <span class="badge-optional">Opsional</span> |
| `feeType` | `string` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `TransferToBankPaymentResponse`**

Perhatikan `referenceNo` dan `referenceNumber` adalah dua field terpisah yang sama-sama ada — bukan duplikat.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Opsional</span> |
| `referenceNumber` | `string` | <span class="badge-mandatory">Wajib</span> |

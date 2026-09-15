---
weight: 9
title: "Transaction Status Inquiry"
description: "Mengecek status transfer yang sudah dikirim sebelumnya, terhadap counterparty bank atau non-bank."
---

## Transaction Status Inquiry

Mengecek status transfer yang sudah dikirim sebelumnya, terhadap counterparty bank atau non-bank.

```go
resp, err := transfercredit.TransactionStatusInquiryBank(ctx, transport, hb, transfercredit.TransactionStatusInquiryBankRequest{
	ServiceCode: "...",
})
if err != nil {
	// errors.Is(err, snap.ErrBadRequest), snap.ErrUnauthorized, etc.
}
```

### `TransactionStatusInquiryBank`

Memanggil endpoint SNAP Transaction Status Inquiry Bank (Service Code 36, path .../{version}/transfer/status). `hb` harus sudah membawa setiap field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body`, yang diatur sendiri oleh `TransactionStatusInquiryBank` agar byte hasil marshal yang sama persis dipakai untuk signing dan wire body.

```go
func TransactionStatusInquiryBank(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req TransactionStatusInquiryBankRequest) (TransactionStatusInquiryBankResponse, error)
```

**Request &mdash; `TransactionStatusInquiryBankRequest`**

`ServiceCode` satu-satunya field wajib — mengacu ke service code transaksi asal (mis. "17" untuk Intrabank).

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Opsional</span> |
| `serviceCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `transactionDate` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `TransactionStatusInquiryBankResponse`**

Struktur flat, tidak ada objek nested. Field request aslinya dikembalikan lagi (Opsional di sini terlepas dari kewajibannya di request). `latestTransactionStatus` kode 2 digit: `00` Sukses, `01` Diinisiasi, `02` Diproses, `03` Pending, `04` Direfund, `05` Dibatalkan, `06` Gagal, `07` Tidak ditemukan.

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


---

### `TransactionStatusInquiryNonBank`

Memanggil endpoint SNAP Transaction Status Inquiry (non-bank) (Service Code 53, path .../{version}/qr/qr-mpm-status). Meski berbagi prefix path `qr/`, ini kategori sendiri, terpisah dari QR/MPM. `hb` harus sudah membawa setiap field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body`, yang diatur sendiri oleh `TransactionStatusInquiryNonBank` agar byte hasil marshal yang sama persis dipakai untuk signing dan wire body.

Query status read-only, tidak ada catatan non-idempotency, sama seperti `TransactionStatusInquiryBank`.

```go
func TransactionStatusInquiryNonBank(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req TransactionStatusInquiryNonBankRequest) (TransactionStatusInquiryNonBankResponse, error)
```

**Request &mdash; `TransactionStatusInquiryNonBankRequest`**

7 field dasar yang sama dengan `TransactionStatusInquiryBankRequest` di atas, ditambah `OriginalResponseCode`, `OriginalResponseMessage`, `SessionID`, dan `RequestID`.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Opsional</span> |
| `serviceCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `transactionDate` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `originalResponseCode` | `string` | <span class="badge-optional">Opsional</span> |
| `originalResponseMessage` | `string` | <span class="badge-optional">Opsional</span> |
| `sessionId` | `string` | <span class="badge-optional">Opsional</span> |
| `requestId` | `string` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `TransactionStatusInquiryNonBankResponse`**

Identik field dengan `TransactionStatusInquiryBankResponse`, dimodelkan sebagai tipe sendiri karena setiap service code SNAP mendapat tipe berbeda meski bentuknya sama.

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

---
weight: 4
title: "Direct Debit BI-FAST"
description: "Registrasi e-mandate dan pembayaran BI-FAST, beserta tipe notifikasi masuknya."
---

## Direct Debit BI-FAST

Registrasi e-mandate dan pembayaran BI-FAST, beserta tipe notifikasi masuknya.

```go
resp, err := transferdebit.DirectDebitBIFASTPayment(ctx, transport, hb, transferdebit.DirectDebitBIFASTPaymentRequest{
	PartnerReferenceNo: "2020102900000000000001",
	CustomerReference: "...",
	BeneficiaryAccountNo: "1234567890",
	BeneficiaryAccountName: "Jane Doe",
	TransactionDate: "2026-09-14T10:00:00+07:00",
	BankCode: "...",
	SourceAccountNo: "1234567890",
	SourceAccountName: "Jane Doe",
	EMandateReffID: "2026-09-14T10:00:00+07:00",
})
if err != nil {
	// errors.Is(err, snap.ErrBadRequest), snap.ErrUnauthorized, etc.
}
```

### `DirectDebitBIFASTEMandateRegistration`

DirectDebitBIFASTEMandateRegistration memanggil endpoint SNAP Registrasi e-Mandate (Service Code 70, HTTP POST). Isi `hb` dengan semua field kecuali `Body` — `DirectDebitBIFASTEMandateRegistration` melakukan marshal request itu sendiri dan memakai byte yang sama persis untuk signing maupun body di wire.

Operasi ini tidak idempotent dan package ini tidak melakukan retry. Bila memanggil ulang setelah gagal atau timeout, gunakan `X-EXTERNAL-ID` yang sama, karena deteksi duplikat di server mengacu pada header itu.

```go
func DirectDebitBIFASTEMandateRegistration(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req DirectDebitBIFASTEMandateRegistrationRequest) (DirectDebitBIFASTEMandateRegistrationResponse, error)
```

**Request &mdash; `DirectDebitBIFASTEMandateRegistrationRequest`**

DirectDebitBIFASTEMandateRegistrationRequest adalah request body untuk Registrasi e-Mandate. `bankCode`, `sourceAccountNo`, `sourceAccountName`, `billerId`, `billerName`, `customerId`, dan `expiredDatetime` bersifat Wajib.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `bankCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `sourceAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `sourceAccountName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `maxAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `billerId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `billerName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `customerId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `expiredDatetime` | `string` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `DirectDebitBIFASTEMandateRegistrationResponse`**

DirectDebitBIFASTEMandateRegistrationResponse adalah response body untuk Registrasi e-Mandate. `referenceNo` bersifat Kondisional — hanya muncul saat berhasil. `eMandateReffId` bersifat Wajib; gunakan nilai ini pada panggilan pembayaran di bawah.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `eMandateReffId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |


---

### `DirectDebitBIFASTPayment`

DirectDebitBIFASTPayment memanggil endpoint SNAP Trigger Direct Debit Transfer / Payment (Service Code 71, HTTP POST). Isi `hb` dengan semua field kecuali `Body` — `DirectDebitBIFASTPayment` melakukan marshal request itu sendiri.

Operasi ini tidak idempotent dan package ini tidak melakukan retry. Bila memanggil ulang setelah gagal atau timeout, gunakan `X-EXTERNAL-ID` yang sama, karena deteksi duplikat di server mengacu pada header itu.

```go
func DirectDebitBIFASTPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req DirectDebitBIFASTPaymentRequest) (DirectDebitBIFASTPaymentResponse, error)
```

**Request &mdash; `DirectDebitBIFASTPaymentRequest`**

DirectDebitBIFASTPaymentRequest adalah request body untuk Trigger Direct Debit Transfer / Payment. `eMandateReffId` berasal dari panggilan e-Mandate Registration sebelumnya.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `currency` | `string` | <span class="badge-optional">Opsional</span> |
| `customerReference` | `string` | <span class="badge-mandatory">Wajib</span> |
| `feeType` | `string` | <span class="badge-optional">Opsional</span> |
| `remark` | `string` | <span class="badge-optional">Opsional</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryAccountName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `transactionDate` | `string` | <span class="badge-mandatory">Wajib</span> |
| `bankCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `sourceAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `sourceAccountName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `eMandateReffId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `DirectDebitBIFASTPaymentResponse`**

DirectDebitBIFASTPaymentResponse adalah response body untuk Trigger Direct Debit Transfer / Payment. `referenceNo` bersifat Kondisional — hanya muncul saat berhasil.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |


---

### `Direct Debit BI-FAST Notification`

{{< callout type="info" >}}
Hanya masuk (inbound) &mdash; package ini tidak memanggil endpoint untuk hal ini. Partner/switcher yang mengirim POST ke URL callback **Anda**; unmarshal body ke `DirectDebitBIFASTNotificationRequest` setelah memverifikasinya dengan `snap.ServerVerifier` (lihat [Verifying inbound requests](/id/docs/concepts/webhooks/)), lalu balas dengan bentuk di bawah.
{{< /callout >}}

**Diterima &mdash; `DirectDebitBIFASTNotificationRequest`**

DirectDebitBIFASTNotificationRequest adalah request body untuk Notify (Service Code 72) — callback settlement yang diterima PJP, bukan panggilan yang dilakukan package ini. Buat HTTP handler Anda sendiri untuk path ini, autentikasi panggilan masuknya dengan `ServerVerifier.VerifyTransactionRequest`, lalu `json.Unmarshal` body ke tipe ini.

`originalReferenceNo`, `transactionStatus`, `eMandateReffId`, `sourceAccountNo`, dan `sourceAccountName` bersifat Wajib; field lainnya Opsional.

{{< callout type="default" >}}
Field status di sini bernama `transactionStatus`, bukan
`latestTransactionStatus` seperti di tempat lain pada package ini — itu
penamaan asli dari standar, dipertahankan apa adanya tanpa dinormalisasi.
{{< /callout >}}

| Field | Type | Presence |
|---|---|---|
| `originalReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Opsional</span> |
| `transactionStatus` | `string` | <span class="badge-mandatory">Wajib</span> |
| `transactionStatusDesc` | `string` | <span class="badge-optional">Opsional</span> |
| `eMandateReffId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `sourceAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `sourceAccountName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `traceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Handler Anda membalas dengan &mdash; `DirectDebitBIFASTNotificationResponse`**

DirectDebitBIFASTNotificationResponse hanya berisi envelope — cuma `responseCode` dan `responseMessage`, tidak ada field lain.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |

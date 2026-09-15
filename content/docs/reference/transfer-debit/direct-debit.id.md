---
weight: 3
title: "Direct Debit"
description: "Pembayaran direct-debit standar, notifikasi masuknya, serta status/batal/refund."
---

## Direct Debit

Pembayaran direct-debit standar, notifikasi masuknya, serta status/batal/refund.

```go
resp, err := transferdebit.DirectDebitPayment(ctx, transport, hb, transferdebit.DirectDebitPaymentRequest{
	PartnerReferenceNo: "2020102900000000000001",
})
if err != nil {
	// errors.Is(err, snap.ErrBadRequest), snap.ErrUnauthorized, etc.
}
```

### `DirectDebitPayment`

DirectDebitPayment memanggil endpoint SNAP Direct Debit Payment (Service Code 54, HTTP POST). Isi `hb` dengan semua field kecuali `Body` — `DirectDebitPayment` melakukan marshal request itu sendiri dan memakai byte yang sama persis untuk signing maupun body di wire.

Operasi ini tidak idempotent dan package ini tidak melakukan retry. Bila memanggil ulang setelah gagal atau timeout, gunakan `X-EXTERNAL-ID` yang sama, karena deteksi duplikat di server mengacu pada header itu.

```go
func DirectDebitPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req DirectDebitPaymentRequest) (DirectDebitPaymentResponse, error)
```

**Request &mdash; `DirectDebitPaymentRequest`**

DirectDebitPaymentRequest adalah request body untuk Direct Debit Payment. `partnerReferenceNo` satu-satunya field Wajib.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | Wajib |
| `bankCardToken` | `string` | Opsional |
| `chargeToken` | `string` | Opsional |
| `otp` | `string` | Opsional |
| `otpTrxCode` | `string` | Opsional |
| `merchantId` | `string` | Opsional |
| `terminalId` | `string` | Opsional |
| `journeyId` | `string` | Opsional |
| `subMerchantId` | `string` | Opsional |
| `amount` | `*snap.Money` | Opsional |
| `urlParams` | `[]DirectDebitPaymentURLParam` | Opsional |
| `externalStoreId` | `string` | Opsional |
| `validUpTo` | `string` | Opsional |
| `pointOfInitiation` | `string` | Opsional |
| `feeType` | `string` | Opsional |
| `disabledPayMethods` | `string` | Opsional |
| `payOptionDetails` | `[]DirectDebitPayOptionDetail` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

{{< details title="DirectDebitPaymentURLParam fields" >}}
DirectDebitPaymentURLParam adalah satu entri dalam array `urlParams[]` pada request — sebuah URL redirect dan cara memakainya. `isDeeplink` adalah flag `"Y"`/`"N"`.

| Field | Type | Presence |
|---|---|---|
| `url` | `string` | Wajib |
| `type` | `string` | Wajib |
| `isDeeplink` | `string` | Wajib |
{{< /details >}}

{{< details title="DirectDebitPayOptionDetail fields" >}}
DirectDebitPayOptionDetail adalah satu entri dalam array `payOptionDetails[]` pada request, mendeskripsikan satu metode pembayaran yang tersedia.

| Field | Type | Presence |
|---|---|---|
| `payMethod` | `string` | Wajib |
| `payOption` | `string` | Wajib |
| `transAmount` | `*snap.Money` | Opsional |
| `feeAmount` | `*snap.Money` | Opsional |
| `cardToken` | `string` | Opsional |
| `merchantToken` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |
{{< /details >}}

**Response &mdash; `DirectDebitPaymentResponse`**

DirectDebitPaymentResponse adalah response body untuk Direct Debit Payment. `referenceNo` bersifat Kondisional — hanya muncul saat berhasil.

{{< callout type="warning" >}}
`appRedirectUrl` dan `webRedirectUrl` datang langsung dari server tanpa
validasi apa pun. Sebelum membuka salah satunya di WebView atau browser,
periksa sendiri skema URL-nya (`https://` atau skema resmi aplikasi Anda) —
respons yang dimanipulasi atau dipalsukan bisa saja menyelipkan URL yang
dikendalikan penyerang.
{{< /callout >}}

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `referenceNo` | `string` | Opsional |
| `partnerReferenceNo` | `string` | Opsional |
| `approvalCode` | `string` | Opsional |
| `appRedirectUrl` | `string` | Opsional |
| `webRedirectUrl` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |


---

### `Direct Debit Payment Notification`

{{< callout type="info" >}}
Hanya masuk (inbound) &mdash; package ini tidak memanggil endpoint untuk hal ini. Partner/switcher yang mengirim POST ke URL callback **Anda**; unmarshal body ke `DirectDebitPaymentNotificationRequest` setelah memverifikasinya dengan `snap.ServerVerifier` (lihat [Verifying inbound requests](/id/docs/concepts/webhooks/)), lalu balas dengan bentuk di bawah.
{{< /callout >}}

**Diterima &mdash; `DirectDebitPaymentNotificationRequest`**

DirectDebitPaymentNotificationRequest adalah request body untuk Direct Debit Payment Notification (Service Code 56) — callback settlement yang diterima PJP, bukan panggilan yang dilakukan package ini. Buat HTTP handler Anda sendiri untuk path ini, autentikasi panggilan masuknya dengan `ServerVerifier.VerifyTransactionRequest`, lalu `json.Unmarshal` body ke tipe ini.

`originalReferenceNo` dan `latestTransactionStatus` bersifat Wajib; field lainnya Opsional.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | Opsional |
| `originalReferenceNo` | `string` | Wajib |
| `originalExternalId` | `string` | Opsional |
| `merchantId` | `string` | Opsional |
| `subMerchantId` | `string` | Opsional |
| `amount` | `*snap.Money` | Opsional |
| `latestTransactionStatus` | `string` | Wajib |
| `transactionStatusDesc` | `string` | Opsional |
| `createdTime` | `string` | Opsional |
| `finishedTime` | `string` | Opsional |
| `externalStoreId` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

**Handler Anda membalas dengan &mdash; `DirectDebitPaymentNotificationResponse`**

DirectDebitPaymentNotificationResponse punya satu field di luar envelope, `approvalCode`, dan sifatnya Opsional.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `approvalCode` | `string` | Opsional |


---

### `DirectDebitPaymentStatus`

DirectDebitPaymentStatus memanggil endpoint SNAP Direct Debit Payment Status (Service Code 55, HTTP POST) untuk mengecek status pembayaran sebelumnya. Isi `hb` dengan semua field kecuali `Body` — `DirectDebitPaymentStatus` melakukan marshal request itu sendiri. Ini pencarian read-only, aman untuk diulang kapan saja.

```go
func DirectDebitPaymentStatus(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req DirectDebitPaymentStatusRequest) (DirectDebitPaymentStatusResponse, error)
```

**Request &mdash; `DirectDebitPaymentStatusRequest`**

DirectDebitPaymentStatusRequest adalah request body untuk Direct Debit Payment Status. `serviceCode` satu-satunya field Wajib — pasangkan dengan reference apa pun yang Anda punya.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | Opsional |
| `originalReferenceNo` | `string` | Opsional |
| `originalExternalId` | `string` | Opsional |
| `serviceCode` | `string` | Wajib |
| `transactionDate` | `string` | Opsional |
| `amount` | `*snap.Money` | Opsional |
| `merchantId` | `string` | Opsional |
| `subMerchantId` | `string` | Opsional |
| `externalStoreId` | `string` | Opsional |

**Response &mdash; `DirectDebitPaymentStatusResponse`**

DirectDebitPaymentStatusResponse adalah response body untuk Direct Debit Payment Status. `latestTransactionStatus` satu-satunya field Wajib di luar envelope.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `originalPartnerReferenceNo` | `string` | Opsional |
| `originalReferenceNo` | `string` | Opsional |
| `originalExternalId` | `string` | Opsional |
| `serviceCode` | `string` | Opsional |
| `transactionDate` | `string` | Opsional |
| `amount` | `*snap.Money` | Opsional |
| `approvalCode` | `string` | Opsional |
| `latestTransactionStatus` | `string` | Wajib |
| `transactionStatusDesc` | `string` | Opsional |
| `originalResponseCode` | `string` | Opsional |
| `originalResponseMessage` | `string` | Opsional |
| `sessionId` | `string` | Opsional |
| `requestId` | `string` | Opsional |
| `refundHistory` | `[]DirectDebitRefundHistoryItem` | Opsional |
| `transAmount` | `*snap.Money` | Opsional |
| `feeAmount` | `*snap.Money` | Opsional |
| `paidTime` | `string` | Opsional |

{{< details title="DirectDebitRefundHistoryItem fields" >}}
DirectDebitRefundHistoryItem adalah satu entri dalam array `refundHistory[]` pada response — sebuah refund yang pernah terjadi pada pembayaran ini. `refundStatus` bernilai salah satu dari `00`, `03`, atau `06`.

| Field | Type | Presence |
|---|---|---|
| `refundNo` | `string` | Opsional |
| `partnerRefundNo` | `string` | Wajib |
| `refundAmount` | `*snap.Money` | Opsional |
| `refundStatus` | `string` | Wajib |
| `refundDate` | `string` | Opsional |
| `reason` | `string` | Opsional |
{{< /details >}}


---

### `DirectDebitPaymentCancel`

DirectDebitPaymentCancel memanggil endpoint SNAP Direct Debit Payment Cancel (Service Code 57, HTTP POST). Isi `hb` dengan semua field kecuali `Body` — `DirectDebitPaymentCancel` melakukan marshal request itu sendiri.

Operasi ini tidak idempotent dan package ini tidak melakukan retry. Bila memanggil ulang setelah gagal atau timeout, gunakan `X-EXTERNAL-ID` yang sama, karena deteksi duplikat di server mengacu pada header itu.

```go
func DirectDebitPaymentCancel(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req DirectDebitPaymentCancelRequest) (DirectDebitPaymentCancelResponse, error)
```

**Request &mdash; `DirectDebitPaymentCancelRequest`**

DirectDebitPaymentCancelRequest adalah request body untuk Direct Debit Payment Cancel. `originalPartnerReferenceNo` satu-satunya field Wajib.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | Wajib |
| `originalReferenceNo` | `string` | Opsional |
| `approvalCode` | `string` | Opsional |
| `originalExternalId` | `string` | Opsional |
| `merchantId` | `string` | Opsional |
| `subMerchantId` | `string` | Opsional |
| `reason` | `string` | Opsional |
| `externalStoreId` | `string` | Opsional |
| `amount` | `*snap.Money` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

**Response &mdash; `DirectDebitPaymentCancelResponse`**

DirectDebitPaymentCancelResponse adalah response body untuk Direct Debit Payment Cancel. `originalReferenceNo` dan `cancelTime` bersifat Kondisional — hanya muncul saat berhasil.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `originalPartnerReferenceNo` | `string` | Opsional |
| `originalReferenceNo` | `string` | Opsional |
| `originalExternalId` | `string` | Opsional |
| `cancelTime` | `string` | Opsional |
| `transactionDate` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |


---

### `DirectDebitPaymentRefund`

DirectDebitPaymentRefund memanggil endpoint SNAP Direct Debit Payment Refund (Service Code 58, HTTP POST). Isi `hb` dengan semua field kecuali `Body` — `DirectDebitPaymentRefund` melakukan marshal request itu sendiri.

Operasi ini tidak idempotent dan package ini tidak melakukan retry. Bila memanggil ulang setelah gagal atau timeout, gunakan `X-EXTERNAL-ID` yang sama, karena deteksi duplikat di server mengacu pada header itu.

```go
func DirectDebitPaymentRefund(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req DirectDebitPaymentRefundRequest) (DirectDebitPaymentRefundResponse, error)
```

**Request &mdash; `DirectDebitPaymentRefundRequest`**

DirectDebitPaymentRefundRequest adalah request body untuk Direct Debit Payment Refund. `originalPartnerReferenceNo` dan `partnerRefundNo` bersifat Wajib.

| Field | Type | Presence |
|---|---|---|
| `merchantId` | `string` | Opsional |
| `subMerchantId` | `string` | Opsional |
| `originalPartnerReferenceNo` | `string` | Wajib |
| `originalReferenceNo` | `string` | Opsional |
| `originalExternalId` | `string` | Opsional |
| `partnerRefundNo` | `string` | Wajib |
| `refundAmount` | `*snap.Money` | Opsional |
| `externalStoreId` | `string` | Opsional |
| `reason` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

**Response &mdash; `DirectDebitPaymentRefundResponse`**

DirectDebitPaymentRefundResponse adalah response body untuk Direct Debit Payment Refund. `originalReferenceNo` bersifat Kondisional — hanya muncul saat berhasil. `refundNo`, `partnerRefundNo`, dan `refundTime` bersifat Wajib.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `originalPartnerReferenceNo` | `string` | Opsional |
| `originalReferenceNo` | `string` | Opsional |
| `originalExternalId` | `string` | Opsional |
| `partnerTrxId` | `string` | Opsional |
| `refundNo` | `string` | Wajib |
| `partnerRefundNo` | `string` | Wajib |
| `refundAmount` | `*snap.Money` | Opsional |
| `refundTime` | `string` | Wajib |
| `additionalInfo` | `json.RawMessage` | Opsional |

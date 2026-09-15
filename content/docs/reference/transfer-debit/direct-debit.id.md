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
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `bankCardToken` | `string` | <span class="badge-optional">Opsional</span> |
| `chargeToken` | `string` | <span class="badge-optional">Opsional</span> |
| `otp` | `string` | <span class="badge-optional">Opsional</span> |
| `otpTrxCode` | `string` | <span class="badge-optional">Opsional</span> |
| `merchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `terminalId` | `string` | <span class="badge-optional">Opsional</span> |
| `journeyId` | `string` | <span class="badge-optional">Opsional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `urlParams` | `[]DirectDebitPaymentURLParam` | <span class="badge-optional">Opsional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Opsional</span> |
| `validUpTo` | `string` | <span class="badge-optional">Opsional</span> |
| `pointOfInitiation` | `string` | <span class="badge-optional">Opsional</span> |
| `feeType` | `string` | <span class="badge-optional">Opsional</span> |
| `disabledPayMethods` | `string` | <span class="badge-optional">Opsional</span> |
| `payOptionDetails` | `[]DirectDebitPayOptionDetail` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

{{< details title="DirectDebitPaymentURLParam fields" >}}
DirectDebitPaymentURLParam adalah satu entri dalam array `urlParams[]` pada request — sebuah URL redirect dan cara memakainya. `isDeeplink` adalah flag `"Y"`/`"N"`.

| Field | Type | Presence |
|---|---|---|
| `url` | `string` | <span class="badge-mandatory">Wajib</span> |
| `type` | `string` | <span class="badge-mandatory">Wajib</span> |
| `isDeeplink` | `string` | <span class="badge-mandatory">Wajib</span> |
{{< /details >}}

{{< details title="DirectDebitPayOptionDetail fields" >}}
DirectDebitPayOptionDetail adalah satu entri dalam array `payOptionDetails[]` pada request, mendeskripsikan satu metode pembayaran yang tersedia.

| Field | Type | Presence |
|---|---|---|
| `payMethod` | `string` | <span class="badge-mandatory">Wajib</span> |
| `payOption` | `string` | <span class="badge-mandatory">Wajib</span> |
| `transAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `feeAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `cardToken` | `string` | <span class="badge-optional">Opsional</span> |
| `merchantToken` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
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
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `approvalCode` | `string` | <span class="badge-optional">Opsional</span> |
| `appRedirectUrl` | `string` | <span class="badge-optional">Opsional</span> |
| `webRedirectUrl` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |


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
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Opsional</span> |
| `merchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `latestTransactionStatus` | `string` | <span class="badge-mandatory">Wajib</span> |
| `transactionStatusDesc` | `string` | <span class="badge-optional">Opsional</span> |
| `createdTime` | `string` | <span class="badge-optional">Opsional</span> |
| `finishedTime` | `string` | <span class="badge-optional">Opsional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Handler Anda membalas dengan &mdash; `DirectDebitPaymentNotificationResponse`**

DirectDebitPaymentNotificationResponse punya satu field di luar envelope, `approvalCode`, dan sifatnya Opsional.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `approvalCode` | `string` | <span class="badge-optional">Opsional</span> |


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
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Opsional</span> |
| `serviceCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `transactionDate` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `merchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `DirectDebitPaymentStatusResponse`**

DirectDebitPaymentStatusResponse adalah response body untuk Direct Debit Payment Status. `latestTransactionStatus` satu-satunya field Wajib di luar envelope.

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
| `approvalCode` | `string` | <span class="badge-optional">Opsional</span> |
| `latestTransactionStatus` | `string` | <span class="badge-mandatory">Wajib</span> |
| `transactionStatusDesc` | `string` | <span class="badge-optional">Opsional</span> |
| `originalResponseCode` | `string` | <span class="badge-optional">Opsional</span> |
| `originalResponseMessage` | `string` | <span class="badge-optional">Opsional</span> |
| `sessionId` | `string` | <span class="badge-optional">Opsional</span> |
| `requestId` | `string` | <span class="badge-optional">Opsional</span> |
| `refundHistory` | `[]DirectDebitRefundHistoryItem` | <span class="badge-optional">Opsional</span> |
| `transAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `feeAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `paidTime` | `string` | <span class="badge-optional">Opsional</span> |

{{< details title="DirectDebitRefundHistoryItem fields" >}}
DirectDebitRefundHistoryItem adalah satu entri dalam array `refundHistory[]` pada response — sebuah refund yang pernah terjadi pada pembayaran ini. `refundStatus` bernilai salah satu dari `00`, `03`, atau `06`.

| Field | Type | Presence |
|---|---|---|
| `refundNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerRefundNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `refundAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `refundStatus` | `string` | <span class="badge-mandatory">Wajib</span> |
| `refundDate` | `string` | <span class="badge-optional">Opsional</span> |
| `reason` | `string` | <span class="badge-optional">Opsional</span> |
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
| `originalPartnerReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `approvalCode` | `string` | <span class="badge-optional">Opsional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Opsional</span> |
| `merchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `reason` | `string` | <span class="badge-optional">Opsional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `DirectDebitPaymentCancelResponse`**

DirectDebitPaymentCancelResponse adalah response body untuk Direct Debit Payment Cancel. `originalReferenceNo` dan `cancelTime` bersifat Kondisional — hanya muncul saat berhasil.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Opsional</span> |
| `cancelTime` | `string` | <span class="badge-optional">Opsional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |


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
| `merchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerRefundNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `refundAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Opsional</span> |
| `reason` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `DirectDebitPaymentRefundResponse`**

DirectDebitPaymentRefundResponse adalah response body untuk Direct Debit Payment Refund. `originalReferenceNo` bersifat Kondisional — hanya muncul saat berhasil. `refundNo`, `partnerRefundNo`, dan `refundTime` bersifat Wajib.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerTrxId` | `string` | <span class="badge-optional">Opsional</span> |
| `refundNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `partnerRefundNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `refundAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `refundTime` | `string` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

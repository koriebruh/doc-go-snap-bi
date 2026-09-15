---
weight: 2
title: "CPM"
description: "QR Customer-Presented-Mode (pelanggan menampilkan QR, merchant yang scan): generate, bayar, query, batal, refund; hasil pembayaran juga datang sebagai notifikasi masuk."
---

## CPM

QR Customer-Presented-Mode (pelanggan menampilkan QR, merchant yang scan): generate, bayar, query, batal, refund; hasil pembayaran juga datang sebagai notifikasi masuk.

```go
resp, err := transferdebit.CPMPayment(ctx, transport, hb, transferdebit.CPMPaymentRequest{
	PartnerReferenceNo: "2020102900000000000001",
	QRContent: "...",
	MerchantID: "...",
})
if err != nil {
	// errors.Is(err, snap.ErrBadRequest), snap.ErrUnauthorized, etc.
}
```

### `CPMGenerateQR`

CPMGenerateQR memanggil endpoint SNAP Generate QR CPM (Service Code 59, HTTP POST). Isi `hb` dengan semua field kecuali `Body` — `CPMGenerateQR` melakukan marshal request itu sendiri dan memakai byte yang sama persis untuk signing maupun body di wire.

Operasi ini tidak idempotent dan package ini tidak melakukan retry. Bila memanggil ulang setelah gagal atau timeout, gunakan `X-EXTERNAL-ID` yang sama, karena deteksi duplikat di server mengacu pada header itu.

```go
func CPMGenerateQR(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req CPMGenerateQRRequest) (CPMGenerateQRResponse, error)
```

**Request &mdash; `CPMGenerateQRRequest`**

CPMGenerateQRRequest adalah request body untuk Generate QR CPM. `partnerTrxDate` satu-satunya field Wajib.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `userAccessToken` | `string` | <span class="badge-optional">Opsional</span> |
| `merchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerTrxDate` | `string` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `CPMGenerateQRResponse`**

CPMGenerateQRResponse adalah response body untuk Generate QR CPM. `expiryTime` adalah satu-satunya field Wajib lainnya; `qrContent`/`qrUrl` sama-sama Opsional biasa (tidak ada aturan salah-satu-di-antaranya).

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `qrContent` | `string` | <span class="badge-optional">Opsional</span> |
| `qrUrl` | `string` | <span class="badge-optional">Opsional</span> |
| `expiryTime` | `string` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |


---

### `CPMPayment`

CPMPayment memanggil endpoint SNAP CPM Payment (Service Code 60, HTTP POST). Isi `hb` dengan semua field kecuali `Body` — `CPMPayment` melakukan marshal request itu sendiri.

Operasi ini tidak idempotent dan package ini tidak melakukan retry. Bila memanggil ulang setelah gagal atau timeout, gunakan `X-EXTERNAL-ID` yang sama, karena deteksi duplikat di server mengacu pada header itu.

```go
func CPMPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req CPMPaymentRequest) (CPMPaymentResponse, error)
```

**Request &mdash; `CPMPaymentRequest`**

CPMPaymentRequest adalah request body untuk CPM Payment. `partnerReferenceNo`, `qrContent`, dan `merchantId` bersifat Wajib.

`items` tidak punya skema tetap di standar, jadi tipenya `json.RawMessage` — sama seperti `additionalInfo` dan field lain yang memang tidak ditentukan bentuknya.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `qrContent` | `string` | <span class="badge-mandatory">Wajib</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `feeAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `merchantId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `title` | `string` | <span class="badge-optional">Opsional</span> |
| `expiryTime` | `string` | <span class="badge-optional">Opsional</span> |
| `items` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Opsional</span> |
| `merchantName` | `string` | <span class="badge-optional">Opsional</span> |
| `merchantLocation` | `string` | <span class="badge-optional">Opsional</span> |
| `acquirerName` | `string` | <span class="badge-optional">Opsional</span> |
| `terminalId` | `string` | <span class="badge-optional">Opsional</span> |
| `scannerInfo` | `*CPMPaymentScannerInfo` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

{{< details title="CPMPaymentScannerInfo fields" >}}
CPMPaymentScannerInfo adalah objek opsional `scannerInfo` yang mendeskripsikan perangkat yang men-scan QR. Keempat field-nya Opsional.

| Field | Type | Presence |
|---|---|---|
| `deviceId` | `string` | <span class="badge-optional">Opsional</span> |
| `deviceVersion` | `string` | <span class="badge-optional">Opsional</span> |
| `deviceModel` | `string` | <span class="badge-optional">Opsional</span> |
| `deviceIp` | `string` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

**Response &mdash; `CPMPaymentResponse`**

CPMPaymentResponse adalah response body untuk CPM Payment. `referenceNo` bersifat Kondisional — hanya muncul saat berhasil. Tidak ada field lain yang Wajib.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |


---

### `CPM Payment Notification`

{{< callout type="info" >}}
Hanya masuk (inbound) &mdash; package ini tidak memanggil endpoint untuk hal ini. Partner/switcher yang mengirim POST ke URL callback **Anda**; unmarshal body ke `CPMPaymentNotificationRequest` setelah memverifikasinya dengan `snap.ServerVerifier` (lihat [Verifying inbound requests](/id/docs/concepts/webhooks/)), lalu balas dengan bentuk di bawah.
{{< /callout >}}

**Diterima &mdash; `CPMPaymentNotificationRequest`**

CPMPaymentNotificationRequest adalah request body untuk Payment Notification (Service Code 79) — callback settlement yang diterima PJP, bukan panggilan yang dilakukan package ini. Buat HTTP handler Anda sendiri untuk path ini, autentikasi panggilan masuknya dengan `ServerVerifier.VerifyTransactionRequest`, lalu `json.Unmarshal` body ke tipe ini.

`merchantId` dan `latestTransactionStatus` bersifat Wajib; field lainnya Opsional.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `merchantId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `latestTransactionStatus` | `string` | <span class="badge-mandatory">Wajib</span> |
| `transactionStatusDesc` | `string` | <span class="badge-optional">Opsional</span> |
| `customerNumber` | `string` | <span class="badge-optional">Opsional</span> |
| `accountType` | `string` | <span class="badge-optional">Opsional</span> |
| `destinationNumber` | `string` | <span class="badge-optional">Opsional</span> |
| `destinationAccountName` | `string` | <span class="badge-optional">Opsional</span> |
| `sessionId` | `string` | <span class="badge-optional">Opsional</span> |
| `bankCode` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Handler Anda membalas dengan &mdash; `CPMPaymentNotificationResponse`**

CPMPaymentNotificationResponse hanya berisi envelope — cuma `responseCode` dan `responseMessage`, tidak ada field lain.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |


---

### `CPMQueryPayment`

CPMQueryPayment memanggil endpoint SNAP Query Payment (Service Code 61, HTTP POST) untuk mengecek status pembayaran CPM sebelumnya. Isi `hb` dengan semua field kecuali `Body` — `CPMQueryPayment` melakukan marshal request itu sendiri. Ini pencarian read-only, aman untuk diulang kapan saja.

```go
func CPMQueryPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req CPMQueryPaymentRequest) (CPMQueryPaymentResponse, error)
```

**Request &mdash; `CPMQueryPaymentRequest`**

CPMQueryPaymentRequest adalah request body untuk Query Payment. Tidak ada field Wajib — cari berdasarkan reference, merchant, atau store ID mana pun yang Anda punya.

| Field | Type | Presence |
|---|---|---|
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Opsional</span> |
| `merchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `CPMQueryPaymentResponse`**

CPMQueryPaymentResponse adalah response body untuk Query Payment. `latestTransactionStatus` dan `paidTime` bersifat Wajib; `originalReferenceNo` Kondisional — hanya muncul saat berhasil.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Opsional</span> |
| `title` | `string` | <span class="badge-optional">Opsional</span> |
| `latestTransactionStatus` | `string` | <span class="badge-mandatory">Wajib</span> |
| `transactionStatusDesc` | `string` | <span class="badge-optional">Opsional</span> |
| `paidTime` | `string` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |


---

### `CPMCancelPayment`

CPMCancelPayment memanggil endpoint SNAP Cancel Payment (Service Code 62, HTTP POST). Isi `hb` dengan semua field kecuali `Body` — `CPMCancelPayment` melakukan marshal request itu sendiri.

Operasi ini tidak idempotent dan package ini tidak melakukan retry. Bila memanggil ulang setelah gagal atau timeout, gunakan `X-EXTERNAL-ID` yang sama, karena deteksi duplikat di server mengacu pada header itu.

```go
func CPMCancelPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req CPMCancelPaymentRequest) (CPMCancelPaymentResponse, error)
```

**Request &mdash; `CPMCancelPaymentRequest`**

CPMCancelPaymentRequest adalah request body untuk Cancel Payment. `originalPartnerReferenceNo` satu-satunya field Wajib.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Opsional</span> |
| `merchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `reason` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `CPMCancelPaymentResponse`**

CPMCancelPaymentResponse adalah response body untuk Cancel Payment. `originalReferenceNo` dan `cancelTime` bersifat Kondisional — hanya muncul saat berhasil.

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

### `CPMRefundPayment`

CPMRefundPayment memanggil endpoint SNAP Refund Payment (Service Code 80, HTTP POST). Isi `hb` dengan semua field kecuali `Body` — `CPMRefundPayment` melakukan marshal request itu sendiri.

Operasi ini tidak idempotent dan package ini tidak melakukan retry. Bila memanggil ulang setelah gagal atau timeout, gunakan `X-EXTERNAL-ID` yang sama, karena deteksi duplikat di server mengacu pada header itu.

```go
func CPMRefundPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req CPMRefundPaymentRequest) (CPMRefundPaymentResponse, error)
```

**Request &mdash; `CPMRefundPaymentRequest`**

CPMRefundPaymentRequest adalah request body untuk Refund Payment. `originalPartnerReferenceNo` dan `partnerRefundNo` bersifat Wajib.

| Field | Type | Presence |
|---|---|---|
| `merchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Opsional</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerRefundNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `refundAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `reason` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `CPMRefundPaymentResponse`**

CPMRefundPaymentResponse adalah response body untuk Refund Payment. `refundNo` dan `refundTime` bersifat Wajib; `partnerRefundNo` di sini Opsional (berbeda dari response Direct Debit Payment Refund, di mana field itu Wajib).

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Opsional</span> |
| `refundNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `partnerRefundNo` | `string` | <span class="badge-optional">Opsional</span> |
| `refundAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `refundTime` | `string` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

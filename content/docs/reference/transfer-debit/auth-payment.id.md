---
weight: 1
title: "Auth Payment"
description: "Alur otorisasi/capture/void/refund gaya kartu: tahan dana dengan AuthPayment, lalu capture, void, atau refund; setiap operasi tulis punya query pasangannya."
---

## Auth Payment

Alur otorisasi/capture/void/refund gaya kartu: tahan dana dengan AuthPayment, lalu capture, void, atau refund; setiap operasi tulis punya query pasangannya.

```go
resp, err := transferdebit.AuthPayment(ctx, transport, hb, transferdebit.AuthPaymentRequest{
	PartnerReferenceNo: "2020102900000000000001",
	MerchantID: "...",
	Title: "...",
})
if err != nil {
	// errors.Is(err, snap.ErrBadRequest), snap.ErrUnauthorized, etc.
}
```

### `AuthPayment`

AuthPayment memanggil endpoint SNAP Auth Payment (Service Code 63, HTTP POST). Fungsi ini menahan dana tanpa menagihnya. Isi `hb` dengan semua field kecuali `Body` — `AuthPayment` melakukan marshal request itu sendiri dan memakai byte yang sama persis untuk signing maupun body di wire.

Operasi ini tidak idempotent dan package ini tidak melakukan retry. Bila memanggil ulang setelah gagal atau timeout, gunakan `X-EXTERNAL-ID` yang sama, karena deteksi duplikat di server mengacu pada header itu.

```go
func AuthPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AuthPaymentRequest) (AuthPaymentResponse, error)
```

**Request &mdash; `AuthPaymentRequest`**

AuthPaymentRequest adalah request body untuk Auth Payment. Fungsi ini menahan dana — Capture (65) nanti menagih sebagian atau seluruhnya, Void (67) melepas bagian yang tidak dicapture.

`items` (daftar barang yang dibeli) tidak punya skema tetap di standar, jadi tipenya `json.RawMessage` — sama seperti `additionalInfo` dan field lain yang memang tidak ditentukan bentuknya oleh standar.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `merchantId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `feeType` | `string` | <span class="badge-optional">Opsional</span> |
| `mcc` | `string` | <span class="badge-optional">Opsional</span> |
| `productCode` | `string` | <span class="badge-optional">Opsional</span> |
| `title` | `string` | <span class="badge-mandatory">Wajib</span> |
| `items` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `AuthPaymentResponse`**

AuthPaymentResponse adalah response body untuk Auth Payment. `referenceNo` bersifat Kondisional — hanya muncul saat berhasil.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `snap.Money` | <span class="badge-mandatory">Wajib</span> |
| `paidTime` | `string` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |


---

### `AuthPaymentQuery`

AuthPaymentQuery memanggil endpoint SNAP Payment Query (Service Code 64, HTTP POST) untuk mengecek status Auth Payment sebelumnya. Isi `hb` dengan semua field kecuali `Body` — `AuthPaymentQuery` melakukan marshal request itu sendiri.

```go
func AuthPaymentQuery(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AuthPaymentQueryRequest) (AuthPaymentQueryResponse, error)
```

**Request &mdash; `AuthPaymentQueryRequest`**

AuthPaymentQueryRequest adalah request body untuk Payment Query. Tidak ada field Wajib — cari berdasarkan reference, merchant, atau store ID mana pun yang Anda punya.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `merchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `AuthPaymentQueryResponse`**

AuthPaymentQueryResponse adalah response body untuk Payment Query. `paidTime` dan `latestTransactionStatus` bersifat Wajib.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `paidTime` | `string` | <span class="badge-mandatory">Wajib</span> |
| `latestTransactionStatus` | `string` | <span class="badge-mandatory">Wajib</span> |
| `transactionStatusDesc` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |


---

### `AuthCapture`

AuthCapture memanggil endpoint SNAP Capture (Service Code 65, HTTP POST). Isi `hb` dengan semua field kecuali `Body` — `AuthCapture` melakukan marshal request itu sendiri.

Operasi ini tidak idempotent dan package ini tidak melakukan retry. Bila memanggil ulang setelah gagal atau timeout, gunakan `X-EXTERNAL-ID` yang sama, karena deteksi duplikat di server mengacu pada header itu.

```go
func AuthCapture(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AuthCaptureRequest) (AuthCaptureResponse, error)
```

**Request &mdash; `AuthCaptureRequest`**

AuthCaptureRequest adalah request body untuk Capture. Fungsi ini menagih sebagian atau seluruh dana yang ditahan oleh Auth Payment (63) — panggil beberapa kali untuk capture parsial.

`lastCapture` adalah string berisi `"true"`/`"false"`, bukan boolean asli — set untuk menandai capture terakhir dalam rangkaian capture parsial.

| Field | Type | Presence |
|---|---|---|
| `originalReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `merchantId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerCaptureNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `captureAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `title` | `string` | <span class="badge-mandatory">Wajib</span> |
| `lastCapture` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `AuthCaptureResponse`**

AuthCaptureResponse adalah response body untuk Capture. `captureNo` dan `captureTime` bersifat Kondisional — hanya muncul saat berhasil.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerCaptureNo` | `string` | <span class="badge-optional">Opsional</span> |
| `captureNo` | `string` | <span class="badge-optional">Opsional</span> |
| `captureAmount` | `snap.Money` | <span class="badge-mandatory">Wajib</span> |
| `captureTime` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |


---

### `AuthCaptureQuery`

AuthCaptureQuery memanggil endpoint SNAP Capture Query (Service Code 66, HTTP POST) untuk mengecek status Capture sebelumnya. Isi `hb` dengan semua field kecuali `Body` — `AuthCaptureQuery` melakukan marshal request itu sendiri.

```go
func AuthCaptureQuery(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AuthCaptureQueryRequest) (AuthCaptureQueryResponse, error)
```

**Request &mdash; `AuthCaptureQueryRequest`**

AuthCaptureQueryRequest adalah request body untuk Capture Query (Service Code 66). `originalReferenceNo`, `merchantId`, dan `partnerCaptureNo` bersifat Wajib.

| Field | Type | Presence |
|---|---|---|
| `originalReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `merchantId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `captureNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerCaptureNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `AuthCaptureQueryResponse`**

AuthCaptureQueryResponse adalah response body untuk Capture Query. `captureAmount` dan `partnerCaptureNo` bersifat Wajib di sini — berbeda dari response Capture sendiri, di mana `partnerCaptureNo` Opsional. `latestCaptureStatus` bernilai salah satu dari `INIT`, `SUCCESS`, atau `FAILED`.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `captureNo` | `string` | <span class="badge-optional">Opsional</span> |
| `captureAmount` | `snap.Money` | <span class="badge-mandatory">Wajib</span> |
| `captureTime` | `string` | <span class="badge-optional">Opsional</span> |
| `latestCaptureStatus` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerCaptureNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |


---

### `AuthVoid`

AuthVoid memanggil endpoint SNAP Void (Service Code 67, HTTP POST). Isi `hb` dengan semua field kecuali `Body` — `AuthVoid` melakukan marshal request itu sendiri.

Operasi ini tidak idempotent dan package ini tidak melakukan retry. Bila memanggil ulang setelah gagal atau timeout, gunakan `X-EXTERNAL-ID` yang sama, karena deteksi duplikat di server mengacu pada header itu.

```go
func AuthVoid(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AuthVoidRequest) (AuthVoidResponse, error)
```

**Request &mdash; `AuthVoidRequest`**

AuthVoidRequest adalah request body untuk Void. Fungsi ini melepas dana hasil hold dari Auth Payment (63) yang belum dicapture.

`voidRemainingAmount` adalah string berisi `"true"`/`"false"`, konvensi yang sama dengan `lastCapture` pada Capture.

| Field | Type | Presence |
|---|---|---|
| `originalReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `merchantId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `voidAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `partnerVoidNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `voidRemainingAmount` | `string` | <span class="badge-optional">Opsional</span> |
| `reason` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `AuthVoidResponse`**

AuthVoidResponse adalah response body untuk Void. `voidNo` dan `voidTime` bersifat Kondisional — hanya muncul saat berhasil.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `voidNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerVoidNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `voidAmount` | `snap.Money` | <span class="badge-mandatory">Wajib</span> |
| `voidTime` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |


---

### `AuthVoidQuery`

AuthVoidQuery memanggil endpoint SNAP Void Query (Service Code 68, HTTP POST) untuk mengecek status Void sebelumnya. Isi `hb` dengan semua field kecuali `Body` — `AuthVoidQuery` melakukan marshal request itu sendiri.

```go
func AuthVoidQuery(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AuthVoidQueryRequest) (AuthVoidQueryResponse, error)
```

**Request &mdash; `AuthVoidQueryRequest`**

AuthVoidQueryRequest adalah request body untuk Void Query. `originalReferenceNo`, `merchantId`, dan `partnerVoidNo` bersifat Wajib.

| Field | Type | Presence |
|---|---|---|
| `originalReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `merchantId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `voidNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerVoidNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `AuthVoidQueryResponse`**

AuthVoidQueryResponse adalah response body untuk Void Query. `voidAmount` bersifat Wajib; `partnerVoidNo` di sini Opsional — berbeda dari response Void sendiri, di mana field itu Wajib. `latestVoidStatus` bernilai salah satu dari `INIT`, `SUCCESS`, atau `FAILED`.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `voidNo` | `string` | <span class="badge-optional">Opsional</span> |
| `voidAmount` | `snap.Money` | <span class="badge-mandatory">Wajib</span> |
| `voidTime` | `string` | <span class="badge-optional">Opsional</span> |
| `latestVoidStatus` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerVoidNo` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |


---

### `AuthRefund`

AuthRefund memanggil endpoint SNAP Refund (Service Code 69, HTTP POST). Isi `hb` dengan semua field kecuali `Body` — `AuthRefund` melakukan marshal request itu sendiri.

Operasi ini tidak idempotent dan package ini tidak melakukan retry. Bila memanggil ulang setelah gagal atau timeout, gunakan `X-EXTERNAL-ID` yang sama, karena deteksi duplikat di server mengacu pada header itu.

```go
func AuthRefund(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AuthRefundRequest) (AuthRefundResponse, error)
```

**Request &mdash; `AuthRefundRequest`**

AuthRefundRequest adalah request body untuk Refund. Fungsi ini membalikkan dana yang sudah dicapture oleh Auth Capture (65).

`originalCaptureNo` bersifat Kondisional — tidak seperti kebanyakan field Kondisional di package ini, field ini wajib diisi justru saat transaksi *asal*-nya gagal, bukan saat berhasil.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerRefundNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `merchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `originalCaptureNo` | `string` | <span class="badge-optional">Opsional</span> |
| `refundAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Opsional</span> |
| `reason` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `AuthRefundResponse`**

AuthRefundResponse adalah response body untuk Refund. `refundNo` dan `refundTime` bersifat Wajib; `partnerRefundNo` Opsional.

`originalCaptureNo` dan `originalReferenceNo` sama-sama Kondisional tapi pemicunya berkebalikan: `originalCaptureNo` muncul saat transaksi gagal, `originalReferenceNo` saat berhasil.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originalCaptureNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerRefundNo` | `string` | <span class="badge-optional">Opsional</span> |
| `refundNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `refundAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `refundTime` | `string` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

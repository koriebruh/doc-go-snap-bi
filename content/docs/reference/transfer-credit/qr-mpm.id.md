---
weight: 8
title: "QR / MPM"
description: "Merchant-Presented-Mode QR: generate, decode, bayar host-to-host, query, batalkan, dan refund — plus alur One-Time-Token yang dipakai ApplyOTT."
---

## QR / MPM

Merchant-Presented-Mode QR: generate, decode, bayar host-to-host, query, batalkan, dan refund — plus alur One-Time-Token yang dipakai `ApplyOTT`.

```go
resp, err := transfercredit.GenerateQRMPM(ctx, transport, hb, transfercredit.GenerateQRMPMRequest{
	PartnerReferenceNo: "2020102900000000000001",
	Amount: &snap.Money{Value: "500000.00", Currency: "IDR"},
	FeeAmount: &snap.Money{Value: "500000.00", Currency: "IDR"},
})
if err != nil {
	// errors.Is(err, snap.ErrBadRequest), snap.ErrUnauthorized, etc.
}
```

### `GenerateQRMPM`

Memanggil endpoint SNAP Generate QR MPM (Service Code 47, path .../{version}/qr/qr-mpm-generate, HTTP POST — tanpa override method). `hb` harus sudah membawa setiap field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body`, yang diatur sendiri oleh `GenerateQRMPM` agar byte hasil marshal yang sama persis dipakai untuk signing dan wire body.

Tidak idempotent dan package ini tidak melakukan retry. Bila memanggil ulang setelah gagal/timeout, gunakan `X-EXTERNAL-ID` yang sama — deteksi duplikat di server mengacu pada header ini.

```go
func GenerateQRMPM(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req GenerateQRMPMRequest) (GenerateQRMPMResponse, error)
```

**Request &mdash; `GenerateQRMPMRequest`**

Semua field Opsional — tidak ada field yang didokumentasikan Wajib.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | Opsional |
| `amount` | `*snap.Money` | Opsional |
| `feeAmount` | `*snap.Money` | Opsional |
| `merchantId` | `string` | Opsional |
| `subMerchantId` | `string` | Opsional |
| `storeId` | `string` | Opsional |
| `terminalId` | `string` | Opsional |
| `validityPeriod` | `string` | Opsional |

**Response &mdash; `GenerateQRMPMResponse`**

`QRContent`, `QRURL`, dan `QRImage` membentuk kondisi one-of-three yang tidak bisa diekspresikan sistem tipe: menurut standar, "jika qrContent kosong, qrUrl atau qrImage harus diisi." Ketiganya dimodelkan Opsional di sini — pemanggil harus mengecek mana yang benar-benar terisi.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `qrContent` | `string` | Opsional |
| `qrUrl` | `string` | Opsional |
| `redirectUrl` | `string` | Opsional |
| `merchantName` | `string` | Opsional |
| `storeId` | `string` | Opsional |
| `terminalId` | `string` | Opsional |


---

### `ApplyOTT`

Memanggil endpoint SNAP Payment Redirect - Apply OTT (Service Code 49, path .../{version}/qr/apply-ott, HTTP POST — tanpa override method). `hb` harus sudah membawa setiap field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body`, yang diatur sendiri oleh `ApplyOTT` agar byte hasil marshal yang sama persis dipakai untuk signing dan wire body.

Tidak idempotent dan package ini tidak melakukan retry. Bila memanggil ulang setelah gagal/timeout, gunakan `X-EXTERNAL-ID` yang sama — deteksi duplikat di server mengacu pada header ini.

```go
func ApplyOTT(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req ApplyOTTRequest) (ApplyOTTResponse, error)
```

Endpoint ini tidak punya request body bertipe selain parameter panggilan di atas.

**Response &mdash; `ApplyOTTResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `userResources` | `[]ApplyOTTUserResource` | Wajib |

{{< details title="Field ApplyOTTUserResource" >}}
Satu entri dalam array `userResources` pada `ApplyOTTResponse`. Meski nama field-nya sama dengan request, ini bentuk yang berbeda (objek, bukan string biasa).

| Field | Type | Presence |
|---|---|---|
| `resourceType` | `string` | Wajib |
| `value` | `string` | Wajib |
{{< /details >}}


---

### `DecodeQRMPM`

Memanggil endpoint SNAP Decode QR MPM (Service Code 48, path .../{version}/qr/qr-mpm-decode, HTTP POST — tanpa override method). `hb` harus sudah membawa setiap field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body`, yang diatur sendiri oleh `DecodeQRMPM` agar byte hasil marshal yang sama persis dipakai untuk signing dan wire body.

Ini decode read-only; tidak seperti `GenerateQRMPM`, tidak ada catatan non-idempotency.

```go
func DecodeQRMPM(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req DecodeQRMPMRequest) (DecodeQRMPMResponse, error)
```

**Request &mdash; `DecodeQRMPMRequest`**

`QRContent` dan `ScanTime` wajib.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | Opsional |
| `qrContent` | `string` | Wajib |
| `amount` | `*snap.Money` | Opsional |
| `merchantId` | `string` | Opsional |
| `subMerchantId` | `string` | Opsional |
| `scanTime` | `string` | Wajib |

**Response &mdash; `DecodeQRMPMResponse`**

`ReferenceNo` dan `RedirectURL` sama-sama dimodelkan Opsional — kondisi wajib dari standar untuk keduanya saling kontradiktif, jadi tidak ada yang dipaksakan di sini.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `referenceNo` | `string` | Opsional |
| `redirectUrl` | `string` | Opsional |
| `merchantName` | `string` | Opsional |
| `merchantCategory` | `string` | Opsional |
| `merchantLocation` | `string` | Opsional |
| `merchantInfos` | `[]MPMMerchantInfo` | Wajib |
| `transactionAmount` | `*snap.Money` | Opsional |
| `feeAmount` | `*snap.Money` | Opsional |

{{< details title="Field MPMMerchantInfo" >}}
Satu entri dalam array `merchantInfos` pada `DecodeQRMPMResponse`.

`MerchantPAN` didokumentasikan numerik tapi dikirim sebagai string berkutip di wire — bentuk ambigu, jadi diketik `json.RawMessage`, bukan `string` atau tipe numerik.

| Field | Type | Presence |
|---|---|---|
| `merchantPAN` | `json.RawMessage` | Wajib |
| `acquirerName` | `string` | Wajib |
{{< /details >}}


---

### `QRMPMPaymentH2H`

Memanggil endpoint SNAP Payment - Host to Host (Service Code 50, path .../{version}/qr/qr-mpm-payment, HTTP POST — tanpa override method). `hb` harus sudah membawa setiap field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body`, yang diatur sendiri oleh `QRMPMPaymentH2H` agar byte hasil marshal yang sama persis dipakai untuk signing dan wire body.

Tidak idempotent dan package ini tidak melakukan retry. Bila memanggil ulang setelah gagal/timeout, gunakan `X-EXTERNAL-ID` yang sama — deteksi duplikat di server mengacu pada header ini.

```go
func QRMPMPaymentH2H(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req QRMPMPaymentH2HRequest) (QRMPMPaymentH2HResponse, error)
```

**Request &mdash; `QRMPMPaymentH2HRequest`**

`PartnerReferenceNo` wajib; field lain Opsional.

`VerificationID` juga muncul di response dengan nama sama tapi batas panjang terdokumentasi berbeda — keduanya sama-sama `string` biasa di Go, package ini tidak menegakkan batas panjang.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | Wajib |
| `merchantId` | `string` | Opsional |
| `subMerchantId` | `string` | Opsional |
| `amount` | `*snap.Money` | Opsional |
| `feeAmount` | `*snap.Money` | Opsional |
| `otp` | `string` | Opsional |
| `verificationId` | `string` | Opsional |

**Response &mdash; `QRMPMPaymentH2HResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `referenceNo` | `string` | Opsional |
| `transactionDate` | `string` | Opsional |
| `verificationId` | `string` | Opsional |


---

### `QR MPM Payment Notification`

{{< callout type="info" >}}
Hanya masuk (inbound) &mdash; package ini tidak memanggil endpoint untuk ini. Partner/switcher yang POST ke callback URL **Anda**; unmarshal body ke `QRMPMPaymentNotificationRequest` setelah memverifikasinya dengan `snap.ServerVerifier` (lihat [Verifying inbound requests](/id/docs/concepts/webhooks/)), lalu balas dengan bentuk di bawah.
{{< /callout >}}

**Diterima &mdash; `QRMPMPaymentNotificationRequest`**

Ini adalah callback settlement yang diterima PJP, bukan panggilan dari package ini — buat HTTP handler sendiri untuk path ini, autentikasi dengan `ServerVerifier.VerifyTransactionRequest`, lalu `json.Unmarshal` body ke tipe ini. `OriginalReferenceNo` dan `LatestTransactionStatus` wajib; field lain Opsional.

| Field | Type | Presence |
|---|---|---|
| `originalReferenceNo` | `string` | Wajib |
| `originalPartnerReferenceNo` | `string` | Opsional |
| `latestTransactionStatus` | `string` | Wajib |
| `customerNumber` | `string` | Opsional |
| `accountType` | `string` | Opsional |
| `destinationNumber` | `string` | Opsional |
| `destinationAccountName` | `string` | Opsional |
| `amount` | `*snap.Money` | Opsional |
| `sessionId` | `string` | Opsional |
| `bankCode` | `string` | Opsional |
| `externalStoreId` | `string` | Opsional |

**Handler Anda membalas dengan &mdash; `QRMPMPaymentNotificationResponse`**

Tidak ada field lain selain envelope standar `responseCode`/`responseMessage`.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |


---

### `QRMPMQueryPayment`

Memanggil endpoint SNAP Query Payment (Service Code 51, path .../{version}/qr/qr-mpm-query, HTTP POST — tanpa override method). `hb` harus sudah membawa setiap field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body`, yang diatur sendiri oleh `QRMPMQueryPayment` agar byte hasil marshal yang sama persis dipakai untuk signing dan wire body.

Query status read-only; tidak ada catatan non-idempotency, sama seperti `TransactionStatusInquiryBank`.

```go
func QRMPMQueryPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req QRMPMQueryPaymentRequest) (QRMPMQueryPaymentResponse, error)
```

**Request &mdash; `QRMPMQueryPaymentRequest`**

Field dasar yang sama dengan [`TransactionStatusInquiryBankRequest`](/id/docs/reference/transfer-credit/transaction-status/), ditambah `MerchantID`, `SubMerchantID`, dan `ExternalStoreID`. `ServiceCode` satu-satunya field wajib.

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
| `additionalInfo` | `json.RawMessage` | Opsional |

**Response &mdash; `QRMPMQueryPaymentResponse`**

Field yang sama dengan [`TransactionStatusInquiryBankResponse`](/id/docs/reference/transfer-credit/transaction-status/), ditambah `PaidTime` dan `TerminalID`.

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
| `beneficiaryAccountNo` | `string` | Wajib |
| `beneficiaryBankCode` | `string` | Opsional |
| `previousResponseCode` | `string` | Opsional |
| `referenceNumber` | `string` | Wajib |
| `sourceAccountNo` | `string` | Wajib |
| `transactionId` | `string` | Opsional |
| `latestTransactionStatus` | `string` | Wajib |
| `transactionStatusDesc` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |
| `paidTime` | `string` | Opsional |
| `terminalId` | `string` | Opsional |


---

### `QRMPMCancelPayment`

Memanggil endpoint SNAP Cancel Payment (Service Code 77, path .../{version}/qr/qr-mpm-cancel, HTTP POST — tanpa override method). `hb` harus sudah membawa setiap field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body`, yang diatur sendiri oleh `QRMPMCancelPayment` agar byte hasil marshal yang sama persis dipakai untuk signing dan wire body.

Tidak idempotent dan package ini tidak melakukan retry. Bila memanggil ulang setelah gagal/timeout, gunakan `X-EXTERNAL-ID` yang sama — deteksi duplikat di server mengacu pada header ini.

```go
func QRMPMCancelPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req QRMPMCancelPaymentRequest) (QRMPMCancelPaymentResponse, error)
```

**Request &mdash; `QRMPMCancelPaymentRequest`**

Berbeda dari endpoint pola originalX lain di package ini, baris ini tidak mendokumentasikan field `serviceCode` dan ketiga field originalX-nya Opsional — `MerchantID` dan `Reason` satu-satunya yang wajib.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | Opsional |
| `originalReferenceNo` | `string` | Opsional |
| `originalExternalId` | `string` | Opsional |
| `merchantId` | `string` | Wajib |
| `subMerchantId` | `string` | Opsional |
| `externalStoreId` | `string` | Opsional |
| `reason` | `string` | Wajib |
| `amount` | `*snap.Money` | Opsional |

**Response &mdash; `QRMPMCancelPaymentResponse`**

`CancelTime` Kondisional (dimodelkan Opsional, sesuai penanganan standar package ini — lihat [Core Conventions](/id/docs/concepts/conventions/)); `TransactionDate` Opsional.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `cancelTime` | `string` | Opsional |
| `transactionDate` | `string` | Opsional |


---

### `QRMPMRefundPayment`

Memanggil endpoint SNAP Refund Payment (Service Code 78, path .../{version}/qr/qr-mpm-refund, HTTP POST — tanpa override method). `hb` harus sudah membawa setiap field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body`, yang diatur sendiri oleh `QRMPMRefundPayment` agar byte hasil marshal yang sama persis dipakai untuk signing dan wire body.

Tidak idempotent dan package ini tidak melakukan retry. Bila memanggil ulang setelah gagal/timeout, gunakan `X-EXTERNAL-ID` yang sama — deteksi duplikat di server mengacu pada header ini.

```go
func QRMPMRefundPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req QRMPMRefundPaymentRequest) (QRMPMRefundPaymentResponse, error)
```

**Request &mdash; `QRMPMRefundPaymentRequest`**

`OriginalPartnerReferenceNo` dan `PartnerRefundNo` wajib; field lain Opsional.

| Field | Type | Presence |
|---|---|---|
| `merchantId` | `string` | Opsional |
| `subMerchantId` | `string` | Opsional |
| `externalStoreId` | `string` | Opsional |
| `originalPartnerReferenceNo` | `string` | Wajib |
| `originalReferenceNo` | `string` | Opsional |
| `originalExternalId` | `string` | Opsional |
| `partnerRefundNo` | `string` | Wajib |
| `refundAmount` | `*snap.Money` | Opsional |
| `reason` | `string` | Opsional |

**Response &mdash; `QRMPMRefundPaymentResponse`**

`RefundNo` dan `RefundTime` wajib; `PartnerRefundNo` dan `RefundAmount` Opsional (dikembalikan lagi, tidak dijamin selalu ada).

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `refundNo` | `string` | Wajib |
| `partnerRefundNo` | `string` | Opsional |
| `refundAmount` | `*snap.Money` | Opsional |
| `refundTime` | `string` | Wajib |

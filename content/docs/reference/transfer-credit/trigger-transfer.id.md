---
weight: 2
title: "Trigger Transfer"
description: "Kumpulan pemanggilan inti pemindahan dana: intrabank, interbank, bulk, request-for-payment, RTGS, dan SKNBI — tiap jalur real-time-gross atau bulk punya tipe notifikasi masuknya sendiri yang harus diterima layanan Anda."
---

## Trigger Transfer

Kumpulan pemanggilan inti pemindahan dana: intrabank, interbank, bulk, request-for-payment, RTGS, dan SKNBI — tiap jalur real-time-gross atau bulk punya tipe notifikasi masuknya sendiri yang harus diterima layanan Anda.

```go
resp, err := transfercredit.InterbankTransfer(ctx, transport, hb, transfercredit.InterbankTransferRequest{
	PartnerReferenceNo: "2020102900000000000001",
	Amount: snap.Money{Value: "500000.00", Currency: "IDR"},
	BeneficiaryAccountNo: "1234567890",
	BeneficiaryAccountName: "Jane Doe",
	BeneficiaryBankCode: "...",
	SourceAccountNo: "1234567890",
	TransactionDate: "2026-09-14T10:00:00+07:00",
})
if err != nil {
	// errors.Is(err, snap.ErrBadRequest), snap.ErrUnauthorized, etc.
}
```

### `IntrabankTransfer`

Memanggil endpoint SNAP Intrabank Transfer (Service Code 17, path .../{version}/transfer-intrabank). `hb` harus sudah diisi semua field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body` — fungsi ini yang mengisinya sendiri agar byte yang sama persis dipakai untuk signing maupun request di wire.

Tidak idempoten — tidak di-retry otomatis. Kalau me-retry request yang gagal/timeout, pakai `X-EXTERNAL-ID` yang sama; ID baru berisiko bikin transfer ganda.

```go
func IntrabankTransfer(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req IntrabankTransferRequest) (IntrabankTransferResponse, error)
```

**Request &mdash; `IntrabankTransferRequest`**

`PartnerReferenceNo`, `Amount`, `BeneficiaryAccountNo`, `SourceAccountNo`, dan `TransactionDate` wajib diisi. `OriginatorInfos` Kondisional.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | Wajib |
| `amount` | `snap.Money` | Wajib |
| `beneficiaryAccountNo` | `string` | Wajib |
| `beneficiaryEmail` | `string` | Opsional |
| `currency` | `string` | Opsional |
| `customerReference` | `string` | Opsional |
| `feeType` | `string` | Opsional |
| `remark` | `string` | Opsional |
| `sourceAccountNo` | `string` | Wajib |
| `transactionDate` | `string` | Wajib |
| `originatorInfos` | `[]TransferOriginatorInfo` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

{{< details title="TransferOriginatorInfo fields" >}}
Bentuk entri "originatorInfos[]" yang dipakai bersama di seluruh kelompok Trigger Transfer. Ketiga field bertipe String.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | Wajib |
| `originatorCustomerName` | `string` | Wajib |
| `originatorBankCode` | `string` | Wajib |
{{< /details >}}

**Response &mdash; `IntrabankTransferResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `referenceNo` | `string` | Opsional |
| `partnerReferenceNo` | `string` | Opsional |
| `amount` | `*snap.Money` | Opsional |
| `beneficiaryAccountNo` | `string` | Opsional |
| `currency` | `string` | Opsional |
| `customerReference` | `string` | Opsional |
| `sourceAccountNo` | `string` | Opsional |
| `transactionDate` | `string` | Opsional |
| `originatorInfos` | `[]TransferOriginatorInfo` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

{{< details title="TransferOriginatorInfo fields" >}}
Bentuk entri "originatorInfos[]" yang dipakai bersama di seluruh kelompok Trigger Transfer. Ketiga field bertipe String.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | Wajib |
| `originatorCustomerName` | `string` | Wajib |
| `originatorBankCode` | `string` | Wajib |
{{< /details >}}


---

### `InterbankTransfer`

Memanggil endpoint SNAP Interbank Transfer (Service Code 18, path .../{version}/transfer-interbank). `hb` harus sudah diisi semua field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body` — fungsi ini yang mengisinya sendiri agar byte yang sama persis dipakai untuk signing maupun request di wire.

Tidak idempoten — tidak di-retry otomatis. Kalau me-retry request yang gagal/timeout, pakai `X-EXTERNAL-ID` yang sama; ID baru berisiko bikin transfer ganda.

```go
func InterbankTransfer(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req InterbankTransferRequest) (InterbankTransferResponse, error)
```

**Request &mdash; `InterbankTransferRequest`**

`PartnerReferenceNo`, `Amount`, `BeneficiaryAccountNo`, `BeneficiaryAccountName`, `BeneficiaryBankCode`, `SourceAccountNo`, dan `TransactionDate` wajib diisi. `OriginatorInfos` Kondisional.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | Wajib |
| `amount` | `snap.Money` | Wajib |
| `beneficiaryAccountNo` | `string` | Wajib |
| `beneficiaryAccountName` | `string` | Wajib |
| `beneficiaryAddress` | `string` | Opsional |
| `beneficiaryBankCode` | `string` | Wajib |
| `beneficiaryBankName` | `string` | Opsional |
| `beneficiaryEmail` | `string` | Opsional |
| `currency` | `string` | Opsional |
| `customerReference` | `string` | Opsional |
| `feeType` | `string` | Opsional |
| `remark` | `string` | Opsional |
| `sourceAccountNo` | `string` | Wajib |
| `transactionDate` | `string` | Wajib |
| `originatorInfos` | `[]TransferOriginatorInfo` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

{{< details title="TransferOriginatorInfo fields" >}}
Bentuk entri "originatorInfos[]" yang dipakai bersama di seluruh kelompok Trigger Transfer. Ketiga field bertipe String.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | Wajib |
| `originatorCustomerName` | `string` | Wajib |
| `originatorBankCode` | `string` | Wajib |
{{< /details >}}

**Response &mdash; `InterbankTransferResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `referenceNo` | `string` | Opsional |
| `partnerReferenceNo` | `string` | Opsional |
| `amount` | `*snap.Money` | Opsional |
| `beneficiaryAccountNo` | `string` | Opsional |
| `currency` | `string` | Opsional |
| `customerReference` | `string` | Opsional |
| `sourceAccountNo` | `string` | Opsional |
| `transactionDate` | `string` | Opsional |
| `traceNo` | `string` | Opsional |
| `originatorInfos` | `[]TransferOriginatorInfo` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

{{< details title="TransferOriginatorInfo fields" >}}
Bentuk entri "originatorInfos[]" yang dipakai bersama di seluruh kelompok Trigger Transfer. Ketiga field bertipe String.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | Wajib |
| `originatorCustomerName` | `string` | Wajib |
| `originatorBankCode` | `string` | Wajib |
{{< /details >}}


---

### `InterbankBulkTransfer`

Memanggil endpoint SNAP Interbank Bulk Transfer (Service Code 20, path .../{version}/transfer-interbank-bulk). `hb` harus sudah diisi semua field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body` — fungsi ini yang mengisinya sendiri agar byte yang sama persis dipakai untuk signing maupun request di wire.

Tidak idempoten — tidak di-retry otomatis. Kalau me-retry request yang gagal/timeout, pakai `X-EXTERNAL-ID` yang sama; ID baru berisiko bikin bulk transfer ganda.

```go
func InterbankBulkTransfer(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req InterbankBulkTransferRequest) (InterbankBulkTransferResponse, error)
```

**Request &mdash; `InterbankBulkTransferRequest`**

`CustomerReference`, `SourceAccountNo`, `TransactionDate`, dan `BulkObject` wajib diisi.

| Field | Type | Presence |
|---|---|---|
| `partnerBulkId` | `string` | Opsional |
| `currency` | `string` | Opsional |
| `customerReference` | `string` | Wajib |
| `feeType` | `string` | Opsional |
| `remark` | `string` | Opsional |
| `sourceAccountNo` | `string` | Wajib |
| `transactionDate` | `string` | Wajib |
| `bulkObject` | `[]InterbankBulkTransferItem` | Wajib |
| `additionalInfo` | `json.RawMessage` | Opsional |

{{< details title="InterbankBulkTransferItem fields" >}}
Satu entri dalam array "bulkObject[]" pada request Interbank Bulk Transfer.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | Wajib |
| `bankCode` | `string` | Wajib |
| `beneficiaryAccountNo` | `string` | Wajib |
| `beneficiaryAccountName` | `string` | Wajib |
| `amount` | `snap.Money` | Wajib |
| `originatorInfos` | `[]TransferOriginatorInfo` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |
{{< /details >}}

{{< details title="TransferOriginatorInfo fields" >}}
Bentuk entri "originatorInfos[]" yang dipakai bersama di seluruh kelompok Trigger Transfer. Ketiga field bertipe String.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | Wajib |
| `originatorCustomerName` | `string` | Wajib |
| `originatorBankCode` | `string` | Wajib |
{{< /details >}}

**Response &mdash; `InterbankBulkTransferResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `bulkId` | `string` | Opsional |
| `partnerBulkId` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |


---

### `Interbank Bulk Transfer Notification`

{{< callout type="info" >}}
Hanya masuk (inbound) &mdash; package ini tidak memanggil endpoint untuk ini. Partner/switcher yang mengirim POST ke callback URL **Anda**; unmarshal body-nya ke `InterbankBulkTransferNotificationRequest` setelah diverifikasi dengan `snap.ServerVerifier` (lihat [Verifying inbound requests](/id/docs/concepts/webhooks/)), lalu balas dengan bentuk di bawah.
{{< /callout >}}

**Diterima &mdash; `InterbankBulkTransferNotificationRequest`**

Body callback settlement untuk API Interbank Bulk Transfer - Notification (Service Code 21, path .../{version}/transfer-interbank-bulk/notify). `bulkId`, `partnerBulkId`, dan `bulkObject` wajib diisi.

| Field | Type | Presence |
|---|---|---|
| `bulkId` | `string` | Wajib |
| `partnerBulkId` | `string` | Wajib |
| `bulkObject` | `[]InterbankBulkTransferNotificationItem` | Wajib |

{{< details title="InterbankBulkTransferNotificationItem fields" >}}
Satu entri dalam array "bulkObject[]" pada request Interbank Bulk Transfer - Notification — bentuk hasil settlement, berbeda dari bentuk instruksi transfer `InterbankBulkTransferItem`.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | Wajib |
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
{{< /details >}}

**Handler Anda membalas dengan &mdash; `InterbankBulkTransferNotificationResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `bulkId` | `string` | Opsional |
| `partnerBulkId` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |


---

### `RequestForPayment`

Memanggil endpoint SNAP Request for Payment (Service Code 19, path .../{version}/transfer-request-for-payment). `hb` harus sudah diisi semua field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body` — fungsi ini yang mengisinya sendiri agar byte yang sama persis dipakai untuk signing maupun request di wire.

Tidak idempoten — tidak di-retry otomatis. Kalau me-retry request yang gagal/timeout, pakai `X-EXTERNAL-ID` yang sama; ID baru berisiko bikin permintaan pembayaran ganda.

```go
func RequestForPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req RequestForPaymentRequest) (RequestForPaymentResponse, error)
```

**Request &mdash; `RequestForPaymentRequest`**

`PartnerReferenceNo`, `BankCode`, `BeneficiaryAccountNo`, `BeneficiaryAccountName`, `ExpiredDatetime`, `SourceAccountNo`, dan `SourceAccountName` wajib diisi.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | Wajib |
| `bankCode` | `string` | Wajib |
| `beneficiaryAccountNo` | `string` | Wajib |
| `beneficiaryAccountName` | `string` | Wajib |
| `remark` | `string` | Opsional |
| `expiredDatetime` | `string` | Wajib |
| `sourceAccountNo` | `string` | Wajib |
| `sourceAccountName` | `string` | Wajib |
| `currency` | `string` | Opsional |
| `amount` | `*snap.Money` | Opsional |
| `feeType` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

**Response &mdash; `RequestForPaymentResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `referenceNo` | `string` | Opsional |
| `partnerReferenceNo` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |


---

### `RTGSTransfer`

Memanggil endpoint SNAP Transfer RTGS (Service Code 22, path .../{version}/transfer-rtgs). `hb` harus sudah diisi semua field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body` — fungsi ini yang mengisinya sendiri agar byte yang sama persis dipakai untuk signing maupun request di wire.

Tidak idempoten — tidak di-retry otomatis. Kalau me-retry request yang gagal/timeout, pakai `X-EXTERNAL-ID` yang sama; ID baru berisiko bikin transfer ganda.

```go
func RTGSTransfer(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req RTGSTransferRequest) (RTGSTransferResponse, error)
```

**Request &mdash; `RTGSTransferRequest`**

`PartnerReferenceNo`, `Amount`, `BeneficiaryAccountNo`, `BeneficiaryAccountName`, `BeneficiaryBankCode`, `SourceAccountNo`, `TransactionDate`, `BeneficiaryCustomerResidence`, dan `BeneficiaryCustomerType` wajib diisi. `OriginatorInfos` Kondisional.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | Wajib |
| `amount` | `snap.Money` | Wajib |
| `beneficiaryAccountNo` | `string` | Wajib |
| `beneficiaryAccountName` | `string` | Wajib |
| `beneficiaryAddress` | `string` | Opsional |
| `beneficiaryBankCode` | `string` | Wajib |
| `beneficiaryBankName` | `string` | Opsional |
| `beneficiaryEmail` | `string` | Opsional |
| `currency` | `string` | Opsional |
| `customerReference` | `string` | Opsional |
| `feeType` | `string` | Opsional |
| `remark` | `string` | Opsional |
| `sourceAccountNo` | `string` | Wajib |
| `transactionDate` | `string` | Wajib |
| `beneficiaryCustomerResidence` | `string` | Wajib |
| `beneficiaryCustomerType` | `string` | Wajib |
| `kodepos` | `string` | Opsional |
| `receiverPhone` | `string` | Opsional |
| `senderCustomerResidence` | `string` | Opsional |
| `senderCustomerType` | `string` | Opsional |
| `senderPhone` | `string` | Opsional |
| `originatorInfos` | `[]TransferOriginatorInfo` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

{{< details title="TransferOriginatorInfo fields" >}}
Bentuk entri "originatorInfos[]" yang dipakai bersama di seluruh kelompok Trigger Transfer. Ketiga field bertipe String.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | Wajib |
| `originatorCustomerName` | `string` | Wajib |
| `originatorBankCode` | `string` | Wajib |
{{< /details >}}

**Response &mdash; `RTGSTransferResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `referenceNo` | `string` | Opsional |
| `partnerReferenceNo` | `string` | Opsional |
| `amount` | `*snap.Money` | Opsional |
| `beneficiaryAccountNo` | `string` | Opsional |
| `currency` | `string` | Opsional |
| `customerReference` | `string` | Opsional |
| `sourceAccountNo` | `string` | Opsional |
| `transactionDate` | `string` | Opsional |
| `traceNo` | `string` | Opsional |
| `transactionStatus` | `string` | Opsional |
| `transactionStatusDesc` | `string` | Opsional |
| `beneficiaryAccountType` | `string` | Opsional |
| `originatorInfos` | `[]TransferOriginatorInfo` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

{{< details title="TransferOriginatorInfo fields" >}}
Bentuk entri "originatorInfos[]" yang dipakai bersama di seluruh kelompok Trigger Transfer. Ketiga field bertipe String.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | Wajib |
| `originatorCustomerName` | `string` | Wajib |
| `originatorBankCode` | `string` | Wajib |
{{< /details >}}


---

### `RTGS Notification`

{{< callout type="info" >}}
Hanya masuk (inbound) &mdash; package ini tidak memanggil endpoint untuk ini. Partner/switcher yang mengirim POST ke callback URL **Anda**; unmarshal body-nya ke `RTGSNotificationRequest` setelah diverifikasi dengan `snap.ServerVerifier` (lihat [Verifying inbound requests](/id/docs/concepts/webhooks/)), lalu balas dengan bentuk di bawah.
{{< /callout >}}

**Diterima &mdash; `RTGSNotificationRequest`**

Body callback settlement untuk API RTGS - Notification (Service Code 76, path .../{version}/transfer-rtgs/notify). `latestTransactionStatus`, `beneficiaryAccountName`, `beneficiaryAccountNo`, `beneficiaryBankCode`, `sourceAccountNo`, dan `transactionDate` wajib diisi.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | Opsional |
| `originalReferenceNo` | `string` | Opsional |
| `originalExternalId` | `string` | Opsional |
| `latestTransactionStatus` | `string` | Wajib |
| `amount` | `*snap.Money` | Opsional |
| `beneficiaryAccountName` | `string` | Wajib |
| `beneficiaryAccountNo` | `string` | Wajib |
| `beneficiaryBankCode` | `string` | Wajib |
| `sourceAccountNo` | `string` | Wajib |
| `transactionDate` | `string` | Wajib |
| `additionalInfo` | `json.RawMessage` | Opsional |

**Handler Anda membalas dengan &mdash; `RTGSNotificationResponse`**

Hanya berisi envelope, tidak ada field lain.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |


---

### `SKNBITransfer`

Memanggil endpoint SNAP Transfer SKNBI (Service Code 23, path .../{version}/transfer-skn). `hb` harus sudah diisi semua field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body` — fungsi ini yang mengisinya sendiri agar byte yang sama persis dipakai untuk signing maupun request di wire.

Tidak idempoten — tidak di-retry otomatis. Kalau me-retry request yang gagal/timeout, pakai `X-EXTERNAL-ID` yang sama; ID baru berisiko bikin transfer ganda.

```go
func SKNBITransfer(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req SKNBITransferRequest) (SKNBITransferResponse, error)
```

**Request &mdash; `SKNBITransferRequest`**

Bentuknya sama dengan `RTGSTransferRequest`, hanya beda service code dan path. `partnerReferenceNo`, `amount`, `beneficiaryAccountNo`, `beneficiaryAccountName`, `beneficiaryBankCode`, `sourceAccountNo`, `transactionDate`, `beneficiaryCustomerResidence`, dan `beneficiaryCustomerType` wajib diisi. `originatorInfos` Kondisional.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | Wajib |
| `amount` | `snap.Money` | Wajib |
| `beneficiaryAccountNo` | `string` | Wajib |
| `beneficiaryAccountName` | `string` | Wajib |
| `beneficiaryAddress` | `string` | Opsional |
| `beneficiaryBankCode` | `string` | Wajib |
| `beneficiaryBankName` | `string` | Opsional |
| `beneficiaryEmail` | `string` | Opsional |
| `currency` | `string` | Opsional |
| `customerReference` | `string` | Opsional |
| `feeType` | `string` | Opsional |
| `remark` | `string` | Opsional |
| `sourceAccountNo` | `string` | Wajib |
| `transactionDate` | `string` | Wajib |
| `beneficiaryCustomerResidence` | `string` | Wajib |
| `beneficiaryCustomerType` | `string` | Wajib |
| `kodepos` | `string` | Opsional |
| `receiverPhone` | `string` | Opsional |
| `senderCustomerResidence` | `string` | Opsional |
| `senderCustomerType` | `string` | Opsional |
| `senderPhone` | `string` | Opsional |
| `originatorInfos` | `[]TransferOriginatorInfo` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

{{< details title="TransferOriginatorInfo fields" >}}
Bentuk entri "originatorInfos[]" yang dipakai bersama di seluruh kelompok Trigger Transfer. Ketiga field bertipe String.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | Wajib |
| `originatorCustomerName` | `string` | Wajib |
| `originatorBankCode` | `string` | Wajib |
{{< /details >}}

**Response &mdash; `SKNBITransferResponse`**

Bentuknya sama dengan `RTGSTransferResponse`.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `referenceNo` | `string` | Opsional |
| `partnerReferenceNo` | `string` | Opsional |
| `amount` | `*snap.Money` | Opsional |
| `beneficiaryAccountNo` | `string` | Opsional |
| `currency` | `string` | Opsional |
| `customerReference` | `string` | Opsional |
| `sourceAccountNo` | `string` | Opsional |
| `transactionDate` | `string` | Opsional |
| `traceNo` | `string` | Opsional |
| `transactionStatus` | `string` | Opsional |
| `transactionStatusDesc` | `string` | Opsional |
| `beneficiaryAccountType` | `string` | Opsional |
| `originatorInfos` | `[]TransferOriginatorInfo` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

{{< details title="TransferOriginatorInfo fields" >}}
Bentuk entri "originatorInfos[]" yang dipakai bersama di seluruh kelompok Trigger Transfer. Ketiga field bertipe String.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | Wajib |
| `originatorCustomerName` | `string` | Wajib |
| `originatorBankCode` | `string` | Wajib |
{{< /details >}}


---

### `SKNBI Notification`

{{< callout type="info" >}}
Hanya masuk (inbound) &mdash; package ini tidak memanggil endpoint untuk ini. Partner/switcher yang mengirim POST ke callback URL **Anda**; unmarshal body-nya ke `SKNBINotificationRequest` setelah diverifikasi dengan `snap.ServerVerifier` (lihat [Verifying inbound requests](/id/docs/concepts/webhooks/)), lalu balas dengan bentuk di bawah.
{{< /callout >}}

**Diterima &mdash; `SKNBINotificationRequest`**

Body callback settlement untuk API SKNBI - Notification (Service Code 75, path .../{version}/transfer-skn/notify) — bentuknya sama dengan `RTGSNotificationRequest`. `latestTransactionStatus`, `beneficiaryAccountName`, `beneficiaryAccountNo`, `beneficiaryBankCode`, `sourceAccountNo`, dan `transactionDate` wajib diisi.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | Opsional |
| `originalReferenceNo` | `string` | Opsional |
| `originalExternalId` | `string` | Opsional |
| `latestTransactionStatus` | `string` | Wajib |
| `amount` | `*snap.Money` | Opsional |
| `beneficiaryAccountName` | `string` | Wajib |
| `beneficiaryAccountNo` | `string` | Wajib |
| `beneficiaryBankCode` | `string` | Wajib |
| `sourceAccountNo` | `string` | Wajib |
| `transactionDate` | `string` | Wajib |
| `additionalInfo` | `json.RawMessage` | Opsional |

**Handler Anda membalas dengan &mdash; `SKNBINotificationResponse`**

Bentuknya sama dengan `RTGSNotificationResponse`: hanya berisi envelope, tidak ada field lain.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |

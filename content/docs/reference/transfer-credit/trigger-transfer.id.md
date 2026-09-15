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
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `amount` | `snap.Money` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryEmail` | `string` | <span class="badge-optional">Opsional</span> |
| `currency` | `string` | <span class="badge-optional">Opsional</span> |
| `customerReference` | `string` | <span class="badge-optional">Opsional</span> |
| `feeType` | `string` | <span class="badge-optional">Opsional</span> |
| `remark` | `string` | <span class="badge-optional">Opsional</span> |
| `sourceAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `transactionDate` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originatorInfos` | `[]TransferOriginatorInfo` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

{{< details title="TransferOriginatorInfo fields" >}}
Bentuk entri "originatorInfos[]" yang dipakai bersama di seluruh kelompok Trigger Transfer. Ketiga field bertipe String.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originatorCustomerName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originatorBankCode` | `string` | <span class="badge-mandatory">Wajib</span> |
{{< /details >}}

**Response &mdash; `IntrabankTransferResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `currency` | `string` | <span class="badge-optional">Opsional</span> |
| `customerReference` | `string` | <span class="badge-optional">Opsional</span> |
| `sourceAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Opsional</span> |
| `originatorInfos` | `[]TransferOriginatorInfo` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

{{< details title="TransferOriginatorInfo fields" >}}
Bentuk entri "originatorInfos[]" yang dipakai bersama di seluruh kelompok Trigger Transfer. Ketiga field bertipe String.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originatorCustomerName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originatorBankCode` | `string` | <span class="badge-mandatory">Wajib</span> |
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
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `amount` | `snap.Money` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryAccountName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryAddress` | `string` | <span class="badge-optional">Opsional</span> |
| `beneficiaryBankCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryBankName` | `string` | <span class="badge-optional">Opsional</span> |
| `beneficiaryEmail` | `string` | <span class="badge-optional">Opsional</span> |
| `currency` | `string` | <span class="badge-optional">Opsional</span> |
| `customerReference` | `string` | <span class="badge-optional">Opsional</span> |
| `feeType` | `string` | <span class="badge-optional">Opsional</span> |
| `remark` | `string` | <span class="badge-optional">Opsional</span> |
| `sourceAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `transactionDate` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originatorInfos` | `[]TransferOriginatorInfo` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

{{< details title="TransferOriginatorInfo fields" >}}
Bentuk entri "originatorInfos[]" yang dipakai bersama di seluruh kelompok Trigger Transfer. Ketiga field bertipe String.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originatorCustomerName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originatorBankCode` | `string` | <span class="badge-mandatory">Wajib</span> |
{{< /details >}}

**Response &mdash; `InterbankTransferResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `currency` | `string` | <span class="badge-optional">Opsional</span> |
| `customerReference` | `string` | <span class="badge-optional">Opsional</span> |
| `sourceAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Opsional</span> |
| `traceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originatorInfos` | `[]TransferOriginatorInfo` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

{{< details title="TransferOriginatorInfo fields" >}}
Bentuk entri "originatorInfos[]" yang dipakai bersama di seluruh kelompok Trigger Transfer. Ketiga field bertipe String.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originatorCustomerName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originatorBankCode` | `string` | <span class="badge-mandatory">Wajib</span> |
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
| `partnerBulkId` | `string` | <span class="badge-optional">Opsional</span> |
| `currency` | `string` | <span class="badge-optional">Opsional</span> |
| `customerReference` | `string` | <span class="badge-mandatory">Wajib</span> |
| `feeType` | `string` | <span class="badge-optional">Opsional</span> |
| `remark` | `string` | <span class="badge-optional">Opsional</span> |
| `sourceAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `transactionDate` | `string` | <span class="badge-mandatory">Wajib</span> |
| `bulkObject` | `[]InterbankBulkTransferItem` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

{{< details title="InterbankBulkTransferItem fields" >}}
Satu entri dalam array "bulkObject[]" pada request Interbank Bulk Transfer.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `bankCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryAccountName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `amount` | `snap.Money` | <span class="badge-mandatory">Wajib</span> |
| `originatorInfos` | `[]TransferOriginatorInfo` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

{{< details title="TransferOriginatorInfo fields" >}}
Bentuk entri "originatorInfos[]" yang dipakai bersama di seluruh kelompok Trigger Transfer. Ketiga field bertipe String.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originatorCustomerName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originatorBankCode` | `string` | <span class="badge-mandatory">Wajib</span> |
{{< /details >}}

**Response &mdash; `InterbankBulkTransferResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `bulkId` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerBulkId` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |


---

### `Interbank Bulk Transfer Notification`

{{< callout type="info" >}}
Hanya masuk (inbound) &mdash; package ini tidak memanggil endpoint untuk ini. Partner/switcher yang mengirim POST ke callback URL **Anda**; unmarshal body-nya ke `InterbankBulkTransferNotificationRequest` setelah diverifikasi dengan `snap.ServerVerifier` (lihat [Verifying inbound requests](/id/docs/concepts/webhooks/)), lalu balas dengan bentuk di bawah.
{{< /callout >}}

**Diterima &mdash; `InterbankBulkTransferNotificationRequest`**

Body callback settlement untuk API Interbank Bulk Transfer - Notification (Service Code 21, path .../{version}/transfer-interbank-bulk/notify). `bulkId`, `partnerBulkId`, dan `bulkObject` wajib diisi.

| Field | Type | Presence |
|---|---|---|
| `bulkId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `partnerBulkId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `bulkObject` | `[]InterbankBulkTransferNotificationItem` | <span class="badge-mandatory">Wajib</span> |

{{< details title="InterbankBulkTransferNotificationItem fields" >}}
Satu entri dalam array "bulkObject[]" pada request Interbank Bulk Transfer - Notification — bentuk hasil settlement, berbeda dari bentuk instruksi transfer `InterbankBulkTransferItem`.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
{{< /details >}}

**Handler Anda membalas dengan &mdash; `InterbankBulkTransferNotificationResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `bulkId` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerBulkId` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |


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
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `bankCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryAccountName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `remark` | `string` | <span class="badge-optional">Opsional</span> |
| `expiredDatetime` | `string` | <span class="badge-mandatory">Wajib</span> |
| `sourceAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `sourceAccountName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `currency` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `feeType` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `RequestForPaymentResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |


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
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `amount` | `snap.Money` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryAccountName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryAddress` | `string` | <span class="badge-optional">Opsional</span> |
| `beneficiaryBankCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryBankName` | `string` | <span class="badge-optional">Opsional</span> |
| `beneficiaryEmail` | `string` | <span class="badge-optional">Opsional</span> |
| `currency` | `string` | <span class="badge-optional">Opsional</span> |
| `customerReference` | `string` | <span class="badge-optional">Opsional</span> |
| `feeType` | `string` | <span class="badge-optional">Opsional</span> |
| `remark` | `string` | <span class="badge-optional">Opsional</span> |
| `sourceAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `transactionDate` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryCustomerResidence` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryCustomerType` | `string` | <span class="badge-mandatory">Wajib</span> |
| `kodepos` | `string` | <span class="badge-optional">Opsional</span> |
| `receiverPhone` | `string` | <span class="badge-optional">Opsional</span> |
| `senderCustomerResidence` | `string` | <span class="badge-optional">Opsional</span> |
| `senderCustomerType` | `string` | <span class="badge-optional">Opsional</span> |
| `senderPhone` | `string` | <span class="badge-optional">Opsional</span> |
| `originatorInfos` | `[]TransferOriginatorInfo` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

{{< details title="TransferOriginatorInfo fields" >}}
Bentuk entri "originatorInfos[]" yang dipakai bersama di seluruh kelompok Trigger Transfer. Ketiga field bertipe String.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originatorCustomerName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originatorBankCode` | `string` | <span class="badge-mandatory">Wajib</span> |
{{< /details >}}

**Response &mdash; `RTGSTransferResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `currency` | `string` | <span class="badge-optional">Opsional</span> |
| `customerReference` | `string` | <span class="badge-optional">Opsional</span> |
| `sourceAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Opsional</span> |
| `traceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `transactionStatus` | `string` | <span class="badge-optional">Opsional</span> |
| `transactionStatusDesc` | `string` | <span class="badge-optional">Opsional</span> |
| `beneficiaryAccountType` | `string` | <span class="badge-optional">Opsional</span> |
| `originatorInfos` | `[]TransferOriginatorInfo` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

{{< details title="TransferOriginatorInfo fields" >}}
Bentuk entri "originatorInfos[]" yang dipakai bersama di seluruh kelompok Trigger Transfer. Ketiga field bertipe String.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originatorCustomerName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originatorBankCode` | `string` | <span class="badge-mandatory">Wajib</span> |
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
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Opsional</span> |
| `latestTransactionStatus` | `string` | <span class="badge-mandatory">Wajib</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `beneficiaryAccountName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryBankCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `sourceAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `transactionDate` | `string` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Handler Anda membalas dengan &mdash; `RTGSNotificationResponse`**

Hanya berisi envelope, tidak ada field lain.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |


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
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `amount` | `snap.Money` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryAccountName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryAddress` | `string` | <span class="badge-optional">Opsional</span> |
| `beneficiaryBankCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryBankName` | `string` | <span class="badge-optional">Opsional</span> |
| `beneficiaryEmail` | `string` | <span class="badge-optional">Opsional</span> |
| `currency` | `string` | <span class="badge-optional">Opsional</span> |
| `customerReference` | `string` | <span class="badge-optional">Opsional</span> |
| `feeType` | `string` | <span class="badge-optional">Opsional</span> |
| `remark` | `string` | <span class="badge-optional">Opsional</span> |
| `sourceAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `transactionDate` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryCustomerResidence` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryCustomerType` | `string` | <span class="badge-mandatory">Wajib</span> |
| `kodepos` | `string` | <span class="badge-optional">Opsional</span> |
| `receiverPhone` | `string` | <span class="badge-optional">Opsional</span> |
| `senderCustomerResidence` | `string` | <span class="badge-optional">Opsional</span> |
| `senderCustomerType` | `string` | <span class="badge-optional">Opsional</span> |
| `senderPhone` | `string` | <span class="badge-optional">Opsional</span> |
| `originatorInfos` | `[]TransferOriginatorInfo` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

{{< details title="TransferOriginatorInfo fields" >}}
Bentuk entri "originatorInfos[]" yang dipakai bersama di seluruh kelompok Trigger Transfer. Ketiga field bertipe String.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originatorCustomerName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originatorBankCode` | `string` | <span class="badge-mandatory">Wajib</span> |
{{< /details >}}

**Response &mdash; `SKNBITransferResponse`**

Bentuknya sama dengan `RTGSTransferResponse`.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `currency` | `string` | <span class="badge-optional">Opsional</span> |
| `customerReference` | `string` | <span class="badge-optional">Opsional</span> |
| `sourceAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Opsional</span> |
| `traceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `transactionStatus` | `string` | <span class="badge-optional">Opsional</span> |
| `transactionStatusDesc` | `string` | <span class="badge-optional">Opsional</span> |
| `beneficiaryAccountType` | `string` | <span class="badge-optional">Opsional</span> |
| `originatorInfos` | `[]TransferOriginatorInfo` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

{{< details title="TransferOriginatorInfo fields" >}}
Bentuk entri "originatorInfos[]" yang dipakai bersama di seluruh kelompok Trigger Transfer. Ketiga field bertipe String.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originatorCustomerName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originatorBankCode` | `string` | <span class="badge-mandatory">Wajib</span> |
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
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Opsional</span> |
| `latestTransactionStatus` | `string` | <span class="badge-mandatory">Wajib</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `beneficiaryAccountName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryBankCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `sourceAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `transactionDate` | `string` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Handler Anda membalas dengan &mdash; `SKNBINotificationResponse`**

Bentuknya sama dengan `RTGSNotificationResponse`: hanya berisi envelope, tidak ada field lain.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |

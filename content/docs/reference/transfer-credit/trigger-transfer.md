---
weight: 2
title: "Trigger Transfer"
description: "The core money-movement calls: intrabank, interbank, bulk, request-for-payment, RTGS and SKNBI — each real-time-gross or bulk rail has its own inbound notification type your service must accept."
---

## Trigger Transfer

The core money-movement calls: intrabank, interbank, bulk, request-for-payment, RTGS and SKNBI — each real-time-gross or bulk rail has its own inbound notification type your service must accept.

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

IntrabankTransfer calls the SNAP Intrabank Transfer endpoint (Service Code 17, path .../{version}/transfer-intrabank). hb must already carry every field snap.HeaderBuilder needs except Body, which IntrabankTransfer sets itself so the exact marshaled bytes are used for both signing and the wire body.

Not idempotent — retries aren't automatic. If you retry a failed or timed-out call, reuse the same X-EXTERNAL-ID; a fresh one risks a duplicate transfer.

```go
func IntrabankTransfer(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req IntrabankTransferRequest) (IntrabankTransferResponse, error)
```

**Request &mdash; `IntrabankTransferRequest`**

IntrabankTransferRequest is the request body for API Intrabank Transfer (Service Code 17). PartnerReferenceNo, Amount, BeneficiaryAccountNo, SourceAccountNo, and TransactionDate are mandatory per the Guides tab. OriginatorInfos is Conditional.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `amount` | `snap.Money` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryEmail` | `string` | <span class="badge-optional">Optional</span> |
| `currency` | `string` | <span class="badge-optional">Optional</span> |
| `customerReference` | `string` | <span class="badge-optional">Optional</span> |
| `feeType` | `string` | <span class="badge-optional">Optional</span> |
| `remark` | `string` | <span class="badge-optional">Optional</span> |
| `sourceAccountNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `transactionDate` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originatorInfos` | `[]TransferOriginatorInfo` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

{{< details title="TransferOriginatorInfo fields" >}}
TransferOriginatorInfo is the shared "originatorInfos[]" entry used by the Trigger Transfer sub-group. All three fields are String per the Guides tab.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originatorCustomerName` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originatorBankCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
{{< /details >}}

**Response &mdash; `IntrabankTransferResponse`**

IntrabankTransferResponse is the response body for API Intrabank Transfer.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-optional">Optional</span> |
| `currency` | `string` | <span class="badge-optional">Optional</span> |
| `customerReference` | `string` | <span class="badge-optional">Optional</span> |
| `sourceAccountNo` | `string` | <span class="badge-optional">Optional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Optional</span> |
| `originatorInfos` | `[]TransferOriginatorInfo` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

{{< details title="TransferOriginatorInfo fields" >}}
TransferOriginatorInfo is the shared "originatorInfos[]" entry used by the Trigger Transfer sub-group. All three fields are String per the Guides tab.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originatorCustomerName` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originatorBankCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
{{< /details >}}


---

### `InterbankTransfer`

InterbankTransfer calls the SNAP Interbank Transfer endpoint (Service Code 18, path .../{version}/transfer-interbank). hb must already carry every field snap.HeaderBuilder needs except Body, which InterbankTransfer sets itself so the exact marshaled bytes are used for both signing and the wire body.

Not idempotent — retries aren't automatic. If you retry a failed or timed-out call, reuse the same X-EXTERNAL-ID; a fresh one risks a duplicate transfer.

```go
func InterbankTransfer(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req InterbankTransferRequest) (InterbankTransferResponse, error)
```

**Request &mdash; `InterbankTransferRequest`**

InterbankTransferRequest is the request body for API Interbank Transfer (Service Code 18). PartnerReferenceNo, Amount, BeneficiaryAccountNo, BeneficiaryAccountName, BeneficiaryBankCode, SourceAccountNo, and TransactionDate are mandatory per the Guides tab. OriginatorInfos is Conditional.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `amount` | `snap.Money` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryAccountName` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryAddress` | `string` | <span class="badge-optional">Optional</span> |
| `beneficiaryBankCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryBankName` | `string` | <span class="badge-optional">Optional</span> |
| `beneficiaryEmail` | `string` | <span class="badge-optional">Optional</span> |
| `currency` | `string` | <span class="badge-optional">Optional</span> |
| `customerReference` | `string` | <span class="badge-optional">Optional</span> |
| `feeType` | `string` | <span class="badge-optional">Optional</span> |
| `remark` | `string` | <span class="badge-optional">Optional</span> |
| `sourceAccountNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `transactionDate` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originatorInfos` | `[]TransferOriginatorInfo` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

{{< details title="TransferOriginatorInfo fields" >}}
TransferOriginatorInfo is the shared "originatorInfos[]" entry used by the Trigger Transfer sub-group. All three fields are String per the Guides tab.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originatorCustomerName` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originatorBankCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
{{< /details >}}

**Response &mdash; `InterbankTransferResponse`**

InterbankTransferResponse is the response body for API Interbank Transfer.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-optional">Optional</span> |
| `currency` | `string` | <span class="badge-optional">Optional</span> |
| `customerReference` | `string` | <span class="badge-optional">Optional</span> |
| `sourceAccountNo` | `string` | <span class="badge-optional">Optional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Optional</span> |
| `traceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originatorInfos` | `[]TransferOriginatorInfo` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

{{< details title="TransferOriginatorInfo fields" >}}
TransferOriginatorInfo is the shared "originatorInfos[]" entry used by the Trigger Transfer sub-group. All three fields are String per the Guides tab.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originatorCustomerName` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originatorBankCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
{{< /details >}}


---

### `InterbankBulkTransfer`

InterbankBulkTransfer calls the SNAP Interbank Bulk Transfer endpoint (Service Code 20, path .../{version}/transfer-interbank-bulk). hb must already carry every field snap.HeaderBuilder needs except Body, which InterbankBulkTransfer sets itself so the exact marshaled bytes are used for both signing and the wire body.

Not idempotent — retries aren't automatic. If you retry a failed or timed-out call, reuse the same X-EXTERNAL-ID; a fresh one risks a duplicate bulk transfer.

```go
func InterbankBulkTransfer(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req InterbankBulkTransferRequest) (InterbankBulkTransferResponse, error)
```

**Request &mdash; `InterbankBulkTransferRequest`**

InterbankBulkTransferRequest is the request body for API Interbank Bulk Transfer (Service Code 20). CustomerReference, SourceAccountNo, TransactionDate, and BulkObject are mandatory per the Guides tab.

| Field | Type | Presence |
|---|---|---|
| `partnerBulkId` | `string` | <span class="badge-optional">Optional</span> |
| `currency` | `string` | <span class="badge-optional">Optional</span> |
| `customerReference` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `feeType` | `string` | <span class="badge-optional">Optional</span> |
| `remark` | `string` | <span class="badge-optional">Optional</span> |
| `sourceAccountNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `transactionDate` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `bulkObject` | `[]InterbankBulkTransferItem` | <span class="badge-mandatory">Mandatory</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

{{< details title="InterbankBulkTransferItem fields" >}}
InterbankBulkTransferItem is one entry in Interbank Bulk Transfer's request "bulkObject[]" array.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `bankCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryAccountName` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `amount` | `snap.Money` | <span class="badge-mandatory">Mandatory</span> |
| `originatorInfos` | `[]TransferOriginatorInfo` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |
{{< /details >}}

{{< details title="TransferOriginatorInfo fields" >}}
TransferOriginatorInfo is the shared "originatorInfos[]" entry used by the Trigger Transfer sub-group. All three fields are String per the Guides tab.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originatorCustomerName` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originatorBankCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
{{< /details >}}

**Response &mdash; `InterbankBulkTransferResponse`**

InterbankBulkTransferResponse is the response body for API Interbank Bulk Transfer.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `bulkId` | `string` | <span class="badge-optional">Optional</span> |
| `partnerBulkId` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |


---

### `Interbank Bulk Transfer Notification`

{{< callout type="info" >}}
Inbound only &mdash; this package does not call an endpoint for this. A partner/switcher POSTs it to **your** callback URL; unmarshal the body into `InterbankBulkTransferNotificationRequest` after verifying it with `snap.ServerVerifier` (see [Verifying inbound requests](/docs/concepts/webhooks/)), then reply with the shape below.
{{< /callout >}}

**Received &mdash; `InterbankBulkTransferNotificationRequest`**

InterbankBulkTransferNotificationRequest is the settlement-callback body for API Interbank Bulk Transfer - Notification (Service Code 21, path .../{version}/transfer-interbank-bulk/notify). `bulkId`, `partnerBulkId`, and `bulkObject` are Mandatory.

| Field | Type | Presence |
|---|---|---|
| `bulkId` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `partnerBulkId` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `bulkObject` | `[]InterbankBulkTransferNotificationItem` | <span class="badge-mandatory">Mandatory</span> |

{{< details title="InterbankBulkTransferNotificationItem fields" >}}
InterbankBulkTransferNotificationItem is one entry in Interbank Bulk Transfer - Notification's request "bulkObject[]" array — a settlement-result callback shape, distinct from InterbankBulkTransferItem's transfer-instruction shape.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
{{< /details >}}

**Your handler replies with &mdash; `InterbankBulkTransferNotificationResponse`**

InterbankBulkTransferNotificationResponse is the response body a caller sends back for API Interbank Bulk Transfer - Notification.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `bulkId` | `string` | <span class="badge-optional">Optional</span> |
| `partnerBulkId` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |


---

### `RequestForPayment`

RequestForPayment calls the SNAP Request for Payment endpoint (Service Code 19, path .../{version}/transfer-request-for-payment). hb must already carry every field snap.HeaderBuilder needs except Body, which RequestForPayment sets itself so the exact marshaled bytes are used for both signing and the wire body.

Not idempotent — retries aren't automatic. If you retry a failed or timed-out call, reuse the same X-EXTERNAL-ID; a fresh one risks a duplicate payment request.

```go
func RequestForPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req RequestForPaymentRequest) (RequestForPaymentResponse, error)
```

**Request &mdash; `RequestForPaymentRequest`**

RequestForPaymentRequest is the request body for API Request for Payment (Service Code 19). PartnerReferenceNo, BankCode, BeneficiaryAccountNo, BeneficiaryAccountName, ExpiredDatetime, SourceAccountNo, and SourceAccountName are mandatory per the Guides tab.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `bankCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryAccountName` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `remark` | `string` | <span class="badge-optional">Optional</span> |
| `expiredDatetime` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `sourceAccountNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `sourceAccountName` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `currency` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `feeType` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `RequestForPaymentResponse`**

RequestForPaymentResponse is the response body for API Request for Payment.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |


---

### `RTGSTransfer`

RTGSTransfer calls the SNAP Transfer RTGS endpoint (Service Code 22, path .../{version}/transfer-rtgs). hb must already carry every field snap.HeaderBuilder needs except Body, which RTGSTransfer sets itself so the exact marshaled bytes are used for both signing and the wire body.

Not idempotent — retries aren't automatic. If you retry a failed or timed-out call, reuse the same X-EXTERNAL-ID; a fresh one risks a duplicate transfer.

```go
func RTGSTransfer(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req RTGSTransferRequest) (RTGSTransferResponse, error)
```

**Request &mdash; `RTGSTransferRequest`**

RTGSTransferRequest is the request body for API Transfer RTGS (Service Code 22). PartnerReferenceNo, Amount, BeneficiaryAccountNo, BeneficiaryAccountName, BeneficiaryBankCode, SourceAccountNo, TransactionDate, BeneficiaryCustomerResidence, and BeneficiaryCustomerType are mandatory per the Guides tab. OriginatorInfos is Conditional.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `amount` | `snap.Money` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryAccountName` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryAddress` | `string` | <span class="badge-optional">Optional</span> |
| `beneficiaryBankCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryBankName` | `string` | <span class="badge-optional">Optional</span> |
| `beneficiaryEmail` | `string` | <span class="badge-optional">Optional</span> |
| `currency` | `string` | <span class="badge-optional">Optional</span> |
| `customerReference` | `string` | <span class="badge-optional">Optional</span> |
| `feeType` | `string` | <span class="badge-optional">Optional</span> |
| `remark` | `string` | <span class="badge-optional">Optional</span> |
| `sourceAccountNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `transactionDate` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryCustomerResidence` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryCustomerType` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `kodepos` | `string` | <span class="badge-optional">Optional</span> |
| `receiverPhone` | `string` | <span class="badge-optional">Optional</span> |
| `senderCustomerResidence` | `string` | <span class="badge-optional">Optional</span> |
| `senderCustomerType` | `string` | <span class="badge-optional">Optional</span> |
| `senderPhone` | `string` | <span class="badge-optional">Optional</span> |
| `originatorInfos` | `[]TransferOriginatorInfo` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

{{< details title="TransferOriginatorInfo fields" >}}
TransferOriginatorInfo is the shared "originatorInfos[]" entry used by the Trigger Transfer sub-group. All three fields are String per the Guides tab.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originatorCustomerName` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originatorBankCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
{{< /details >}}

**Response &mdash; `RTGSTransferResponse`**

RTGSTransferResponse is the response body for API Transfer RTGS.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-optional">Optional</span> |
| `currency` | `string` | <span class="badge-optional">Optional</span> |
| `customerReference` | `string` | <span class="badge-optional">Optional</span> |
| `sourceAccountNo` | `string` | <span class="badge-optional">Optional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Optional</span> |
| `traceNo` | `string` | <span class="badge-optional">Optional</span> |
| `transactionStatus` | `string` | <span class="badge-optional">Optional</span> |
| `transactionStatusDesc` | `string` | <span class="badge-optional">Optional</span> |
| `beneficiaryAccountType` | `string` | <span class="badge-optional">Optional</span> |
| `originatorInfos` | `[]TransferOriginatorInfo` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

{{< details title="TransferOriginatorInfo fields" >}}
TransferOriginatorInfo is the shared "originatorInfos[]" entry used by the Trigger Transfer sub-group. All three fields are String per the Guides tab.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originatorCustomerName` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originatorBankCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
{{< /details >}}


---

### `RTGS Notification`

{{< callout type="info" >}}
Inbound only &mdash; this package does not call an endpoint for this. A partner/switcher POSTs it to **your** callback URL; unmarshal the body into `RTGSNotificationRequest` after verifying it with `snap.ServerVerifier` (see [Verifying inbound requests](/docs/concepts/webhooks/)), then reply with the shape below.
{{< /callout >}}

**Received &mdash; `RTGSNotificationRequest`**

RTGSNotificationRequest is the settlement-callback body for API RTGS - Notification (Service Code 76, path .../{version}/transfer-rtgs/notify). `latestTransactionStatus`, `beneficiaryAccountName`, `beneficiaryAccountNo`, `beneficiaryBankCode`, `sourceAccountNo`, and `transactionDate` are Mandatory.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Optional</span> |
| `latestTransactionStatus` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `beneficiaryAccountName` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryBankCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `sourceAccountNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `transactionDate` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Your handler replies with &mdash; `RTGSNotificationResponse`**

RTGSNotificationResponse is the response body a caller sends back for API RTGS - Notification — envelope-only, no other fields.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |


---

### `SKNBITransfer`

SKNBITransfer calls the SNAP Transfer SKNBI endpoint (Service Code 23, path .../{version}/transfer-skn). hb must already carry every field snap.HeaderBuilder needs except Body, which SKNBITransfer sets itself so the exact marshaled bytes are used for both signing and the wire body.

Not idempotent — retries aren't automatic. If you retry a failed or timed-out call, reuse the same X-EXTERNAL-ID; a fresh one risks a duplicate transfer.

```go
func SKNBITransfer(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req SKNBITransferRequest) (SKNBITransferResponse, error)
```

**Request &mdash; `SKNBITransferRequest`**

SKNBITransferRequest is the request body for API Transfer SKNBI (Service Code 23) — the same shape as `RTGSTransferRequest`, with its own service code and path. `partnerReferenceNo`, `amount`, `beneficiaryAccountNo`, `beneficiaryAccountName`, `beneficiaryBankCode`, `sourceAccountNo`, `transactionDate`, `beneficiaryCustomerResidence`, and `beneficiaryCustomerType` are Mandatory. `originatorInfos` is Conditional.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `amount` | `snap.Money` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryAccountName` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryAddress` | `string` | <span class="badge-optional">Optional</span> |
| `beneficiaryBankCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryBankName` | `string` | <span class="badge-optional">Optional</span> |
| `beneficiaryEmail` | `string` | <span class="badge-optional">Optional</span> |
| `currency` | `string` | <span class="badge-optional">Optional</span> |
| `customerReference` | `string` | <span class="badge-optional">Optional</span> |
| `feeType` | `string` | <span class="badge-optional">Optional</span> |
| `remark` | `string` | <span class="badge-optional">Optional</span> |
| `sourceAccountNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `transactionDate` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryCustomerResidence` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryCustomerType` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `kodepos` | `string` | <span class="badge-optional">Optional</span> |
| `receiverPhone` | `string` | <span class="badge-optional">Optional</span> |
| `senderCustomerResidence` | `string` | <span class="badge-optional">Optional</span> |
| `senderCustomerType` | `string` | <span class="badge-optional">Optional</span> |
| `senderPhone` | `string` | <span class="badge-optional">Optional</span> |
| `originatorInfos` | `[]TransferOriginatorInfo` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

{{< details title="TransferOriginatorInfo fields" >}}
TransferOriginatorInfo is the shared "originatorInfos[]" entry used by the Trigger Transfer sub-group. All three fields are String per the Guides tab.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originatorCustomerName` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originatorBankCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
{{< /details >}}

**Response &mdash; `SKNBITransferResponse`**

SKNBITransferResponse is the response body for API Transfer SKNBI — the same shape as `RTGSTransferResponse`.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-optional">Optional</span> |
| `currency` | `string` | <span class="badge-optional">Optional</span> |
| `customerReference` | `string` | <span class="badge-optional">Optional</span> |
| `sourceAccountNo` | `string` | <span class="badge-optional">Optional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Optional</span> |
| `traceNo` | `string` | <span class="badge-optional">Optional</span> |
| `transactionStatus` | `string` | <span class="badge-optional">Optional</span> |
| `transactionStatusDesc` | `string` | <span class="badge-optional">Optional</span> |
| `beneficiaryAccountType` | `string` | <span class="badge-optional">Optional</span> |
| `originatorInfos` | `[]TransferOriginatorInfo` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

{{< details title="TransferOriginatorInfo fields" >}}
TransferOriginatorInfo is the shared "originatorInfos[]" entry used by the Trigger Transfer sub-group. All three fields are String per the Guides tab.

| Field | Type | Presence |
|---|---|---|
| `originatorCustomerNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originatorCustomerName` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originatorBankCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
{{< /details >}}


---

### `SKNBI Notification`

{{< callout type="info" >}}
Inbound only &mdash; this package does not call an endpoint for this. A partner/switcher POSTs it to **your** callback URL; unmarshal the body into `SKNBINotificationRequest` after verifying it with `snap.ServerVerifier` (see [Verifying inbound requests](/docs/concepts/webhooks/)), then reply with the shape below.
{{< /callout >}}

**Received &mdash; `SKNBINotificationRequest`**

SKNBINotificationRequest is the settlement-callback body for API SKNBI - Notification (Service Code 75, path .../{version}/transfer-skn/notify) — the same shape as `RTGSNotificationRequest`. `latestTransactionStatus`, `beneficiaryAccountName`, `beneficiaryAccountNo`, `beneficiaryBankCode`, `sourceAccountNo`, and `transactionDate` are Mandatory.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Optional</span> |
| `latestTransactionStatus` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `beneficiaryAccountName` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryBankCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `sourceAccountNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `transactionDate` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Your handler replies with &mdash; `SKNBINotificationResponse`**

SKNBINotificationResponse is the response body a caller sends back for API SKNBI - Notification — the same shape as `RTGSNotificationResponse`: envelope-only, no other fields.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |


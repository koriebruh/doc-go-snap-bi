---
weight: 8
title: "QR / MPM"
description: "Merchant-Presented-Mode QR: generate, decode, pay host-to-host, query, cancel, and refund — plus the One-Time-Token flow used by ApplyOTT."
---

## QR / MPM

Merchant-Presented-Mode QR: generate, decode, pay host-to-host, query, cancel, and refund — plus the One-Time-Token flow used by ApplyOTT.

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

GenerateQRMPM calls the SNAP Generate QR MPM endpoint (Service Code 47, path .../{version}/qr/qr-mpm-generate, HTTP POST — no method override). hb must already carry every field snap.HeaderBuilder needs except Body, which GenerateQRMPM sets itself so the exact marshaled bytes are used for both signing and the wire body.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func GenerateQRMPM(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req GenerateQRMPMRequest) (GenerateQRMPMResponse, error)
```

**Request &mdash; `GenerateQRMPMRequest`**

GenerateQRMPMRequest is the request body for API Generate QR MPM (Service Code 47). Every field is Optional per the Guides tab — no field in this request is documented Mandatory.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `feeAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `merchantId` | `string` | <span class="badge-optional">Optional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `storeId` | `string` | <span class="badge-optional">Optional</span> |
| `terminalId` | `string` | <span class="badge-optional">Optional</span> |
| `validityPeriod` | `string` | <span class="badge-optional">Optional</span> |

**Response &mdash; `GenerateQRMPMResponse`**

GenerateQRMPMResponse is the response body for API Generate QR MPM.

QRContent, QRURL, and QRImage form a one-of-three condition the type system cannot express: per the Guides tab, "if [qrContent is] null, qrUrl or qrImage must be filled." All three are Optional here; callers must check which of the three came back non-empty.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `qrContent` | `string` | <span class="badge-optional">Optional</span> |
| `qrUrl` | `string` | <span class="badge-optional">Optional</span> |
| `redirectUrl` | `string` | <span class="badge-optional">Optional</span> |
| `merchantName` | `string` | <span class="badge-optional">Optional</span> |
| `storeId` | `string` | <span class="badge-optional">Optional</span> |
| `terminalId` | `string` | <span class="badge-optional">Optional</span> |


---

### `ApplyOTT`

ApplyOTT calls the SNAP Payment Redirect - Apply OTT endpoint (Service Code 49, path .../{version}/qr/apply-ott, HTTP POST — no method override). hb must already carry every field snap.HeaderBuilder needs except Body, which ApplyOTT sets itself so the exact marshaled bytes are used for both signing and the wire body.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func ApplyOTT(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req ApplyOTTRequest) (ApplyOTTResponse, error)
```

This endpoint takes no typed request body beyond the call parameters shown above.

**Response &mdash; `ApplyOTTResponse`**

ApplyOTTResponse is the response body for API Payment Redirect - Apply OTT.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `userResources` | `[]ApplyOTTUserResource` | <span class="badge-mandatory">Mandatory</span> |

{{< details title="ApplyOTTUserResource fields" >}}
ApplyOTTUserResource is one entry in an ApplyOTTResponse's userResources array. Despite sharing a field name with the request, this is a distinct shape (an object, not a bare string).

| Field | Type | Presence |
|---|---|---|
| `resourceType` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `value` | `string` | <span class="badge-mandatory">Mandatory</span> |
{{< /details >}}


---

### `DecodeQRMPM`

DecodeQRMPM calls the SNAP Decode QR MPM endpoint (Service Code 48, path .../{version}/qr/qr-mpm-decode, HTTP POST — no method override). hb must already carry every field snap.HeaderBuilder needs except Body, which DecodeQRMPM sets itself so the exact marshaled bytes are used for both signing and the wire body.

This is a read-only decode; unlike GenerateQRMPM it carries no non-idempotency note.

```go
func DecodeQRMPM(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req DecodeQRMPMRequest) (DecodeQRMPMResponse, error)
```

**Request &mdash; `DecodeQRMPMRequest`**

DecodeQRMPMRequest is the request body for API Decode QR MPM (Service Code 48). QRContent and ScanTime are Mandatory per the Guides tab.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `qrContent` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `merchantId` | `string` | <span class="badge-optional">Optional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `scanTime` | `string` | <span class="badge-mandatory">Mandatory</span> |

**Response &mdash; `DecodeQRMPMResponse`**

DecodeQRMPMResponse is the response body for API Decode QR MPM.

ReferenceNo and RedirectURL are both modeled Optional — the standard's own conditions for when each is required are contradictory, so neither is asserted here.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `redirectUrl` | `string` | <span class="badge-optional">Optional</span> |
| `merchantName` | `string` | <span class="badge-optional">Optional</span> |
| `merchantCategory` | `string` | <span class="badge-optional">Optional</span> |
| `merchantLocation` | `string` | <span class="badge-optional">Optional</span> |
| `merchantInfos` | `[]MPMMerchantInfo` | <span class="badge-mandatory">Mandatory</span> |
| `transactionAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `feeAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |

{{< details title="MPMMerchantInfo fields" >}}
MPMMerchantInfo is one entry in a DecodeQRMPMResponse's merchantInfos array.

MerchantPAN is documented as numeric but sent quoted as a string on the wire — an ambiguous shape, so it's typed `json.RawMessage` rather than `string` or a numeric type.

| Field | Type | Presence |
|---|---|---|
| `merchantPAN` | `json.RawMessage` | <span class="badge-mandatory">Mandatory</span> |
| `acquirerName` | `string` | <span class="badge-mandatory">Mandatory</span> |
{{< /details >}}


---

### `QRMPMPaymentH2H`

QRMPMPaymentH2H calls the SNAP Payment - Host to Host endpoint (Service Code 50, path .../{version}/qr/qr-mpm-payment, HTTP POST — no method override). hb must already carry every field snap.HeaderBuilder needs except Body, which QRMPMPaymentH2H sets itself so the exact marshaled bytes are used for both signing and the wire body.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func QRMPMPaymentH2H(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req QRMPMPaymentH2HRequest) (QRMPMPaymentH2HResponse, error)
```

**Request &mdash; `QRMPMPaymentH2HRequest`**

QRMPMPaymentH2HRequest is the request body for API Payment - Host to Host (Service Code 50). PartnerReferenceNo is Mandatory; every other field is Optional per the Guides tab.

VerificationID also appears on the response under the same name with a different documented max length — both are plain `string` in Go, this package doesn't enforce length limits.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `merchantId` | `string` | <span class="badge-optional">Optional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `feeAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `otp` | `string` | <span class="badge-optional">Optional</span> |
| `verificationId` | `string` | <span class="badge-optional">Optional</span> |

**Response &mdash; `QRMPMPaymentH2HResponse`**

QRMPMPaymentH2HResponse is the response body for API Payment - Host to Host.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Optional</span> |
| `verificationId` | `string` | <span class="badge-optional">Optional</span> |


---

### `QR MPM Payment Notification`

{{< callout type="info" >}}
Inbound only &mdash; this package does not call an endpoint for this. A partner/switcher POSTs it to **your** callback URL; unmarshal the body into `QRMPMPaymentNotificationRequest` after verifying it with `snap.ServerVerifier` (see [Verifying inbound requests](/docs/concepts/webhooks/)), then reply with the shape below.
{{< /callout >}}

**Received &mdash; `QRMPMPaymentNotificationRequest`**

QRMPMPaymentNotificationRequest is the request body for API Payment Notification (Service Code 52, path .../{version}/qr/qr-mpm-notify). This is a settlement callback the PJP receives, not a call this package makes — wire your own HTTP handler for this path, authenticate the request with `ServerVerifier.VerifyTransactionRequest`, then `json.Unmarshal` the body into this type. OriginalReferenceNo and LatestTransactionStatus are Mandatory; every other field is Optional.

| Field | Type | Presence |
|---|---|---|
| `originalReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `latestTransactionStatus` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `customerNumber` | `string` | <span class="badge-optional">Optional</span> |
| `accountType` | `string` | <span class="badge-optional">Optional</span> |
| `destinationNumber` | `string` | <span class="badge-optional">Optional</span> |
| `destinationAccountName` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `sessionId` | `string` | <span class="badge-optional">Optional</span> |
| `bankCode` | `string` | <span class="badge-optional">Optional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Optional</span> |

**Your handler replies with &mdash; `QRMPMPaymentNotificationResponse`**

QRMPMPaymentNotificationResponse is the response body your handler sends back — no fields beyond the standard `responseCode`/`responseMessage` envelope.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |


---

### `QRMPMQueryPayment`

QRMPMQueryPayment calls the SNAP Query Payment endpoint (Service Code 51, path .../{version}/qr/qr-mpm-query, HTTP POST — no method override). hb must already carry every field snap.HeaderBuilder needs except Body, which QRMPMQueryPayment sets itself so the exact marshaled bytes are used for both signing and the wire body.

This is a read-only status query; unlike the package's mutating calls it carries no non-idempotency note, matching TransactionStatusInquiryBank's precedent.

```go
func QRMPMQueryPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req QRMPMQueryPaymentRequest) (QRMPMQueryPaymentResponse, error)
```

**Request &mdash; `QRMPMQueryPaymentRequest`**

QRMPMQueryPaymentRequest is the request body for API Query Payment (Service Code 51) — the same base fields as [`TransactionStatusInquiryBankRequest`](/docs/reference/transfer-credit/transaction-status/), plus MerchantID, SubMerchantID, and ExternalStoreID. ServiceCode is the only Mandatory field.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Optional</span> |
| `serviceCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `transactionDate` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `merchantId` | `string` | <span class="badge-optional">Optional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `QRMPMQueryPaymentResponse`**

QRMPMQueryPaymentResponse is the response body for API Query Payment — the same fields as [`TransactionStatusInquiryBankResponse`](/docs/reference/transfer-credit/transaction-status/), plus PaidTime and TerminalID.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Optional</span> |
| `serviceCode` | `string` | <span class="badge-optional">Optional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryBankCode` | `string` | <span class="badge-optional">Optional</span> |
| `previousResponseCode` | `string` | <span class="badge-optional">Optional</span> |
| `referenceNumber` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `sourceAccountNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `transactionId` | `string` | <span class="badge-optional">Optional</span> |
| `latestTransactionStatus` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `transactionStatusDesc` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |
| `paidTime` | `string` | <span class="badge-optional">Optional</span> |
| `terminalId` | `string` | <span class="badge-optional">Optional</span> |


---

### `QRMPMCancelPayment`

QRMPMCancelPayment calls the SNAP Cancel Payment endpoint (Service Code 77, path .../{version}/qr/qr-mpm-cancel, HTTP POST — no method override). hb must already carry every field snap.HeaderBuilder needs except Body, which QRMPMCancelPayment sets itself so the exact marshaled bytes are used for both signing and the wire body.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func QRMPMCancelPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req QRMPMCancelPaymentRequest) (QRMPMCancelPaymentResponse, error)
```

**Request &mdash; `QRMPMCancelPaymentRequest`**

QRMPMCancelPaymentRequest is the request body for API Cancel Payment (Service Code 77). Unlike the package's other originalX-pattern endpoints, this row documents no serviceCode field and all three originalX fields as Optional — MerchantID and Reason are the only Mandatory fields.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Optional</span> |
| `merchantId` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Optional</span> |
| `reason` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |

**Response &mdash; `QRMPMCancelPaymentResponse`**

QRMPMCancelPaymentResponse is the response body for API Cancel Payment. CancelTime is Conditional (modeled Optional, per this package's usual handling — see [Core Conventions](/docs/concepts/conventions/)); TransactionDate is Optional.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `cancelTime` | `string` | <span class="badge-optional">Optional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Optional</span> |


---

### `QRMPMRefundPayment`

QRMPMRefundPayment calls the SNAP Refund Payment endpoint (Service Code 78, path .../{version}/qr/qr-mpm-refund, HTTP POST — no method override). hb must already carry every field snap.HeaderBuilder needs except Body, which QRMPMRefundPayment sets itself so the exact marshaled bytes are used for both signing and the wire body.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func QRMPMRefundPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req QRMPMRefundPaymentRequest) (QRMPMRefundPaymentResponse, error)
```

**Request &mdash; `QRMPMRefundPaymentRequest`**

QRMPMRefundPaymentRequest is the request body for API Refund Payment (Service Code 78). OriginalPartnerReferenceNo and PartnerRefundNo are Mandatory; every other field is Optional per the Guides tab.

| Field | Type | Presence |
|---|---|---|
| `merchantId` | `string` | <span class="badge-optional">Optional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Optional</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Optional</span> |
| `partnerRefundNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `refundAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `reason` | `string` | <span class="badge-optional">Optional</span> |

**Response &mdash; `QRMPMRefundPaymentResponse`**

QRMPMRefundPaymentResponse is the response body for API Refund Payment. RefundNo and RefundTime are Mandatory; PartnerRefundNo and RefundAmount are Optional (echoed back, not guaranteed).

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `refundNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `partnerRefundNo` | `string` | <span class="badge-optional">Optional</span> |
| `refundAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `refundTime` | `string` | <span class="badge-mandatory">Mandatory</span> |


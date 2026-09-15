---
weight: 2
title: "CPM"
description: "Customer-Presented-Mode QR (the customer shows a QR, the merchant scans it): generate, pay, query, cancel, refund; payment results also arrive as an inbound notification."
---

## CPM

Customer-Presented-Mode QR (the customer shows a QR, the merchant scans it): generate, pay, query, cancel, refund; payment results also arrive as an inbound notification.

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

CPMGenerateQR calls the SNAP Generate QR CPM endpoint (Service Code 59, HTTP POST). Pass `hb` with everything except `Body` already set — `CPMGenerateQR` marshals the request itself and uses those exact bytes for both signing and the wire body.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func CPMGenerateQR(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req CPMGenerateQRRequest) (CPMGenerateQRResponse, error)
```

**Request &mdash; `CPMGenerateQRRequest`**

CPMGenerateQRRequest is the request body for Generate QR CPM. `partnerTrxDate` is the only Mandatory field.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `userAccessToken` | `string` | <span class="badge-optional">Optional</span> |
| `merchantId` | `string` | <span class="badge-optional">Optional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `partnerTrxDate` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `CPMGenerateQRResponse`**

CPMGenerateQRResponse is the response body for Generate QR CPM. `expiryTime` is the only other Mandatory field; `qrContent`/`qrUrl` are both plain Optional (no one-of-many rule between them).

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `qrContent` | `string` | <span class="badge-optional">Optional</span> |
| `qrUrl` | `string` | <span class="badge-optional">Optional</span> |
| `expiryTime` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |


---

### `CPMPayment`

CPMPayment calls the SNAP CPM Payment endpoint (Service Code 60, HTTP POST). Pass `hb` with everything except `Body` already set — `CPMPayment` marshals the request itself.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func CPMPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req CPMPaymentRequest) (CPMPaymentResponse, error)
```

**Request &mdash; `CPMPaymentRequest`**

CPMPaymentRequest is the request body for CPM Payment. `partnerReferenceNo`, `qrContent`, and `merchantId` are Mandatory.

`items` has no fixed schema in the standard, so it's typed `json.RawMessage` — the same treatment as `additionalInfo` and every other genuinely untyped field.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `qrContent` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `feeAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `merchantId` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `title` | `string` | <span class="badge-optional">Optional</span> |
| `expiryTime` | `string` | <span class="badge-optional">Optional</span> |
| `items` | `json.RawMessage` | <span class="badge-optional">Optional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Optional</span> |
| `merchantName` | `string` | <span class="badge-optional">Optional</span> |
| `merchantLocation` | `string` | <span class="badge-optional">Optional</span> |
| `acquirerName` | `string` | <span class="badge-optional">Optional</span> |
| `terminalId` | `string` | <span class="badge-optional">Optional</span> |
| `scannerInfo` | `*CPMPaymentScannerInfo` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

{{< details title="CPMPaymentScannerInfo fields" >}}
CPMPaymentScannerInfo is the optional `scannerInfo` object describing the device that scanned the QR. All four fields are Optional.

| Field | Type | Presence |
|---|---|---|
| `deviceId` | `string` | <span class="badge-optional">Optional</span> |
| `deviceVersion` | `string` | <span class="badge-optional">Optional</span> |
| `deviceModel` | `string` | <span class="badge-optional">Optional</span> |
| `deviceIp` | `string` | <span class="badge-optional">Optional</span> |
{{< /details >}}

**Response &mdash; `CPMPaymentResponse`**

CPMPaymentResponse is the response body for CPM Payment. `referenceNo` is Conditional — present only on success. No other field is Mandatory.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |


---

### `CPM Payment Notification`

{{< callout type="info" >}}
Inbound only &mdash; this package does not call an endpoint for this. A partner/switcher POSTs it to **your** callback URL; unmarshal the body into `CPMPaymentNotificationRequest` after verifying it with `snap.ServerVerifier` (see [Verifying inbound requests](/docs/concepts/webhooks/)), then reply with the shape below.
{{< /callout >}}

**Received &mdash; `CPMPaymentNotificationRequest`**

CPMPaymentNotificationRequest is the request body for Payment Notification (Service Code 79) — a settlement callback the PJP receives, not a call this package makes. Wire your own HTTP handler for this path, authenticate the inbound call with `ServerVerifier.VerifyTransactionRequest`, then `json.Unmarshal` the body into this type.

`merchantId` and `latestTransactionStatus` are Mandatory; every other field is Optional.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `merchantId` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `latestTransactionStatus` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `transactionStatusDesc` | `string` | <span class="badge-optional">Optional</span> |
| `customerNumber` | `string` | <span class="badge-optional">Optional</span> |
| `accountType` | `string` | <span class="badge-optional">Optional</span> |
| `destinationNumber` | `string` | <span class="badge-optional">Optional</span> |
| `destinationAccountName` | `string` | <span class="badge-optional">Optional</span> |
| `sessionId` | `string` | <span class="badge-optional">Optional</span> |
| `bankCode` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Your handler replies with &mdash; `CPMPaymentNotificationResponse`**

CPMPaymentNotificationResponse is envelope-only — just `responseCode` and `responseMessage`, no other fields.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |


---

### `CPMQueryPayment`

CPMQueryPayment calls the SNAP Query Payment endpoint (Service Code 61, HTTP POST) to check a previous CPM payment's status. Pass `hb` with everything except `Body` already set — `CPMQueryPayment` marshals the request itself. This is a read-only lookup, safe to retry freely.

```go
func CPMQueryPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req CPMQueryPaymentRequest) (CPMQueryPaymentResponse, error)
```

**Request &mdash; `CPMQueryPaymentRequest`**

CPMQueryPaymentRequest is the request body for Query Payment. No field is Mandatory — query by whichever reference, merchant, or store ID you have.

| Field | Type | Presence |
|---|---|---|
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Optional</span> |
| `merchantId` | `string` | <span class="badge-optional">Optional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `CPMQueryPaymentResponse`**

CPMQueryPaymentResponse is the response body for Query Payment. `latestTransactionStatus` and `paidTime` are Mandatory; `originalReferenceNo` is Conditional — present only on success.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Optional</span> |
| `title` | `string` | <span class="badge-optional">Optional</span> |
| `latestTransactionStatus` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `transactionStatusDesc` | `string` | <span class="badge-optional">Optional</span> |
| `paidTime` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |


---

### `CPMCancelPayment`

CPMCancelPayment calls the SNAP Cancel Payment endpoint (Service Code 62, HTTP POST). Pass `hb` with everything except `Body` already set — `CPMCancelPayment` marshals the request itself.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func CPMCancelPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req CPMCancelPaymentRequest) (CPMCancelPaymentResponse, error)
```

**Request &mdash; `CPMCancelPaymentRequest`**

CPMCancelPaymentRequest is the request body for Cancel Payment. `originalPartnerReferenceNo` is the only Mandatory field.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Optional</span> |
| `merchantId` | `string` | <span class="badge-optional">Optional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `reason` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `CPMCancelPaymentResponse`**

CPMCancelPaymentResponse is the response body for Cancel Payment. `originalReferenceNo` and `cancelTime` are Conditional — present only on success.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Optional</span> |
| `cancelTime` | `string` | <span class="badge-optional">Optional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |


---

### `CPMRefundPayment`

CPMRefundPayment calls the SNAP Refund Payment endpoint (Service Code 80, HTTP POST). Pass `hb` with everything except `Body` already set — `CPMRefundPayment` marshals the request itself.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func CPMRefundPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req CPMRefundPaymentRequest) (CPMRefundPaymentResponse, error)
```

**Request &mdash; `CPMRefundPaymentRequest`**

CPMRefundPaymentRequest is the request body for Refund Payment. `originalPartnerReferenceNo` and `partnerRefundNo` are Mandatory.

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
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `CPMRefundPaymentResponse`**

CPMRefundPaymentResponse is the response body for Refund Payment. `refundNo` and `refundTime` are Mandatory; `partnerRefundNo` is Optional here (unlike Direct Debit Payment Refund's own response, where it's Mandatory).

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Optional</span> |
| `refundNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `partnerRefundNo` | `string` | <span class="badge-optional">Optional</span> |
| `refundAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `refundTime` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

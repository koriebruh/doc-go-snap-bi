---
weight: 3
title: "Direct Debit"
description: "Standard direct-debit payment, its inbound notification, and status/cancel/refund."
---

## Direct Debit

Standard direct-debit payment, its inbound notification, and status/cancel/refund.

```go
resp, err := transferdebit.DirectDebitPayment(ctx, transport, hb, transferdebit.DirectDebitPaymentRequest{
	PartnerReferenceNo: "2020102900000000000001",
})
if err != nil {
	// errors.Is(err, snap.ErrBadRequest), snap.ErrUnauthorized, etc.
}
```

### `DirectDebitPayment`

DirectDebitPayment calls the SNAP Direct Debit Payment endpoint (Service Code 54, HTTP POST). Pass `hb` with everything except `Body` already set — `DirectDebitPayment` marshals the request itself and uses those exact bytes for both signing and the wire body.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func DirectDebitPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req DirectDebitPaymentRequest) (DirectDebitPaymentResponse, error)
```

**Request &mdash; `DirectDebitPaymentRequest`**

DirectDebitPaymentRequest is the request body for Direct Debit Payment. `partnerReferenceNo` is the only Mandatory field.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | Mandatory |
| `bankCardToken` | `string` | Optional |
| `chargeToken` | `string` | Optional |
| `otp` | `string` | Optional |
| `otpTrxCode` | `string` | Optional |
| `merchantId` | `string` | Optional |
| `terminalId` | `string` | Optional |
| `journeyId` | `string` | Optional |
| `subMerchantId` | `string` | Optional |
| `amount` | `*snap.Money` | Optional |
| `urlParams` | `[]DirectDebitPaymentURLParam` | Optional |
| `externalStoreId` | `string` | Optional |
| `validUpTo` | `string` | Optional |
| `pointOfInitiation` | `string` | Optional |
| `feeType` | `string` | Optional |
| `disabledPayMethods` | `string` | Optional |
| `payOptionDetails` | `[]DirectDebitPayOptionDetail` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |

{{< details title="DirectDebitPaymentURLParam fields" >}}
DirectDebitPaymentURLParam is one entry in the request's `urlParams[]` array — a redirect URL and how to use it. `isDeeplink` is a `"Y"`/`"N"` flag.

| Field | Type | Presence |
|---|---|---|
| `url` | `string` | Mandatory |
| `type` | `string` | Mandatory |
| `isDeeplink` | `string` | Mandatory |
{{< /details >}}

{{< details title="DirectDebitPayOptionDetail fields" >}}
DirectDebitPayOptionDetail is one entry in the request's `payOptionDetails[]` array, describing one available payment method.

| Field | Type | Presence |
|---|---|---|
| `payMethod` | `string` | Mandatory |
| `payOption` | `string` | Mandatory |
| `transAmount` | `*snap.Money` | Optional |
| `feeAmount` | `*snap.Money` | Optional |
| `cardToken` | `string` | Optional |
| `merchantToken` | `string` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |
{{< /details >}}

**Response &mdash; `DirectDebitPaymentResponse`**

DirectDebitPaymentResponse is the response body for Direct Debit Payment. `referenceNo` is Conditional — present only on success.

{{< callout type="warning" >}}
`appRedirectUrl` and `webRedirectUrl` come straight from the server with no
validation. Before opening either in a WebView or browser, check the
scheme yourself (`https://` or your app's own registered scheme) — a
tampered or spoofed response could otherwise hand you an attacker-controlled URL.
{{< /callout >}}

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Mandatory |
| `responseMessage` | `string` | Mandatory |
| `referenceNo` | `string` | Optional |
| `partnerReferenceNo` | `string` | Optional |
| `approvalCode` | `string` | Optional |
| `appRedirectUrl` | `string` | Optional |
| `webRedirectUrl` | `string` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |


---

### `Direct Debit Payment Notification`

{{< callout type="info" >}}
Inbound only &mdash; this package does not call an endpoint for this. A partner/switcher POSTs it to **your** callback URL; unmarshal the body into `DirectDebitPaymentNotificationRequest` after verifying it with `snap.ServerVerifier` (see [Verifying inbound requests](/docs/concepts/webhooks/)), then reply with the shape below.
{{< /callout >}}

**Received &mdash; `DirectDebitPaymentNotificationRequest`**

DirectDebitPaymentNotificationRequest is the request body for Direct Debit Payment Notification (Service Code 56) — a settlement callback the PJP receives, not a call this package makes. Wire your own HTTP handler for this path, authenticate the inbound call with `ServerVerifier.VerifyTransactionRequest`, then `json.Unmarshal` the body into this type.

`originalReferenceNo` and `latestTransactionStatus` are Mandatory; every other field is Optional.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | Optional |
| `originalReferenceNo` | `string` | Mandatory |
| `originalExternalId` | `string` | Optional |
| `merchantId` | `string` | Optional |
| `subMerchantId` | `string` | Optional |
| `amount` | `*snap.Money` | Optional |
| `latestTransactionStatus` | `string` | Mandatory |
| `transactionStatusDesc` | `string` | Optional |
| `createdTime` | `string` | Optional |
| `finishedTime` | `string` | Optional |
| `externalStoreId` | `string` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |

**Your handler replies with &mdash; `DirectDebitPaymentNotificationResponse`**

DirectDebitPaymentNotificationResponse has one field beyond the envelope, `approvalCode`, and it's Optional.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Mandatory |
| `responseMessage` | `string` | Mandatory |
| `approvalCode` | `string` | Optional |


---

### `DirectDebitPaymentStatus`

DirectDebitPaymentStatus calls the SNAP Direct Debit Payment Status endpoint (Service Code 55, HTTP POST) to check a previous payment's status. Pass `hb` with everything except `Body` already set — `DirectDebitPaymentStatus` marshals the request itself. This is a read-only lookup, safe to retry freely.

```go
func DirectDebitPaymentStatus(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req DirectDebitPaymentStatusRequest) (DirectDebitPaymentStatusResponse, error)
```

**Request &mdash; `DirectDebitPaymentStatusRequest`**

DirectDebitPaymentStatusRequest is the request body for Direct Debit Payment Status. `serviceCode` is the only Mandatory field — pair it with whichever reference you have.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | Optional |
| `originalReferenceNo` | `string` | Optional |
| `originalExternalId` | `string` | Optional |
| `serviceCode` | `string` | Mandatory |
| `transactionDate` | `string` | Optional |
| `amount` | `*snap.Money` | Optional |
| `merchantId` | `string` | Optional |
| `subMerchantId` | `string` | Optional |
| `externalStoreId` | `string` | Optional |

**Response &mdash; `DirectDebitPaymentStatusResponse`**

DirectDebitPaymentStatusResponse is the response body for Direct Debit Payment Status. `latestTransactionStatus` is the only Mandatory field beyond the envelope.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Mandatory |
| `responseMessage` | `string` | Mandatory |
| `originalPartnerReferenceNo` | `string` | Optional |
| `originalReferenceNo` | `string` | Optional |
| `originalExternalId` | `string` | Optional |
| `serviceCode` | `string` | Optional |
| `transactionDate` | `string` | Optional |
| `amount` | `*snap.Money` | Optional |
| `approvalCode` | `string` | Optional |
| `latestTransactionStatus` | `string` | Mandatory |
| `transactionStatusDesc` | `string` | Optional |
| `originalResponseCode` | `string` | Optional |
| `originalResponseMessage` | `string` | Optional |
| `sessionId` | `string` | Optional |
| `requestId` | `string` | Optional |
| `refundHistory` | `[]DirectDebitRefundHistoryItem` | Optional |
| `transAmount` | `*snap.Money` | Optional |
| `feeAmount` | `*snap.Money` | Optional |
| `paidTime` | `string` | Optional |

{{< details title="DirectDebitRefundHistoryItem fields" >}}
DirectDebitRefundHistoryItem is one entry in the response's `refundHistory[]` array — a past refund against this payment. `refundStatus` is one of `00`, `03`, or `06`.

| Field | Type | Presence |
|---|---|---|
| `refundNo` | `string` | Optional |
| `partnerRefundNo` | `string` | Mandatory |
| `refundAmount` | `*snap.Money` | Optional |
| `refundStatus` | `string` | Mandatory |
| `refundDate` | `string` | Optional |
| `reason` | `string` | Optional |
{{< /details >}}


---

### `DirectDebitPaymentCancel`

DirectDebitPaymentCancel calls the SNAP Direct Debit Payment Cancel endpoint (Service Code 57, HTTP POST). Pass `hb` with everything except `Body` already set — `DirectDebitPaymentCancel` marshals the request itself.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func DirectDebitPaymentCancel(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req DirectDebitPaymentCancelRequest) (DirectDebitPaymentCancelResponse, error)
```

**Request &mdash; `DirectDebitPaymentCancelRequest`**

DirectDebitPaymentCancelRequest is the request body for Direct Debit Payment Cancel. `originalPartnerReferenceNo` is the only Mandatory field.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | Mandatory |
| `originalReferenceNo` | `string` | Optional |
| `approvalCode` | `string` | Optional |
| `originalExternalId` | `string` | Optional |
| `merchantId` | `string` | Optional |
| `subMerchantId` | `string` | Optional |
| `reason` | `string` | Optional |
| `externalStoreId` | `string` | Optional |
| `amount` | `*snap.Money` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |

**Response &mdash; `DirectDebitPaymentCancelResponse`**

DirectDebitPaymentCancelResponse is the response body for Direct Debit Payment Cancel. `originalReferenceNo` and `cancelTime` are Conditional — present only on success.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Mandatory |
| `responseMessage` | `string` | Mandatory |
| `originalPartnerReferenceNo` | `string` | Optional |
| `originalReferenceNo` | `string` | Optional |
| `originalExternalId` | `string` | Optional |
| `cancelTime` | `string` | Optional |
| `transactionDate` | `string` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |


---

### `DirectDebitPaymentRefund`

DirectDebitPaymentRefund calls the SNAP Direct Debit Payment Refund endpoint (Service Code 58, HTTP POST). Pass `hb` with everything except `Body` already set — `DirectDebitPaymentRefund` marshals the request itself.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func DirectDebitPaymentRefund(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req DirectDebitPaymentRefundRequest) (DirectDebitPaymentRefundResponse, error)
```

**Request &mdash; `DirectDebitPaymentRefundRequest`**

DirectDebitPaymentRefundRequest is the request body for Direct Debit Payment Refund. `originalPartnerReferenceNo` and `partnerRefundNo` are Mandatory.

| Field | Type | Presence |
|---|---|---|
| `merchantId` | `string` | Optional |
| `subMerchantId` | `string` | Optional |
| `originalPartnerReferenceNo` | `string` | Mandatory |
| `originalReferenceNo` | `string` | Optional |
| `originalExternalId` | `string` | Optional |
| `partnerRefundNo` | `string` | Mandatory |
| `refundAmount` | `*snap.Money` | Optional |
| `externalStoreId` | `string` | Optional |
| `reason` | `string` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |

**Response &mdash; `DirectDebitPaymentRefundResponse`**

DirectDebitPaymentRefundResponse is the response body for Direct Debit Payment Refund. `originalReferenceNo` is Conditional — present only on success. `refundNo`, `partnerRefundNo`, and `refundTime` are Mandatory.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Mandatory |
| `responseMessage` | `string` | Mandatory |
| `originalPartnerReferenceNo` | `string` | Optional |
| `originalReferenceNo` | `string` | Optional |
| `originalExternalId` | `string` | Optional |
| `partnerTrxId` | `string` | Optional |
| `refundNo` | `string` | Mandatory |
| `partnerRefundNo` | `string` | Mandatory |
| `refundAmount` | `*snap.Money` | Optional |
| `refundTime` | `string` | Mandatory |
| `additionalInfo` | `json.RawMessage` | Optional |

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
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `bankCardToken` | `string` | <span class="badge-optional">Optional</span> |
| `chargeToken` | `string` | <span class="badge-optional">Optional</span> |
| `otp` | `string` | <span class="badge-optional">Optional</span> |
| `otpTrxCode` | `string` | <span class="badge-optional">Optional</span> |
| `merchantId` | `string` | <span class="badge-optional">Optional</span> |
| `terminalId` | `string` | <span class="badge-optional">Optional</span> |
| `journeyId` | `string` | <span class="badge-optional">Optional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `urlParams` | `[]DirectDebitPaymentURLParam` | <span class="badge-optional">Optional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Optional</span> |
| `validUpTo` | `string` | <span class="badge-optional">Optional</span> |
| `pointOfInitiation` | `string` | <span class="badge-optional">Optional</span> |
| `feeType` | `string` | <span class="badge-optional">Optional</span> |
| `disabledPayMethods` | `string` | <span class="badge-optional">Optional</span> |
| `payOptionDetails` | `[]DirectDebitPayOptionDetail` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

{{< details title="DirectDebitPaymentURLParam fields" >}}
DirectDebitPaymentURLParam is one entry in the request's `urlParams[]` array — a redirect URL and how to use it. `isDeeplink` is a `"Y"`/`"N"` flag.

| Field | Type | Presence |
|---|---|---|
| `url` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `type` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `isDeeplink` | `string` | <span class="badge-mandatory">Mandatory</span> |
{{< /details >}}

{{< details title="DirectDebitPayOptionDetail fields" >}}
DirectDebitPayOptionDetail is one entry in the request's `payOptionDetails[]` array, describing one available payment method.

| Field | Type | Presence |
|---|---|---|
| `payMethod` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `payOption` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `transAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `feeAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `cardToken` | `string` | <span class="badge-optional">Optional</span> |
| `merchantToken` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |
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
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `approvalCode` | `string` | <span class="badge-optional">Optional</span> |
| `appRedirectUrl` | `string` | <span class="badge-optional">Optional</span> |
| `webRedirectUrl` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |


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
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Optional</span> |
| `merchantId` | `string` | <span class="badge-optional">Optional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `latestTransactionStatus` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `transactionStatusDesc` | `string` | <span class="badge-optional">Optional</span> |
| `createdTime` | `string` | <span class="badge-optional">Optional</span> |
| `finishedTime` | `string` | <span class="badge-optional">Optional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Your handler replies with &mdash; `DirectDebitPaymentNotificationResponse`**

DirectDebitPaymentNotificationResponse has one field beyond the envelope, `approvalCode`, and it's Optional.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `approvalCode` | `string` | <span class="badge-optional">Optional</span> |


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
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Optional</span> |
| `serviceCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `transactionDate` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `merchantId` | `string` | <span class="badge-optional">Optional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Optional</span> |

**Response &mdash; `DirectDebitPaymentStatusResponse`**

DirectDebitPaymentStatusResponse is the response body for Direct Debit Payment Status. `latestTransactionStatus` is the only Mandatory field beyond the envelope.

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
| `approvalCode` | `string` | <span class="badge-optional">Optional</span> |
| `latestTransactionStatus` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `transactionStatusDesc` | `string` | <span class="badge-optional">Optional</span> |
| `originalResponseCode` | `string` | <span class="badge-optional">Optional</span> |
| `originalResponseMessage` | `string` | <span class="badge-optional">Optional</span> |
| `sessionId` | `string` | <span class="badge-optional">Optional</span> |
| `requestId` | `string` | <span class="badge-optional">Optional</span> |
| `refundHistory` | `[]DirectDebitRefundHistoryItem` | <span class="badge-optional">Optional</span> |
| `transAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `feeAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `paidTime` | `string` | <span class="badge-optional">Optional</span> |

{{< details title="DirectDebitRefundHistoryItem fields" >}}
DirectDebitRefundHistoryItem is one entry in the response's `refundHistory[]` array — a past refund against this payment. `refundStatus` is one of `00`, `03`, or `06`.

| Field | Type | Presence |
|---|---|---|
| `refundNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerRefundNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `refundAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `refundStatus` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `refundDate` | `string` | <span class="badge-optional">Optional</span> |
| `reason` | `string` | <span class="badge-optional">Optional</span> |
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
| `originalPartnerReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `approvalCode` | `string` | <span class="badge-optional">Optional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Optional</span> |
| `merchantId` | `string` | <span class="badge-optional">Optional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `reason` | `string` | <span class="badge-optional">Optional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `DirectDebitPaymentCancelResponse`**

DirectDebitPaymentCancelResponse is the response body for Direct Debit Payment Cancel. `originalReferenceNo` and `cancelTime` are Conditional — present only on success.

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
| `merchantId` | `string` | <span class="badge-optional">Optional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Optional</span> |
| `partnerRefundNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `refundAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Optional</span> |
| `reason` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `DirectDebitPaymentRefundResponse`**

DirectDebitPaymentRefundResponse is the response body for Direct Debit Payment Refund. `originalReferenceNo` is Conditional — present only on success. `refundNo`, `partnerRefundNo`, and `refundTime` are Mandatory.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Optional</span> |
| `partnerTrxId` | `string` | <span class="badge-optional">Optional</span> |
| `refundNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `partnerRefundNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `refundAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `refundTime` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

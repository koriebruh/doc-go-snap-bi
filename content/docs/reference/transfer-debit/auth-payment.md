---
weight: 1
title: "Auth Payment"
description: "Card-style authorize/capture/void/refund flow: hold funds with AuthPayment, then capture, void, or refund; each write has a matching query call."
---

## Auth Payment

Card-style authorize/capture/void/refund flow: hold funds with AuthPayment, then capture, void, or refund; each write has a matching query call.

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

AuthPayment calls the SNAP Auth Payment endpoint (Service Code 63, HTTP POST). It places a hold on funds without charging them. Pass `hb` with everything except `Body` already set — `AuthPayment` marshals the request itself and uses those exact bytes for both signing and the wire body.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func AuthPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AuthPaymentRequest) (AuthPaymentResponse, error)
```

**Request &mdash; `AuthPaymentRequest`**

AuthPaymentRequest is the request body for Auth Payment. It places a hold on funds — Capture (65) later charges some or all of it, Void (67) releases what wasn't captured.

`items` (a list of purchased goods) has no fixed schema in the standard, so it's typed `json.RawMessage` — the same treatment as `additionalInfo` and every other field the standard leaves genuinely untyped.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `merchantId` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `feeType` | `string` | <span class="badge-optional">Optional</span> |
| `mcc` | `string` | <span class="badge-optional">Optional</span> |
| `productCode` | `string` | <span class="badge-optional">Optional</span> |
| `title` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `items` | `json.RawMessage` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `AuthPaymentResponse`**

AuthPaymentResponse is the response body for Auth Payment. `referenceNo` is Conditional — present only on success.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `snap.Money` | <span class="badge-mandatory">Mandatory</span> |
| `paidTime` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |


---

### `AuthPaymentQuery`

AuthPaymentQuery calls the SNAP Payment Query endpoint (Service Code 64, HTTP POST) to check a previous Auth Payment's status. Pass `hb` with everything except `Body` already set — `AuthPaymentQuery` marshals the request itself.

```go
func AuthPaymentQuery(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AuthPaymentQueryRequest) (AuthPaymentQueryResponse, error)
```

**Request &mdash; `AuthPaymentQueryRequest`**

AuthPaymentQueryRequest is the request body for Payment Query. No field is Mandatory — query by whichever reference, merchant, or store ID you have.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `merchantId` | `string` | <span class="badge-optional">Optional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `AuthPaymentQueryResponse`**

AuthPaymentQueryResponse is the response body for Payment Query. `paidTime` and `latestTransactionStatus` are Mandatory.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `paidTime` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `latestTransactionStatus` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `transactionStatusDesc` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |


---

### `AuthCapture`

AuthCapture calls the SNAP Capture endpoint (Service Code 65, HTTP POST). Pass `hb` with everything except `Body` already set — `AuthCapture` marshals the request itself.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func AuthCapture(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AuthCaptureRequest) (AuthCaptureResponse, error)
```

**Request &mdash; `AuthCaptureRequest`**

AuthCaptureRequest is the request body for Capture. It charges some or all of an amount held by Auth Payment (63) — call it multiple times for partial captures.

`lastCapture` is a string holding `"true"`/`"false"`, not a real boolean — set it to mark the final capture in a partial-capture sequence.

| Field | Type | Presence |
|---|---|---|
| `originalReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `merchantId` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `partnerCaptureNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `captureAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `title` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `lastCapture` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `AuthCaptureResponse`**

AuthCaptureResponse is the response body for Capture. `captureNo` and `captureTime` are Conditional — present only on success.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerCaptureNo` | `string` | <span class="badge-optional">Optional</span> |
| `captureNo` | `string` | <span class="badge-optional">Optional</span> |
| `captureAmount` | `snap.Money` | <span class="badge-mandatory">Mandatory</span> |
| `captureTime` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |


---

### `AuthCaptureQuery`

AuthCaptureQuery calls the SNAP Capture Query endpoint (Service Code 66, HTTP POST) to check a previous Capture's status. Pass `hb` with everything except `Body` already set — `AuthCaptureQuery` marshals the request itself.

```go
func AuthCaptureQuery(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AuthCaptureQueryRequest) (AuthCaptureQueryResponse, error)
```

**Request &mdash; `AuthCaptureQueryRequest`**

AuthCaptureQueryRequest is the request body for Capture Query (Service Code 66). `originalReferenceNo`, `merchantId`, and `partnerCaptureNo` are Mandatory.

| Field | Type | Presence |
|---|---|---|
| `originalReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `merchantId` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `captureNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerCaptureNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `AuthCaptureQueryResponse`**

AuthCaptureQueryResponse is the response body for Capture Query. `captureAmount` and `partnerCaptureNo` are Mandatory here — unlike Capture's own response, where `partnerCaptureNo` is Optional. `latestCaptureStatus` is one of `INIT`, `SUCCESS`, or `FAILED`.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `captureNo` | `string` | <span class="badge-optional">Optional</span> |
| `captureAmount` | `snap.Money` | <span class="badge-mandatory">Mandatory</span> |
| `captureTime` | `string` | <span class="badge-optional">Optional</span> |
| `latestCaptureStatus` | `string` | <span class="badge-optional">Optional</span> |
| `partnerCaptureNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |


---

### `AuthVoid`

AuthVoid calls the SNAP Void endpoint (Service Code 67, HTTP POST). Pass `hb` with everything except `Body` already set — `AuthVoid` marshals the request itself.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func AuthVoid(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AuthVoidRequest) (AuthVoidResponse, error)
```

**Request &mdash; `AuthVoidRequest`**

AuthVoidRequest is the request body for Void. It releases funds a hold from Auth Payment (63) never captured.

`voidRemainingAmount` is a string holding `"true"`/`"false"`, the same convention as Capture's `lastCapture`.

| Field | Type | Presence |
|---|---|---|
| `originalReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `merchantId` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `voidAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `partnerVoidNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `voidRemainingAmount` | `string` | <span class="badge-optional">Optional</span> |
| `reason` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `AuthVoidResponse`**

AuthVoidResponse is the response body for Void. `voidNo` and `voidTime` are Conditional — present only on success.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `voidNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerVoidNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `voidAmount` | `snap.Money` | <span class="badge-mandatory">Mandatory</span> |
| `voidTime` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |


---

### `AuthVoidQuery`

AuthVoidQuery calls the SNAP Void Query endpoint (Service Code 68, HTTP POST) to check a previous Void's status. Pass `hb` with everything except `Body` already set — `AuthVoidQuery` marshals the request itself.

```go
func AuthVoidQuery(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AuthVoidQueryRequest) (AuthVoidQueryResponse, error)
```

**Request &mdash; `AuthVoidQueryRequest`**

AuthVoidQueryRequest is the request body for Void Query. `originalReferenceNo`, `merchantId`, and `partnerVoidNo` are Mandatory.

| Field | Type | Presence |
|---|---|---|
| `originalReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `merchantId` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `voidNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerVoidNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `AuthVoidQueryResponse`**

AuthVoidQueryResponse is the response body for Void Query. `voidAmount` is Mandatory; `partnerVoidNo` is Optional here — unlike Void's own response, where it's Mandatory. `latestVoidStatus` is one of `INIT`, `SUCCESS`, or `FAILED`.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `voidNo` | `string` | <span class="badge-optional">Optional</span> |
| `voidAmount` | `snap.Money` | <span class="badge-mandatory">Mandatory</span> |
| `voidTime` | `string` | <span class="badge-optional">Optional</span> |
| `latestVoidStatus` | `string` | <span class="badge-optional">Optional</span> |
| `partnerVoidNo` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |


---

### `AuthRefund`

AuthRefund calls the SNAP Refund endpoint (Service Code 69, HTTP POST). Pass `hb` with everything except `Body` already set — `AuthRefund` marshals the request itself.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func AuthRefund(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AuthRefundRequest) (AuthRefundResponse, error)
```

**Request &mdash; `AuthRefundRequest`**

AuthRefundRequest is the request body for Refund. It reverses an amount already captured by Auth Capture (65).

`originalCaptureNo` is Conditional — unlike most Conditional fields in this package, it's required when the *original* transaction failed, not when it succeeded.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerRefundNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `merchantId` | `string` | <span class="badge-optional">Optional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `originalCaptureNo` | `string` | <span class="badge-optional">Optional</span> |
| `refundAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Optional</span> |
| `reason` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `AuthRefundResponse`**

AuthRefundResponse is the response body for Refund. `refundNo` and `refundTime` are Mandatory; `partnerRefundNo` is Optional.

`originalCaptureNo` and `originalReferenceNo` are both Conditional but on opposite triggers: `originalCaptureNo` appears when the transaction failed, `originalReferenceNo` when it succeeded.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originalCaptureNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerRefundNo` | `string` | <span class="badge-optional">Optional</span> |
| `refundNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `refundAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `refundTime` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

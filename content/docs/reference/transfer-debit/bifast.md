---
weight: 4
title: "Direct Debit BI-FAST"
description: "BI-FAST e-mandate registration and payment, with its inbound notification type."
---

## Direct Debit BI-FAST

BI-FAST e-mandate registration and payment, with its inbound notification type.

```go
resp, err := transferdebit.DirectDebitBIFASTPayment(ctx, transport, hb, transferdebit.DirectDebitBIFASTPaymentRequest{
	PartnerReferenceNo: "2020102900000000000001",
	CustomerReference: "...",
	BeneficiaryAccountNo: "1234567890",
	BeneficiaryAccountName: "Jane Doe",
	TransactionDate: "2026-09-14T10:00:00+07:00",
	BankCode: "...",
	SourceAccountNo: "1234567890",
	SourceAccountName: "Jane Doe",
	EMandateReffID: "2026-09-14T10:00:00+07:00",
})
if err != nil {
	// errors.Is(err, snap.ErrBadRequest), snap.ErrUnauthorized, etc.
}
```

### `DirectDebitBIFASTEMandateRegistration`

DirectDebitBIFASTEMandateRegistration calls the SNAP Registrasi e-Mandate endpoint (Service Code 70, HTTP POST). Pass `hb` with everything except `Body` already set — `DirectDebitBIFASTEMandateRegistration` marshals the request itself and uses those exact bytes for both signing and the wire body.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func DirectDebitBIFASTEMandateRegistration(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req DirectDebitBIFASTEMandateRegistrationRequest) (DirectDebitBIFASTEMandateRegistrationResponse, error)
```

**Request &mdash; `DirectDebitBIFASTEMandateRegistrationRequest`**

DirectDebitBIFASTEMandateRegistrationRequest is the request body for Registrasi e-Mandate. `bankCode`, `sourceAccountNo`, `sourceAccountName`, `billerId`, `billerName`, `customerId`, and `expiredDatetime` are Mandatory.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `bankCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `sourceAccountNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `sourceAccountName` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `maxAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `billerId` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `billerName` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `customerId` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `expiredDatetime` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `DirectDebitBIFASTEMandateRegistrationResponse`**

DirectDebitBIFASTEMandateRegistrationResponse is the response body for Registrasi e-Mandate. `referenceNo` is Conditional — present only on success. `eMandateReffId` is Mandatory; use it in the payment call below.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `eMandateReffId` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |


---

### `DirectDebitBIFASTPayment`

DirectDebitBIFASTPayment calls the SNAP Trigger Direct Debit Transfer / Payment endpoint (Service Code 71, HTTP POST). Pass `hb` with everything except `Body` already set — `DirectDebitBIFASTPayment` marshals the request itself.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func DirectDebitBIFASTPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req DirectDebitBIFASTPaymentRequest) (DirectDebitBIFASTPaymentResponse, error)
```

**Request &mdash; `DirectDebitBIFASTPaymentRequest`**

DirectDebitBIFASTPaymentRequest is the request body for Trigger Direct Debit Transfer / Payment. `eMandateReffId` comes from a prior e-Mandate Registration call.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `currency` | `string` | <span class="badge-optional">Optional</span> |
| `customerReference` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `feeType` | `string` | <span class="badge-optional">Optional</span> |
| `remark` | `string` | <span class="badge-optional">Optional</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryAccountName` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `transactionDate` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `bankCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `sourceAccountNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `sourceAccountName` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `eMandateReffId` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `DirectDebitBIFASTPaymentResponse`**

DirectDebitBIFASTPaymentResponse is the response body for Trigger Direct Debit Transfer / Payment. `referenceNo` is Conditional — present only on success.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |


---

### `Direct Debit BI-FAST Notification`

{{< callout type="info" >}}
Inbound only &mdash; this package does not call an endpoint for this. A partner/switcher POSTs it to **your** callback URL; unmarshal the body into `DirectDebitBIFASTNotificationRequest` after verifying it with `snap.ServerVerifier` (see [Verifying inbound requests](/docs/concepts/webhooks/)), then reply with the shape below.
{{< /callout >}}

**Received &mdash; `DirectDebitBIFASTNotificationRequest`**

DirectDebitBIFASTNotificationRequest is the request body for Notify (Service Code 72) — a settlement callback the PJP receives, not a call this package makes. Wire your own HTTP handler for this path, authenticate the inbound call with `ServerVerifier.VerifyTransactionRequest`, then `json.Unmarshal` the body into this type.

`originalReferenceNo`, `transactionStatus`, `eMandateReffId`, `sourceAccountNo`, and `sourceAccountName` are Mandatory; every other field is Optional.

{{< callout type="default" >}}
The status field here is `transactionStatus`, not `latestTransactionStatus`
like everywhere else in the package — that's the standard's own naming,
kept as-is rather than normalized.
{{< /callout >}}

| Field | Type | Presence |
|---|---|---|
| `originalReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Optional</span> |
| `transactionStatus` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `transactionStatusDesc` | `string` | <span class="badge-optional">Optional</span> |
| `eMandateReffId` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `sourceAccountNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `sourceAccountName` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `traceNo` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Your handler replies with &mdash; `DirectDebitBIFASTNotificationResponse`**

DirectDebitBIFASTNotificationResponse is envelope-only — just `responseCode` and `responseMessage`, no other fields.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |

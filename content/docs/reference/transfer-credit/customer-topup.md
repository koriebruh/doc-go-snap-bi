---
weight: 4
title: "Customer Top Up"
description: "Top-up an e-money/e-wallet account: inquiry, top-up, and status check."
---

## Customer Top Up

Top-up an e-money/e-wallet account: inquiry, top-up, and status check.

```go
resp, err := transfercredit.CustomerTopUp(ctx, transport, hb, transfercredit.CustomerTopUpRequest{
	PartnerReferenceNo: "2020102900000000000001",
})
if err != nil {
	// errors.Is(err, snap.ErrBadRequest), snap.ErrUnauthorized, etc.
}
```

### `AccountInquiryCustomerTopUp`

AccountInquiryCustomerTopUp calls the SNAP Account Inquiry - Customer Top Up endpoint (Service Code 37, path .../{version}/emoney/account-inquiry). hb must already carry every field snap.HeaderBuilder needs except Body, which AccountInquiryCustomerTopUp sets itself so the exact marshaled bytes are used for both signing and the wire body.

```go
func AccountInquiryCustomerTopUp(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AccountInquiryCustomerTopUpRequest) (AccountInquiryCustomerTopUpResponse, error)
```

**Request &mdash; `AccountInquiryCustomerTopUpRequest`**

AccountInquiryCustomerTopUpRequest is the request body for Account Inquiry - Customer Top Up (Service Code 37). Amount is the only Mandatory field. CustomerNumber is Conditional — required unless a B2B2C access token already identifies the customer.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `customerNumber` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `snap.Money` | <span class="badge-mandatory">Mandatory</span> |
| `transactionDate` | `string` | <span class="badge-optional">Optional</span> |

**Response &mdash; `AccountInquiryCustomerTopUpResponse`**

AccountInquiryCustomerTopUpResponse is the response body for Account Inquiry - Customer Top Up. `customerNumber` comes back masked (e.g. `"XXXXXXXXX1857"`). `customerMonthlyInLimit` is `json.RawMessage` because the standard shows it as a quoted number — a plain string field can't safely assume every issuer sends it the same way.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `sessionId` | `string` | <span class="badge-optional">Optional</span> |
| `customerNumber` | `string` | <span class="badge-optional">Optional</span> |
| `customerName` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `customerMonthlyInLimit` | `json.RawMessage` | <span class="badge-optional">Optional</span> |
| `minAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `maxAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `feeAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `feeType` | `string` | <span class="badge-optional">Optional</span> |


---

### `CustomerTopUp`

CustomerTopUp calls the SNAP Customer Top Up endpoint (Service Code 38, path .../{version}/emoney/topup). hb must already carry every field snap.HeaderBuilder needs except Body, which CustomerTopUp sets itself so the exact marshaled bytes are used for both signing and the wire body.

This operation is not idempotent and isn't retried automatically. If you retry a failed or timed-out call, reuse the same X-EXTERNAL-ID — the server's duplicate-detection keys on it, so a fresh one risks a duplicate top-up.

```go
func CustomerTopUp(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req CustomerTopUpRequest) (CustomerTopUpResponse, error)
```

**Request &mdash; `CustomerTopUpRequest`**

CustomerTopUpRequest is the request body for Customer Top Up (Service Code 38). `partnerReferenceNo` is the only Mandatory field. `categoryId` is `json.RawMessage` for the same reason as `customerMonthlyInLimit` above: the standard shows it as a quoted number, not a guaranteed string.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `customerNumber` | `string` | <span class="badge-optional">Optional</span> |
| `customerName` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `feeAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Optional</span> |
| `sessionId` | `string` | <span class="badge-optional">Optional</span> |
| `categoryId` | `json.RawMessage` | <span class="badge-optional">Optional</span> |
| `notes` | `string` | <span class="badge-optional">Optional</span> |

**Response &mdash; `CustomerTopUpResponse`**

CustomerTopUpResponse is the response body for Customer Top Up. `referenceNumber` isn't in the standard's field table, but it does appear in the standard's own worked example, so it's included here too.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `sessionId` | `string` | <span class="badge-optional">Optional</span> |
| `customerNumber` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `referenceNumber` | `string` | <span class="badge-optional">Optional</span> |


---

### `CustomerTopUpInquiryStatus`

CustomerTopUpInquiryStatus calls the SNAP Customer Top Up Inquiry Status endpoint (Service Code 39, path .../{version}/emoney/topup-status). hb must already carry every field snap.HeaderBuilder needs except Body, which CustomerTopUpInquiryStatus sets itself so the exact marshaled bytes are used for both signing and the wire body.

```go
func CustomerTopUpInquiryStatus(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req CustomerTopUpInquiryStatusRequest) (CustomerTopUpInquiryStatusResponse, error)
```

**Request &mdash; `CustomerTopUpInquiryStatusRequest`**

CustomerTopUpInquiryStatusRequest is the request body for Customer Top Up Inquiry Status (Service Code 39) — the same shape as [`TransactionStatusInquiryBankRequest`](/docs/reference/transfer-credit/transaction-status/), under its own type name. `serviceCode` is the only Mandatory field.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Optional</span> |
| `serviceCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `transactionDate` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `CustomerTopUpInquiryStatusResponse`**

CustomerTopUpInquiryStatusResponse is the response body for Customer Top Up Inquiry Status — the same shape as `TransactionStatusInquiryBankResponse`, under its own type name.

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


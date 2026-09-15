---
weight: 6
title: "Transfer to Bank"
description: "Inquiry and payment for a transfer routed to an external bank."
---

## Transfer to Bank

Inquiry and payment for a transfer routed to an external bank.

```go
resp, err := transfercredit.TransferToBankPayment(ctx, transport, hb, transfercredit.TransferToBankPaymentRequest{
	PartnerReferenceNo: "2020102900000000000001",
	CustomerNumber: "2020102900000000000001",
	BeneficiaryAccountNumber: "...",
	Amount: snap.Money{Value: "500000.00", Currency: "IDR"},
})
if err != nil {
	// errors.Is(err, snap.ErrBadRequest), snap.ErrUnauthorized, etc.
}
```

### `TransferToBankAccountInquiry`

TransferToBankAccountInquiry calls the SNAP Transfer To Bank - Account Inquiry endpoint (Service Code 42, path .../{version}/emoney/bank-account-inquiry, HTTP POST — no method override). hb must already carry every field snap.HeaderBuilder needs except Body, which TransferToBankAccountInquiry sets itself so the exact marshaled bytes are used for both signing and the wire body.

```go
func TransferToBankAccountInquiry(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req TransferToBankAccountInquiryRequest) (TransferToBankAccountInquiryResponse, error)
```

**Request &mdash; `TransferToBankAccountInquiryRequest`**

TransferToBankAccountInquiryRequest is the request body for API Transfer To Bank - Account Inquiry (Service Code 42). CustomerNumber and Amount are Mandatory. Note the wire field is `CustomerNumber` (capital C) here — every other endpoint uses lowercase `customerNumber`. Likely a documentation typo, but this package matches the documented casing exactly since no example confirms a fix.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `CustomerNumber` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `amount` | `snap.Money` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryAccountNumber` | `string` | <span class="badge-optional">Optional</span> |

**Response &mdash; `TransferToBankAccountInquiryResponse`**

TransferToBankAccountInquiryResponse is the response body for API Transfer To Bank - Account Inquiry.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `accountType` | `string` | <span class="badge-optional">Optional</span> |
| `beneficiaryAccountNumber` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryAccountName` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryBankCode` | `string` | <span class="badge-optional">Optional</span> |
| `beneficiaryBankShortName` | `string` | <span class="badge-optional">Optional</span> |
| `beneficiaryBankName` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `snap.Money` | <span class="badge-mandatory">Mandatory</span> |
| `sessionId` | `string` | <span class="badge-optional">Optional</span> |


---

### `TransferToBankPayment`

TransferToBankPayment calls the SNAP Transfer To Bank - Payment Transaction endpoint (Service Code 43, path .../{version}/emoney/transfer-bank, HTTP POST — no method override). hb must already carry every field snap.HeaderBuilder needs except Body, which TransferToBankPayment sets itself so the exact marshaled bytes are used for both signing and the wire body.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func TransferToBankPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req TransferToBankPaymentRequest) (TransferToBankPaymentResponse, error)
```

**Request &mdash; `TransferToBankPaymentRequest`**

TransferToBankPaymentRequest is the request body for API Transfer To Bank - Payment Transaction (Service Code 43). PartnerReferenceNo, CustomerNumber, BeneficiaryAccountNumber, and Amount are Mandatory. Unlike Account Inquiry above, `customerNumber` here uses the normal lowercase casing.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `customerNumber` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `accountType` | `string` | <span class="badge-optional">Optional</span> |
| `beneficiaryAccountNumber` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `beneficiaryBankCode` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `snap.Money` | <span class="badge-mandatory">Mandatory</span> |
| `sessionId` | `string` | <span class="badge-optional">Optional</span> |
| `feeType` | `string` | <span class="badge-optional">Optional</span> |

**Response &mdash; `TransferToBankPaymentResponse`**

TransferToBankPaymentResponse is the response body for API Transfer To Bank - Payment Transaction. Note `referenceNo` and `referenceNumber` are two separate fields, both present — not a duplicate.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Optional</span> |
| `referenceNumber` | `string` | <span class="badge-mandatory">Mandatory</span> |


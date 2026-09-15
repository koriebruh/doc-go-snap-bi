---
weight: 7
title: "Transfer to OTC"
description: "Create, cancel, and check the status of an over-the-counter cash-pickup transfer."
---

## Transfer to OTC

Create, cancel, and check the status of an over-the-counter cash-pickup transfer.

```go
resp, err := transfercredit.TransferToOTCCreatePayment(ctx, transport, hb, transfercredit.TransferToOTCCreatePaymentRequest{
	PartnerReferenceNo: "2020102900000000000001",
	CustomerNumber: "2020102900000000000001",
	OTP: "...",
	Amount: snap.Money{Value: "500000.00", Currency: "IDR"},
})
if err != nil {
	// errors.Is(err, snap.ErrBadRequest), snap.ErrUnauthorized, etc.
}
```

### `TransferToOTCCreatePayment`

TransferToOTCCreatePayment calls the SNAP Transfer To OTC - Create Payment endpoint (Service Code 44, path .../{version}/emoney/otc-cashout, HTTP POST — no method override). hb must already carry every field snap.HeaderBuilder needs except Body, which TransferToOTCCreatePayment sets itself so the exact marshaled bytes are used for both signing and the wire body.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func TransferToOTCCreatePayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req TransferToOTCCreatePaymentRequest) (TransferToOTCCreatePaymentResponse, error)
```

**Request &mdash; `TransferToOTCCreatePaymentRequest`**

TransferToOTCCreatePaymentRequest is the request body for API Transfer To OTC - Create Payment (Service Code 44). PartnerReferenceNo, CustomerNumber, OTP, and Amount are mandatory per the Guides tab.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `customerNumber` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `otp` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `amount` | `snap.Money` | <span class="badge-mandatory">Mandatory</span> |
| `feeType` | `string` | <span class="badge-optional">Optional</span> |

**Response &mdash; `TransferToOTCCreatePaymentResponse`**

TransferToOTCCreatePaymentResponse is the response body for API Transfer To OTC - Create Payment.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Optional</span> |


---

### `TransferToOTCCancelPayment`

TransferToOTCCancelPayment calls the SNAP Transfer To OTC - Cancel Payment endpoint (Service Code 46, HTTP POST). The standard's own docs disagree on the exact path (`.../emoney/otc-cancel` vs `.../otc/cashout/cancel`) — this package makes no assumption either way and always uses the `EndpointURL` you supply in `hb`. It sets `Body` itself so the exact marshaled bytes are used for both signing and the wire body.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func TransferToOTCCancelPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req TransferToOTCCancelPaymentRequest) (TransferToOTCCancelPaymentResponse, error)
```

**Request &mdash; `TransferToOTCCancelPaymentRequest`**

TransferToOTCCancelPaymentRequest is the request body for API Transfer To OTC - Cancel Payment (Service Code 46). OriginalPartnerReferenceNo, CustomerNumber, and Reason are mandatory per the Guides tab; OriginalReferenceNo is Conditional here (it flips to Mandatory in the response — see TransferToOTCCancelPaymentResponse's doc comment).

| Field | Type | Presence |
|---|---|---|
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Optional</span> |
| `customerNumber` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `reason` | `string` | <span class="badge-mandatory">Mandatory</span> |

**Response &mdash; `TransferToOTCCancelPaymentResponse`**

TransferToOTCCancelPaymentResponse is the response body for API Transfer To OTC - Cancel Payment. OriginalReferenceNo is Mandatory here (it was Conditional on the request). CancelTime is Conditional — required only if the cancellation succeeded — so it's modeled Optional.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originalReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `cancelTime` | `string` | <span class="badge-optional">Optional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Optional</span> |


---

### `TransferToOTCTransferStatus`

TransferToOTCTransferStatus calls the SNAP Transfer To OTC - Transfer Status endpoint (Service Code 45, path .../{version}/emoney/otc-status, HTTP POST — no method override). hb must already carry every field snap.HeaderBuilder needs except Body, which TransferToOTCTransferStatus sets itself so the exact marshaled bytes are used for both signing and the wire body.

```go
func TransferToOTCTransferStatus(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req TransferToOTCTransferStatusRequest) (TransferToOTCTransferStatusResponse, error)
```

**Request &mdash; `TransferToOTCTransferStatusRequest`**

TransferToOTCTransferStatusRequest is the request body for API Transfer To OTC - Transfer Status (Service Code 45). It follows the same shape as [`TransactionStatusInquiryBankRequest`](/docs/reference/transfer-credit/transaction-status/), plus CustomerNumber and a Mandatory (not Optional) Amount. ServiceCode and CustomerNumber are Mandatory.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Optional</span> |
| `serviceCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `transactionDate` | `string` | <span class="badge-optional">Optional</span> |
| `customerNumber` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `amount` | `snap.Money` | <span class="badge-mandatory">Mandatory</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `TransferToOTCTransferStatusResponse`**

TransferToOTCTransferStatusResponse is the response body for API Transfer To OTC - Transfer Status — field-identical to [`TransactionStatusInquiryBankResponse`](/docs/reference/transfer-credit/transaction-status/), modeled as its own type since each SNAP service code gets a distinct type even when shapes match.

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


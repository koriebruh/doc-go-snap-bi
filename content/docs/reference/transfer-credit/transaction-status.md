---
weight: 9
title: "Transaction Status Inquiry"
description: "Check a previously submitted transfer's status against a bank or non-bank counterparty."
---

## Transaction Status Inquiry

Check a previously submitted transfer's status against a bank or non-bank counterparty.

```go
resp, err := transfercredit.TransactionStatusInquiryBank(ctx, transport, hb, transfercredit.TransactionStatusInquiryBankRequest{
	ServiceCode: "...",
})
if err != nil {
	// errors.Is(err, snap.ErrBadRequest), snap.ErrUnauthorized, etc.
}
```

### `TransactionStatusInquiryBank`

TransactionStatusInquiryBank calls the SNAP Transaction Status Inquiry Bank endpoint (Service Code 36, path .../{version}/transfer/status). hb must already carry every field snap.HeaderBuilder needs except Body, which TransactionStatusInquiryBank sets itself so the exact marshaled bytes are used for both signing and the wire body.

```go
func TransactionStatusInquiryBank(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req TransactionStatusInquiryBankRequest) (TransactionStatusInquiryBankResponse, error)
```

**Request &mdash; `TransactionStatusInquiryBankRequest`**

TransactionStatusInquiryBankRequest is the request body for API Transaction Status Inquiry Bank (Service Code 36). ServiceCode is the only mandatory field per the Guides tab — it points at the original transaction's service code (e.g. "17" for Intrabank).

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Optional</span> |
| `serviceCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `transactionDate` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `TransactionStatusInquiryBankResponse`**

TransactionStatusInquiryBankResponse is the response body for API Transaction Status Inquiry Bank — a flat structure, no nested data object. The original request fields are echoed back (Optional here regardless of their request cardinality). `latestTransactionStatus` is a 2-digit code: `00` Success, `01` Initiated, `02` Paying, `03` Pending, `04` Refunded, `05` Canceled, `06` Failed, `07` Not found.

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


---

### `TransactionStatusInquiryNonBank`

TransactionStatusInquiryNonBank calls the SNAP Transaction Status Inquiry (non-bank) endpoint (Service Code 53, path .../{version}/qr/qr-mpm-status). Despite the shared `qr/` path prefix, this is its own category, separate from QR/MPM. hb must already carry every field snap.HeaderBuilder needs except Body, which TransactionStatusInquiryNonBank sets itself so the exact marshaled bytes are used for both signing and the wire body.

This is a read-only status query and carries no non-idempotency note, matching TransactionStatusInquiryBank's precedent.

```go
func TransactionStatusInquiryNonBank(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req TransactionStatusInquiryNonBankRequest) (TransactionStatusInquiryNonBankResponse, error)
```

**Request &mdash; `TransactionStatusInquiryNonBankRequest`**

TransactionStatusInquiryNonBankRequest is the request body for API Transaction Status Inquiry (non-bank, Service Code 53) — the same 7 base fields as `TransactionStatusInquiryBankRequest` above, plus OriginalResponseCode, OriginalResponseMessage, SessionID, and RequestID.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalExternalId` | `string` | <span class="badge-optional">Optional</span> |
| `serviceCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `transactionDate` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |
| `originalResponseCode` | `string` | <span class="badge-optional">Optional</span> |
| `originalResponseMessage` | `string` | <span class="badge-optional">Optional</span> |
| `sessionId` | `string` | <span class="badge-optional">Optional</span> |
| `requestId` | `string` | <span class="badge-optional">Optional</span> |

**Response &mdash; `TransactionStatusInquiryNonBankResponse`**

TransactionStatusInquiryNonBankResponse is the response body for API Transaction Status Inquiry (non-bank) — field-identical to `TransactionStatusInquiryBankResponse`, modeled as its own type since each SNAP service code gets a distinct type even when shapes match.

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


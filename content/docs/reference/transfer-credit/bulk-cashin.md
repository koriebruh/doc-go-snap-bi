---
weight: 5
title: "Bulk Cash In"
description: "Submit a batch of cash-in instructions; settlement results arrive as an inbound notification, not a synchronous response."
---

## Bulk Cash In

Submit a batch of cash-in instructions; settlement results arrive as an inbound notification, not a synchronous response.

```go
resp, err := transfercredit.SubmitBulkCashIn(ctx, transport, hb, transfercredit.SubmitBulkCashInRequest{
	TransactionDate: "2026-09-14T10:00:00+07:00",
})
if err != nil {
	// errors.Is(err, snap.ErrBadRequest), snap.ErrUnauthorized, etc.
}
```

### `SubmitBulkCashIn`

SubmitBulkCashIn calls the SNAP Submit Bulk Cash In endpoint (Service Code 40, path .../{version}/emoney/bulk-cashin-payment). hb must already carry every field snap.HeaderBuilder needs except Body, which SubmitBulkCashIn sets itself so the exact marshaled bytes are used for both signing and the wire body.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func SubmitBulkCashIn(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req SubmitBulkCashInRequest) (SubmitBulkCashInResponse, error)
```

**Request &mdash; `SubmitBulkCashInRequest`**

SubmitBulkCashInRequest is the request body for API Submit Bulk Cash In (Service Code 40). TransactionDate is the only top-level mandatory field per the Guides tab.

| Field | Type | Presence |
|---|---|---|
| `partnerBulkId` | `string` | <span class="badge-optional">Optional</span> |
| `transactionDate` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `currency` | `string` | <span class="badge-optional">Optional</span> |
| `bulkObject` | `[]BulkCashInItem` | <span class="badge-optional">Optional</span> |
| `feeType` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

{{< details title="BulkCashInItem fields" >}}
BulkCashInItem is one entry in Submit Bulk Cash In's request "bulkObject[]" array. AccountNumber and PartnerReferenceNo are mandatory per the Guides tab.

| Field | Type | Presence |
|---|---|---|
| `accountNumber` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `accountName` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |
{{< /details >}}

**Response &mdash; `SubmitBulkCashInResponse`**

SubmitBulkCashInResponse is the response body for API Submit Bulk Cash In. Note its field is `bulkid` (lowercase d) — likely a typo in the standard, but this package matches the documented wire casing exactly since no worked example confirms a fix. The Notify Bulk Cash In response below uses the normal camelCase `bulkId` instead.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `bulkid` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `partnerBulkId` | `string` | <span class="badge-optional">Optional</span> |


---

### `Notify Bulk Cash In`

{{< callout type="info" >}}
Inbound only &mdash; this package does not call an endpoint for this. A partner/switcher POSTs it to **your** callback URL; unmarshal the body into `NotifyBulkCashInRequest` after verifying it with `snap.ServerVerifier` (see [Verifying inbound requests](/docs/concepts/webhooks/)), then reply with the shape below.
{{< /callout >}}

**Received &mdash; `NotifyBulkCashInRequest`**

NotifyBulkCashInRequest is the request body for API Notify Bulk Cash In (Service Code 41, path .../{version}/emoney/bulk-cashin-notify). This is a settlement callback the PJP receives, not a call this package makes — wire your own HTTP handler for this path, authenticate the request with `ServerVerifier.VerifyTransactionRequest`, then `json.Unmarshal` the body into this type. BulkID and PartnerBulkID are Mandatory.

| Field | Type | Presence |
|---|---|---|
| `bulkId` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `partnerBulkId` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `bulkObject` | `[]BulkCashInNotificationItem` | <span class="badge-mandatory">Mandatory</span> |

{{< details title="BulkCashInNotificationItem fields" >}}
BulkCashInNotificationItem is one entry in the notification's `bulkObject[]` array — a settlement-result shape, distinct from `BulkCashInItem`'s transfer-instruction shape. CustomerNumber, ReferenceNo, PartnerReferenceNo, ResponseCode, and ResponseMessage are all Mandatory.

| Field | Type | Presence |
|---|---|---|
| `customerNumber` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `customerName` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `referenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |
{{< /details >}}

**Your handler replies with &mdash; `NotifyBulkCashInResponse`**

NotifyBulkCashInResponse is the response body your handler sends back. BulkID and PartnerBulkID are Mandatory. Its `bulkId` field is normal camelCase — unlike `SubmitBulkCashInResponse`'s lowercase `bulkid` above.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `bulkId` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `partnerBulkId` | `string` | <span class="badge-mandatory">Mandatory</span> |


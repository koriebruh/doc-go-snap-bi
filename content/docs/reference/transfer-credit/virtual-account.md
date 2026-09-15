---
weight: 3
title: "Virtual Account"
description: "Full VA lifecycle: management (create/update/inquire/delete) and the transaction-side calls (inquiry, payment, status, intrabank variants, report)."
---

## Virtual Account

Full VA lifecycle: management (create/update/inquire/delete) and the transaction-side calls (inquiry, payment, status, intrabank variants, report).

```go
resp, err := transfercredit.CreateVA(ctx, transport, hb, transfercredit.CreateVARequest{
	VirtualAccountName: "Jane Doe",
	TrxID: "...",
})
if err != nil {
	// errors.Is(err, snap.ErrBadRequest), snap.ErrUnauthorized, etc.
}
```

### `CreateVA`

CreateVA calls the SNAP VA - Create VA endpoint (Service Code 27, path .../{version}/transfer-va/create-va). hb must already carry every field snap.HeaderBuilder needs except Body, which CreateVA sets itself so the exact marshaled bytes are used for both signing and the wire body.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it — a fresh X-EXTERNAL-ID on retry risks creating a duplicate VA.

```go
func CreateVA(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req CreateVARequest) (CreateVAResponse, error)
```

**Request &mdash; `CreateVARequest`**

CreateVARequest is the request body for API VA - Create VA (Service Code 27). VirtualAccountName and TrxID are mandatory per the Guides tab; unlike every other Virtual Account endpoint, the identity triple (PartnerServiceID, CustomerNo, VirtualAccountNo) is Optional here.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Optional |
| `customerNo` | `string` | Optional |
| `virtualAccountNo` | `string` | Optional |
| `virtualAccountName` | `string` | Mandatory |
| `trxId` | `string` | Mandatory |
| `totalAmount` | `*snap.Money` | Optional |
| `billDetails` | `[]BillDetail` | Optional |
| `freeTexts` | `[]LocalizedText` | Optional |
| `virtualAccountTrxType` | `string` | Optional |
| `feeAmount` | `*snap.Money` | Optional |
| `expiredDate` | `string` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |

{{< details title="BillDetail fields" >}}
BillDetail is one entry in the `billDetails[]` array (max 24 entries) used across the Virtual Account group. `billReferenceNo` is `json.RawMessage` because the standard documents it as Numeric but some issuers send it as a bare JSON number — when you set it yourself (e.g. in `CreateVARequest`), supply a complete JSON value like `json.RawMessage(\`"BILLREF1"\`)` or `json.RawMessage(\`123\`)`, not a bare Go string.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | Optional |
| `billNo` | `string` | Optional |
| `billName` | `string` | Optional |
| `billShortName` | `string` | Optional |
| `billDescription` | `*LocalizedText` | Optional |
| `billSubCompany` | `string` | Optional |
| `billAmount` | `*snap.Money` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |
| `billAmountLabel` | `string` | Optional |
| `billAmountValue` | `string` | Optional |
| `billReferenceNo` | `json.RawMessage` | Optional |
| `status` | `string` | Optional |
| `reason` | `*LocalizedText` | Optional |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
LocalizedText is the shared {english, indonesia} bilingual text shape used across the Virtual Account sub-group (e.g. inquiryReason, paymentFlagReason, billDescription, per-bill reason, freeTexts[] entries). Both fields are String, unmarked for M/O in the source, so both carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | Optional |
| `indonesia` | `string` | Optional |
{{< /details >}}

**Response &mdash; `CreateVAResponse`**

CreateVAResponse is the response body for API VA - Create VA.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Mandatory |
| `responseMessage` | `string` | Mandatory |
| `virtualAccountData` | `*CreateVAData` | Optional |

{{< details title="CreateVAData fields" >}}
CreateVAData is the "virtualAccountData" object in CreateVAResponse.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Optional |
| `customerNo` | `string` | Optional |
| `virtualAccountNo` | `string` | Optional |
| `virtualAccountName` | `string` | Optional |
| `trxId` | `string` | Optional |
| `totalAmount` | `*snap.Money` | Optional |
| `billDetails` | `[]BillDetail` | Optional |
| `freeTexts` | `[]LocalizedText` | Optional |
| `virtualAccountTrxType` | `string` | Optional |
| `feeAmount` | `*snap.Money` | Optional |
| `expiredDate` | `string` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |
{{< /details >}}

{{< details title="BillDetail fields" >}}
BillDetail is one entry in the `billDetails[]` array (max 24 entries) used across the Virtual Account group. `billReferenceNo` is `json.RawMessage` because the standard documents it as Numeric but some issuers send it as a bare JSON number — when you set it yourself (e.g. in `CreateVARequest`), supply a complete JSON value like `json.RawMessage(\`"BILLREF1"\`)` or `json.RawMessage(\`123\`)`, not a bare Go string.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | Optional |
| `billNo` | `string` | Optional |
| `billName` | `string` | Optional |
| `billShortName` | `string` | Optional |
| `billDescription` | `*LocalizedText` | Optional |
| `billSubCompany` | `string` | Optional |
| `billAmount` | `*snap.Money` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |
| `billAmountLabel` | `string` | Optional |
| `billAmountValue` | `string` | Optional |
| `billReferenceNo` | `json.RawMessage` | Optional |
| `status` | `string` | Optional |
| `reason` | `*LocalizedText` | Optional |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
LocalizedText is the shared {english, indonesia} bilingual text shape used across the Virtual Account sub-group (e.g. inquiryReason, paymentFlagReason, billDescription, per-bill reason, freeTexts[] entries). Both fields are String, unmarked for M/O in the source, so both carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | Optional |
| `indonesia` | `string` | Optional |
{{< /details >}}


---

### `UpdateVA`

UpdateVA calls the SNAP VA - Update VA endpoint (Service Code 28, path .../{version}/transfer-va/update-va, HTTP PUT). hb must already carry every field snap.HeaderBuilder needs except Method and Body, which UpdateVA sets itself: Method to PUT (the method is fixed by this endpoint, not caller-configurable) and Body so the exact marshaled bytes are used for both signing and the wire body.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func UpdateVA(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req UpdateVARequest) (UpdateVAResponse, error)
```

**Request &mdash; `UpdateVARequest`**

UpdateVARequest is the request body for API VA - Update VA (Service Code 28). PartnerServiceID, CustomerNo, VirtualAccountNo, VirtualAccountName, and TrxID are mandatory per the Guides tab — unlike Create VA, the identity triple is Mandatory here.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Mandatory |
| `customerNo` | `string` | Mandatory |
| `virtualAccountNo` | `string` | Mandatory |
| `virtualAccountName` | `string` | Mandatory |
| `trxId` | `string` | Mandatory |
| `totalAmount` | `*snap.Money` | Optional |
| `billDetails` | `[]BillDetail` | Optional |
| `freeTexts` | `[]LocalizedText` | Optional |
| `virtualAccountTrxType` | `string` | Optional |
| `feeAmount` | `*snap.Money` | Optional |
| `expiredDate` | `string` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |

{{< details title="BillDetail fields" >}}
BillDetail is one entry in the `billDetails[]` array (max 24 entries) used across the Virtual Account group. `billReferenceNo` is `json.RawMessage` because the standard documents it as Numeric but some issuers send it as a bare JSON number — when you set it yourself (e.g. in `CreateVARequest`), supply a complete JSON value like `json.RawMessage(\`"BILLREF1"\`)` or `json.RawMessage(\`123\`)`, not a bare Go string.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | Optional |
| `billNo` | `string` | Optional |
| `billName` | `string` | Optional |
| `billShortName` | `string` | Optional |
| `billDescription` | `*LocalizedText` | Optional |
| `billSubCompany` | `string` | Optional |
| `billAmount` | `*snap.Money` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |
| `billAmountLabel` | `string` | Optional |
| `billAmountValue` | `string` | Optional |
| `billReferenceNo` | `json.RawMessage` | Optional |
| `status` | `string` | Optional |
| `reason` | `*LocalizedText` | Optional |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
LocalizedText is the shared {english, indonesia} bilingual text shape used across the Virtual Account sub-group (e.g. inquiryReason, paymentFlagReason, billDescription, per-bill reason, freeTexts[] entries). Both fields are String, unmarked for M/O in the source, so both carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | Optional |
| `indonesia` | `string` | Optional |
{{< /details >}}

**Response &mdash; `UpdateVAResponse`**

UpdateVAResponse is the response body for API VA - Update VA.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Mandatory |
| `responseMessage` | `string` | Mandatory |
| `virtualAccountData` | `*UpdateVAData` | Optional |

{{< details title="UpdateVAData fields" >}}
UpdateVAData is the "virtualAccountData" object in UpdateVAResponse — Create VA's data fields plus LastUpdateDate and PaymentDate.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Optional |
| `customerNo` | `string` | Optional |
| `virtualAccountNo` | `string` | Optional |
| `virtualAccountName` | `string` | Optional |
| `trxId` | `string` | Optional |
| `totalAmount` | `*snap.Money` | Optional |
| `billDetails` | `[]BillDetail` | Optional |
| `freeTexts` | `[]LocalizedText` | Optional |
| `virtualAccountTrxType` | `string` | Optional |
| `feeAmount` | `*snap.Money` | Optional |
| `expiredDate` | `string` | Optional |
| `lastUpdateDate` | `string` | Optional |
| `paymentDate` | `string` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |
{{< /details >}}

{{< details title="BillDetail fields" >}}
BillDetail is one entry in the `billDetails[]` array (max 24 entries) used across the Virtual Account group. `billReferenceNo` is `json.RawMessage` because the standard documents it as Numeric but some issuers send it as a bare JSON number — when you set it yourself (e.g. in `CreateVARequest`), supply a complete JSON value like `json.RawMessage(\`"BILLREF1"\`)` or `json.RawMessage(\`123\`)`, not a bare Go string.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | Optional |
| `billNo` | `string` | Optional |
| `billName` | `string` | Optional |
| `billShortName` | `string` | Optional |
| `billDescription` | `*LocalizedText` | Optional |
| `billSubCompany` | `string` | Optional |
| `billAmount` | `*snap.Money` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |
| `billAmountLabel` | `string` | Optional |
| `billAmountValue` | `string` | Optional |
| `billReferenceNo` | `json.RawMessage` | Optional |
| `status` | `string` | Optional |
| `reason` | `*LocalizedText` | Optional |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
LocalizedText is the shared {english, indonesia} bilingual text shape used across the Virtual Account sub-group (e.g. inquiryReason, paymentFlagReason, billDescription, per-bill reason, freeTexts[] entries). Both fields are String, unmarked for M/O in the source, so both carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | Optional |
| `indonesia` | `string` | Optional |
{{< /details >}}


---

### `UpdateStatusVA`

UpdateStatusVA calls the SNAP VA - Update Status VA endpoint (Service Code 29, path .../{version}/transfer-va/update-status, HTTP PUT). hb must already carry every field snap.HeaderBuilder needs except Method and Body, which UpdateStatusVA sets itself: Method to PUT (the method is fixed by this endpoint, not caller-configurable) and Body so the exact marshaled bytes are used for both signing and the wire body.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func UpdateStatusVA(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req UpdateStatusVARequest) (UpdateStatusVAResponse, error)
```

**Request &mdash; `UpdateStatusVARequest`**

UpdateStatusVARequest is the request body for API VA - Update Status VA (Service Code 29). PartnerServiceID, CustomerNo, VirtualAccountNo, TrxID, and PaidStatus are mandatory per the Guides tab. PaidStatus values are "Y"/"N" per the research doc.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Mandatory |
| `customerNo` | `string` | Mandatory |
| `virtualAccountNo` | `string` | Mandatory |
| `trxId` | `string` | Mandatory |
| `paidStatus` | `string` | Mandatory |
| `additionalInfo` | `json.RawMessage` | Optional |

**Response &mdash; `UpdateStatusVAResponse`**

UpdateStatusVAResponse is the response body for API VA - Update Status VA.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Mandatory |
| `responseMessage` | `string` | Mandatory |
| `virtualAccountData` | `*UpdateStatusVAData` | Optional |

{{< details title="UpdateStatusVAData fields" >}}
UpdateStatusVAData is the "virtualAccountData" object in UpdateStatusVAResponse — per the research doc, "the full VA data object", the same field set as UpdateVAData, under its own type name.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Optional |
| `customerNo` | `string` | Optional |
| `virtualAccountNo` | `string` | Optional |
| `virtualAccountName` | `string` | Optional |
| `trxId` | `string` | Optional |
| `totalAmount` | `*snap.Money` | Optional |
| `billDetails` | `[]BillDetail` | Optional |
| `freeTexts` | `[]LocalizedText` | Optional |
| `virtualAccountTrxType` | `string` | Optional |
| `feeAmount` | `*snap.Money` | Optional |
| `expiredDate` | `string` | Optional |
| `lastUpdateDate` | `string` | Optional |
| `paymentDate` | `string` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |
{{< /details >}}

{{< details title="BillDetail fields" >}}
BillDetail is one entry in the `billDetails[]` array (max 24 entries) used across the Virtual Account group. `billReferenceNo` is `json.RawMessage` because the standard documents it as Numeric but some issuers send it as a bare JSON number — when you set it yourself (e.g. in `CreateVARequest`), supply a complete JSON value like `json.RawMessage(\`"BILLREF1"\`)` or `json.RawMessage(\`123\`)`, not a bare Go string.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | Optional |
| `billNo` | `string` | Optional |
| `billName` | `string` | Optional |
| `billShortName` | `string` | Optional |
| `billDescription` | `*LocalizedText` | Optional |
| `billSubCompany` | `string` | Optional |
| `billAmount` | `*snap.Money` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |
| `billAmountLabel` | `string` | Optional |
| `billAmountValue` | `string` | Optional |
| `billReferenceNo` | `json.RawMessage` | Optional |
| `status` | `string` | Optional |
| `reason` | `*LocalizedText` | Optional |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
LocalizedText is the shared {english, indonesia} bilingual text shape used across the Virtual Account sub-group (e.g. inquiryReason, paymentFlagReason, billDescription, per-bill reason, freeTexts[] entries). Both fields are String, unmarked for M/O in the source, so both carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | Optional |
| `indonesia` | `string` | Optional |
{{< /details >}}


---

### `InquiryVA`

InquiryVA calls the SNAP VA - Inquiry VA endpoint (Service Code 30, path .../{version}/transfer-va/inquiry-va). hb must already carry every field snap.HeaderBuilder needs except Body, which InquiryVA sets itself so the exact marshaled bytes are used for both signing and the wire body.

```go
func InquiryVA(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req InquiryVARequest) (InquiryVAResponse, error)
```

**Request &mdash; `InquiryVARequest`**

InquiryVARequest is the request body for API VA - Inquiry VA (Service Code 30). PartnerServiceID, CustomerNo, VirtualAccountNo, and TrxID are mandatory per the Guides tab.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Mandatory |
| `customerNo` | `string` | Mandatory |
| `virtualAccountNo` | `string` | Mandatory |
| `trxId` | `string` | Mandatory |
| `additionalInfo` | `json.RawMessage` | Optional |

**Response &mdash; `InquiryVAResponse`**

InquiryVAResponse is the response body for API VA - Inquiry VA.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Mandatory |
| `responseMessage` | `string` | Mandatory |
| `virtualAccountData` | `*InquiryVAData` | Optional |

{{< details title="InquiryVAData fields" >}}
InquiryVAData is the "virtualAccountData" object in InquiryVAResponse — per the research doc, "full VA data object (same shape as Update VA response)", the same field set as UpdateVAData, under its own type name.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Optional |
| `customerNo` | `string` | Optional |
| `virtualAccountNo` | `string` | Optional |
| `virtualAccountName` | `string` | Optional |
| `trxId` | `string` | Optional |
| `totalAmount` | `*snap.Money` | Optional |
| `billDetails` | `[]BillDetail` | Optional |
| `freeTexts` | `[]LocalizedText` | Optional |
| `virtualAccountTrxType` | `string` | Optional |
| `feeAmount` | `*snap.Money` | Optional |
| `expiredDate` | `string` | Optional |
| `lastUpdateDate` | `string` | Optional |
| `paymentDate` | `string` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |
{{< /details >}}

{{< details title="BillDetail fields" >}}
BillDetail is one entry in the `billDetails[]` array (max 24 entries) used across the Virtual Account group. `billReferenceNo` is `json.RawMessage` because the standard documents it as Numeric but some issuers send it as a bare JSON number — when you set it yourself (e.g. in `CreateVARequest`), supply a complete JSON value like `json.RawMessage(\`"BILLREF1"\`)` or `json.RawMessage(\`123\`)`, not a bare Go string.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | Optional |
| `billNo` | `string` | Optional |
| `billName` | `string` | Optional |
| `billShortName` | `string` | Optional |
| `billDescription` | `*LocalizedText` | Optional |
| `billSubCompany` | `string` | Optional |
| `billAmount` | `*snap.Money` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |
| `billAmountLabel` | `string` | Optional |
| `billAmountValue` | `string` | Optional |
| `billReferenceNo` | `json.RawMessage` | Optional |
| `status` | `string` | Optional |
| `reason` | `*LocalizedText` | Optional |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
LocalizedText is the shared {english, indonesia} bilingual text shape used across the Virtual Account sub-group (e.g. inquiryReason, paymentFlagReason, billDescription, per-bill reason, freeTexts[] entries). Both fields are String, unmarked for M/O in the source, so both carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | Optional |
| `indonesia` | `string` | Optional |
{{< /details >}}


---

### `DeleteVA`

DeleteVA calls the SNAP VA - Delete VA endpoint (Service Code 31, path .../{version}/transfer-va/delete-va, HTTP DELETE). hb must already carry every field snap.HeaderBuilder needs except Method and Body, which DeleteVA sets itself: Method to DELETE (the method is fixed by this endpoint, not caller-configurable) and Body, since this DELETE ships a JSON request body rather than using path parameters — the exact marshaled bytes are used for both signing and the wire body.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func DeleteVA(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req DeleteVARequest) (DeleteVAResponse, error)
```

**Request &mdash; `DeleteVARequest`**

DeleteVARequest is the request body for API VA - Delete VA (Service Code 31). PartnerServiceID, CustomerNo, and VirtualAccountNo are mandatory per the Guides tab; TrxID is Optional.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Mandatory |
| `customerNo` | `string` | Mandatory |
| `virtualAccountNo` | `string` | Mandatory |
| `trxId` | `string` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |

**Response &mdash; `DeleteVAResponse`**

DeleteVAResponse is the response body for API VA - Delete VA.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Mandatory |
| `responseMessage` | `string` | Mandatory |
| `virtualAccountData` | `*DeleteVAData` | Optional |

{{< details title="DeleteVAData fields" >}}
DeleteVAData is the "virtualAccountData" object in DeleteVAResponse — a smaller shape than the other VA management endpoints' data object, per the research doc.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Optional |
| `customerNo` | `string` | Optional |
| `virtualAccountNo` | `string` | Optional |
| `trxId` | `string` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |
{{< /details >}}


---

### `VAInquiry`

VAInquiry calls the SNAP VA - VA Inquiry endpoint (Service Code 24, path .../{version}/transfer-va/inquiry). hb must already carry every field snap.HeaderBuilder needs except Body, which VAInquiry sets itself so the exact marshaled bytes are used for both signing and the wire body.

```go
func VAInquiry(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req VAInquiryRequest) (VAInquiryResponse, error)
```

**Request &mdash; `VAInquiryRequest`**

VAInquiryRequest is the request body for API VA - VA Inquiry (Service Code 24). `partnerServiceId`, `customerNo`, `virtualAccountNo`, and `inquiryRequestId` are Mandatory. `customerNo` is `json.RawMessage` because a sibling endpoint's worked example shows it as a bare JSON number, not a quoted string — supply a complete JSON value (e.g. `json.RawMessage(\`"98765"\`)` or `json.RawMessage(\`98765\`)`), not a bare Go string.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Mandatory |
| `customerNo` | `json.RawMessage` | Mandatory |
| `virtualAccountNo` | `string` | Mandatory |
| `trxDateInit` | `string` | Optional |
| `channelCode` | `json.RawMessage` | Optional |
| `language` | `string` | Optional |
| `hashedSourceAccountNo` | `string` | Optional |
| `sourceBankCode` | `string` | Optional |
| `passApp` | `string` | Optional |
| `inquiryRequestId` | `string` | Mandatory |
| `additionalInfo` | `json.RawMessage` | Optional |

**Response &mdash; `VAInquiryResponse`**

VAInquiryResponse is the response body for API VA - VA Inquiry.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Mandatory |
| `responseMessage` | `string` | Mandatory |
| `virtualAccountData` | `*VAInquiryData` | Optional |

{{< details title="VAInquiryData fields" >}}
VAInquiryData is the "virtualAccountData" object in VAInquiryResponse. Fields beyond the identity triple carry no M/O letter in the Guides tab, so all are Optional (omitempty); InquiryReason, TotalAmount, and FeeAmount are pointers since omitempty has no effect on a non-pointer struct value.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Optional |
| `customerNo` | `json.RawMessage` | Optional |
| `virtualAccountNo` | `string` | Optional |
| `inquiryStatus` | `string` | Optional |
| `inquiryReason` | `*LocalizedText` | Optional |
| `virtualAccountName` | `string` | Optional |
| `virtualAccountEmail` | `string` | Optional |
| `virtualAccountPhone` | `string` | Optional |
| `inquiryRequestId` | `string` | Optional |
| `totalAmount` | `*snap.Money` | Optional |
| `subCompany` | `string` | Optional |
| `billDetails` | `[]BillDetail` | Optional |
| `freeTexts` | `[]LocalizedText` | Optional |
| `virtualAccountTrxType` | `string` | Optional |
| `feeAmount` | `*snap.Money` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
LocalizedText is the shared {english, indonesia} bilingual text shape used across the Virtual Account sub-group (e.g. inquiryReason, paymentFlagReason, billDescription, per-bill reason, freeTexts[] entries). Both fields are String, unmarked for M/O in the source, so both carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | Optional |
| `indonesia` | `string` | Optional |
{{< /details >}}

{{< details title="BillDetail fields" >}}
BillDetail is one entry in the `billDetails[]` array (max 24 entries) used across the Virtual Account group. `billReferenceNo` is `json.RawMessage` because the standard documents it as Numeric but some issuers send it as a bare JSON number — when you set it yourself (e.g. in `CreateVARequest`), supply a complete JSON value like `json.RawMessage(\`"BILLREF1"\`)` or `json.RawMessage(\`123\`)`, not a bare Go string.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | Optional |
| `billNo` | `string` | Optional |
| `billName` | `string` | Optional |
| `billShortName` | `string` | Optional |
| `billDescription` | `*LocalizedText` | Optional |
| `billSubCompany` | `string` | Optional |
| `billAmount` | `*snap.Money` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |
| `billAmountLabel` | `string` | Optional |
| `billAmountValue` | `string` | Optional |
| `billReferenceNo` | `json.RawMessage` | Optional |
| `status` | `string` | Optional |
| `reason` | `*LocalizedText` | Optional |
{{< /details >}}


---

### `VAPayment`

VAPayment calls the SNAP VA - VA Payment endpoint (Service Code 25, path .../{version}/transfer-va/payment, HTTP POST — no method override). hb must already carry every field snap.HeaderBuilder needs except Body, which VAPayment sets itself so the exact marshaled bytes are used for both signing and the wire body.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func VAPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req VAPaymentRequest) (VAPaymentResponse, error)
```

**Request &mdash; `VAPaymentRequest`**

VAPaymentRequest is the request body for API VA - VA Payment (Service Code 25). `partnerServiceId`, `customerNo`, `virtualAccountNo`, `paymentRequestId`, and `paidAmount` are Mandatory. `trxId` is Conditional — required if the VA was created via `CreateVA`. `customerNo`, `channelCode`, and `paymentType` are `json.RawMessage` since the standard's worked examples show them as bare numbers rather than quoted strings.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Mandatory |
| `customerNo` | `json.RawMessage` | Mandatory |
| `virtualAccountNo` | `string` | Mandatory |
| `trxId` | `string` | Optional |
| `paymentRequestId` | `string` | Mandatory |
| `channelCode` | `json.RawMessage` | Optional |
| `hashedSourceAccountNo` | `string` | Optional |
| `sourceBankCode` | `string` | Optional |
| `paidAmount` | `snap.Money` | Mandatory |
| `cumulativePaymentAmount` | `*snap.Money` | Optional |
| `paidBills` | `string` | Optional |
| `totalAmount` | `*snap.Money` | Optional |
| `trxDateTime` | `string` | Optional |
| `referenceNo` | `string` | Optional |
| `journalNum` | `string` | Optional |
| `paymentType` | `json.RawMessage` | Optional |
| `flagAdvise` | `string` | Optional |
| `subCompany` | `string` | Optional |
| `billDetails` | `[]BillDetail` | Optional |
| `freeTexts` | `[]LocalizedText` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |

{{< details title="BillDetail fields" >}}
BillDetail is one entry in the `billDetails[]` array (max 24 entries) used across the Virtual Account group. `billReferenceNo` is `json.RawMessage` because the standard documents it as Numeric but some issuers send it as a bare JSON number — when you set it yourself (e.g. in `CreateVARequest`), supply a complete JSON value like `json.RawMessage(\`"BILLREF1"\`)` or `json.RawMessage(\`123\`)`, not a bare Go string.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | Optional |
| `billNo` | `string` | Optional |
| `billName` | `string` | Optional |
| `billShortName` | `string` | Optional |
| `billDescription` | `*LocalizedText` | Optional |
| `billSubCompany` | `string` | Optional |
| `billAmount` | `*snap.Money` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |
| `billAmountLabel` | `string` | Optional |
| `billAmountValue` | `string` | Optional |
| `billReferenceNo` | `json.RawMessage` | Optional |
| `status` | `string` | Optional |
| `reason` | `*LocalizedText` | Optional |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
LocalizedText is the shared {english, indonesia} bilingual text shape used across the Virtual Account sub-group (e.g. inquiryReason, paymentFlagReason, billDescription, per-bill reason, freeTexts[] entries). Both fields are String, unmarked for M/O in the source, so both carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | Optional |
| `indonesia` | `string` | Optional |
{{< /details >}}

**Response &mdash; `VAPaymentResponse`**

VAPaymentResponse is the response body for API VA - VA Payment.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Mandatory |
| `responseMessage` | `string` | Mandatory |
| `virtualAccountData` | `*VAPaymentData` | Optional |

{{< details title="VAPaymentData fields" >}}
VAPaymentData is the `virtualAccountData` object in VAPaymentResponse — it mirrors the request's fields plus `paymentFlagReason` and `paymentFlagStatus`.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Optional |
| `customerNo` | `json.RawMessage` | Optional |
| `virtualAccountNo` | `string` | Optional |
| `trxId` | `string` | Optional |
| `paymentRequestId` | `string` | Optional |
| `channelCode` | `json.RawMessage` | Optional |
| `hashedSourceAccountNo` | `string` | Optional |
| `sourceBankCode` | `string` | Optional |
| `paidAmount` | `*snap.Money` | Optional |
| `cumulativePaymentAmount` | `*snap.Money` | Optional |
| `paidBills` | `string` | Optional |
| `totalAmount` | `*snap.Money` | Optional |
| `trxDateTime` | `string` | Optional |
| `referenceNo` | `string` | Optional |
| `journalNum` | `string` | Optional |
| `paymentType` | `json.RawMessage` | Optional |
| `flagAdvise` | `string` | Optional |
| `subCompany` | `string` | Optional |
| `billDetails` | `[]BillDetail` | Optional |
| `freeTexts` | `[]LocalizedText` | Optional |
| `paymentFlagReason` | `*LocalizedText` | Optional |
| `paymentFlagStatus` | `string` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |
{{< /details >}}

{{< details title="BillDetail fields" >}}
BillDetail is one entry in the `billDetails[]` array (max 24 entries) used across the Virtual Account group. `billReferenceNo` is `json.RawMessage` because the standard documents it as Numeric but some issuers send it as a bare JSON number — when you set it yourself (e.g. in `CreateVARequest`), supply a complete JSON value like `json.RawMessage(\`"BILLREF1"\`)` or `json.RawMessage(\`123\`)`, not a bare Go string.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | Optional |
| `billNo` | `string` | Optional |
| `billName` | `string` | Optional |
| `billShortName` | `string` | Optional |
| `billDescription` | `*LocalizedText` | Optional |
| `billSubCompany` | `string` | Optional |
| `billAmount` | `*snap.Money` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |
| `billAmountLabel` | `string` | Optional |
| `billAmountValue` | `string` | Optional |
| `billReferenceNo` | `json.RawMessage` | Optional |
| `status` | `string` | Optional |
| `reason` | `*LocalizedText` | Optional |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
LocalizedText is the shared {english, indonesia} bilingual text shape used across the Virtual Account sub-group (e.g. inquiryReason, paymentFlagReason, billDescription, per-bill reason, freeTexts[] entries). Both fields are String, unmarked for M/O in the source, so both carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | Optional |
| `indonesia` | `string` | Optional |
{{< /details >}}


---

### `VAInquiryStatus`

VAInquiryStatus calls the SNAP VA - VA Inquiry Status endpoint (Service Code 26, path .../{version}/transfer-va/status). hb must already carry every field snap.HeaderBuilder needs except Body, which VAInquiryStatus sets itself so the exact marshaled bytes are used for both signing and the wire body.

```go
func VAInquiryStatus(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req VAInquiryStatusRequest) (VAInquiryStatusResponse, error)
```

**Request &mdash; `VAInquiryStatusRequest`**

VAInquiryStatusRequest is the request body for API VA - VA Inquiry Status (Service Code 26). `partnerServiceId`, `customerNo`, and `virtualAccountNo` (the identity triple) are Mandatory; `inquiryRequestId` and `paymentRequestId` are Optional/Conditional. This package always decodes the response as a single object, per the standard's own type declaration.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Mandatory |
| `customerNo` | `json.RawMessage` | Mandatory |
| `virtualAccountNo` | `string` | Mandatory |
| `inquiryRequestId` | `string` | Optional |
| `paymentRequestId` | `string` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |

**Response &mdash; `VAInquiryStatusResponse`**

VAInquiryStatusResponse is the response body for API VA - VA Inquiry Status.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Mandatory |
| `responseMessage` | `string` | Mandatory |
| `virtualAccountData` | `*VAInquiryStatusData` | Optional |

{{< details title="VAInquiryStatusData fields" >}}
VAInquiryStatusData is the `virtualAccountData` object in VAInquiryStatusResponse — the same shape as `VAPaymentData` plus `transactionDate`, kept as its own type since it belongs to a different Service Code.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Optional |
| `customerNo` | `json.RawMessage` | Optional |
| `virtualAccountNo` | `string` | Optional |
| `trxId` | `string` | Optional |
| `paymentRequestId` | `string` | Optional |
| `channelCode` | `json.RawMessage` | Optional |
| `hashedSourceAccountNo` | `string` | Optional |
| `sourceBankCode` | `string` | Optional |
| `paidAmount` | `*snap.Money` | Optional |
| `cumulativePaymentAmount` | `*snap.Money` | Optional |
| `paidBills` | `string` | Optional |
| `totalAmount` | `*snap.Money` | Optional |
| `trxDateTime` | `string` | Optional |
| `referenceNo` | `string` | Optional |
| `journalNum` | `string` | Optional |
| `paymentType` | `json.RawMessage` | Optional |
| `flagAdvise` | `string` | Optional |
| `subCompany` | `string` | Optional |
| `billDetails` | `[]BillDetail` | Optional |
| `freeTexts` | `[]LocalizedText` | Optional |
| `paymentFlagReason` | `*LocalizedText` | Optional |
| `paymentFlagStatus` | `string` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |
| `transactionDate` | `string` | Optional |
{{< /details >}}

{{< details title="BillDetail fields" >}}
BillDetail is one entry in the `billDetails[]` array (max 24 entries) used across the Virtual Account group. `billReferenceNo` is `json.RawMessage` because the standard documents it as Numeric but some issuers send it as a bare JSON number — when you set it yourself (e.g. in `CreateVARequest`), supply a complete JSON value like `json.RawMessage(\`"BILLREF1"\`)` or `json.RawMessage(\`123\`)`, not a bare Go string.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | Optional |
| `billNo` | `string` | Optional |
| `billName` | `string` | Optional |
| `billShortName` | `string` | Optional |
| `billDescription` | `*LocalizedText` | Optional |
| `billSubCompany` | `string` | Optional |
| `billAmount` | `*snap.Money` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |
| `billAmountLabel` | `string` | Optional |
| `billAmountValue` | `string` | Optional |
| `billReferenceNo` | `json.RawMessage` | Optional |
| `status` | `string` | Optional |
| `reason` | `*LocalizedText` | Optional |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
LocalizedText is the shared {english, indonesia} bilingual text shape used across the Virtual Account sub-group (e.g. inquiryReason, paymentFlagReason, billDescription, per-bill reason, freeTexts[] entries). Both fields are String, unmarked for M/O in the source, so both carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | Optional |
| `indonesia` | `string` | Optional |
{{< /details >}}


---

### `VAInquiryPaymentIntrabank`

VAInquiryPaymentIntrabank calls the SNAP VA - Inquiry Payment Intrabank endpoint (Service Code 32, path .../{version}/transfer-va/inquiry-intrabank). hb must already carry every field snap.HeaderBuilder needs except Body, which VAInquiryPaymentIntrabank sets itself so the exact marshaled bytes are used for both signing and the wire body.

```go
func VAInquiryPaymentIntrabank(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req VAInquiryPaymentIntrabankRequest) (VAInquiryPaymentIntrabankResponse, error)
```

**Request &mdash; `VAInquiryPaymentIntrabankRequest`**

VAInquiryPaymentIntrabankRequest is the request body for API VA - Inquiry Payment Intrabank (Service Code 32). `partnerServiceId`, `customerNo`, and `virtualAccountNo` (the identity triple) are Mandatory. `customerNo` is `json.RawMessage` since the standard's worked example for this endpoint shows it as a bare JSON number.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Mandatory |
| `customerNo` | `json.RawMessage` | Mandatory |
| `virtualAccountNo` | `string` | Mandatory |
| `partnerReferenceNo` | `string` | Optional |
| `sourceAccountNo` | `string` | Optional |
| `sourceAccountType` | `string` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |

**Response &mdash; `VAInquiryPaymentIntrabankResponse`**

VAInquiryPaymentIntrabankResponse is the response body for API VA - Inquiry Payment Intrabank.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Mandatory |
| `responseMessage` | `string` | Mandatory |
| `virtualAccountdata` | `*VAInquiryPaymentIntrabankData` | Optional |

{{< details title="VAInquiryPaymentIntrabankData fields" >}}
VAInquiryPaymentIntrabankData is the `virtualAccountdata` object (lowercase "d" — deliberately matching the standard's own wire key, unlike most other VA endpoints which use `virtualAccountData`) in VAInquiryPaymentIntrabankResponse.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Optional |
| `customerNo` | `json.RawMessage` | Optional |
| `virtualAccountNo` | `string` | Optional |
| `partnerReferenceNo` | `string` | Optional |
| `sourceAccountNo` | `string` | Optional |
| `sourceAccountType` | `string` | Optional |
| `productName` | `string` | Optional |
| `billAmountLabel` | `string` | Optional |
| `billAmountValue` | `string` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |
{{< /details >}}


---

### `VAPaymentIntrabank`

VAPaymentIntrabank calls the SNAP VA - Payment Intrabank endpoint (Service Code 33, path .../{version}/transfer-va/payment-intrabank, HTTP POST — no method override). hb must already carry every field snap.HeaderBuilder needs except Body, which VAPaymentIntrabank sets itself so the exact marshaled bytes are used for both signing and the wire body.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func VAPaymentIntrabank(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req VAPaymentIntrabankRequest) (VAPaymentIntrabankResponse, error)
```

**Request &mdash; `VAPaymentIntrabankRequest`**

VAPaymentIntrabankRequest is the request body for API VA - Payment Intrabank (Service Code 33). `partnerServiceId`, `customerNo`, `virtualAccountNo`, `partnerReferenceNo`, and `paidAmount` are Mandatory. `customerNo` and `referenceNo` are `json.RawMessage` since the standard's worked examples show both as bare numbers, even though `referenceNo` appears quoted in the response. `paymentStatus` is a free-text status string, not the package's usual 2-digit `transactionStatus` code.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Mandatory |
| `customerNo` | `json.RawMessage` | Mandatory |
| `virtualAccountNo` | `string` | Mandatory |
| `sourceAccountNo` | `string` | Optional |
| `sourceAccountType` | `string` | Optional |
| `inquiryRequestId` | `string` | Optional |
| `partnerReferenceNo` | `string` | Mandatory |
| `paidAmount` | `snap.Money` | Mandatory |
| `cumulativePaymentAmount` | `*snap.Money` | Optional |
| `paidBills` | `string` | Optional |
| `paymentStatus` | `string` | Optional |
| `referenceNo` | `json.RawMessage` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |

**Response &mdash; `VAPaymentIntrabankResponse`**

VAPaymentIntrabankResponse is the response body for API VA - Payment Intrabank.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Mandatory |
| `responseMessage` | `string` | Mandatory |
| `virtualAccountdata` | `*VAPaymentIntrabankData` | Optional |

{{< details title="VAPaymentIntrabankData fields" >}}
VAPaymentIntrabankData is the `virtualAccountdata` object (lowercase "d") in VAPaymentIntrabankResponse — it mirrors the request's own fields.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Optional |
| `customerNo` | `json.RawMessage` | Optional |
| `virtualAccountNo` | `string` | Optional |
| `sourceAccountNo` | `string` | Optional |
| `sourceAccountType` | `string` | Optional |
| `inquiryRequestId` | `string` | Optional |
| `partnerReferenceNo` | `string` | Optional |
| `paidAmount` | `*snap.Money` | Optional |
| `cumulativePaymentAmount` | `*snap.Money` | Optional |
| `paidBills` | `string` | Optional |
| `paymentStatus` | `string` | Optional |
| `referenceNo` | `json.RawMessage` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |
{{< /details >}}


---

### `VANotifyPaymentIntrabank`

VANotifyPaymentIntrabank calls the SNAP VA - Notify Payment Intrabank endpoint (Service Code 34, path .../{version}/transfer-va/notify-payment-intrabank, HTTP POST — no method override). hb must already carry every field snap.HeaderBuilder needs except Body, which VANotifyPaymentIntrabank sets itself so the exact marshaled bytes are used for both signing and the wire body.

This operation is not idempotent and this package does not retry. Callers that retry a failed or timed-out call should reuse the same X-EXTERNAL-ID, since the server's own duplicate-detection keys on it.

```go
func VANotifyPaymentIntrabank(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req VANotifyPaymentIntrabankRequest) (VANotifyPaymentIntrabankResponse, error)
```

**Request &mdash; `VANotifyPaymentIntrabankRequest`**

VANotifyPaymentIntrabankRequest is the request body for API VA - Notify Payment Intrabank (Service Code 34). Unlike the RTGS/SKNBI/Interbank-Bulk notifications, this one is outbound — your code calls it, the PJP receives it — so it's a normal calling function, not an inbound-only struct. `customerNo` is `json.RawMessage` since the standard's worked example shows it as a bare number.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Mandatory |
| `customerNo` | `json.RawMessage` | Mandatory |
| `virtualAccountNo` | `string` | Mandatory |
| `inquiryRequestId` | `string` | Optional |
| `paymentRequestId` | `string` | Optional |
| `partnerReferenceNo` | `string` | Optional |
| `trxDateTime` | `string` | Optional |
| `paymentStatus` | `string` | Optional |
| `paymentFlagReason` | `*LocalizedText` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |

{{< details title="LocalizedText fields" >}}
LocalizedText is the shared {english, indonesia} bilingual text shape used across the Virtual Account sub-group (e.g. inquiryReason, paymentFlagReason, billDescription, per-bill reason, freeTexts[] entries). Both fields are String, unmarked for M/O in the source, so both carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | Optional |
| `indonesia` | `string` | Optional |
{{< /details >}}

**Response &mdash; `VANotifyPaymentIntrabankResponse`**

VANotifyPaymentIntrabankResponse is the response body for API VA - Notify Payment Intrabank.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Mandatory |
| `responseMessage` | `string` | Mandatory |
| `virtualAccountdata` | `*VANotifyPaymentIntrabankData` | Optional |

{{< details title="VANotifyPaymentIntrabankData fields" >}}
VANotifyPaymentIntrabankData is the `virtualAccountdata` object (lowercase "d") in VANotifyPaymentIntrabankResponse — it mirrors most of the request's fields, plus the envelope.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Optional |
| `customerNo` | `json.RawMessage` | Optional |
| `virtualAccountNo` | `string` | Optional |
| `inquiryRequestId` | `string` | Optional |
| `paymentRequestId` | `string` | Optional |
| `partnerReferenceNo` | `string` | Optional |
| `trxDateTime` | `string` | Optional |
| `paymentStatus` | `string` | Optional |
| `paymentFlagReason` | `*LocalizedText` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
LocalizedText is the shared {english, indonesia} bilingual text shape used across the Virtual Account sub-group (e.g. inquiryReason, paymentFlagReason, billDescription, per-bill reason, freeTexts[] entries). Both fields are String, unmarked for M/O in the source, so both carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | Optional |
| `indonesia` | `string` | Optional |
{{< /details >}}


---

### `VAGetReport`

VAGetReport calls the SNAP VA - Get Report endpoint (Service Code 35, path .../{version}/transfer-va/report). hb must already carry every field snap.HeaderBuilder needs except Method and Body: VAGetReport sets Method to POST itself (the standard documents this endpoint inconsistently as both GET and POST-with-body; this package always uses POST) and Body, so the exact marshaled bytes are used for both signing and the wire body.

A report covering a wide date range can return an unbounded number of array entries; the shared transport layer caps every response body at 10 MiB (see transport.go), so callers pulling large reports should page by narrower date/time ranges rather than one unbounded call.

```go
func VAGetReport(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req VAGetReportRequest) (VAGetReportResponse, error)
```

**Request &mdash; `VAGetReportRequest`**

VAGetReportRequest is the request body for API VA - Get Report (Service Code 35). `partnerServiceId` is the only Mandatory field; it's `json.RawMessage` here because the standard documents it as a Number for this endpoint specifically, unlike every other VA endpoint where it's a String.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `json.RawMessage` | Mandatory |
| `startDate` | `string` | Optional |
| `startTime` | `string` | Optional |
| `endDate` | `string` | Optional |
| `endTime` | `string` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |

**Response &mdash; `VAGetReportResponse`**

VAGetReportResponse is the response body for API VA - Get Report — the only VA response in this package whose data field is an array rather than a single object.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Mandatory |
| `responseMessage` | `string` | Mandatory |
| `virtualAccountdata` | `[]GetReportData` | Optional |

{{< details title="GetReportData fields" >}}
GetReportData is one entry in VAGetReportResponse's `virtualAccountdata` array (lowercase "d") — the same shape as `VAInquiryStatusData`, kept as its own type since it belongs to a different Service Code.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Optional |
| `customerNo` | `json.RawMessage` | Optional |
| `virtualAccountNo` | `string` | Optional |
| `trxId` | `string` | Optional |
| `paymentRequestId` | `string` | Optional |
| `channelCode` | `json.RawMessage` | Optional |
| `hashedSourceAccountNo` | `string` | Optional |
| `sourceBankCode` | `string` | Optional |
| `paidAmount` | `*snap.Money` | Optional |
| `cumulativePaymentAmount` | `*snap.Money` | Optional |
| `paidBills` | `string` | Optional |
| `totalAmount` | `*snap.Money` | Optional |
| `trxDateTime` | `string` | Optional |
| `referenceNo` | `string` | Optional |
| `journalNum` | `string` | Optional |
| `paymentType` | `json.RawMessage` | Optional |
| `flagAdvise` | `string` | Optional |
| `subCompany` | `string` | Optional |
| `billDetails` | `[]BillDetail` | Optional |
| `freeTexts` | `[]LocalizedText` | Optional |
| `paymentFlagReason` | `*LocalizedText` | Optional |
| `paymentFlagStatus` | `string` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |
| `transactionDate` | `string` | Optional |
{{< /details >}}

{{< details title="BillDetail fields" >}}
BillDetail is one entry in the `billDetails[]` array (max 24 entries) used across the Virtual Account group. `billReferenceNo` is `json.RawMessage` because the standard documents it as Numeric but some issuers send it as a bare JSON number — when you set it yourself (e.g. in `CreateVARequest`), supply a complete JSON value like `json.RawMessage(\`"BILLREF1"\`)` or `json.RawMessage(\`123\`)`, not a bare Go string.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | Optional |
| `billNo` | `string` | Optional |
| `billName` | `string` | Optional |
| `billShortName` | `string` | Optional |
| `billDescription` | `*LocalizedText` | Optional |
| `billSubCompany` | `string` | Optional |
| `billAmount` | `*snap.Money` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |
| `billAmountLabel` | `string` | Optional |
| `billAmountValue` | `string` | Optional |
| `billReferenceNo` | `json.RawMessage` | Optional |
| `status` | `string` | Optional |
| `reason` | `*LocalizedText` | Optional |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
LocalizedText is the shared {english, indonesia} bilingual text shape used across the Virtual Account sub-group (e.g. inquiryReason, paymentFlagReason, billDescription, per-bill reason, freeTexts[] entries). Both fields are String, unmarked for M/O in the source, so both carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | Optional |
| `indonesia` | `string` | Optional |
{{< /details >}}


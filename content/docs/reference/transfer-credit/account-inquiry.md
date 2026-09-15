---
weight: 1
title: "Account Inquiry"
description: "Look up a beneficiary account's name/status before a transfer."
---

## Account Inquiry

Look up a beneficiary account's name/status before a transfer.

```go
resp, err := transfercredit.AccountInquiryInternal(ctx, transport, hb, transfercredit.AccountInquiryInternalRequest{
	BeneficiaryAccountNo: "1234567890",
})
if err != nil {
	// errors.Is(err, snap.ErrBadRequest), snap.ErrUnauthorized, etc.
}
```

### `AccountInquiryInternal`

AccountInquiryInternal calls the SNAP Internal Account Inquiry endpoint (Service Code 15, path .../{version}/account-inquiry-internal). hb must already carry every field snap.HeaderBuilder needs except Body, which AccountInquiryInternal sets itself so the exact marshaled bytes are used for both signing and the wire body.

```go
func AccountInquiryInternal(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AccountInquiryInternalRequest) (AccountInquiryInternalResponse, error)
```

**Request &mdash; `AccountInquiryInternalRequest`**

AccountInquiryInternalRequest is the request body for API Internal Account Inquiry (Service Code 15). BeneficiaryAccountNo is the only mandatory field per the Guides tab.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | Optional |
| `beneficiaryAccountNo` | `string` | Mandatory |
| `additionalInfo` | `json.RawMessage` | Optional |

**Response &mdash; `AccountInquiryInternalResponse`**

AccountInquiryInternalResponse is the response body for API Internal Account Inquiry.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Mandatory |
| `responseMessage` | `string` | Mandatory |
| `referenceNo` | `string` | Optional |
| `partnerReferenceNo` | `string` | Optional |
| `beneficiaryAccountName` | `string` | Mandatory |
| `beneficiaryAccountNo` | `string` | Mandatory |
| `beneficiaryAccountStatus` | `string` | Optional |
| `beneficiaryAccountType` | `string` | Optional |
| `currency` | `string` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |


---

### `AccountInquiryExternal`

AccountInquiryExternal calls the SNAP External Account Inquiry endpoint (Service Code 16, path .../{version}/account-inquiry-external). hb must already carry every field snap.HeaderBuilder needs except Body, which AccountInquiryExternal sets itself so the exact marshaled bytes are used for both signing and the wire body.

```go
func AccountInquiryExternal(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AccountInquiryExternalRequest) (AccountInquiryExternalResponse, error)
```

**Request &mdash; `AccountInquiryExternalRequest`**

AccountInquiryExternalRequest is the request body for API External Account Inquiry (Service Code 16). BeneficiaryAccountNo and BeneficiaryBankCode are mandatory per the Guides tab.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | Optional |
| `beneficiaryAccountNo` | `string` | Mandatory |
| `beneficiaryBankCode` | `string` | Mandatory |
| `additionalInfo` | `json.RawMessage` | Optional |

**Response &mdash; `AccountInquiryExternalResponse`**

AccountInquiryExternalResponse is the response body for API External Account Inquiry.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Mandatory |
| `responseMessage` | `string` | Mandatory |
| `referenceNo` | `string` | Optional |
| `partnerReferenceNo` | `string` | Optional |
| `beneficiaryAccountName` | `string` | Mandatory |
| `beneficiaryAccountNo` | `string` | Mandatory |
| `beneficiaryBankName` | `string` | Optional |
| `currency` | `string` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |


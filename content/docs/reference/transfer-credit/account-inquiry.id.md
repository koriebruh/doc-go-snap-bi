---
weight: 1
title: "Pengecekan Rekening"
description: "Cek nama/status rekening penerima sebelum melakukan transfer."
---

## Pengecekan Rekening

Cek nama/status rekening penerima sebelum melakukan transfer.

```go
resp, err := transfercredit.AccountInquiryInternal(ctx, transport, hb, transfercredit.AccountInquiryInternalRequest{
	BeneficiaryAccountNo: "1234567890",
})
if err != nil {
	// errors.Is(err, snap.ErrBadRequest), snap.ErrUnauthorized, etc.
}
```

### `AccountInquiryInternal`

Memanggil endpoint SNAP Internal Account Inquiry (Service Code 15, path .../{version}/account-inquiry-internal). `hb` harus sudah diisi semua field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body` — fungsi ini yang mengisinya sendiri agar byte yang sama persis dipakai untuk signing maupun request di wire.

```go
func AccountInquiryInternal(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AccountInquiryInternalRequest) (AccountInquiryInternalResponse, error)
```

**Request &mdash; `AccountInquiryInternalRequest`**

`BeneficiaryAccountNo` adalah satu-satunya field wajib.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | Opsional |
| `beneficiaryAccountNo` | `string` | Wajib |
| `additionalInfo` | `json.RawMessage` | Opsional |

**Response &mdash; `AccountInquiryInternalResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `referenceNo` | `string` | Opsional |
| `partnerReferenceNo` | `string` | Opsional |
| `beneficiaryAccountName` | `string` | Wajib |
| `beneficiaryAccountNo` | `string` | Wajib |
| `beneficiaryAccountStatus` | `string` | Opsional |
| `beneficiaryAccountType` | `string` | Opsional |
| `currency` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |


---

### `AccountInquiryExternal`

Memanggil endpoint SNAP External Account Inquiry (Service Code 16, path .../{version}/account-inquiry-external). `hb` harus sudah diisi semua field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body` — fungsi ini yang mengisinya sendiri agar byte yang sama persis dipakai untuk signing maupun request di wire.

```go
func AccountInquiryExternal(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AccountInquiryExternalRequest) (AccountInquiryExternalResponse, error)
```

**Request &mdash; `AccountInquiryExternalRequest`**

`BeneficiaryAccountNo` dan `BeneficiaryBankCode` wajib diisi.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | Opsional |
| `beneficiaryAccountNo` | `string` | Wajib |
| `beneficiaryBankCode` | `string` | Wajib |
| `additionalInfo` | `json.RawMessage` | Opsional |

**Response &mdash; `AccountInquiryExternalResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `referenceNo` | `string` | Opsional |
| `partnerReferenceNo` | `string` | Opsional |
| `beneficiaryAccountName` | `string` | Wajib |
| `beneficiaryAccountNo` | `string` | Wajib |
| `beneficiaryBankName` | `string` | Opsional |
| `currency` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

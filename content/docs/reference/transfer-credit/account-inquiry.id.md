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
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `AccountInquiryInternalResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `beneficiaryAccountName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryAccountStatus` | `string` | <span class="badge-optional">Opsional</span> |
| `beneficiaryAccountType` | `string` | <span class="badge-optional">Opsional</span> |
| `currency` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |


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
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryBankCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `AccountInquiryExternalResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `beneficiaryAccountName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `beneficiaryBankName` | `string` | <span class="badge-optional">Opsional</span> |
| `currency` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

---
weight: 2
title: "Informasi Saldo"
description: "Informasi Saldo — Service Code 11 — 1 endpoint"
---

## Informasi Saldo

Kategori terkecil di portal: satu endpoint, satu file, satu package, di `balanceinfo`.

```go
resp, err := balanceinfo.BalanceInquiry(ctx, transport, hb, balanceinfo.BalanceInquiryRequest{
	PartnerReferenceNo: "2020102900000000000001",
	BankCardToken: "...",
	AccountNo: "1234567890",
})
if err != nil {
	// errors.Is(err, snap.ErrBadRequest), snap.ErrUnauthorized, etc.
}
```

### `BalanceInquiry`

Mengecek saldo sebuah account (Service Code 11). Isi semua field `HeaderBuilder` kecuali `Body` — `BalanceInquiry` melakukan marshal terhadap request dan mengatur `Body`-nya sendiri, jadi byte yang sama persis ditandatangani dan dikirim.

```go
func BalanceInquiry(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req BalanceInquiryRequest) (BalanceInquiryResponse, error)
```

**Request &mdash; `BalanceInquiryRequest`**

Isi tepat salah satu dari `BankCardToken` atau `AccountNo` (kecuali token customer B2B2C sudah menyediakan accountnya). Server menolak request yang tidak mengisi keduanya — package ini tidak memeriksanya untuk Anda.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `bankCardToken` | `string` | <span class="badge-optional">Opsional</span> |
| `accountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `balanceTypes` | `[]string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `BalanceInquiryResponse`**

Body response-nya.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `accountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `name` | `string` | <span class="badge-optional">Opsional</span> |
| `accountInfos` | `[]AccountInfo` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

{{< details title="AccountInfo fields" >}}
Satu entri di `accountInfos`.

| Field | Type | Presence |
|---|---|---|
| `balanceType` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `floatAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `holdAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `availableBalance` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `ledgerBalance` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `currentMultilateralLimit` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `registrationStatusCode` | `string` | <span class="badge-optional">Opsional</span> |
| `status` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

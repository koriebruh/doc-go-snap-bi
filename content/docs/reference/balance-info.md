---
weight: 2
title: "Balance Info"
description: "Informasi Saldo — Service Code 11 — 1 endpoint"
---

## Balance Info

The portal's smallest category: one endpoint, one file, one package, in `balanceinfo`.

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

Checks an account's balance (Service Code 11). Set every `HeaderBuilder` field except `Body` — `BalanceInquiry` marshals the request and sets `Body` itself, so the same bytes are signed and sent.

```go
func BalanceInquiry(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req BalanceInquiryRequest) (BalanceInquiryResponse, error)
```

**Request &mdash; `BalanceInquiryRequest`**

Set exactly one of `BankCardToken` or `AccountNo` (unless a B2B2C customer token already supplies the account). The server rejects a request that sets neither — this package doesn't check that for you.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `bankCardToken` | `string` | <span class="badge-optional">Optional</span> |
| `accountNo` | `string` | <span class="badge-optional">Optional</span> |
| `balanceTypes` | `[]string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `BalanceInquiryResponse`**

The response body.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `accountNo` | `string` | <span class="badge-optional">Optional</span> |
| `name` | `string` | <span class="badge-optional">Optional</span> |
| `accountInfos` | `[]AccountInfo` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

{{< details title="AccountInfo fields" >}}
One entry in `accountInfos`.

| Field | Type | Presence |
|---|---|---|
| `balanceType` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `floatAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `holdAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `availableBalance` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `ledgerBalance` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `currentMultilateralLimit` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `registrationStatusCode` | `string` | <span class="badge-optional">Optional</span> |
| `status` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |
{{< /details >}}


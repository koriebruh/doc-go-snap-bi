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
| `partnerReferenceNo` | `string` | Optional |
| `bankCardToken` | `string` | Optional |
| `accountNo` | `string` | Optional |
| `balanceTypes` | `[]string` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |

**Response &mdash; `BalanceInquiryResponse`**

The response body.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Mandatory |
| `responseMessage` | `string` | Mandatory |
| `referenceNo` | `string` | Optional |
| `partnerReferenceNo` | `string` | Optional |
| `accountNo` | `string` | Optional |
| `name` | `string` | Optional |
| `accountInfos` | `[]AccountInfo` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |

{{< details title="AccountInfo fields" >}}
One entry in `accountInfos`.

| Field | Type | Presence |
|---|---|---|
| `balanceType` | `string` | Optional |
| `amount` | `*snap.Money` | Optional |
| `floatAmount` | `*snap.Money` | Optional |
| `holdAmount` | `*snap.Money` | Optional |
| `availableBalance` | `*snap.Money` | Optional |
| `ledgerBalance` | `*snap.Money` | Optional |
| `currentMultilateralLimit` | `*snap.Money` | Optional |
| `registrationStatusCode` | `string` | Optional |
| `status` | `string` | Optional |
| `additionalInfo` | `json.RawMessage` | Optional |
{{< /details >}}


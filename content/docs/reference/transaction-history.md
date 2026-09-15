---
weight: 3
title: "Transaction History"
description: "Riwayat Transaksi — Service Codes 12-14 — 3 endpoints"
---

## Transaction History

List, detail, and statement lookups over previously settled transactions — the `transactionhistory` package (Service Codes 12-14).

```go
resp, err := transactionhistory.TransactionHistoryList(ctx, transport, hb, transactionhistory.TransactionHistoryListRequest{
	PartnerReferenceNo: "2020102900000000000001",
	FromDateTime: "2026-09-14T10:00:00+07:00",
	ToDateTime: "2026-09-14T10:00:00+07:00",
})
if err != nil {
	// errors.Is(err, snap.ErrBadRequest), snap.ErrUnauthorized, etc.
}
```

### `TransactionHistoryList`

Lists past transactions in a date range (Service Code 12).

```go
func TransactionHistoryList(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req TransactionHistoryListRequest) (TransactionHistoryListResponse, error)
```

**Request &mdash; `TransactionHistoryListRequest`**

`pageSize` and `pageNumber` are `string`, not `int` — the standard sends them as quoted numbers on the wire (e.g. `"10"`).

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `fromDateTime` | `string` | <span class="badge-optional">Optional</span> |
| `toDateTime` | `string` | <span class="badge-optional">Optional</span> |
| `pageSize` | `string` | <span class="badge-optional">Optional</span> |
| `pageNumber` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `TransactionHistoryListResponse`**

The response body.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `detailData` | `[]TransactionDetail` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

{{< details title="TransactionDetail fields" >}}
One entry in `detailData`.

| Field | Type | Presence |
|---|---|---|
| `dateTime` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `remark` | `string` | <span class="badge-optional">Optional</span> |
| `sourceOfFunds` | `[]SourceOfFund` | <span class="badge-optional">Optional</span> |
| `status` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `type` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |
{{< /details >}}

{{< details title="SourceOfFund fields" >}}
Describes one source of funds used for a transaction. `source` is Mandatory; `amount` is a pointer since only its own `value`/`currency` are Mandatory, not the container itself.

| Field | Type | Presence |
|---|---|---|
| `source` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
{{< /details >}}


---

### `TransactionHistoryDetail`

Fetches one transaction's full detail (Service Code 13).

```go
func TransactionHistoryDetail(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req TransactionHistoryDetailRequest) (TransactionHistoryDetailResponse, error)
```

**Request &mdash; `TransactionHistoryDetailRequest`**

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `TransactionHistoryDetailResponse`**

`amount` and `refundAmount` are pointers since the container itself is Optional, even though `Money`'s own `value`/`currency` are Mandatory.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `cancelledTime` | `string` | <span class="badge-optional">Optional</span> |
| `dateTime` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `refundAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `remark` | `string` | <span class="badge-optional">Optional</span> |
| `sourceOfFunds` | `[]SourceOfFund` | <span class="badge-optional">Optional</span> |
| `status` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `type` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

{{< details title="SourceOfFund fields" >}}
Describes one source of funds used for a transaction. `source` is Mandatory; `amount` is a pointer since only its own `value`/`currency` are Mandatory, not the container itself.

| Field | Type | Presence |
|---|---|---|
| `source` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
{{< /details >}}


---

### `BankStatement`

Fetches a bank-statement-style transaction listing with running balances (Service Code 14).

```go
func BankStatement(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req BankStatementRequest) (BankStatementResponse, error)
```

**Request &mdash; `BankStatementRequest`**

`bankCardToken` and `accountNo` are mutually exclusive — set exactly one. This package doesn't enforce that; the server does.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `bankCardToken` | `string` | <span class="badge-optional">Optional</span> |
| `accountNo` | `string` | <span class="badge-optional">Optional</span> |
| `fromDateTime` | `string` | <span class="badge-optional">Optional</span> |
| `toDateTime` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `BankStatementResponse`**

The response body.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `balance` | `[]BankStatementBalance` | <span class="badge-optional">Optional</span> |
| `totalCreditEntries` | `*BankStatementEntryTotal` | <span class="badge-optional">Optional</span> |
| `totalDebitEntries` | `*BankStatementEntryTotal` | <span class="badge-optional">Optional</span> |
| `hasMore` | `string` | <span class="badge-optional">Optional</span> |
| `lastRecordDateTime` | `string` | <span class="badge-optional">Optional</span> |
| `detailData` | `[]BankStatementDetail` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

{{< details title="BankStatementBalance fields" >}}
One entry in `balance`: the running balance before/after the statement period. Uses `BankStatementBalanceAmount` instead of plain `Money` because it also carries a `dateTime`.

| Field | Type | Presence |
|---|---|---|
| `amount` | `BankStatementBalanceAmount` | <span class="badge-mandatory">Mandatory</span> |
| `startingBalance` | `BankStatementBalanceAmount` | <span class="badge-mandatory">Mandatory</span> |
| `endingBalance` | `BankStatementBalanceAmount` | <span class="badge-mandatory">Mandatory</span> |
{{< /details >}}

{{< details title="BankStatementBalanceAmount fields" >}}
The `{value, currency, dateTime}` shape used by `BankStatementBalance` — like `Money`, plus a timestamp.

| Field | Type | Presence |
|---|---|---|
| `value` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `currency` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `dateTime` | `string` | <span class="badge-mandatory">Mandatory</span> |
{{< /details >}}

{{< details title="BankStatementEntryTotal fields" >}}
Shared shape for `totalCreditEntries` and `totalDebitEntries`. `numberOfEntries` is `string`, not `int` — same reasoning as `pageSize`/`pageNumber` above.

| Field | Type | Presence |
|---|---|---|
| `numberOfEntries` | `string` | <span class="badge-optional">Optional</span> |
| `amount` | `snap.Money` | <span class="badge-mandatory">Mandatory</span> |
{{< /details >}}

{{< details title="BankStatementDetail fields" >}}
One entry in `detailData`: a single transaction line.

| Field | Type | Presence |
|---|---|---|
| `detailBalance` | `*BankStatementDetailBalance` | <span class="badge-optional">Optional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `originAmount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
| `transactionDate` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `remark` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `transactionId` | `string` | <span class="badge-optional">Optional</span> |
| `type` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `transactionDetailStatus` | `string` | <span class="badge-optional">Optional</span> |
| `detailInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |
{{< /details >}}

{{< details title="BankStatementDetailBalance fields" >}}
The balance immediately before (`startAmount`) and after (`endAmount`) one transaction.

| Field | Type | Presence |
|---|---|---|
| `startAmount` | `[]BankStatementDetailBalanceEntry` | <span class="badge-optional">Optional</span> |
| `endAmount` | `[]BankStatementDetailBalanceEntry` | <span class="badge-optional">Optional</span> |
{{< /details >}}

{{< details title="BankStatementDetailBalanceEntry fields" >}}
One entry in `startAmount`/`endAmount`.

| Field | Type | Presence |
|---|---|---|
| `amount` | `*snap.Money` | <span class="badge-optional">Optional</span> |
{{< /details >}}


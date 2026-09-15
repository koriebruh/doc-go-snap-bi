---
weight: 3
title: "Riwayat Transaksi"
description: "Riwayat Transaksi — Service Code 12-14 — 3 endpoint"
---

## Riwayat Transaksi

Pencarian list, detail, dan statement atas transaksi yang sudah settle — package `transactionhistory` (Service Code 12-14).

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

Menampilkan daftar transaksi lampau dalam rentang tanggal (Service Code 12).

```go
func TransactionHistoryList(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req TransactionHistoryListRequest) (TransactionHistoryListResponse, error)
```

**Request &mdash; `TransactionHistoryListRequest`**

`pageSize` dan `pageNumber` bertipe `string`, bukan `int` — standarnya mengirim keduanya sebagai angka berkutip di wire (contoh: `"10"`).

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `fromDateTime` | `string` | <span class="badge-optional">Opsional</span> |
| `toDateTime` | `string` | <span class="badge-optional">Opsional</span> |
| `pageSize` | `string` | <span class="badge-optional">Opsional</span> |
| `pageNumber` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `TransactionHistoryListResponse`**

Body response-nya.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `detailData` | `[]TransactionDetail` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

{{< details title="TransactionDetail fields" >}}
Satu entri di `detailData`.

| Field | Type | Presence |
|---|---|---|
| `dateTime` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `remark` | `string` | <span class="badge-optional">Opsional</span> |
| `sourceOfFunds` | `[]SourceOfFund` | <span class="badge-optional">Opsional</span> |
| `status` | `string` | <span class="badge-mandatory">Wajib</span> |
| `type` | `string` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

{{< details title="SourceOfFund fields" >}}
Mendeskripsikan satu sumber dana yang dipakai untuk sebuah transaksi. `source` bersifat Wajib; `amount` berupa pointer karena hanya `value`/`currency` miliknya sendiri yang Wajib, bukan objek pembungkusnya.

| Field | Type | Presence |
|---|---|---|
| `source` | `string` | <span class="badge-mandatory">Wajib</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
{{< /details >}}


---

### `TransactionHistoryDetail`

Mengambil detail lengkap satu transaksi (Service Code 13).

```go
func TransactionHistoryDetail(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req TransactionHistoryDetailRequest) (TransactionHistoryDetailResponse, error)
```

**Request &mdash; `TransactionHistoryDetailRequest`**

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `TransactionHistoryDetailResponse`**

`amount` dan `refundAmount` berupa pointer karena objek pembungkusnya sendiri Opsional, meskipun `value`/`currency` milik `Money` Wajib.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `cancelledTime` | `string` | <span class="badge-optional">Opsional</span> |
| `dateTime` | `string` | <span class="badge-mandatory">Wajib</span> |
| `refundAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `remark` | `string` | <span class="badge-optional">Opsional</span> |
| `sourceOfFunds` | `[]SourceOfFund` | <span class="badge-optional">Opsional</span> |
| `status` | `string` | <span class="badge-mandatory">Wajib</span> |
| `type` | `string` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

{{< details title="SourceOfFund fields" >}}
Mendeskripsikan satu sumber dana yang dipakai untuk sebuah transaksi. `source` bersifat Wajib; `amount` berupa pointer karena hanya `value`/`currency` miliknya sendiri yang Wajib, bukan objek pembungkusnya.

| Field | Type | Presence |
|---|---|---|
| `source` | `string` | <span class="badge-mandatory">Wajib</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
{{< /details >}}


---

### `BankStatement`

Mengambil daftar transaksi bergaya rekening koran (bank statement) lengkap dengan saldo berjalan (Service Code 14).

```go
func BankStatement(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req BankStatementRequest) (BankStatementResponse, error)
```

**Request &mdash; `BankStatementRequest`**

`bankCardToken` dan `accountNo` saling eksklusif — isi tepat salah satu. Package ini tidak memaksakan aturan itu; servernya yang melakukan.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `bankCardToken` | `string` | <span class="badge-optional">Opsional</span> |
| `accountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `fromDateTime` | `string` | <span class="badge-optional">Opsional</span> |
| `toDateTime` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `BankStatementResponse`**

Body response-nya.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `balance` | `[]BankStatementBalance` | <span class="badge-optional">Opsional</span> |
| `totalCreditEntries` | `*BankStatementEntryTotal` | <span class="badge-optional">Opsional</span> |
| `totalDebitEntries` | `*BankStatementEntryTotal` | <span class="badge-optional">Opsional</span> |
| `hasMore` | `string` | <span class="badge-optional">Opsional</span> |
| `lastRecordDateTime` | `string` | <span class="badge-optional">Opsional</span> |
| `detailData` | `[]BankStatementDetail` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

{{< details title="BankStatementBalance fields" >}}
Satu entri di `balance`: saldo berjalan sebelum/sesudah periode statement. Memakai `BankStatementBalanceAmount`, bukan `Money` polos, karena juga membawa `dateTime`.

| Field | Type | Presence |
|---|---|---|
| `amount` | `BankStatementBalanceAmount` | <span class="badge-mandatory">Wajib</span> |
| `startingBalance` | `BankStatementBalanceAmount` | <span class="badge-mandatory">Wajib</span> |
| `endingBalance` | `BankStatementBalanceAmount` | <span class="badge-mandatory">Wajib</span> |
{{< /details >}}

{{< details title="BankStatementBalanceAmount fields" >}}
Bentuk `{value, currency, dateTime}` yang dipakai `BankStatementBalance` — seperti `Money`, ditambah timestamp.

| Field | Type | Presence |
|---|---|---|
| `value` | `string` | <span class="badge-mandatory">Wajib</span> |
| `currency` | `string` | <span class="badge-mandatory">Wajib</span> |
| `dateTime` | `string` | <span class="badge-mandatory">Wajib</span> |
{{< /details >}}

{{< details title="BankStatementEntryTotal fields" >}}
Bentuk yang dipakai bersama oleh `totalCreditEntries` dan `totalDebitEntries`. `numberOfEntries` bertipe `string`, bukan `int` — alasannya sama seperti `pageSize`/`pageNumber` di atas.

| Field | Type | Presence |
|---|---|---|
| `numberOfEntries` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `snap.Money` | <span class="badge-mandatory">Wajib</span> |
{{< /details >}}

{{< details title="BankStatementDetail fields" >}}
Satu entri di `detailData`: satu baris transaksi.

| Field | Type | Presence |
|---|---|---|
| `detailBalance` | `*BankStatementDetailBalance` | <span class="badge-optional">Opsional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `originAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `transactionDate` | `string` | <span class="badge-mandatory">Wajib</span> |
| `remark` | `string` | <span class="badge-mandatory">Wajib</span> |
| `transactionId` | `string` | <span class="badge-optional">Opsional</span> |
| `type` | `string` | <span class="badge-mandatory">Wajib</span> |
| `transactionDetailStatus` | `string` | <span class="badge-optional">Opsional</span> |
| `detailInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

{{< details title="BankStatementDetailBalance fields" >}}
Saldo tepat sebelum (`startAmount`) dan sesudah (`endAmount`) satu transaksi.

| Field | Type | Presence |
|---|---|---|
| `startAmount` | `[]BankStatementDetailBalanceEntry` | <span class="badge-optional">Opsional</span> |
| `endAmount` | `[]BankStatementDetailBalanceEntry` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

{{< details title="BankStatementDetailBalanceEntry fields" >}}
Satu entri di `startAmount`/`endAmount`.

| Field | Type | Presence |
|---|---|---|
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

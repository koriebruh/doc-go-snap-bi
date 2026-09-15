---
weight: 5
title: "Bulk Cash In"
description: "Kirim sekumpulan instruksi cash-in; hasil settlement datang sebagai notifikasi masuk, bukan response sinkron."
---

## Bulk Cash In

Kirim sekumpulan instruksi cash-in; hasil settlement datang sebagai notifikasi masuk, bukan response sinkron.

```go
resp, err := transfercredit.SubmitBulkCashIn(ctx, transport, hb, transfercredit.SubmitBulkCashInRequest{
	TransactionDate: "2026-09-14T10:00:00+07:00",
})
if err != nil {
	// errors.Is(err, snap.ErrBadRequest), snap.ErrUnauthorized, etc.
}
```

### `SubmitBulkCashIn`

Memanggil endpoint SNAP Submit Bulk Cash In (Service Code 40, path .../{version}/emoney/bulk-cashin-payment). `hb` harus sudah membawa setiap field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body`, yang diatur sendiri oleh `SubmitBulkCashIn` agar byte hasil marshal yang sama persis dipakai untuk signing dan wire body.

Tidak idempotent dan package ini tidak melakukan retry. Bila memanggil ulang setelah gagal/timeout, gunakan `X-EXTERNAL-ID` yang sama — deteksi duplikat di server mengacu pada header ini.

```go
func SubmitBulkCashIn(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req SubmitBulkCashInRequest) (SubmitBulkCashInResponse, error)
```

**Request &mdash; `SubmitBulkCashInRequest`**

`TransactionDate` satu-satunya field wajib di level atas.

| Field | Type | Presence |
|---|---|---|
| `partnerBulkId` | `string` | <span class="badge-optional">Opsional</span> |
| `transactionDate` | `string` | <span class="badge-mandatory">Wajib</span> |
| `currency` | `string` | <span class="badge-optional">Opsional</span> |
| `bulkObject` | `[]BulkCashInItem` | <span class="badge-optional">Opsional</span> |
| `feeType` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

{{< details title="Field BulkCashInItem" >}}
Satu entri dalam array `bulkObject[]` pada request Submit Bulk Cash In. `AccountNumber` dan `PartnerReferenceNo` wajib.

| Field | Type | Presence |
|---|---|---|
| `accountNumber` | `string` | <span class="badge-mandatory">Wajib</span> |
| `accountName` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

**Response &mdash; `SubmitBulkCashInResponse`**

Perhatikan field-nya `bulkid` (huruf d kecil) — kemungkinan salah ketik di standar, tapi package ini mengikuti casing yang terdokumentasi apa adanya karena tidak ada contoh yang mengoreksinya. Response Notify Bulk Cash In di bawah memakai camelCase normal `bulkId`.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `bulkid` | `string` | <span class="badge-mandatory">Wajib</span> |
| `partnerBulkId` | `string` | <span class="badge-optional">Opsional</span> |


---

### `Notify Bulk Cash In`

{{< callout type="info" >}}
Hanya masuk (inbound) &mdash; package ini tidak memanggil endpoint untuk ini. Partner/switcher yang POST ke callback URL **Anda**; unmarshal body ke `NotifyBulkCashInRequest` setelah memverifikasinya dengan `snap.ServerVerifier` (lihat [Verifying inbound requests](/id/docs/concepts/webhooks/)), lalu balas dengan bentuk di bawah.
{{< /callout >}}

**Diterima &mdash; `NotifyBulkCashInRequest`**

Ini adalah callback settlement yang diterima PJP, bukan panggilan dari package ini — buat HTTP handler sendiri untuk path ini, autentikasi dengan `ServerVerifier.VerifyTransactionRequest`, lalu `json.Unmarshal` body ke tipe ini. `BulkID` dan `PartnerBulkID` wajib.

| Field | Type | Presence |
|---|---|---|
| `bulkId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `partnerBulkId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `bulkObject` | `[]BulkCashInNotificationItem` | <span class="badge-mandatory">Wajib</span> |

{{< details title="Field BulkCashInNotificationItem" >}}
Satu entri dalam array `bulkObject[]` notifikasi ini — bentuk hasil settlement, berbeda dari bentuk instruksi transfer `BulkCashInItem`. `CustomerNumber`, `ReferenceNo`, `PartnerReferenceNo`, `ResponseCode`, dan `ResponseMessage` semuanya wajib.

| Field | Type | Presence |
|---|---|---|
| `customerNumber` | `string` | <span class="badge-mandatory">Wajib</span> |
| `customerName` | `string` | <span class="badge-optional">Opsional</span> |
| `amount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `referenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

**Handler Anda membalas dengan &mdash; `NotifyBulkCashInResponse`**

`BulkID` dan `PartnerBulkID` wajib. Field `bulkId`-nya camelCase normal — beda dari `bulkid` huruf kecil pada `SubmitBulkCashInResponse` di atas.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `bulkId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `partnerBulkId` | `string` | <span class="badge-mandatory">Wajib</span> |

---
weight: 3
title: "Virtual Account"
description: "Siklus hidup VA lengkap: manajemen (create/update/inquire/delete) dan pemanggilan sisi transaksi (inquiry, payment, status, varian intrabank, report)."
---

## Virtual Account

Siklus hidup VA lengkap: manajemen (create/update/inquire/delete) dan pemanggilan sisi transaksi (inquiry, payment, status, varian intrabank, report).

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

Memanggil endpoint SNAP VA - Create VA (Service Code 27, path .../{version}/transfer-va/create-va). `hb` harus sudah diisi semua field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body` — CreateVA yang mengisinya sendiri agar byte yang sama persis dipakai untuk signing maupun request di wire.

Tidak idempoten dan tidak di-retry otomatis oleh package ini. Kalau me-retry request yang gagal/timeout, pakai `X-EXTERNAL-ID` yang sama — server mendeteksi duplikat lewat header ini, jadi ID baru berisiko membuat VA duplikat.

```go
func CreateVA(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req CreateVARequest) (CreateVAResponse, error)
```

**Request &mdash; `CreateVARequest`**

`VirtualAccountName` dan `TrxID` wajib diisi; tidak seperti endpoint Virtual Account lainnya, identity triple (`PartnerServiceID`, `CustomerNo`, `VirtualAccountNo`) di sini Opsional.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | <span class="badge-optional">Opsional</span> |
| `customerNo` | `string` | <span class="badge-optional">Opsional</span> |
| `virtualAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `virtualAccountName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `trxId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `totalAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `billDetails` | `[]BillDetail` | <span class="badge-optional">Opsional</span> |
| `freeTexts` | `[]LocalizedText` | <span class="badge-optional">Opsional</span> |
| `virtualAccountTrxType` | `string` | <span class="badge-optional">Opsional</span> |
| `feeAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `expiredDate` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

{{< details title="BillDetail fields" >}}
Satu entri dalam array `billDetails[]` (maksimal 24 entri) yang dipakai di seluruh kelompok Virtual Account. `billReferenceNo` bertipe `json.RawMessage` karena standarnya mendokumentasikan field ini sebagai Numeric tapi sebagian issuer mengirimnya sebagai angka JSON polos — kalau Anda mengisinya sendiri (mis. di `CreateVARequest`), berikan nilai JSON yang lengkap seperti `json.RawMessage(\`"BILLREF1"\`)` atau `json.RawMessage(\`123\`)`, bukan string Go biasa.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | <span class="badge-optional">Opsional</span> |
| `billNo` | `string` | <span class="badge-optional">Opsional</span> |
| `billName` | `string` | <span class="badge-optional">Opsional</span> |
| `billShortName` | `string` | <span class="badge-optional">Opsional</span> |
| `billDescription` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
| `billSubCompany` | `string` | <span class="badge-optional">Opsional</span> |
| `billAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `billAmountLabel` | `string` | <span class="badge-optional">Opsional</span> |
| `billAmountValue` | `string` | <span class="badge-optional">Opsional</span> |
| `billReferenceNo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `status` | `string` | <span class="badge-optional">Opsional</span> |
| `reason` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
Bentuk teks dwibahasa {english, indonesia} yang dipakai bersama di seluruh sub-kelompok Virtual Account (mis. inquiryReason, paymentFlagReason, billDescription, reason per-bill, entri freeTexts[]). Kedua field bertipe String, tidak ditandai M/O di sumbernya, jadi keduanya carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | <span class="badge-optional">Opsional</span> |
| `indonesia` | `string` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

**Response &mdash; `CreateVAResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `virtualAccountData` | `*CreateVAData` | <span class="badge-optional">Opsional</span> |

{{< details title="CreateVAData fields" >}}
Objek `virtualAccountData` pada `CreateVAResponse`.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | <span class="badge-optional">Opsional</span> |
| `customerNo` | `string` | <span class="badge-optional">Opsional</span> |
| `virtualAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `virtualAccountName` | `string` | <span class="badge-optional">Opsional</span> |
| `trxId` | `string` | <span class="badge-optional">Opsional</span> |
| `totalAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `billDetails` | `[]BillDetail` | <span class="badge-optional">Opsional</span> |
| `freeTexts` | `[]LocalizedText` | <span class="badge-optional">Opsional</span> |
| `virtualAccountTrxType` | `string` | <span class="badge-optional">Opsional</span> |
| `feeAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `expiredDate` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

{{< details title="BillDetail fields" >}}
Satu entri dalam array `billDetails[]` (maksimal 24 entri) yang dipakai di seluruh kelompok Virtual Account. `billReferenceNo` bertipe `json.RawMessage` karena standarnya mendokumentasikan field ini sebagai Numeric tapi sebagian issuer mengirimnya sebagai angka JSON polos — kalau Anda mengisinya sendiri (mis. di `CreateVARequest`), berikan nilai JSON yang lengkap seperti `json.RawMessage(\`"BILLREF1"\`)` atau `json.RawMessage(\`123\`)`, bukan string Go biasa.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | <span class="badge-optional">Opsional</span> |
| `billNo` | `string` | <span class="badge-optional">Opsional</span> |
| `billName` | `string` | <span class="badge-optional">Opsional</span> |
| `billShortName` | `string` | <span class="badge-optional">Opsional</span> |
| `billDescription` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
| `billSubCompany` | `string` | <span class="badge-optional">Opsional</span> |
| `billAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `billAmountLabel` | `string` | <span class="badge-optional">Opsional</span> |
| `billAmountValue` | `string` | <span class="badge-optional">Opsional</span> |
| `billReferenceNo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `status` | `string` | <span class="badge-optional">Opsional</span> |
| `reason` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
Bentuk teks dwibahasa {english, indonesia} yang dipakai bersama di seluruh sub-kelompok Virtual Account (mis. inquiryReason, paymentFlagReason, billDescription, reason per-bill, entri freeTexts[]). Kedua field bertipe String, tidak ditandai M/O di sumbernya, jadi keduanya carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | <span class="badge-optional">Opsional</span> |
| `indonesia` | `string` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

---

### `UpdateVA`

Memanggil endpoint SNAP VA - Update VA (Service Code 28, path .../{version}/transfer-va/update-va, HTTP PUT). `hb` harus sudah diisi semua field yang dibutuhkan `snap.HeaderBuilder` kecuali `Method` dan `Body` — `UpdateVA` yang mengisinya sendiri: `Method` diisi PUT (method-nya tetap, tidak bisa diubah pemanggil) dan `Body` diisi agar byte yang sama persis dipakai untuk signing maupun request di wire.

Tidak idempoten dan tidak di-retry otomatis oleh package ini. Kalau me-retry request yang gagal/timeout, pakai `X-EXTERNAL-ID` yang sama — server mendeteksi duplikat lewat header ini.

```go
func UpdateVA(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req UpdateVARequest) (UpdateVAResponse, error)
```

**Request &mdash; `UpdateVARequest`**

`PartnerServiceID`, `CustomerNo`, `VirtualAccountNo`, `VirtualAccountName`, dan `TrxID` wajib diisi — tidak seperti Create VA, identity triple di sini Wajib.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `customerNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `virtualAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `virtualAccountName` | `string` | <span class="badge-mandatory">Wajib</span> |
| `trxId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `totalAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `billDetails` | `[]BillDetail` | <span class="badge-optional">Opsional</span> |
| `freeTexts` | `[]LocalizedText` | <span class="badge-optional">Opsional</span> |
| `virtualAccountTrxType` | `string` | <span class="badge-optional">Opsional</span> |
| `feeAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `expiredDate` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

{{< details title="BillDetail fields" >}}
Satu entri dalam array `billDetails[]` (maksimal 24 entri) yang dipakai di seluruh kelompok Virtual Account. `billReferenceNo` bertipe `json.RawMessage` karena standarnya mendokumentasikan field ini sebagai Numeric tapi sebagian issuer mengirimnya sebagai angka JSON polos — kalau Anda mengisinya sendiri (mis. di `CreateVARequest`), berikan nilai JSON yang lengkap seperti `json.RawMessage(\`"BILLREF1"\`)` atau `json.RawMessage(\`123\`)`, bukan string Go biasa.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | <span class="badge-optional">Opsional</span> |
| `billNo` | `string` | <span class="badge-optional">Opsional</span> |
| `billName` | `string` | <span class="badge-optional">Opsional</span> |
| `billShortName` | `string` | <span class="badge-optional">Opsional</span> |
| `billDescription` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
| `billSubCompany` | `string` | <span class="badge-optional">Opsional</span> |
| `billAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `billAmountLabel` | `string` | <span class="badge-optional">Opsional</span> |
| `billAmountValue` | `string` | <span class="badge-optional">Opsional</span> |
| `billReferenceNo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `status` | `string` | <span class="badge-optional">Opsional</span> |
| `reason` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
Bentuk teks dwibahasa {english, indonesia} yang dipakai bersama di seluruh sub-kelompok Virtual Account (mis. inquiryReason, paymentFlagReason, billDescription, reason per-bill, entri freeTexts[]). Kedua field bertipe String, tidak ditandai M/O di sumbernya, jadi keduanya carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | <span class="badge-optional">Opsional</span> |
| `indonesia` | `string` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

**Response &mdash; `UpdateVAResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `virtualAccountData` | `*UpdateVAData` | <span class="badge-optional">Opsional</span> |

{{< details title="UpdateVAData fields" >}}
Objek `virtualAccountData` pada `UpdateVAResponse` — field data Create VA ditambah `LastUpdateDate` dan `PaymentDate`.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | <span class="badge-optional">Opsional</span> |
| `customerNo` | `string` | <span class="badge-optional">Opsional</span> |
| `virtualAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `virtualAccountName` | `string` | <span class="badge-optional">Opsional</span> |
| `trxId` | `string` | <span class="badge-optional">Opsional</span> |
| `totalAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `billDetails` | `[]BillDetail` | <span class="badge-optional">Opsional</span> |
| `freeTexts` | `[]LocalizedText` | <span class="badge-optional">Opsional</span> |
| `virtualAccountTrxType` | `string` | <span class="badge-optional">Opsional</span> |
| `feeAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `expiredDate` | `string` | <span class="badge-optional">Opsional</span> |
| `lastUpdateDate` | `string` | <span class="badge-optional">Opsional</span> |
| `paymentDate` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

{{< details title="BillDetail fields" >}}
Satu entri dalam array `billDetails[]` (maksimal 24 entri) yang dipakai di seluruh kelompok Virtual Account. `billReferenceNo` bertipe `json.RawMessage` karena standarnya mendokumentasikan field ini sebagai Numeric tapi sebagian issuer mengirimnya sebagai angka JSON polos — kalau Anda mengisinya sendiri (mis. di `CreateVARequest`), berikan nilai JSON yang lengkap seperti `json.RawMessage(\`"BILLREF1"\`)` atau `json.RawMessage(\`123\`)`, bukan string Go biasa.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | <span class="badge-optional">Opsional</span> |
| `billNo` | `string` | <span class="badge-optional">Opsional</span> |
| `billName` | `string` | <span class="badge-optional">Opsional</span> |
| `billShortName` | `string` | <span class="badge-optional">Opsional</span> |
| `billDescription` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
| `billSubCompany` | `string` | <span class="badge-optional">Opsional</span> |
| `billAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `billAmountLabel` | `string` | <span class="badge-optional">Opsional</span> |
| `billAmountValue` | `string` | <span class="badge-optional">Opsional</span> |
| `billReferenceNo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `status` | `string` | <span class="badge-optional">Opsional</span> |
| `reason` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
Bentuk teks dwibahasa {english, indonesia} yang dipakai bersama di seluruh sub-kelompok Virtual Account (mis. inquiryReason, paymentFlagReason, billDescription, reason per-bill, entri freeTexts[]). Kedua field bertipe String, tidak ditandai M/O di sumbernya, jadi keduanya carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | <span class="badge-optional">Opsional</span> |
| `indonesia` | `string` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

---

### `UpdateStatusVA`

Memanggil endpoint SNAP VA - Update Status VA (Service Code 29, path .../{version}/transfer-va/update-status, HTTP PUT). `hb` harus sudah diisi semua field yang dibutuhkan `snap.HeaderBuilder` kecuali `Method` dan `Body` — `UpdateStatusVA` yang mengisinya sendiri: `Method` diisi PUT (method-nya tetap, tidak bisa diubah pemanggil) dan `Body` diisi agar byte yang sama persis dipakai untuk signing maupun request di wire.

Tidak idempoten dan tidak di-retry otomatis oleh package ini. Kalau me-retry request yang gagal/timeout, pakai `X-EXTERNAL-ID` yang sama — server mendeteksi duplikat lewat header ini.

```go
func UpdateStatusVA(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req UpdateStatusVARequest) (UpdateStatusVAResponse, error)
```

**Request &mdash; `UpdateStatusVARequest`**

`PartnerServiceID`, `CustomerNo`, `VirtualAccountNo`, `TrxID`, dan `PaidStatus` wajib diisi. Nilai `PaidStatus` adalah `"Y"`/`"N"`.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `customerNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `virtualAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `trxId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `paidStatus` | `string` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `UpdateStatusVAResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `virtualAccountData` | `*UpdateStatusVAData` | <span class="badge-optional">Opsional</span> |

{{< details title="UpdateStatusVAData fields" >}}
Objek `virtualAccountData` pada `UpdateStatusVAResponse` — himpunan field yang sama dengan `UpdateVAData`, hanya beda nama tipe.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | <span class="badge-optional">Opsional</span> |
| `customerNo` | `string` | <span class="badge-optional">Opsional</span> |
| `virtualAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `virtualAccountName` | `string` | <span class="badge-optional">Opsional</span> |
| `trxId` | `string` | <span class="badge-optional">Opsional</span> |
| `totalAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `billDetails` | `[]BillDetail` | <span class="badge-optional">Opsional</span> |
| `freeTexts` | `[]LocalizedText` | <span class="badge-optional">Opsional</span> |
| `virtualAccountTrxType` | `string` | <span class="badge-optional">Opsional</span> |
| `feeAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `expiredDate` | `string` | <span class="badge-optional">Opsional</span> |
| `lastUpdateDate` | `string` | <span class="badge-optional">Opsional</span> |
| `paymentDate` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

{{< details title="BillDetail fields" >}}
Satu entri dalam array `billDetails[]` (maksimal 24 entri) yang dipakai di seluruh kelompok Virtual Account. `billReferenceNo` bertipe `json.RawMessage` karena standarnya mendokumentasikan field ini sebagai Numeric tapi sebagian issuer mengirimnya sebagai angka JSON polos — kalau Anda mengisinya sendiri (mis. di `CreateVARequest`), berikan nilai JSON yang lengkap seperti `json.RawMessage(\`"BILLREF1"\`)` atau `json.RawMessage(\`123\`)`, bukan string Go biasa.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | <span class="badge-optional">Opsional</span> |
| `billNo` | `string` | <span class="badge-optional">Opsional</span> |
| `billName` | `string` | <span class="badge-optional">Opsional</span> |
| `billShortName` | `string` | <span class="badge-optional">Opsional</span> |
| `billDescription` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
| `billSubCompany` | `string` | <span class="badge-optional">Opsional</span> |
| `billAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `billAmountLabel` | `string` | <span class="badge-optional">Opsional</span> |
| `billAmountValue` | `string` | <span class="badge-optional">Opsional</span> |
| `billReferenceNo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `status` | `string` | <span class="badge-optional">Opsional</span> |
| `reason` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
Bentuk teks dwibahasa {english, indonesia} yang dipakai bersama di seluruh sub-kelompok Virtual Account (mis. inquiryReason, paymentFlagReason, billDescription, reason per-bill, entri freeTexts[]). Kedua field bertipe String, tidak ditandai M/O di sumbernya, jadi keduanya carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | <span class="badge-optional">Opsional</span> |
| `indonesia` | `string` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

---

### `InquiryVA`

Memanggil endpoint SNAP VA - Inquiry VA (Service Code 30, path .../{version}/transfer-va/inquiry-va). `hb` harus sudah diisi semua field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body` — InquiryVA yang mengisinya sendiri agar byte yang sama persis dipakai untuk signing maupun request di wire.

```go
func InquiryVA(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req InquiryVARequest) (InquiryVAResponse, error)
```

**Request &mdash; `InquiryVARequest`**

`PartnerServiceID`, `CustomerNo`, `VirtualAccountNo`, dan `TrxID` wajib diisi.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `customerNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `virtualAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `trxId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `InquiryVAResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `virtualAccountData` | `*InquiryVAData` | <span class="badge-optional">Opsional</span> |

{{< details title="InquiryVAData fields" >}}
Objek `virtualAccountData` pada `InquiryVAResponse` — himpunan field yang sama dengan `UpdateVAData` (bentuknya sama seperti response Update VA), hanya beda nama tipe.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | <span class="badge-optional">Opsional</span> |
| `customerNo` | `string` | <span class="badge-optional">Opsional</span> |
| `virtualAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `virtualAccountName` | `string` | <span class="badge-optional">Opsional</span> |
| `trxId` | `string` | <span class="badge-optional">Opsional</span> |
| `totalAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `billDetails` | `[]BillDetail` | <span class="badge-optional">Opsional</span> |
| `freeTexts` | `[]LocalizedText` | <span class="badge-optional">Opsional</span> |
| `virtualAccountTrxType` | `string` | <span class="badge-optional">Opsional</span> |
| `feeAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `expiredDate` | `string` | <span class="badge-optional">Opsional</span> |
| `lastUpdateDate` | `string` | <span class="badge-optional">Opsional</span> |
| `paymentDate` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

{{< details title="BillDetail fields" >}}
Satu entri dalam array `billDetails[]` (maksimal 24 entri) yang dipakai di seluruh kelompok Virtual Account. `billReferenceNo` bertipe `json.RawMessage` karena standarnya mendokumentasikan field ini sebagai Numeric tapi sebagian issuer mengirimnya sebagai angka JSON polos — kalau Anda mengisinya sendiri (mis. di `CreateVARequest`), berikan nilai JSON yang lengkap seperti `json.RawMessage(\`"BILLREF1"\`)` atau `json.RawMessage(\`123\`)`, bukan string Go biasa.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | <span class="badge-optional">Opsional</span> |
| `billNo` | `string` | <span class="badge-optional">Opsional</span> |
| `billName` | `string` | <span class="badge-optional">Opsional</span> |
| `billShortName` | `string` | <span class="badge-optional">Opsional</span> |
| `billDescription` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
| `billSubCompany` | `string` | <span class="badge-optional">Opsional</span> |
| `billAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `billAmountLabel` | `string` | <span class="badge-optional">Opsional</span> |
| `billAmountValue` | `string` | <span class="badge-optional">Opsional</span> |
| `billReferenceNo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `status` | `string` | <span class="badge-optional">Opsional</span> |
| `reason` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
Bentuk teks dwibahasa {english, indonesia} yang dipakai bersama di seluruh sub-kelompok Virtual Account (mis. inquiryReason, paymentFlagReason, billDescription, reason per-bill, entri freeTexts[]). Kedua field bertipe String, tidak ditandai M/O di sumbernya, jadi keduanya carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | <span class="badge-optional">Opsional</span> |
| `indonesia` | `string` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

---

### `DeleteVA`

Memanggil endpoint SNAP VA - Delete VA (Service Code 31, path .../{version}/transfer-va/delete-va, HTTP DELETE). `hb` harus sudah diisi semua field yang dibutuhkan `snap.HeaderBuilder` kecuali `Method` dan `Body` — `DeleteVA` yang mengisinya sendiri: `Method` diisi DELETE (method-nya tetap, tidak bisa diubah pemanggil) dan `Body` diisi karena endpoint DELETE ini tetap mengirim body JSON, bukan lewat path parameter — byte yang sama persis dipakai untuk signing maupun request di wire.

Tidak idempoten dan tidak di-retry otomatis oleh package ini. Kalau me-retry request yang gagal/timeout, pakai `X-EXTERNAL-ID` yang sama — server mendeteksi duplikat lewat header ini.

```go
func DeleteVA(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req DeleteVARequest) (DeleteVAResponse, error)
```

**Request &mdash; `DeleteVARequest`**

`PartnerServiceID`, `CustomerNo`, dan `VirtualAccountNo` wajib diisi; `TrxID` Opsional.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `customerNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `virtualAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `trxId` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `DeleteVAResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `virtualAccountData` | `*DeleteVAData` | <span class="badge-optional">Opsional</span> |

{{< details title="DeleteVAData fields" >}}
Objek `virtualAccountData` pada `DeleteVAResponse` — bentuknya lebih kecil dibanding data object endpoint manajemen VA lainnya.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | <span class="badge-optional">Opsional</span> |
| `customerNo` | `string` | <span class="badge-optional">Opsional</span> |
| `virtualAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `trxId` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

---

### `VAInquiry`

Memanggil endpoint SNAP VA - VA Inquiry (Service Code 24, path .../{version}/transfer-va/inquiry). `hb` harus sudah diisi semua field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body` — VAInquiry yang mengisinya sendiri agar byte yang sama persis dipakai untuk signing maupun request di wire.

```go
func VAInquiry(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req VAInquiryRequest) (VAInquiryResponse, error)
```

**Request &mdash; `VAInquiryRequest`**

`partnerServiceId`, `customerNo`, `virtualAccountNo`, dan `inquiryRequestId` Wajib. `customerNo` bertipe `json.RawMessage` karena contoh resmi endpoint sejenis menampilkannya sebagai angka JSON polos, bukan string berkutip — berikan nilai JSON lengkap (mis. `json.RawMessage(\`"98765"\`)` atau `json.RawMessage(\`98765\`)`), bukan string Go biasa.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `customerNo` | `json.RawMessage` | <span class="badge-mandatory">Wajib</span> |
| `virtualAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `trxDateInit` | `string` | <span class="badge-optional">Opsional</span> |
| `channelCode` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `language` | `string` | <span class="badge-optional">Opsional</span> |
| `hashedSourceAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `sourceBankCode` | `string` | <span class="badge-optional">Opsional</span> |
| `passApp` | `string` | <span class="badge-optional">Opsional</span> |
| `inquiryRequestId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `VAInquiryResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `virtualAccountData` | `*VAInquiryData` | <span class="badge-optional">Opsional</span> |

{{< details title="VAInquiryData fields" >}}
Objek `virtualAccountData` pada `VAInquiryResponse`. Field selain identity triple tidak berlabel M/O di sumbernya, jadi semuanya Opsional (omitempty); `InquiryReason`, `TotalAmount`, dan `FeeAmount` berupa pointer karena omitempty tidak berlaku pada nilai struct non-pointer.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | <span class="badge-optional">Opsional</span> |
| `customerNo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `virtualAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `inquiryStatus` | `string` | <span class="badge-optional">Opsional</span> |
| `inquiryReason` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
| `virtualAccountName` | `string` | <span class="badge-optional">Opsional</span> |
| `virtualAccountEmail` | `string` | <span class="badge-optional">Opsional</span> |
| `virtualAccountPhone` | `string` | <span class="badge-optional">Opsional</span> |
| `inquiryRequestId` | `string` | <span class="badge-optional">Opsional</span> |
| `totalAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `subCompany` | `string` | <span class="badge-optional">Opsional</span> |
| `billDetails` | `[]BillDetail` | <span class="badge-optional">Opsional</span> |
| `freeTexts` | `[]LocalizedText` | <span class="badge-optional">Opsional</span> |
| `virtualAccountTrxType` | `string` | <span class="badge-optional">Opsional</span> |
| `feeAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
Bentuk teks dwibahasa {english, indonesia} yang dipakai bersama di seluruh sub-kelompok Virtual Account (mis. inquiryReason, paymentFlagReason, billDescription, reason per-bill, entri freeTexts[]). Kedua field bertipe String, tidak ditandai M/O di sumbernya, jadi keduanya carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | <span class="badge-optional">Opsional</span> |
| `indonesia` | `string` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

{{< details title="BillDetail fields" >}}
Satu entri dalam array `billDetails[]` (maksimal 24 entri) yang dipakai di seluruh kelompok Virtual Account. `billReferenceNo` bertipe `json.RawMessage` karena standarnya mendokumentasikan field ini sebagai Numeric tapi sebagian issuer mengirimnya sebagai angka JSON polos — kalau Anda mengisinya sendiri (mis. di `CreateVARequest`), berikan nilai JSON yang lengkap seperti `json.RawMessage(\`"BILLREF1"\`)` atau `json.RawMessage(\`123\`)`, bukan string Go biasa.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | <span class="badge-optional">Opsional</span> |
| `billNo` | `string` | <span class="badge-optional">Opsional</span> |
| `billName` | `string` | <span class="badge-optional">Opsional</span> |
| `billShortName` | `string` | <span class="badge-optional">Opsional</span> |
| `billDescription` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
| `billSubCompany` | `string` | <span class="badge-optional">Opsional</span> |
| `billAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `billAmountLabel` | `string` | <span class="badge-optional">Opsional</span> |
| `billAmountValue` | `string` | <span class="badge-optional">Opsional</span> |
| `billReferenceNo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `status` | `string` | <span class="badge-optional">Opsional</span> |
| `reason` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

---

### `VAPayment`

Memanggil endpoint SNAP VA - VA Payment (Service Code 25, path .../{version}/transfer-va/payment, HTTP POST — tanpa override method). `hb` harus sudah diisi semua field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body` — VAPayment yang mengisinya sendiri agar byte yang sama persis dipakai untuk signing maupun request di wire.

Tidak idempoten dan tidak di-retry otomatis oleh package ini. Kalau me-retry request yang gagal/timeout, pakai `X-EXTERNAL-ID` yang sama — server mendeteksi duplikat lewat header ini.

```go
func VAPayment(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req VAPaymentRequest) (VAPaymentResponse, error)
```

**Request &mdash; `VAPaymentRequest`**

`partnerServiceId`, `customerNo`, `virtualAccountNo`, `paymentRequestId`, dan `paidAmount` Wajib. `trxId` Kondisional — wajib diisi kalau VA-nya dibuat lewat `CreateVA`. `customerNo`, `channelCode`, dan `paymentType` bertipe `json.RawMessage` karena contoh resmi standarnya menampilkan ketiganya sebagai angka polos, bukan string berkutip.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `customerNo` | `json.RawMessage` | <span class="badge-mandatory">Wajib</span> |
| `virtualAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `trxId` | `string` | <span class="badge-optional">Opsional</span> |
| `paymentRequestId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `channelCode` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `hashedSourceAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `sourceBankCode` | `string` | <span class="badge-optional">Opsional</span> |
| `paidAmount` | `snap.Money` | <span class="badge-mandatory">Wajib</span> |
| `cumulativePaymentAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `paidBills` | `string` | <span class="badge-optional">Opsional</span> |
| `totalAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `trxDateTime` | `string` | <span class="badge-optional">Opsional</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `journalNum` | `string` | <span class="badge-optional">Opsional</span> |
| `paymentType` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `flagAdvise` | `string` | <span class="badge-optional">Opsional</span> |
| `subCompany` | `string` | <span class="badge-optional">Opsional</span> |
| `billDetails` | `[]BillDetail` | <span class="badge-optional">Opsional</span> |
| `freeTexts` | `[]LocalizedText` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

{{< details title="BillDetail fields" >}}
Satu entri dalam array `billDetails[]` (maksimal 24 entri) yang dipakai di seluruh kelompok Virtual Account. `billReferenceNo` bertipe `json.RawMessage` karena standarnya mendokumentasikan field ini sebagai Numeric tapi sebagian issuer mengirimnya sebagai angka JSON polos — kalau Anda mengisinya sendiri (mis. di `CreateVARequest`), berikan nilai JSON yang lengkap seperti `json.RawMessage(\`"BILLREF1"\`)` atau `json.RawMessage(\`123\`)`, bukan string Go biasa.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | <span class="badge-optional">Opsional</span> |
| `billNo` | `string` | <span class="badge-optional">Opsional</span> |
| `billName` | `string` | <span class="badge-optional">Opsional</span> |
| `billShortName` | `string` | <span class="badge-optional">Opsional</span> |
| `billDescription` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
| `billSubCompany` | `string` | <span class="badge-optional">Opsional</span> |
| `billAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `billAmountLabel` | `string` | <span class="badge-optional">Opsional</span> |
| `billAmountValue` | `string` | <span class="badge-optional">Opsional</span> |
| `billReferenceNo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `status` | `string` | <span class="badge-optional">Opsional</span> |
| `reason` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
Bentuk teks dwibahasa {english, indonesia} yang dipakai bersama di seluruh sub-kelompok Virtual Account (mis. inquiryReason, paymentFlagReason, billDescription, reason per-bill, entri freeTexts[]). Kedua field bertipe String, tidak ditandai M/O di sumbernya, jadi keduanya carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | <span class="badge-optional">Opsional</span> |
| `indonesia` | `string` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

**Response &mdash; `VAPaymentResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `virtualAccountData` | `*VAPaymentData` | <span class="badge-optional">Opsional</span> |

{{< details title="VAPaymentData fields" >}}
Objek `virtualAccountData` pada `VAPaymentResponse` — mencerminkan field request-nya ditambah `paymentFlagReason` dan `paymentFlagStatus`.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | <span class="badge-optional">Opsional</span> |
| `customerNo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `virtualAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `trxId` | `string` | <span class="badge-optional">Opsional</span> |
| `paymentRequestId` | `string` | <span class="badge-optional">Opsional</span> |
| `channelCode` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `hashedSourceAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `sourceBankCode` | `string` | <span class="badge-optional">Opsional</span> |
| `paidAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `cumulativePaymentAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `paidBills` | `string` | <span class="badge-optional">Opsional</span> |
| `totalAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `trxDateTime` | `string` | <span class="badge-optional">Opsional</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `journalNum` | `string` | <span class="badge-optional">Opsional</span> |
| `paymentType` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `flagAdvise` | `string` | <span class="badge-optional">Opsional</span> |
| `subCompany` | `string` | <span class="badge-optional">Opsional</span> |
| `billDetails` | `[]BillDetail` | <span class="badge-optional">Opsional</span> |
| `freeTexts` | `[]LocalizedText` | <span class="badge-optional">Opsional</span> |
| `paymentFlagReason` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
| `paymentFlagStatus` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

{{< details title="BillDetail fields" >}}
Satu entri dalam array `billDetails[]` (maksimal 24 entri) yang dipakai di seluruh kelompok Virtual Account. `billReferenceNo` bertipe `json.RawMessage` karena standarnya mendokumentasikan field ini sebagai Numeric tapi sebagian issuer mengirimnya sebagai angka JSON polos — kalau Anda mengisinya sendiri (mis. di `CreateVARequest`), berikan nilai JSON yang lengkap seperti `json.RawMessage(\`"BILLREF1"\`)` atau `json.RawMessage(\`123\`)`, bukan string Go biasa.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | <span class="badge-optional">Opsional</span> |
| `billNo` | `string` | <span class="badge-optional">Opsional</span> |
| `billName` | `string` | <span class="badge-optional">Opsional</span> |
| `billShortName` | `string` | <span class="badge-optional">Opsional</span> |
| `billDescription` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
| `billSubCompany` | `string` | <span class="badge-optional">Opsional</span> |
| `billAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `billAmountLabel` | `string` | <span class="badge-optional">Opsional</span> |
| `billAmountValue` | `string` | <span class="badge-optional">Opsional</span> |
| `billReferenceNo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `status` | `string` | <span class="badge-optional">Opsional</span> |
| `reason` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
Bentuk teks dwibahasa {english, indonesia} yang dipakai bersama di seluruh sub-kelompok Virtual Account (mis. inquiryReason, paymentFlagReason, billDescription, reason per-bill, entri freeTexts[]). Kedua field bertipe String, tidak ditandai M/O di sumbernya, jadi keduanya carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | <span class="badge-optional">Opsional</span> |
| `indonesia` | `string` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

---

### `VAInquiryStatus`

Memanggil endpoint SNAP VA - VA Inquiry Status (Service Code 26, path .../{version}/transfer-va/status). `hb` harus sudah diisi semua field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body` — VAInquiryStatus yang mengisinya sendiri agar byte yang sama persis dipakai untuk signing maupun request di wire.

```go
func VAInquiryStatus(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req VAInquiryStatusRequest) (VAInquiryStatusResponse, error)
```

**Request &mdash; `VAInquiryStatusRequest`**

`partnerServiceId`, `customerNo`, dan `virtualAccountNo` (identity triple) Wajib; `inquiryRequestId` dan `paymentRequestId` Opsional/Kondisional. Package ini selalu men-decode response sebagai satu objek tunggal, sesuai deklarasi tipe standarnya.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `customerNo` | `json.RawMessage` | <span class="badge-mandatory">Wajib</span> |
| `virtualAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `inquiryRequestId` | `string` | <span class="badge-optional">Opsional</span> |
| `paymentRequestId` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `VAInquiryStatusResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `virtualAccountData` | `*VAInquiryStatusData` | <span class="badge-optional">Opsional</span> |

{{< details title="VAInquiryStatusData fields" >}}
Objek `virtualAccountData` pada `VAInquiryStatusResponse` — bentuknya sama dengan `VAPaymentData` ditambah `transactionDate`, disimpan sebagai tipe sendiri karena Service Code-nya berbeda.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | <span class="badge-optional">Opsional</span> |
| `customerNo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `virtualAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `trxId` | `string` | <span class="badge-optional">Opsional</span> |
| `paymentRequestId` | `string` | <span class="badge-optional">Opsional</span> |
| `channelCode` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `hashedSourceAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `sourceBankCode` | `string` | <span class="badge-optional">Opsional</span> |
| `paidAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `cumulativePaymentAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `paidBills` | `string` | <span class="badge-optional">Opsional</span> |
| `totalAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `trxDateTime` | `string` | <span class="badge-optional">Opsional</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `journalNum` | `string` | <span class="badge-optional">Opsional</span> |
| `paymentType` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `flagAdvise` | `string` | <span class="badge-optional">Opsional</span> |
| `subCompany` | `string` | <span class="badge-optional">Opsional</span> |
| `billDetails` | `[]BillDetail` | <span class="badge-optional">Opsional</span> |
| `freeTexts` | `[]LocalizedText` | <span class="badge-optional">Opsional</span> |
| `paymentFlagReason` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
| `paymentFlagStatus` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

{{< details title="BillDetail fields" >}}
Satu entri dalam array `billDetails[]` (maksimal 24 entri) yang dipakai di seluruh kelompok Virtual Account. `billReferenceNo` bertipe `json.RawMessage` karena standarnya mendokumentasikan field ini sebagai Numeric tapi sebagian issuer mengirimnya sebagai angka JSON polos — kalau Anda mengisinya sendiri (mis. di `CreateVARequest`), berikan nilai JSON yang lengkap seperti `json.RawMessage(\`"BILLREF1"\`)` atau `json.RawMessage(\`123\`)`, bukan string Go biasa.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | <span class="badge-optional">Opsional</span> |
| `billNo` | `string` | <span class="badge-optional">Opsional</span> |
| `billName` | `string` | <span class="badge-optional">Opsional</span> |
| `billShortName` | `string` | <span class="badge-optional">Opsional</span> |
| `billDescription` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
| `billSubCompany` | `string` | <span class="badge-optional">Opsional</span> |
| `billAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `billAmountLabel` | `string` | <span class="badge-optional">Opsional</span> |
| `billAmountValue` | `string` | <span class="badge-optional">Opsional</span> |
| `billReferenceNo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `status` | `string` | <span class="badge-optional">Opsional</span> |
| `reason` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
Bentuk teks dwibahasa {english, indonesia} yang dipakai bersama di seluruh sub-kelompok Virtual Account (mis. inquiryReason, paymentFlagReason, billDescription, reason per-bill, entri freeTexts[]). Kedua field bertipe String, tidak ditandai M/O di sumbernya, jadi keduanya carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | <span class="badge-optional">Opsional</span> |
| `indonesia` | `string` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

---

### `VAInquiryPaymentIntrabank`

Memanggil endpoint SNAP VA - Inquiry Payment Intrabank (Service Code 32, path .../{version}/transfer-va/inquiry-intrabank). `hb` harus sudah diisi semua field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body` — VAInquiryPaymentIntrabank yang mengisinya sendiri agar byte yang sama persis dipakai untuk signing maupun request di wire.

```go
func VAInquiryPaymentIntrabank(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req VAInquiryPaymentIntrabankRequest) (VAInquiryPaymentIntrabankResponse, error)
```

**Request &mdash; `VAInquiryPaymentIntrabankRequest`**

`partnerServiceId`, `customerNo`, dan `virtualAccountNo` (identity triple) Wajib. `customerNo` bertipe `json.RawMessage` karena contoh resmi endpoint ini menampilkannya sebagai angka JSON polos.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `customerNo` | `json.RawMessage` | <span class="badge-mandatory">Wajib</span> |
| `virtualAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `sourceAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `sourceAccountType` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `VAInquiryPaymentIntrabankResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `virtualAccountdata` | `*VAInquiryPaymentIntrabankData` | <span class="badge-optional">Opsional</span> |

{{< details title="VAInquiryPaymentIntrabankData fields" >}}
Objek `virtualAccountdata` (huruf "d" kecil — sengaja mengikuti wire key standarnya, tidak seperti kebanyakan endpoint VA lain yang pakai `virtualAccountData`) pada `VAInquiryPaymentIntrabankResponse`.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | <span class="badge-optional">Opsional</span> |
| `customerNo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `virtualAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `sourceAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `sourceAccountType` | `string` | <span class="badge-optional">Opsional</span> |
| `productName` | `string` | <span class="badge-optional">Opsional</span> |
| `billAmountLabel` | `string` | <span class="badge-optional">Opsional</span> |
| `billAmountValue` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

---

### `VAPaymentIntrabank`

Memanggil endpoint SNAP VA - Payment Intrabank (Service Code 33, path .../{version}/transfer-va/payment-intrabank, HTTP POST — tanpa override method). `hb` harus sudah diisi semua field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body` — VAPaymentIntrabank yang mengisinya sendiri agar byte yang sama persis dipakai untuk signing maupun request di wire.

Tidak idempoten dan tidak di-retry otomatis oleh package ini. Kalau me-retry request yang gagal/timeout, pakai `X-EXTERNAL-ID` yang sama — server mendeteksi duplikat lewat header ini.

```go
func VAPaymentIntrabank(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req VAPaymentIntrabankRequest) (VAPaymentIntrabankResponse, error)
```

**Request &mdash; `VAPaymentIntrabankRequest`**

`partnerServiceId`, `customerNo`, `virtualAccountNo`, `partnerReferenceNo`, dan `paidAmount` Wajib. `customerNo` dan `referenceNo` bertipe `json.RawMessage` karena contoh resmi standarnya menampilkan keduanya sebagai angka polos, meski `referenceNo` muncul berkutip di response. `paymentStatus` berupa string status bebas, bukan kode 2 digit `transactionStatus` seperti biasanya di package ini.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `customerNo` | `json.RawMessage` | <span class="badge-mandatory">Wajib</span> |
| `virtualAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `sourceAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `sourceAccountType` | `string` | <span class="badge-optional">Opsional</span> |
| `inquiryRequestId` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `paidAmount` | `snap.Money` | <span class="badge-mandatory">Wajib</span> |
| `cumulativePaymentAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `paidBills` | `string` | <span class="badge-optional">Opsional</span> |
| `paymentStatus` | `string` | <span class="badge-optional">Opsional</span> |
| `referenceNo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `VAPaymentIntrabankResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `virtualAccountdata` | `*VAPaymentIntrabankData` | <span class="badge-optional">Opsional</span> |

{{< details title="VAPaymentIntrabankData fields" >}}
Objek `virtualAccountdata` (huruf "d" kecil) pada `VAPaymentIntrabankResponse` — mencerminkan field request-nya sendiri.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | <span class="badge-optional">Opsional</span> |
| `customerNo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `virtualAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `sourceAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `sourceAccountType` | `string` | <span class="badge-optional">Opsional</span> |
| `inquiryRequestId` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `paidAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `cumulativePaymentAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `paidBills` | `string` | <span class="badge-optional">Opsional</span> |
| `paymentStatus` | `string` | <span class="badge-optional">Opsional</span> |
| `referenceNo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

---

### `VANotifyPaymentIntrabank`

Memanggil endpoint SNAP VA - Notify Payment Intrabank (Service Code 34, path .../{version}/transfer-va/notify-payment-intrabank, HTTP POST — tanpa override method). `hb` harus sudah diisi semua field yang dibutuhkan `snap.HeaderBuilder` kecuali `Body` — VANotifyPaymentIntrabank yang mengisinya sendiri agar byte yang sama persis dipakai untuk signing maupun request di wire.

Tidak idempoten dan tidak di-retry otomatis oleh package ini. Kalau me-retry request yang gagal/timeout, pakai `X-EXTERNAL-ID` yang sama — server mendeteksi duplikat lewat header ini.

```go
func VANotifyPaymentIntrabank(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req VANotifyPaymentIntrabankRequest) (VANotifyPaymentIntrabankResponse, error)
```

**Request &mdash; `VANotifyPaymentIntrabankRequest`**

Berbeda dari notifikasi RTGS/SKNBI/Interbank-Bulk, yang ini outbound — kode Anda yang memanggilnya, PJP yang menerimanya — jadi ini fungsi pemanggil biasa, bukan struct inbound-only. `customerNo` bertipe `json.RawMessage` karena contoh resmi standarnya menampilkannya sebagai angka polos.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `customerNo` | `json.RawMessage` | <span class="badge-mandatory">Wajib</span> |
| `virtualAccountNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `inquiryRequestId` | `string` | <span class="badge-optional">Opsional</span> |
| `paymentRequestId` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `trxDateTime` | `string` | <span class="badge-optional">Opsional</span> |
| `paymentStatus` | `string` | <span class="badge-optional">Opsional</span> |
| `paymentFlagReason` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

{{< details title="LocalizedText fields" >}}
Bentuk teks dwibahasa {english, indonesia} yang dipakai bersama di seluruh sub-kelompok Virtual Account (mis. inquiryReason, paymentFlagReason, billDescription, reason per-bill, entri freeTexts[]). Kedua field bertipe String, tidak ditandai M/O di sumbernya, jadi keduanya carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | <span class="badge-optional">Opsional</span> |
| `indonesia` | `string` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

**Response &mdash; `VANotifyPaymentIntrabankResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `virtualAccountdata` | `*VANotifyPaymentIntrabankData` | <span class="badge-optional">Opsional</span> |

{{< details title="VANotifyPaymentIntrabankData fields" >}}
Objek `virtualAccountdata` (huruf "d" kecil) pada `VANotifyPaymentIntrabankResponse` — mencerminkan sebagian besar field request-nya, ditambah envelope.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | <span class="badge-optional">Opsional</span> |
| `customerNo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `virtualAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `inquiryRequestId` | `string` | <span class="badge-optional">Opsional</span> |
| `paymentRequestId` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `trxDateTime` | `string` | <span class="badge-optional">Opsional</span> |
| `paymentStatus` | `string` | <span class="badge-optional">Opsional</span> |
| `paymentFlagReason` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
Bentuk teks dwibahasa {english, indonesia} yang dipakai bersama di seluruh sub-kelompok Virtual Account (mis. inquiryReason, paymentFlagReason, billDescription, reason per-bill, entri freeTexts[]). Kedua field bertipe String, tidak ditandai M/O di sumbernya, jadi keduanya carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | <span class="badge-optional">Opsional</span> |
| `indonesia` | `string` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

---

### `VAGetReport`

Memanggil endpoint SNAP VA - Get Report (Service Code 35, path .../{version}/transfer-va/report). `hb` harus sudah diisi semua field yang dibutuhkan `snap.HeaderBuilder` kecuali `Method` dan `Body`: `VAGetReport` mengisi `Method` dengan POST sendiri (standarnya mendokumentasikan endpoint ini secara tidak konsisten sebagai GET maupun POST-dengan-body; package ini selalu pakai POST) dan `Body`, agar byte yang sama persis dipakai untuk signing maupun request di wire.

Laporan dengan rentang tanggal lebar bisa mengembalikan jumlah entri array yang tidak terbatas; transport layer bersama membatasi setiap response body sampai 10 MiB (lihat transport.go), jadi kalau menarik laporan besar sebaiknya di-page pakai rentang tanggal/waktu yang lebih sempit, bukan satu panggilan tak terbatas.

```go
func VAGetReport(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req VAGetReportRequest) (VAGetReportResponse, error)
```

**Request &mdash; `VAGetReportRequest`**

`partnerServiceId` satu-satunya field Wajib; bertipe `json.RawMessage` di sini karena standarnya mendokumentasikan field ini sebagai Number khusus untuk endpoint ini, tidak seperti endpoint VA lain yang bertipe String.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `json.RawMessage` | <span class="badge-mandatory">Wajib</span> |
| `startDate` | `string` | <span class="badge-optional">Opsional</span> |
| `startTime` | `string` | <span class="badge-optional">Opsional</span> |
| `endDate` | `string` | <span class="badge-optional">Opsional</span> |
| `endTime` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `VAGetReportResponse`**

Satu-satunya response VA di package ini yang field data-nya berupa array, bukan objek tunggal.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `virtualAccountdata` | `[]GetReportData` | <span class="badge-optional">Opsional</span> |

{{< details title="GetReportData fields" >}}
Satu entri dalam array `virtualAccountdata` (huruf "d" kecil) pada `VAGetReportResponse` — bentuknya sama dengan `VAInquiryStatusData`, disimpan sebagai tipe sendiri karena Service Code-nya berbeda.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | <span class="badge-optional">Opsional</span> |
| `customerNo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `virtualAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `trxId` | `string` | <span class="badge-optional">Opsional</span> |
| `paymentRequestId` | `string` | <span class="badge-optional">Opsional</span> |
| `channelCode` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `hashedSourceAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `sourceBankCode` | `string` | <span class="badge-optional">Opsional</span> |
| `paidAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `cumulativePaymentAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `paidBills` | `string` | <span class="badge-optional">Opsional</span> |
| `totalAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `trxDateTime` | `string` | <span class="badge-optional">Opsional</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `journalNum` | `string` | <span class="badge-optional">Opsional</span> |
| `paymentType` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `flagAdvise` | `string` | <span class="badge-optional">Opsional</span> |
| `subCompany` | `string` | <span class="badge-optional">Opsional</span> |
| `billDetails` | `[]BillDetail` | <span class="badge-optional">Opsional</span> |
| `freeTexts` | `[]LocalizedText` | <span class="badge-optional">Opsional</span> |
| `paymentFlagReason` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
| `paymentFlagStatus` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

{{< details title="BillDetail fields" >}}
Satu entri dalam array `billDetails[]` (maksimal 24 entri) yang dipakai di seluruh kelompok Virtual Account. `billReferenceNo` bertipe `json.RawMessage` karena standarnya mendokumentasikan field ini sebagai Numeric tapi sebagian issuer mengirimnya sebagai angka JSON polos — kalau Anda mengisinya sendiri (mis. di `CreateVARequest`), berikan nilai JSON yang lengkap seperti `json.RawMessage(\`"BILLREF1"\`)` atau `json.RawMessage(\`123\`)`, bukan string Go biasa.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | <span class="badge-optional">Opsional</span> |
| `billNo` | `string` | <span class="badge-optional">Opsional</span> |
| `billName` | `string` | <span class="badge-optional">Opsional</span> |
| `billShortName` | `string` | <span class="badge-optional">Opsional</span> |
| `billDescription` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
| `billSubCompany` | `string` | <span class="badge-optional">Opsional</span> |
| `billAmount` | `*snap.Money` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `billAmountLabel` | `string` | <span class="badge-optional">Opsional</span> |
| `billAmountValue` | `string` | <span class="badge-optional">Opsional</span> |
| `billReferenceNo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `status` | `string` | <span class="badge-optional">Opsional</span> |
| `reason` | `*LocalizedText` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
Bentuk teks dwibahasa {english, indonesia} yang dipakai bersama di seluruh sub-kelompok Virtual Account (mis. inquiryReason, paymentFlagReason, billDescription, reason per-bill, entri freeTexts[]). Kedua field bertipe String, tidak ditandai M/O di sumbernya, jadi keduanya carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | <span class="badge-optional">Opsional</span> |
| `indonesia` | `string` | <span class="badge-optional">Opsional</span> |
{{< /details >}}


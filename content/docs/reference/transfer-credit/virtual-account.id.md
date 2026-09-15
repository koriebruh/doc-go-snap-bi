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
| `partnerServiceId` | `string` | Opsional |
| `customerNo` | `string` | Opsional |
| `virtualAccountNo` | `string` | Opsional |
| `virtualAccountName` | `string` | Wajib |
| `trxId` | `string` | Wajib |
| `totalAmount` | `*snap.Money` | Opsional |
| `billDetails` | `[]BillDetail` | Opsional |
| `freeTexts` | `[]LocalizedText` | Opsional |
| `virtualAccountTrxType` | `string` | Opsional |
| `feeAmount` | `*snap.Money` | Opsional |
| `expiredDate` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

{{< details title="BillDetail fields" >}}
Satu entri dalam array `billDetails[]` (maksimal 24 entri) yang dipakai di seluruh kelompok Virtual Account. `billReferenceNo` bertipe `json.RawMessage` karena standarnya mendokumentasikan field ini sebagai Numeric tapi sebagian issuer mengirimnya sebagai angka JSON polos — kalau Anda mengisinya sendiri (mis. di `CreateVARequest`), berikan nilai JSON yang lengkap seperti `json.RawMessage(\`"BILLREF1"\`)` atau `json.RawMessage(\`123\`)`, bukan string Go biasa.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | Opsional |
| `billNo` | `string` | Opsional |
| `billName` | `string` | Opsional |
| `billShortName` | `string` | Opsional |
| `billDescription` | `*LocalizedText` | Opsional |
| `billSubCompany` | `string` | Opsional |
| `billAmount` | `*snap.Money` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |
| `billAmountLabel` | `string` | Opsional |
| `billAmountValue` | `string` | Opsional |
| `billReferenceNo` | `json.RawMessage` | Opsional |
| `status` | `string` | Opsional |
| `reason` | `*LocalizedText` | Opsional |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
Bentuk teks dwibahasa {english, indonesia} yang dipakai bersama di seluruh sub-kelompok Virtual Account (mis. inquiryReason, paymentFlagReason, billDescription, reason per-bill, entri freeTexts[]). Kedua field bertipe String, tidak ditandai M/O di sumbernya, jadi keduanya carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | Opsional |
| `indonesia` | `string` | Opsional |
{{< /details >}}

**Response &mdash; `CreateVAResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `virtualAccountData` | `*CreateVAData` | Opsional |

{{< details title="CreateVAData fields" >}}
Objek `virtualAccountData` pada `CreateVAResponse`.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Opsional |
| `customerNo` | `string` | Opsional |
| `virtualAccountNo` | `string` | Opsional |
| `virtualAccountName` | `string` | Opsional |
| `trxId` | `string` | Opsional |
| `totalAmount` | `*snap.Money` | Opsional |
| `billDetails` | `[]BillDetail` | Opsional |
| `freeTexts` | `[]LocalizedText` | Opsional |
| `virtualAccountTrxType` | `string` | Opsional |
| `feeAmount` | `*snap.Money` | Opsional |
| `expiredDate` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |
{{< /details >}}

{{< details title="BillDetail fields" >}}
Satu entri dalam array `billDetails[]` (maksimal 24 entri) yang dipakai di seluruh kelompok Virtual Account. `billReferenceNo` bertipe `json.RawMessage` karena standarnya mendokumentasikan field ini sebagai Numeric tapi sebagian issuer mengirimnya sebagai angka JSON polos — kalau Anda mengisinya sendiri (mis. di `CreateVARequest`), berikan nilai JSON yang lengkap seperti `json.RawMessage(\`"BILLREF1"\`)` atau `json.RawMessage(\`123\`)`, bukan string Go biasa.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | Opsional |
| `billNo` | `string` | Opsional |
| `billName` | `string` | Opsional |
| `billShortName` | `string` | Opsional |
| `billDescription` | `*LocalizedText` | Opsional |
| `billSubCompany` | `string` | Opsional |
| `billAmount` | `*snap.Money` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |
| `billAmountLabel` | `string` | Opsional |
| `billAmountValue` | `string` | Opsional |
| `billReferenceNo` | `json.RawMessage` | Opsional |
| `status` | `string` | Opsional |
| `reason` | `*LocalizedText` | Opsional |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
Bentuk teks dwibahasa {english, indonesia} yang dipakai bersama di seluruh sub-kelompok Virtual Account (mis. inquiryReason, paymentFlagReason, billDescription, reason per-bill, entri freeTexts[]). Kedua field bertipe String, tidak ditandai M/O di sumbernya, jadi keduanya carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | Opsional |
| `indonesia` | `string` | Opsional |
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
| `partnerServiceId` | `string` | Wajib |
| `customerNo` | `string` | Wajib |
| `virtualAccountNo` | `string` | Wajib |
| `virtualAccountName` | `string` | Wajib |
| `trxId` | `string` | Wajib |
| `totalAmount` | `*snap.Money` | Opsional |
| `billDetails` | `[]BillDetail` | Opsional |
| `freeTexts` | `[]LocalizedText` | Opsional |
| `virtualAccountTrxType` | `string` | Opsional |
| `feeAmount` | `*snap.Money` | Opsional |
| `expiredDate` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

{{< details title="BillDetail fields" >}}
Satu entri dalam array `billDetails[]` (maksimal 24 entri) yang dipakai di seluruh kelompok Virtual Account. `billReferenceNo` bertipe `json.RawMessage` karena standarnya mendokumentasikan field ini sebagai Numeric tapi sebagian issuer mengirimnya sebagai angka JSON polos — kalau Anda mengisinya sendiri (mis. di `CreateVARequest`), berikan nilai JSON yang lengkap seperti `json.RawMessage(\`"BILLREF1"\`)` atau `json.RawMessage(\`123\`)`, bukan string Go biasa.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | Opsional |
| `billNo` | `string` | Opsional |
| `billName` | `string` | Opsional |
| `billShortName` | `string` | Opsional |
| `billDescription` | `*LocalizedText` | Opsional |
| `billSubCompany` | `string` | Opsional |
| `billAmount` | `*snap.Money` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |
| `billAmountLabel` | `string` | Opsional |
| `billAmountValue` | `string` | Opsional |
| `billReferenceNo` | `json.RawMessage` | Opsional |
| `status` | `string` | Opsional |
| `reason` | `*LocalizedText` | Opsional |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
Bentuk teks dwibahasa {english, indonesia} yang dipakai bersama di seluruh sub-kelompok Virtual Account (mis. inquiryReason, paymentFlagReason, billDescription, reason per-bill, entri freeTexts[]). Kedua field bertipe String, tidak ditandai M/O di sumbernya, jadi keduanya carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | Opsional |
| `indonesia` | `string` | Opsional |
{{< /details >}}

**Response &mdash; `UpdateVAResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `virtualAccountData` | `*UpdateVAData` | Opsional |

{{< details title="UpdateVAData fields" >}}
Objek `virtualAccountData` pada `UpdateVAResponse` — field data Create VA ditambah `LastUpdateDate` dan `PaymentDate`.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Opsional |
| `customerNo` | `string` | Opsional |
| `virtualAccountNo` | `string` | Opsional |
| `virtualAccountName` | `string` | Opsional |
| `trxId` | `string` | Opsional |
| `totalAmount` | `*snap.Money` | Opsional |
| `billDetails` | `[]BillDetail` | Opsional |
| `freeTexts` | `[]LocalizedText` | Opsional |
| `virtualAccountTrxType` | `string` | Opsional |
| `feeAmount` | `*snap.Money` | Opsional |
| `expiredDate` | `string` | Opsional |
| `lastUpdateDate` | `string` | Opsional |
| `paymentDate` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |
{{< /details >}}

{{< details title="BillDetail fields" >}}
Satu entri dalam array `billDetails[]` (maksimal 24 entri) yang dipakai di seluruh kelompok Virtual Account. `billReferenceNo` bertipe `json.RawMessage` karena standarnya mendokumentasikan field ini sebagai Numeric tapi sebagian issuer mengirimnya sebagai angka JSON polos — kalau Anda mengisinya sendiri (mis. di `CreateVARequest`), berikan nilai JSON yang lengkap seperti `json.RawMessage(\`"BILLREF1"\`)` atau `json.RawMessage(\`123\`)`, bukan string Go biasa.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | Opsional |
| `billNo` | `string` | Opsional |
| `billName` | `string` | Opsional |
| `billShortName` | `string` | Opsional |
| `billDescription` | `*LocalizedText` | Opsional |
| `billSubCompany` | `string` | Opsional |
| `billAmount` | `*snap.Money` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |
| `billAmountLabel` | `string` | Opsional |
| `billAmountValue` | `string` | Opsional |
| `billReferenceNo` | `json.RawMessage` | Opsional |
| `status` | `string` | Opsional |
| `reason` | `*LocalizedText` | Opsional |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
Bentuk teks dwibahasa {english, indonesia} yang dipakai bersama di seluruh sub-kelompok Virtual Account (mis. inquiryReason, paymentFlagReason, billDescription, reason per-bill, entri freeTexts[]). Kedua field bertipe String, tidak ditandai M/O di sumbernya, jadi keduanya carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | Opsional |
| `indonesia` | `string` | Opsional |
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
| `partnerServiceId` | `string` | Wajib |
| `customerNo` | `string` | Wajib |
| `virtualAccountNo` | `string` | Wajib |
| `trxId` | `string` | Wajib |
| `paidStatus` | `string` | Wajib |
| `additionalInfo` | `json.RawMessage` | Opsional |

**Response &mdash; `UpdateStatusVAResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `virtualAccountData` | `*UpdateStatusVAData` | Opsional |

{{< details title="UpdateStatusVAData fields" >}}
Objek `virtualAccountData` pada `UpdateStatusVAResponse` — himpunan field yang sama dengan `UpdateVAData`, hanya beda nama tipe.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Opsional |
| `customerNo` | `string` | Opsional |
| `virtualAccountNo` | `string` | Opsional |
| `virtualAccountName` | `string` | Opsional |
| `trxId` | `string` | Opsional |
| `totalAmount` | `*snap.Money` | Opsional |
| `billDetails` | `[]BillDetail` | Opsional |
| `freeTexts` | `[]LocalizedText` | Opsional |
| `virtualAccountTrxType` | `string` | Opsional |
| `feeAmount` | `*snap.Money` | Opsional |
| `expiredDate` | `string` | Opsional |
| `lastUpdateDate` | `string` | Opsional |
| `paymentDate` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |
{{< /details >}}

{{< details title="BillDetail fields" >}}
Satu entri dalam array `billDetails[]` (maksimal 24 entri) yang dipakai di seluruh kelompok Virtual Account. `billReferenceNo` bertipe `json.RawMessage` karena standarnya mendokumentasikan field ini sebagai Numeric tapi sebagian issuer mengirimnya sebagai angka JSON polos — kalau Anda mengisinya sendiri (mis. di `CreateVARequest`), berikan nilai JSON yang lengkap seperti `json.RawMessage(\`"BILLREF1"\`)` atau `json.RawMessage(\`123\`)`, bukan string Go biasa.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | Opsional |
| `billNo` | `string` | Opsional |
| `billName` | `string` | Opsional |
| `billShortName` | `string` | Opsional |
| `billDescription` | `*LocalizedText` | Opsional |
| `billSubCompany` | `string` | Opsional |
| `billAmount` | `*snap.Money` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |
| `billAmountLabel` | `string` | Opsional |
| `billAmountValue` | `string` | Opsional |
| `billReferenceNo` | `json.RawMessage` | Opsional |
| `status` | `string` | Opsional |
| `reason` | `*LocalizedText` | Opsional |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
Bentuk teks dwibahasa {english, indonesia} yang dipakai bersama di seluruh sub-kelompok Virtual Account (mis. inquiryReason, paymentFlagReason, billDescription, reason per-bill, entri freeTexts[]). Kedua field bertipe String, tidak ditandai M/O di sumbernya, jadi keduanya carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | Opsional |
| `indonesia` | `string` | Opsional |
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
| `partnerServiceId` | `string` | Wajib |
| `customerNo` | `string` | Wajib |
| `virtualAccountNo` | `string` | Wajib |
| `trxId` | `string` | Wajib |
| `additionalInfo` | `json.RawMessage` | Opsional |

**Response &mdash; `InquiryVAResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `virtualAccountData` | `*InquiryVAData` | Opsional |

{{< details title="InquiryVAData fields" >}}
Objek `virtualAccountData` pada `InquiryVAResponse` — himpunan field yang sama dengan `UpdateVAData` (bentuknya sama seperti response Update VA), hanya beda nama tipe.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Opsional |
| `customerNo` | `string` | Opsional |
| `virtualAccountNo` | `string` | Opsional |
| `virtualAccountName` | `string` | Opsional |
| `trxId` | `string` | Opsional |
| `totalAmount` | `*snap.Money` | Opsional |
| `billDetails` | `[]BillDetail` | Opsional |
| `freeTexts` | `[]LocalizedText` | Opsional |
| `virtualAccountTrxType` | `string` | Opsional |
| `feeAmount` | `*snap.Money` | Opsional |
| `expiredDate` | `string` | Opsional |
| `lastUpdateDate` | `string` | Opsional |
| `paymentDate` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |
{{< /details >}}

{{< details title="BillDetail fields" >}}
Satu entri dalam array `billDetails[]` (maksimal 24 entri) yang dipakai di seluruh kelompok Virtual Account. `billReferenceNo` bertipe `json.RawMessage` karena standarnya mendokumentasikan field ini sebagai Numeric tapi sebagian issuer mengirimnya sebagai angka JSON polos — kalau Anda mengisinya sendiri (mis. di `CreateVARequest`), berikan nilai JSON yang lengkap seperti `json.RawMessage(\`"BILLREF1"\`)` atau `json.RawMessage(\`123\`)`, bukan string Go biasa.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | Opsional |
| `billNo` | `string` | Opsional |
| `billName` | `string` | Opsional |
| `billShortName` | `string` | Opsional |
| `billDescription` | `*LocalizedText` | Opsional |
| `billSubCompany` | `string` | Opsional |
| `billAmount` | `*snap.Money` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |
| `billAmountLabel` | `string` | Opsional |
| `billAmountValue` | `string` | Opsional |
| `billReferenceNo` | `json.RawMessage` | Opsional |
| `status` | `string` | Opsional |
| `reason` | `*LocalizedText` | Opsional |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
Bentuk teks dwibahasa {english, indonesia} yang dipakai bersama di seluruh sub-kelompok Virtual Account (mis. inquiryReason, paymentFlagReason, billDescription, reason per-bill, entri freeTexts[]). Kedua field bertipe String, tidak ditandai M/O di sumbernya, jadi keduanya carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | Opsional |
| `indonesia` | `string` | Opsional |
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
| `partnerServiceId` | `string` | Wajib |
| `customerNo` | `string` | Wajib |
| `virtualAccountNo` | `string` | Wajib |
| `trxId` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

**Response &mdash; `DeleteVAResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `virtualAccountData` | `*DeleteVAData` | Opsional |

{{< details title="DeleteVAData fields" >}}
Objek `virtualAccountData` pada `DeleteVAResponse` — bentuknya lebih kecil dibanding data object endpoint manajemen VA lainnya.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Opsional |
| `customerNo` | `string` | Opsional |
| `virtualAccountNo` | `string` | Opsional |
| `trxId` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |
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
| `partnerServiceId` | `string` | Wajib |
| `customerNo` | `json.RawMessage` | Wajib |
| `virtualAccountNo` | `string` | Wajib |
| `trxDateInit` | `string` | Opsional |
| `channelCode` | `json.RawMessage` | Opsional |
| `language` | `string` | Opsional |
| `hashedSourceAccountNo` | `string` | Opsional |
| `sourceBankCode` | `string` | Opsional |
| `passApp` | `string` | Opsional |
| `inquiryRequestId` | `string` | Wajib |
| `additionalInfo` | `json.RawMessage` | Opsional |

**Response &mdash; `VAInquiryResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `virtualAccountData` | `*VAInquiryData` | Opsional |

{{< details title="VAInquiryData fields" >}}
Objek `virtualAccountData` pada `VAInquiryResponse`. Field selain identity triple tidak berlabel M/O di sumbernya, jadi semuanya Opsional (omitempty); `InquiryReason`, `TotalAmount`, dan `FeeAmount` berupa pointer karena omitempty tidak berlaku pada nilai struct non-pointer.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Opsional |
| `customerNo` | `json.RawMessage` | Opsional |
| `virtualAccountNo` | `string` | Opsional |
| `inquiryStatus` | `string` | Opsional |
| `inquiryReason` | `*LocalizedText` | Opsional |
| `virtualAccountName` | `string` | Opsional |
| `virtualAccountEmail` | `string` | Opsional |
| `virtualAccountPhone` | `string` | Opsional |
| `inquiryRequestId` | `string` | Opsional |
| `totalAmount` | `*snap.Money` | Opsional |
| `subCompany` | `string` | Opsional |
| `billDetails` | `[]BillDetail` | Opsional |
| `freeTexts` | `[]LocalizedText` | Opsional |
| `virtualAccountTrxType` | `string` | Opsional |
| `feeAmount` | `*snap.Money` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
Bentuk teks dwibahasa {english, indonesia} yang dipakai bersama di seluruh sub-kelompok Virtual Account (mis. inquiryReason, paymentFlagReason, billDescription, reason per-bill, entri freeTexts[]). Kedua field bertipe String, tidak ditandai M/O di sumbernya, jadi keduanya carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | Opsional |
| `indonesia` | `string` | Opsional |
{{< /details >}}

{{< details title="BillDetail fields" >}}
Satu entri dalam array `billDetails[]` (maksimal 24 entri) yang dipakai di seluruh kelompok Virtual Account. `billReferenceNo` bertipe `json.RawMessage` karena standarnya mendokumentasikan field ini sebagai Numeric tapi sebagian issuer mengirimnya sebagai angka JSON polos — kalau Anda mengisinya sendiri (mis. di `CreateVARequest`), berikan nilai JSON yang lengkap seperti `json.RawMessage(\`"BILLREF1"\`)` atau `json.RawMessage(\`123\`)`, bukan string Go biasa.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | Opsional |
| `billNo` | `string` | Opsional |
| `billName` | `string` | Opsional |
| `billShortName` | `string` | Opsional |
| `billDescription` | `*LocalizedText` | Opsional |
| `billSubCompany` | `string` | Opsional |
| `billAmount` | `*snap.Money` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |
| `billAmountLabel` | `string` | Opsional |
| `billAmountValue` | `string` | Opsional |
| `billReferenceNo` | `json.RawMessage` | Opsional |
| `status` | `string` | Opsional |
| `reason` | `*LocalizedText` | Opsional |
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
| `partnerServiceId` | `string` | Wajib |
| `customerNo` | `json.RawMessage` | Wajib |
| `virtualAccountNo` | `string` | Wajib |
| `trxId` | `string` | Opsional |
| `paymentRequestId` | `string` | Wajib |
| `channelCode` | `json.RawMessage` | Opsional |
| `hashedSourceAccountNo` | `string` | Opsional |
| `sourceBankCode` | `string` | Opsional |
| `paidAmount` | `snap.Money` | Wajib |
| `cumulativePaymentAmount` | `*snap.Money` | Opsional |
| `paidBills` | `string` | Opsional |
| `totalAmount` | `*snap.Money` | Opsional |
| `trxDateTime` | `string` | Opsional |
| `referenceNo` | `string` | Opsional |
| `journalNum` | `string` | Opsional |
| `paymentType` | `json.RawMessage` | Opsional |
| `flagAdvise` | `string` | Opsional |
| `subCompany` | `string` | Opsional |
| `billDetails` | `[]BillDetail` | Opsional |
| `freeTexts` | `[]LocalizedText` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

{{< details title="BillDetail fields" >}}
Satu entri dalam array `billDetails[]` (maksimal 24 entri) yang dipakai di seluruh kelompok Virtual Account. `billReferenceNo` bertipe `json.RawMessage` karena standarnya mendokumentasikan field ini sebagai Numeric tapi sebagian issuer mengirimnya sebagai angka JSON polos — kalau Anda mengisinya sendiri (mis. di `CreateVARequest`), berikan nilai JSON yang lengkap seperti `json.RawMessage(\`"BILLREF1"\`)` atau `json.RawMessage(\`123\`)`, bukan string Go biasa.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | Opsional |
| `billNo` | `string` | Opsional |
| `billName` | `string` | Opsional |
| `billShortName` | `string` | Opsional |
| `billDescription` | `*LocalizedText` | Opsional |
| `billSubCompany` | `string` | Opsional |
| `billAmount` | `*snap.Money` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |
| `billAmountLabel` | `string` | Opsional |
| `billAmountValue` | `string` | Opsional |
| `billReferenceNo` | `json.RawMessage` | Opsional |
| `status` | `string` | Opsional |
| `reason` | `*LocalizedText` | Opsional |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
Bentuk teks dwibahasa {english, indonesia} yang dipakai bersama di seluruh sub-kelompok Virtual Account (mis. inquiryReason, paymentFlagReason, billDescription, reason per-bill, entri freeTexts[]). Kedua field bertipe String, tidak ditandai M/O di sumbernya, jadi keduanya carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | Opsional |
| `indonesia` | `string` | Opsional |
{{< /details >}}

**Response &mdash; `VAPaymentResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `virtualAccountData` | `*VAPaymentData` | Opsional |

{{< details title="VAPaymentData fields" >}}
Objek `virtualAccountData` pada `VAPaymentResponse` — mencerminkan field request-nya ditambah `paymentFlagReason` dan `paymentFlagStatus`.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Opsional |
| `customerNo` | `json.RawMessage` | Opsional |
| `virtualAccountNo` | `string` | Opsional |
| `trxId` | `string` | Opsional |
| `paymentRequestId` | `string` | Opsional |
| `channelCode` | `json.RawMessage` | Opsional |
| `hashedSourceAccountNo` | `string` | Opsional |
| `sourceBankCode` | `string` | Opsional |
| `paidAmount` | `*snap.Money` | Opsional |
| `cumulativePaymentAmount` | `*snap.Money` | Opsional |
| `paidBills` | `string` | Opsional |
| `totalAmount` | `*snap.Money` | Opsional |
| `trxDateTime` | `string` | Opsional |
| `referenceNo` | `string` | Opsional |
| `journalNum` | `string` | Opsional |
| `paymentType` | `json.RawMessage` | Opsional |
| `flagAdvise` | `string` | Opsional |
| `subCompany` | `string` | Opsional |
| `billDetails` | `[]BillDetail` | Opsional |
| `freeTexts` | `[]LocalizedText` | Opsional |
| `paymentFlagReason` | `*LocalizedText` | Opsional |
| `paymentFlagStatus` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |
{{< /details >}}

{{< details title="BillDetail fields" >}}
Satu entri dalam array `billDetails[]` (maksimal 24 entri) yang dipakai di seluruh kelompok Virtual Account. `billReferenceNo` bertipe `json.RawMessage` karena standarnya mendokumentasikan field ini sebagai Numeric tapi sebagian issuer mengirimnya sebagai angka JSON polos — kalau Anda mengisinya sendiri (mis. di `CreateVARequest`), berikan nilai JSON yang lengkap seperti `json.RawMessage(\`"BILLREF1"\`)` atau `json.RawMessage(\`123\`)`, bukan string Go biasa.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | Opsional |
| `billNo` | `string` | Opsional |
| `billName` | `string` | Opsional |
| `billShortName` | `string` | Opsional |
| `billDescription` | `*LocalizedText` | Opsional |
| `billSubCompany` | `string` | Opsional |
| `billAmount` | `*snap.Money` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |
| `billAmountLabel` | `string` | Opsional |
| `billAmountValue` | `string` | Opsional |
| `billReferenceNo` | `json.RawMessage` | Opsional |
| `status` | `string` | Opsional |
| `reason` | `*LocalizedText` | Opsional |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
Bentuk teks dwibahasa {english, indonesia} yang dipakai bersama di seluruh sub-kelompok Virtual Account (mis. inquiryReason, paymentFlagReason, billDescription, reason per-bill, entri freeTexts[]). Kedua field bertipe String, tidak ditandai M/O di sumbernya, jadi keduanya carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | Opsional |
| `indonesia` | `string` | Opsional |
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
| `partnerServiceId` | `string` | Wajib |
| `customerNo` | `json.RawMessage` | Wajib |
| `virtualAccountNo` | `string` | Wajib |
| `inquiryRequestId` | `string` | Opsional |
| `paymentRequestId` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

**Response &mdash; `VAInquiryStatusResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `virtualAccountData` | `*VAInquiryStatusData` | Opsional |

{{< details title="VAInquiryStatusData fields" >}}
Objek `virtualAccountData` pada `VAInquiryStatusResponse` — bentuknya sama dengan `VAPaymentData` ditambah `transactionDate`, disimpan sebagai tipe sendiri karena Service Code-nya berbeda.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Opsional |
| `customerNo` | `json.RawMessage` | Opsional |
| `virtualAccountNo` | `string` | Opsional |
| `trxId` | `string` | Opsional |
| `paymentRequestId` | `string` | Opsional |
| `channelCode` | `json.RawMessage` | Opsional |
| `hashedSourceAccountNo` | `string` | Opsional |
| `sourceBankCode` | `string` | Opsional |
| `paidAmount` | `*snap.Money` | Opsional |
| `cumulativePaymentAmount` | `*snap.Money` | Opsional |
| `paidBills` | `string` | Opsional |
| `totalAmount` | `*snap.Money` | Opsional |
| `trxDateTime` | `string` | Opsional |
| `referenceNo` | `string` | Opsional |
| `journalNum` | `string` | Opsional |
| `paymentType` | `json.RawMessage` | Opsional |
| `flagAdvise` | `string` | Opsional |
| `subCompany` | `string` | Opsional |
| `billDetails` | `[]BillDetail` | Opsional |
| `freeTexts` | `[]LocalizedText` | Opsional |
| `paymentFlagReason` | `*LocalizedText` | Opsional |
| `paymentFlagStatus` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |
| `transactionDate` | `string` | Opsional |
{{< /details >}}

{{< details title="BillDetail fields" >}}
Satu entri dalam array `billDetails[]` (maksimal 24 entri) yang dipakai di seluruh kelompok Virtual Account. `billReferenceNo` bertipe `json.RawMessage` karena standarnya mendokumentasikan field ini sebagai Numeric tapi sebagian issuer mengirimnya sebagai angka JSON polos — kalau Anda mengisinya sendiri (mis. di `CreateVARequest`), berikan nilai JSON yang lengkap seperti `json.RawMessage(\`"BILLREF1"\`)` atau `json.RawMessage(\`123\`)`, bukan string Go biasa.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | Opsional |
| `billNo` | `string` | Opsional |
| `billName` | `string` | Opsional |
| `billShortName` | `string` | Opsional |
| `billDescription` | `*LocalizedText` | Opsional |
| `billSubCompany` | `string` | Opsional |
| `billAmount` | `*snap.Money` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |
| `billAmountLabel` | `string` | Opsional |
| `billAmountValue` | `string` | Opsional |
| `billReferenceNo` | `json.RawMessage` | Opsional |
| `status` | `string` | Opsional |
| `reason` | `*LocalizedText` | Opsional |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
Bentuk teks dwibahasa {english, indonesia} yang dipakai bersama di seluruh sub-kelompok Virtual Account (mis. inquiryReason, paymentFlagReason, billDescription, reason per-bill, entri freeTexts[]). Kedua field bertipe String, tidak ditandai M/O di sumbernya, jadi keduanya carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | Opsional |
| `indonesia` | `string` | Opsional |
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
| `partnerServiceId` | `string` | Wajib |
| `customerNo` | `json.RawMessage` | Wajib |
| `virtualAccountNo` | `string` | Wajib |
| `partnerReferenceNo` | `string` | Opsional |
| `sourceAccountNo` | `string` | Opsional |
| `sourceAccountType` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

**Response &mdash; `VAInquiryPaymentIntrabankResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `virtualAccountdata` | `*VAInquiryPaymentIntrabankData` | Opsional |

{{< details title="VAInquiryPaymentIntrabankData fields" >}}
Objek `virtualAccountdata` (huruf "d" kecil — sengaja mengikuti wire key standarnya, tidak seperti kebanyakan endpoint VA lain yang pakai `virtualAccountData`) pada `VAInquiryPaymentIntrabankResponse`.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Opsional |
| `customerNo` | `json.RawMessage` | Opsional |
| `virtualAccountNo` | `string` | Opsional |
| `partnerReferenceNo` | `string` | Opsional |
| `sourceAccountNo` | `string` | Opsional |
| `sourceAccountType` | `string` | Opsional |
| `productName` | `string` | Opsional |
| `billAmountLabel` | `string` | Opsional |
| `billAmountValue` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |
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
| `partnerServiceId` | `string` | Wajib |
| `customerNo` | `json.RawMessage` | Wajib |
| `virtualAccountNo` | `string` | Wajib |
| `sourceAccountNo` | `string` | Opsional |
| `sourceAccountType` | `string` | Opsional |
| `inquiryRequestId` | `string` | Opsional |
| `partnerReferenceNo` | `string` | Wajib |
| `paidAmount` | `snap.Money` | Wajib |
| `cumulativePaymentAmount` | `*snap.Money` | Opsional |
| `paidBills` | `string` | Opsional |
| `paymentStatus` | `string` | Opsional |
| `referenceNo` | `json.RawMessage` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

**Response &mdash; `VAPaymentIntrabankResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `virtualAccountdata` | `*VAPaymentIntrabankData` | Opsional |

{{< details title="VAPaymentIntrabankData fields" >}}
Objek `virtualAccountdata` (huruf "d" kecil) pada `VAPaymentIntrabankResponse` — mencerminkan field request-nya sendiri.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Opsional |
| `customerNo` | `json.RawMessage` | Opsional |
| `virtualAccountNo` | `string` | Opsional |
| `sourceAccountNo` | `string` | Opsional |
| `sourceAccountType` | `string` | Opsional |
| `inquiryRequestId` | `string` | Opsional |
| `partnerReferenceNo` | `string` | Opsional |
| `paidAmount` | `*snap.Money` | Opsional |
| `cumulativePaymentAmount` | `*snap.Money` | Opsional |
| `paidBills` | `string` | Opsional |
| `paymentStatus` | `string` | Opsional |
| `referenceNo` | `json.RawMessage` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |
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
| `partnerServiceId` | `string` | Wajib |
| `customerNo` | `json.RawMessage` | Wajib |
| `virtualAccountNo` | `string` | Wajib |
| `inquiryRequestId` | `string` | Opsional |
| `paymentRequestId` | `string` | Opsional |
| `partnerReferenceNo` | `string` | Opsional |
| `trxDateTime` | `string` | Opsional |
| `paymentStatus` | `string` | Opsional |
| `paymentFlagReason` | `*LocalizedText` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

{{< details title="LocalizedText fields" >}}
Bentuk teks dwibahasa {english, indonesia} yang dipakai bersama di seluruh sub-kelompok Virtual Account (mis. inquiryReason, paymentFlagReason, billDescription, reason per-bill, entri freeTexts[]). Kedua field bertipe String, tidak ditandai M/O di sumbernya, jadi keduanya carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | Opsional |
| `indonesia` | `string` | Opsional |
{{< /details >}}

**Response &mdash; `VANotifyPaymentIntrabankResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `virtualAccountdata` | `*VANotifyPaymentIntrabankData` | Opsional |

{{< details title="VANotifyPaymentIntrabankData fields" >}}
Objek `virtualAccountdata` (huruf "d" kecil) pada `VANotifyPaymentIntrabankResponse` — mencerminkan sebagian besar field request-nya, ditambah envelope.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Opsional |
| `customerNo` | `json.RawMessage` | Opsional |
| `virtualAccountNo` | `string` | Opsional |
| `inquiryRequestId` | `string` | Opsional |
| `paymentRequestId` | `string` | Opsional |
| `partnerReferenceNo` | `string` | Opsional |
| `trxDateTime` | `string` | Opsional |
| `paymentStatus` | `string` | Opsional |
| `paymentFlagReason` | `*LocalizedText` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
Bentuk teks dwibahasa {english, indonesia} yang dipakai bersama di seluruh sub-kelompok Virtual Account (mis. inquiryReason, paymentFlagReason, billDescription, reason per-bill, entri freeTexts[]). Kedua field bertipe String, tidak ditandai M/O di sumbernya, jadi keduanya carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | Opsional |
| `indonesia` | `string` | Opsional |
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
| `partnerServiceId` | `json.RawMessage` | Wajib |
| `startDate` | `string` | Opsional |
| `startTime` | `string` | Opsional |
| `endDate` | `string` | Opsional |
| `endTime` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

**Response &mdash; `VAGetReportResponse`**

Satu-satunya response VA di package ini yang field data-nya berupa array, bukan objek tunggal.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `virtualAccountdata` | `[]GetReportData` | Opsional |

{{< details title="GetReportData fields" >}}
Satu entri dalam array `virtualAccountdata` (huruf "d" kecil) pada `VAGetReportResponse` — bentuknya sama dengan `VAInquiryStatusData`, disimpan sebagai tipe sendiri karena Service Code-nya berbeda.

| Field | Type | Presence |
|---|---|---|
| `partnerServiceId` | `string` | Opsional |
| `customerNo` | `json.RawMessage` | Opsional |
| `virtualAccountNo` | `string` | Opsional |
| `trxId` | `string` | Opsional |
| `paymentRequestId` | `string` | Opsional |
| `channelCode` | `json.RawMessage` | Opsional |
| `hashedSourceAccountNo` | `string` | Opsional |
| `sourceBankCode` | `string` | Opsional |
| `paidAmount` | `*snap.Money` | Opsional |
| `cumulativePaymentAmount` | `*snap.Money` | Opsional |
| `paidBills` | `string` | Opsional |
| `totalAmount` | `*snap.Money` | Opsional |
| `trxDateTime` | `string` | Opsional |
| `referenceNo` | `string` | Opsional |
| `journalNum` | `string` | Opsional |
| `paymentType` | `json.RawMessage` | Opsional |
| `flagAdvise` | `string` | Opsional |
| `subCompany` | `string` | Opsional |
| `billDetails` | `[]BillDetail` | Opsional |
| `freeTexts` | `[]LocalizedText` | Opsional |
| `paymentFlagReason` | `*LocalizedText` | Opsional |
| `paymentFlagStatus` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |
| `transactionDate` | `string` | Opsional |
{{< /details >}}

{{< details title="BillDetail fields" >}}
Satu entri dalam array `billDetails[]` (maksimal 24 entri) yang dipakai di seluruh kelompok Virtual Account. `billReferenceNo` bertipe `json.RawMessage` karena standarnya mendokumentasikan field ini sebagai Numeric tapi sebagian issuer mengirimnya sebagai angka JSON polos — kalau Anda mengisinya sendiri (mis. di `CreateVARequest`), berikan nilai JSON yang lengkap seperti `json.RawMessage(\`"BILLREF1"\`)` atau `json.RawMessage(\`123\`)`, bukan string Go biasa.

| Field | Type | Presence |
|---|---|---|
| `billCode` | `string` | Opsional |
| `billNo` | `string` | Opsional |
| `billName` | `string` | Opsional |
| `billShortName` | `string` | Opsional |
| `billDescription` | `*LocalizedText` | Opsional |
| `billSubCompany` | `string` | Opsional |
| `billAmount` | `*snap.Money` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |
| `billAmountLabel` | `string` | Opsional |
| `billAmountValue` | `string` | Opsional |
| `billReferenceNo` | `json.RawMessage` | Opsional |
| `status` | `string` | Opsional |
| `reason` | `*LocalizedText` | Opsional |
{{< /details >}}

{{< details title="LocalizedText fields" >}}
Bentuk teks dwibahasa {english, indonesia} yang dipakai bersama di seluruh sub-kelompok Virtual Account (mis. inquiryReason, paymentFlagReason, billDescription, reason per-bill, entri freeTexts[]). Kedua field bertipe String, tidak ditandai M/O di sumbernya, jadi keduanya carry omitempty.

| Field | Type | Presence |
|---|---|---|
| `english` | `string` | Opsional |
| `indonesia` | `string` | Opsional |
{{< /details >}}


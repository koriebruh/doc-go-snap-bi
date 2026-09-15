---
weight: 1
title: "Registrasi"
description: "Registrasi — Service Code 01-10, 81 — 11 endpoint"
---

## Registrasi

Account binding, registrasi kartu, dan verifikasi OTP — package `registration` (Service Code 01-10, 81). Ada dua alur di sini: alur **account** (binding berbasis OAuth, dimulai dari `GetOAuthURL` → `AccountBinding`) dan alur **card** (`CardRegistration` beserta varian Set Limit/Inquiry/Unbinding-nya).

```go
resp, err := registration.AccountBinding(ctx, transport, hb, registration.AccountBindingRequest{
	MerchantID: "...",
})
if err != nil {
	// errors.Is(err, snap.ErrBadRequest), snap.ErrUnauthorized, etc.
}
```

Setiap fungsi di bawah punya bentuk pemanggilan yang sama: isi `hb` (semua field kecuali `Body` — fungsinya sendiri yang marshal request dan mengatur `Body`), panggil, lalu cek `err`. Lihat [Core Conventions](/id/docs/concepts/conventions/) untuk pola lengkapnya.

### `GetOAuthURL`

Memulai alur OAuth account-binding dengan membangun URL otorisasi (Service Code 10). Ini panggilan GET read-only: `hb.EndpointURL` harus berupa URL http(s) polos tanpa query string atau fragment — kalau tidak, akan error, bukan diam-diam digabung jadi satu.

```go
func GetOAuthURL(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req GetOAuthURLRequest) (GetOAuthURLResponse, error)
```

**Request &mdash; `GetOAuthURLRequest`**

Beda dari endpoint lain di sini, ini bukan JSON — `GetOAuthURL` membangun query string URL langsung dari field-field ini. `RedirectURL`, `Scopes`, dan `State` bersifat Wajib; `SeamlessSign` bersifat Kondisional (wajib hanya jika `SeamlessData` diisi); sisanya Opsional.

| Query parameter | Type | Presence |
|---|---|---|
| `RedirectURL` | `string` | Wajib |
| `Scopes` | `[]string` (digabung dengan `,`) | Wajib |
| `State` | `string` | Wajib |
| `MerchantID` | `string` | Opsional |
| `SubMerchantID` | `string` | Opsional |
| `Lang` | `string` (ISO 639-1) | Opsional |
| `AllowRegistration` | `*bool` | Opsional |
| `SeamlessData` | `string` | Opsional |
| `MobileNumber` | `string` | Opsional |
| `VerifiedTime` | `string` | Opsional |
| `ExternalUID` | `string` | Opsional |
| `DeviceID` | `string` | Opsional |
| `SeamlessSign` | `string` | Kondisional — wajib jika `SeamlessData` diisi |

**Response &mdash; `GetOAuthURLResponse`**

Semua field Wajib.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `authCode` | `string` | Wajib |
| `state` | `string` | Wajib |


---

### `AccountCreation`

Membuat sebuah account (Service Code 06).

Tidak idempotent. Saat retry, pakai `X-EXTERNAL-ID` yang sama — kalau pakai yang baru, berisiko membuat account kedua.

```go
func AccountCreation(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AccountCreationRequest) (AccountCreationResponse, error)
```

**Request &mdash; `AccountCreationRequest`**

Semua field Opsional — endpoint ini mencakup beberapa alur onboarding (seamless data, redirect OAuth, pembuatan langsung), masing-masing memakai subset field yang berbeda.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | Opsional |
| `countryCode` | `string` | Opsional |
| `customerId` | `string` | Opsional |
| `deviceInfo` | `*DeviceInfo` | Opsional |
| `email` | `string` | Opsional |
| `lang` | `string` | Opsional |
| `locale` | `string` | Opsional |
| `name` | `string` | Opsional |
| `onboardingPartner` | `string` | Opsional |
| `phoneNo` | `string` | Opsional |
| `redirectUrl` | `string` | Opsional |
| `scopes` | `string` | Opsional |
| `seamlessData` | `string` | Opsional |
| `seamlessSign` | `string` | Opsional |
| `state` | `string` | Opsional |
| `merchantId` | `string` | Opsional |
| `subMerchantId` | `string` | Opsional |
| `terminalType` | `json.RawMessage` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

{{< details title="DeviceInfo fields" >}}
DeviceInfo mendeskripsikan perangkat yang memulai request registrasi.

| Field | Type | Presence |
|---|---|---|
| `os` | `string` | Opsional |
| `osVersion` | `string` | Opsional |
| `model` | `string` | Opsional |
| `manufacturer` | `string` | Opsional |
{{< /details >}}

**Response &mdash; `AccountCreationResponse`**

`apiKey` bertipe `json.RawMessage` karena standarnya tidak menyebutkan apakah dikirim sebagai string berkutip atau angka polos — tipe ini menerima keduanya tanpa menggagalkan seluruh proses decode.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `referenceNo` | `string` | Opsional |
| `partnerReferenceNo` | `string` | Opsional |
| `authCode` | `string` | Opsional |
| `apiKey` | `json.RawMessage` | Opsional |
| `accountId` | `string` | Opsional |
| `state` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |


---

### `AccountBinding`

Mengikat (bind) account customer untuk pemakaian B2B2C (Service Code 07).

Tidak idempotent. Saat retry, pakai `X-EXTERNAL-ID` yang sama — kalau pakai yang baru, berisiko membuat binding ganda atau token terbit dua kali.

```go
func AccountBinding(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AccountBindingRequest) (AccountBindingResponse, error)
```

**Request &mdash; `AccountBindingRequest`**

`MerchantID` satu-satunya field Wajib.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | Opsional |
| `action` | `string` | Opsional |
| `additionalData` | `json.RawMessage` | Opsional |
| `userId` | `string` | Opsional |
| `email` | `string` | Opsional |
| `postalAddress` | `string` | Opsional |
| `authCode` | `string` | Opsional |
| `grantType` | `string` | Opsional |
| `isBindAndPay` | `string` | Opsional |
| `lang` | `string` | Opsional |
| `locale` | `string` | Opsional |
| `merchantId` | `string` | Wajib |
| `subMerchantId` | `string` | Opsional |
| `msisdn` | `string` | Opsional |
| `otp` | `string` | Opsional |
| `phoneNo` | `string` | Opsional |
| `platformType` | `string` | Opsional |
| `redirectUrl` | `string` | Opsional |
| `referenceId` | `string` | Opsional |
| `refreshToken` | `string` | Opsional |
| `successParams` | `*BindingSuccessParams` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

{{< details title="BindingSuccessParams fields" >}}
Objek `successParams` di sisi request.

| Field | Type | Presence |
|---|---|---|
| `accountId` | `string` | Opsional |
| `terminalId` | `string` | Opsional |
| `tokenRequestorId` | `string` | Opsional |
{{< /details >}}

**Response &mdash; `AccountBindingResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `referenceNo` | `string` | Opsional |
| `partnerReferenceNo` | `string` | Opsional |
| `accountToken` | `string` | Opsional |
| `accessTokenInfo` | `*BindingAccessTokenInfo` | Opsional |
| `linkId` | `string` | Opsional |
| `nextAction` | `string` | Opsional |
| `linkageToken` | `string` | Opsional |
| `params` | `json.RawMessage` | Opsional |
| `pinWebViewUrl` | `string` | Opsional |
| `redirectToDeeplink` | `string` | Opsional |
| `redirectUrl` | `string` | Opsional |
| `userInfo` | `*BindingUserInfo` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

{{< details title="BindingAccessTokenInfo fields" >}}
Objek `accessTokenInfo` di sisi response. `expiresIn`/`reExpiresIn` di sini adalah string datetime ISO 8601 — beda bentuk dari `Token.ExpiresIn` milik endpoint access-token B2B/B2B2C (durasi hasil parsing dari hitungan detik). Nama field sama, endpoint beda, makna beda.

| Field | Type | Presence |
|---|---|---|
| `accessToken` | `string` | Opsional |
| `expiresIn` | `string` | Opsional |
| `refreshToken` | `string` | Opsional |
| `reExpiresIn` | `string` | Opsional |
| `tokenStatus` | `string` | Opsional |
{{< /details >}}

{{< details title="BindingUserInfo fields" >}}
Objek `userInfo` di sisi response.

| Field | Type | Presence |
|---|---|---|
| `publicUserId` | `string` | Opsional |
{{< /details >}}


---

### `AccountBindingInquiry`

Mencari detail account yang sudah di-bind (Service Code 08).

```go
func AccountBindingInquiry(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AccountBindingInquiryRequest) (AccountBindingInquiryResponse, error)
```

**Request &mdash; `AccountBindingInquiryRequest`**

Standarnya tidak mendefinisikan field identifier account untuk panggilan ini; jika PJP Anda butuh satu, taruh di `AdditionalInfo`.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

**Response &mdash; `AccountBindingInquiryResponse`**

Lebih flat dibanding `AccountBindingResponse` — tidak ada nesting `accessTokenInfo`/`userInfo`. `accountTransactionLimit` bertipe `json.RawMessage` karena standarnya tidak menjamin field ini selalu dikirim sebagai string berkutip di semua PJP.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `referenceNo` | `string` | Opsional |
| `partnerReferenceNo` | `string` | Opsional |
| `accountCurrency` | `string` | Opsional |
| `accountName` | `string` | Opsional |
| `accountNo` | `string` | Opsional |
| `accountTransactionLimit` | `json.RawMessage` | Opsional |
| `endDatePeriod` | `string` | Opsional |
| `startDatePeriod` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |


---

### `AccountUnbinding`

Menghapus sebuah account binding (Service Code 09).

Tidak idempotent. Saat retry, pakai `X-EXTERNAL-ID` yang sama.

```go
func AccountUnbinding(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AccountUnbindingRequest) (AccountUnbindingResponse, error)
```

**Request &mdash; `AccountUnbindingRequest`**

`MerchantID` satu-satunya field Wajib. `LinkID` dan `TokenID` — yang sebenarnya mengidentifikasi binding mana yang mau dihapus — keduanya Opsional menurut standar; package ini tidak memaksa salah satunya harus diisi, karena itu aturan bisnis, bukan aturan bentuk wire.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | Opsional |
| `linkId` | `string` | Opsional |
| `merchantId` | `string` | Wajib |
| `subMerchantId` | `string` | Opsional |
| `tokenId` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

**Response &mdash; `AccountUnbindingResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `referenceNo` | `string` | Opsional |
| `partnerReferenceNo` | `string` | Opsional |
| `merchantId` | `string` | Opsional |
| `subMerchantId` | `string` | Opsional |
| `linkId` | `string` | Opsional |
| `unlinkResult` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |


---

### `OTP`

Memicu pengiriman OTP, misalnya lewat SMS (Service Code 81).

Memicu efek samping nyata di luar sistem. Saat retry, pakai `X-EXTERNAL-ID` yang sama — kalau pakai yang baru, berisiko OTP terkirim dua kali.

```go
func OTP(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req OTPRequest) (OTPResponse, error)
```

**Request &mdash; `OTPRequest`**

`JourneyID` satu-satunya field Wajib. Untuk panggilan bentuk B2B2C, atur `HeaderBuilder.B2B2C` (dan `AuthorizationCustomer`/`DeviceID`) sama seperti endpoint B2B2C lainnya — tidak ada field khusus di sini. `BankCardToken` bersifat Kondisional.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | Opsional |
| `journeyId` | `string` | Wajib |
| `merchantId` | `string` | Opsional |
| `subMerchant` | `string` | Opsional |
| `externalStoreId` | `string` | Opsional |
| `trxDateTime` | `string` | Opsional |
| `bankCardToken` | `string` | Kondisional |
| `otpTrxCode` | `string` | Opsional |
| `otpReasonCode` | `string` | Opsional |
| `otpReasonMessage` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

**Response &mdash; `OTPResponse`**

`chargeToken` bersifat Wajib di sini (padahal Opsional di `CardRegistrationResponse` — nama field sama, endpoint beda).

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `referenceNo` | `string` | Opsional |
| `partnerReferenceNo` | `string` | Opsional |
| `chargeToken` | `string` | Wajib |
| `additionalInfo` | `json.RawMessage` | Opsional |


---

### `VerifyOTP`

Memverifikasi OTP yang sudah diterbitkan sebelumnya (Service Code 04, Direct Integration).

Tidak idempotent — verifikasi mengonsumsi state di sisi server (membatalkan OTP, kemungkinan terhitung sebagai satu percobaan). Saat retry, pakai `X-EXTERNAL-ID` yang sama — kalau pakai yang baru, berisiko membakar percobaan ekstra atau memproses ulang panggilan yang sudah selesai.

```go
func VerifyOTP(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req VerifyOTPRequest) (VerifyOTPResponse, error)
```

**Request &mdash; `VerifyOTPRequest`**

Semua field Opsional.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | Opsional |
| `originalReferenceNo` | `string` | Opsional |
| `action` | `string` | Opsional |
| `merchantId` | `string` | Opsional |
| `otp` | `string` | Opsional |
| `chargeToken` | `string` | Opsional |
| `type` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

**Response &mdash; `VerifyOTPResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `originalReferenceNo` | `string` | Opsional |
| `originalPartnerReferenceNo` | `string` | Opsional |
| `accountNo` | `string` | Opsional |
| `bankCardToken` | `string` | Opsional |
| `cardPan` | `string` | Opsional |
| `customerId` | `string` | Opsional |
| `email` | `string` | Opsional |
| `expiredDatetime` | `string` | Opsional |
| `expiryDate` | `string` | Opsional |
| `identificationNo` | `string` | Opsional |
| `linkageToken` | `string` | Opsional |
| `phoneNo` | `string` | Opsional |
| `qParamsURL` | `string` | Opsional |
| `qParams` | `json.RawMessage` | Opsional |
| `sendOtpFlag` | `string` | Opsional |
| `subscribeDatetime` | `string` | Opsional |
| `tokenExpiryTime` | `string` | Opsional |
| `transactionTimestamp` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |


---

### `CardRegistration`

Mendaftarkan kartu dan menerbitkan `BankCardToken` (Service Code 01).

Tidak idempotent — setiap panggilan menerbitkan token baru. Saat retry, pakai `X-EXTERNAL-ID` yang sama — kalau pakai yang baru, berisiko membuat bind kartu ganda.

```go
func CardRegistration(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req CardRegistrationRequest) (CardRegistrationResponse, error)
```

**Request &mdash; `CardRegistrationRequest`**

`BankCardNo` dan `CustIDMerchant` adalah dua field Wajib. `CardData` dan `Limit` bertipe `json.RawMessage` — standarnya mengizinkan bentuk JSON non-string (objek polos atau angka) untuk keduanya. Kalau Anda mengisi dari string Go, kutip dulu sendiri (contoh: `json.RawMessage(`"1000000"`)`, bukan `json.RawMessage(limitStr)`) supaya sesuai bentuk wire yang diharapkan.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | Opsional |
| `accountName` | `string` | Opsional |
| `cardData` | `json.RawMessage` | Opsional |
| `bankAccountNo` | `string` | Opsional |
| `bankCardNo` | `string` | Wajib |
| `bankCardType` | `string` | Opsional |
| `dateOfBirth` | `string` | Opsional |
| `email` | `string` | Opsional |
| `expiredDatetime` | `string` | Opsional |
| `expiryDate` | `string` | Opsional |
| `identificationNo` | `string` | Opsional |
| `identificationType` | `string` | Opsional |
| `custIdMerchant` | `string` | Wajib |
| `isBindAndPay` | `string` | Opsional |
| `merchantId` | `string` | Opsional |
| `terminalId` | `string` | Opsional |
| `journeyId` | `string` | Opsional |
| `subMerchantId` | `string` | Opsional |
| `externalStoreId` | `string` | Opsional |
| `limit` | `json.RawMessage` | Opsional |
| `merchantLogoUrl` | `string` | Opsional |
| `phoneNo` | `string` | Opsional |
| `sendOtpFlag` | `string` | Opsional |
| `type` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

**Response &mdash; `CardRegistrationResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `referenceNo` | `string` | Opsional |
| `partnerReferenceNo` | `string` | Opsional |
| `bankCardToken` | `string` | Wajib |
| `chargeToken` | `string` | Opsional |
| `randomString` | `string` | Opsional |
| `tokenExpiryTime` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |


---

### `CardRegistrationInquiry`

Mencari account kartu terdaftar berdasarkan ID customer merchant (Service Code 03). Ini satu-satunya endpoint GET read-only di package ini; `custIDMerchant` dikirim sebagai segmen path URL, sudah divalidasi dan digabung dengan aman ke `hb.EndpointURL`.

```go
func CardRegistrationInquiry(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, custIDMerchant string) (CardRegistrationInquiryResponse, error)
```

Endpoint ini tidak punya request body bertipe selain parameter panggilan di atas.

**Response &mdash; `CardRegistrationInquiryResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `accountList` | `[]CardRegistrationInquiryAccount` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

{{< details title="CardRegistrationInquiryAccount fields" >}}
Satu entri di `accountList`, membungkus objek `accountData` di dalamnya.

| Field | Type | Presence |
|---|---|---|
| `accountData` | `CardRegistrationInquiryAccountData` | Wajib |
{{< /details >}}

{{< details title="CardRegistrationInquiryAccountData fields" >}}
Objek `accountData` di dalamnya. `maxLimit` dan `credentialNo` adalah string tampilan yang sudah di-mask/diformat (contoh: `"************0750"`), bukan nilai mentah.

| Field | Type | Presence |
|---|---|---|
| `accountId` | `string` | Opsional |
| `createdDate` | `string` | Opsional |
| `credentialNo` | `string` | Opsional |
| `credentialType` | `string` | Opsional |
| `maxLimit` | `string` | Opsional |
| `status` | `string` | Opsional |
{{< /details >}}


---

### `CardRegistrationSetLimit`

Mengatur limit transaksi pada kartu terdaftar (Service Code 02).

```go
func CardRegistrationSetLimit(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req CardRegistrationSetLimitRequest) (CardRegistrationSetLimitResponse, error)
```

**Request &mdash; `CardRegistrationSetLimitRequest`**

`BankCardToken` satu-satunya field Wajib. `Limit` bertipe `json.RawMessage` dengan alasan sama seperti di `CardRegistrationRequest` — kutip dulu string Go-nya sebelum diisikan (contoh: `json.RawMessage(`"1000000"`)`).

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | Opsional |
| `bankAccountNo` | `string` | Opsional |
| `bankCardNo` | `string` | Opsional |
| `limit` | `json.RawMessage` | Opsional |
| `bankCardToken` | `string` | Wajib |
| `otp` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

**Response &mdash; `CardRegistrationSetLimitResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `referenceNo` | `string` | Opsional |
| `partnerReferenceNo` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |


---

### `CardRegistrationUnbinding`

Menghapus registrasi kartu (Service Code 05).

Tidak idempotent. Saat retry, pakai `X-EXTERNAL-ID` yang sama.

```go
func CardRegistrationUnbinding(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req CardRegistrationUnbindingRequest) (CardRegistrationUnbindingResponse, error)
```

**Request &mdash; `CardRegistrationUnbindingRequest`**

`Token` satu-satunya field Wajib.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | Opsional |
| `token` | `string` | Wajib |
| `bankCardNo` | `string` | Opsional |
| `type` | `string` | Opsional |
| `part` | `string` | Opsional |
| `merchantId` | `string` | Opsional |
| `subMerchantId` | `string` | Opsional |
| `terminalId` | `string` | Opsional |
| `tokenRequestorId` | `string` | Opsional |
| `journeyId` | `string` | Opsional |
| `transactionDate` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

**Response &mdash; `CardRegistrationUnbindingResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | Wajib |
| `responseMessage` | `string` | Wajib |
| `referenceNo` | `string` | Opsional |
| `partnerReferenceNo` | `string` | Opsional |
| `message` | `string` | Opsional |
| `customerId` | `string` | Opsional |
| `unsubscribeDate` | `string` | Opsional |
| `additionalInfo` | `json.RawMessage` | Opsional |

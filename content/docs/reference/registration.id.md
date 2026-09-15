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
| `RedirectURL` | `string` | <span class="badge-mandatory">Wajib</span> |
| `Scopes` | `[]string` (digabung dengan `,`) | <span class="badge-mandatory">Wajib</span> |
| `State` | `string` | <span class="badge-mandatory">Wajib</span> |
| `MerchantID` | `string` | <span class="badge-optional">Opsional</span> |
| `SubMerchantID` | `string` | <span class="badge-optional">Opsional</span> |
| `Lang` | `string` (ISO 639-1) | <span class="badge-optional">Opsional</span> |
| `AllowRegistration` | `*bool` | <span class="badge-optional">Opsional</span> |
| `SeamlessData` | `string` | <span class="badge-optional">Opsional</span> |
| `MobileNumber` | `string` | <span class="badge-optional">Opsional</span> |
| `VerifiedTime` | `string` | <span class="badge-optional">Opsional</span> |
| `ExternalUID` | `string` | <span class="badge-optional">Opsional</span> |
| `DeviceID` | `string` | <span class="badge-optional">Opsional</span> |
| `SeamlessSign` | `string` | Kondisional — wajib jika `SeamlessData` diisi |

**Response &mdash; `GetOAuthURLResponse`**

Semua field Wajib.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `authCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `state` | `string` | <span class="badge-mandatory">Wajib</span> |


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
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `countryCode` | `string` | <span class="badge-optional">Opsional</span> |
| `customerId` | `string` | <span class="badge-optional">Opsional</span> |
| `deviceInfo` | `*DeviceInfo` | <span class="badge-optional">Opsional</span> |
| `email` | `string` | <span class="badge-optional">Opsional</span> |
| `lang` | `string` | <span class="badge-optional">Opsional</span> |
| `locale` | `string` | <span class="badge-optional">Opsional</span> |
| `name` | `string` | <span class="badge-optional">Opsional</span> |
| `onboardingPartner` | `string` | <span class="badge-optional">Opsional</span> |
| `phoneNo` | `string` | <span class="badge-optional">Opsional</span> |
| `redirectUrl` | `string` | <span class="badge-optional">Opsional</span> |
| `scopes` | `string` | <span class="badge-optional">Opsional</span> |
| `seamlessData` | `string` | <span class="badge-optional">Opsional</span> |
| `seamlessSign` | `string` | <span class="badge-optional">Opsional</span> |
| `state` | `string` | <span class="badge-optional">Opsional</span> |
| `merchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `terminalType` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

{{< details title="DeviceInfo fields" >}}
DeviceInfo mendeskripsikan perangkat yang memulai request registrasi.

| Field | Type | Presence |
|---|---|---|
| `os` | `string` | <span class="badge-optional">Opsional</span> |
| `osVersion` | `string` | <span class="badge-optional">Opsional</span> |
| `model` | `string` | <span class="badge-optional">Opsional</span> |
| `manufacturer` | `string` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

**Response &mdash; `AccountCreationResponse`**

`apiKey` bertipe `json.RawMessage` karena standarnya tidak menyebutkan apakah dikirim sebagai string berkutip atau angka polos — tipe ini menerima keduanya tanpa menggagalkan seluruh proses decode.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `authCode` | `string` | <span class="badge-optional">Opsional</span> |
| `apiKey` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `accountId` | `string` | <span class="badge-optional">Opsional</span> |
| `state` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |


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
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `action` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalData` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `userId` | `string` | <span class="badge-optional">Opsional</span> |
| `email` | `string` | <span class="badge-optional">Opsional</span> |
| `postalAddress` | `string` | <span class="badge-optional">Opsional</span> |
| `authCode` | `string` | <span class="badge-optional">Opsional</span> |
| `grantType` | `string` | <span class="badge-optional">Opsional</span> |
| `isBindAndPay` | `string` | <span class="badge-optional">Opsional</span> |
| `lang` | `string` | <span class="badge-optional">Opsional</span> |
| `locale` | `string` | <span class="badge-optional">Opsional</span> |
| `merchantId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `msisdn` | `string` | <span class="badge-optional">Opsional</span> |
| `otp` | `string` | <span class="badge-optional">Opsional</span> |
| `phoneNo` | `string` | <span class="badge-optional">Opsional</span> |
| `platformType` | `string` | <span class="badge-optional">Opsional</span> |
| `redirectUrl` | `string` | <span class="badge-optional">Opsional</span> |
| `referenceId` | `string` | <span class="badge-optional">Opsional</span> |
| `refreshToken` | `string` | <span class="badge-optional">Opsional</span> |
| `successParams` | `*BindingSuccessParams` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

{{< details title="BindingSuccessParams fields" >}}
Objek `successParams` di sisi request.

| Field | Type | Presence |
|---|---|---|
| `accountId` | `string` | <span class="badge-optional">Opsional</span> |
| `terminalId` | `string` | <span class="badge-optional">Opsional</span> |
| `tokenRequestorId` | `string` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

**Response &mdash; `AccountBindingResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `accountToken` | `string` | <span class="badge-optional">Opsional</span> |
| `accessTokenInfo` | `*BindingAccessTokenInfo` | <span class="badge-optional">Opsional</span> |
| `linkId` | `string` | <span class="badge-optional">Opsional</span> |
| `nextAction` | `string` | <span class="badge-optional">Opsional</span> |
| `linkageToken` | `string` | <span class="badge-optional">Opsional</span> |
| `params` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `pinWebViewUrl` | `string` | <span class="badge-optional">Opsional</span> |
| `redirectToDeeplink` | `string` | <span class="badge-optional">Opsional</span> |
| `redirectUrl` | `string` | <span class="badge-optional">Opsional</span> |
| `userInfo` | `*BindingUserInfo` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

{{< details title="BindingAccessTokenInfo fields" >}}
Objek `accessTokenInfo` di sisi response. `expiresIn`/`reExpiresIn` di sini adalah string datetime ISO 8601 — beda bentuk dari `Token.ExpiresIn` milik endpoint access-token B2B/B2B2C (durasi hasil parsing dari hitungan detik). Nama field sama, endpoint beda, makna beda.

| Field | Type | Presence |
|---|---|---|
| `accessToken` | `string` | <span class="badge-optional">Opsional</span> |
| `expiresIn` | `string` | <span class="badge-optional">Opsional</span> |
| `refreshToken` | `string` | <span class="badge-optional">Opsional</span> |
| `reExpiresIn` | `string` | <span class="badge-optional">Opsional</span> |
| `tokenStatus` | `string` | <span class="badge-optional">Opsional</span> |
{{< /details >}}

{{< details title="BindingUserInfo fields" >}}
Objek `userInfo` di sisi response.

| Field | Type | Presence |
|---|---|---|
| `publicUserId` | `string` | <span class="badge-optional">Opsional</span> |
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
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `AccountBindingInquiryResponse`**

Lebih flat dibanding `AccountBindingResponse` — tidak ada nesting `accessTokenInfo`/`userInfo`. `accountTransactionLimit` bertipe `json.RawMessage` karena standarnya tidak menjamin field ini selalu dikirim sebagai string berkutip di semua PJP.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `accountCurrency` | `string` | <span class="badge-optional">Opsional</span> |
| `accountName` | `string` | <span class="badge-optional">Opsional</span> |
| `accountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `accountTransactionLimit` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `endDatePeriod` | `string` | <span class="badge-optional">Opsional</span> |
| `startDatePeriod` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |


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
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `linkId` | `string` | <span class="badge-optional">Opsional</span> |
| `merchantId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `tokenId` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `AccountUnbindingResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `merchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `linkId` | `string` | <span class="badge-optional">Opsional</span> |
| `unlinkResult` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |


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
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `journeyId` | `string` | <span class="badge-mandatory">Wajib</span> |
| `merchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `subMerchant` | `string` | <span class="badge-optional">Opsional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Opsional</span> |
| `trxDateTime` | `string` | <span class="badge-optional">Opsional</span> |
| `bankCardToken` | `string` | Kondisional |
| `otpTrxCode` | `string` | <span class="badge-optional">Opsional</span> |
| `otpReasonCode` | `string` | <span class="badge-optional">Opsional</span> |
| `otpReasonMessage` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `OTPResponse`**

`chargeToken` bersifat Wajib di sini (padahal Opsional di `CardRegistrationResponse` — nama field sama, endpoint beda).

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `chargeToken` | `string` | <span class="badge-mandatory">Wajib</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |


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
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `action` | `string` | <span class="badge-optional">Opsional</span> |
| `merchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `otp` | `string` | <span class="badge-optional">Opsional</span> |
| `chargeToken` | `string` | <span class="badge-optional">Opsional</span> |
| `type` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `VerifyOTPResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `accountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `bankCardToken` | `string` | <span class="badge-optional">Opsional</span> |
| `cardPan` | `string` | <span class="badge-optional">Opsional</span> |
| `customerId` | `string` | <span class="badge-optional">Opsional</span> |
| `email` | `string` | <span class="badge-optional">Opsional</span> |
| `expiredDatetime` | `string` | <span class="badge-optional">Opsional</span> |
| `expiryDate` | `string` | <span class="badge-optional">Opsional</span> |
| `identificationNo` | `string` | <span class="badge-optional">Opsional</span> |
| `linkageToken` | `string` | <span class="badge-optional">Opsional</span> |
| `phoneNo` | `string` | <span class="badge-optional">Opsional</span> |
| `qParamsURL` | `string` | <span class="badge-optional">Opsional</span> |
| `qParams` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `sendOtpFlag` | `string` | <span class="badge-optional">Opsional</span> |
| `subscribeDatetime` | `string` | <span class="badge-optional">Opsional</span> |
| `tokenExpiryTime` | `string` | <span class="badge-optional">Opsional</span> |
| `transactionTimestamp` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |


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
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `accountName` | `string` | <span class="badge-optional">Opsional</span> |
| `cardData` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `bankAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `bankCardNo` | `string` | <span class="badge-mandatory">Wajib</span> |
| `bankCardType` | `string` | <span class="badge-optional">Opsional</span> |
| `dateOfBirth` | `string` | <span class="badge-optional">Opsional</span> |
| `email` | `string` | <span class="badge-optional">Opsional</span> |
| `expiredDatetime` | `string` | <span class="badge-optional">Opsional</span> |
| `expiryDate` | `string` | <span class="badge-optional">Opsional</span> |
| `identificationNo` | `string` | <span class="badge-optional">Opsional</span> |
| `identificationType` | `string` | <span class="badge-optional">Opsional</span> |
| `custIdMerchant` | `string` | <span class="badge-mandatory">Wajib</span> |
| `isBindAndPay` | `string` | <span class="badge-optional">Opsional</span> |
| `merchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `terminalId` | `string` | <span class="badge-optional">Opsional</span> |
| `journeyId` | `string` | <span class="badge-optional">Opsional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Opsional</span> |
| `limit` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `merchantLogoUrl` | `string` | <span class="badge-optional">Opsional</span> |
| `phoneNo` | `string` | <span class="badge-optional">Opsional</span> |
| `sendOtpFlag` | `string` | <span class="badge-optional">Opsional</span> |
| `type` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `CardRegistrationResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `bankCardToken` | `string` | <span class="badge-mandatory">Wajib</span> |
| `chargeToken` | `string` | <span class="badge-optional">Opsional</span> |
| `randomString` | `string` | <span class="badge-optional">Opsional</span> |
| `tokenExpiryTime` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |


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
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `accountList` | `[]CardRegistrationInquiryAccount` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

{{< details title="CardRegistrationInquiryAccount fields" >}}
Satu entri di `accountList`, membungkus objek `accountData` di dalamnya.

| Field | Type | Presence |
|---|---|---|
| `accountData` | `CardRegistrationInquiryAccountData` | <span class="badge-mandatory">Wajib</span> |
{{< /details >}}

{{< details title="CardRegistrationInquiryAccountData fields" >}}
Objek `accountData` di dalamnya. `maxLimit` dan `credentialNo` adalah string tampilan yang sudah di-mask/diformat (contoh: `"************0750"`), bukan nilai mentah.

| Field | Type | Presence |
|---|---|---|
| `accountId` | `string` | <span class="badge-optional">Opsional</span> |
| `createdDate` | `string` | <span class="badge-optional">Opsional</span> |
| `credentialNo` | `string` | <span class="badge-optional">Opsional</span> |
| `credentialType` | `string` | <span class="badge-optional">Opsional</span> |
| `maxLimit` | `string` | <span class="badge-optional">Opsional</span> |
| `status` | `string` | <span class="badge-optional">Opsional</span> |
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
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `bankAccountNo` | `string` | <span class="badge-optional">Opsional</span> |
| `bankCardNo` | `string` | <span class="badge-optional">Opsional</span> |
| `limit` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |
| `bankCardToken` | `string` | <span class="badge-mandatory">Wajib</span> |
| `otp` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `CardRegistrationSetLimitResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |


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
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `token` | `string` | <span class="badge-mandatory">Wajib</span> |
| `bankCardNo` | `string` | <span class="badge-optional">Opsional</span> |
| `type` | `string` | <span class="badge-optional">Opsional</span> |
| `part` | `string` | <span class="badge-optional">Opsional</span> |
| `merchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Opsional</span> |
| `terminalId` | `string` | <span class="badge-optional">Opsional</span> |
| `tokenRequestorId` | `string` | <span class="badge-optional">Opsional</span> |
| `journeyId` | `string` | <span class="badge-optional">Opsional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

**Response &mdash; `CardRegistrationUnbindingResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Wajib</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Wajib</span> |
| `referenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Opsional</span> |
| `message` | `string` | <span class="badge-optional">Opsional</span> |
| `customerId` | `string` | <span class="badge-optional">Opsional</span> |
| `unsubscribeDate` | `string` | <span class="badge-optional">Opsional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Opsional</span> |

---
weight: 1
title: "Registration"
description: "Registrasi — Service Codes 01-10, 81 — 11 endpoints"
---

## Registration

Account binding, card registration, and OTP verification — the `registration` package (Service Codes 01-10, 81). Two flows live here: the **account** flow (OAuth-based binding, driven by `GetOAuthURL` → `AccountBinding`) and the **card** flow (`CardRegistration` and its Set Limit/Inquiry/Unbinding variants).

```go
resp, err := registration.AccountBinding(ctx, transport, hb, registration.AccountBindingRequest{
	MerchantID: "...",
})
if err != nil {
	// errors.Is(err, snap.ErrBadRequest), snap.ErrUnauthorized, etc.
}
```

Every function below has the same call shape: fill in `hb` (everything except `Body` — the function marshals the request and sets `Body` itself), call it, and check `err`. See [Core Conventions](/docs/concepts/conventions/) for the full pattern.

### `GetOAuthURL`

Starts the OAuth account-binding flow by building an authorization URL (Service Code 10). This is a read-only GET call: `hb.EndpointURL` must be a bare http(s) URL with no query string or fragment — it errors instead of silently merging into one.

```go
func GetOAuthURL(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req GetOAuthURLRequest) (GetOAuthURLResponse, error)
```

**Request &mdash; `GetOAuthURLRequest`**

Unlike every other endpoint here, this isn't JSON — `GetOAuthURL` builds a URL query string directly from these fields. `RedirectURL`, `Scopes`, and `State` are Mandatory; `SeamlessSign` is Conditional (required only if `SeamlessData` is set); everything else is Optional.

| Query parameter | Type | Presence |
|---|---|---|
| `RedirectURL` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `Scopes` | `[]string` (joined with `,`) | <span class="badge-mandatory">Mandatory</span> |
| `State` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `MerchantID` | `string` | <span class="badge-optional">Optional</span> |
| `SubMerchantID` | `string` | <span class="badge-optional">Optional</span> |
| `Lang` | `string` (ISO 639-1) | <span class="badge-optional">Optional</span> |
| `AllowRegistration` | `*bool` | <span class="badge-optional">Optional</span> |
| `SeamlessData` | `string` | <span class="badge-optional">Optional</span> |
| `MobileNumber` | `string` | <span class="badge-optional">Optional</span> |
| `VerifiedTime` | `string` | <span class="badge-optional">Optional</span> |
| `ExternalUID` | `string` | <span class="badge-optional">Optional</span> |
| `DeviceID` | `string` | <span class="badge-optional">Optional</span> |
| `SeamlessSign` | `string` | Conditional — required if `SeamlessData` is set |

**Response &mdash; `GetOAuthURLResponse`**

Every field is Mandatory.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `authCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `state` | `string` | <span class="badge-mandatory">Mandatory</span> |


---

### `AccountCreation`

Creates an account (Service Code 06).

Not idempotent. On retry, reuse the same `X-EXTERNAL-ID` — a fresh one risks creating a second account.

```go
func AccountCreation(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AccountCreationRequest) (AccountCreationResponse, error)
```

**Request &mdash; `AccountCreationRequest`**

Every field is Optional — this endpoint covers several onboarding flows (seamless data, OAuth redirect, direct creation), each using a different subset of fields.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `countryCode` | `string` | <span class="badge-optional">Optional</span> |
| `customerId` | `string` | <span class="badge-optional">Optional</span> |
| `deviceInfo` | `*DeviceInfo` | <span class="badge-optional">Optional</span> |
| `email` | `string` | <span class="badge-optional">Optional</span> |
| `lang` | `string` | <span class="badge-optional">Optional</span> |
| `locale` | `string` | <span class="badge-optional">Optional</span> |
| `name` | `string` | <span class="badge-optional">Optional</span> |
| `onboardingPartner` | `string` | <span class="badge-optional">Optional</span> |
| `phoneNo` | `string` | <span class="badge-optional">Optional</span> |
| `redirectUrl` | `string` | <span class="badge-optional">Optional</span> |
| `scopes` | `string` | <span class="badge-optional">Optional</span> |
| `seamlessData` | `string` | <span class="badge-optional">Optional</span> |
| `seamlessSign` | `string` | <span class="badge-optional">Optional</span> |
| `state` | `string` | <span class="badge-optional">Optional</span> |
| `merchantId` | `string` | <span class="badge-optional">Optional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `terminalType` | `json.RawMessage` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

{{< details title="DeviceInfo fields" >}}
DeviceInfo describes the device initiating a registration request.

| Field | Type | Presence |
|---|---|---|
| `os` | `string` | <span class="badge-optional">Optional</span> |
| `osVersion` | `string` | <span class="badge-optional">Optional</span> |
| `model` | `string` | <span class="badge-optional">Optional</span> |
| `manufacturer` | `string` | <span class="badge-optional">Optional</span> |
{{< /details >}}

**Response &mdash; `AccountCreationResponse`**

`apiKey` is `json.RawMessage` because the standard doesn't say whether it's sent as a quoted string or a bare number — this accepts either without failing the whole decode.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `authCode` | `string` | <span class="badge-optional">Optional</span> |
| `apiKey` | `json.RawMessage` | <span class="badge-optional">Optional</span> |
| `accountId` | `string` | <span class="badge-optional">Optional</span> |
| `state` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |


---

### `AccountBinding`

Binds a customer account for B2B2C use (Service Code 07).

Not idempotent. On retry, reuse the same `X-EXTERNAL-ID` — a fresh one risks a duplicate binding or a second token issuance.

```go
func AccountBinding(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AccountBindingRequest) (AccountBindingResponse, error)
```

**Request &mdash; `AccountBindingRequest`**

`MerchantID` is the only Mandatory field.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `action` | `string` | <span class="badge-optional">Optional</span> |
| `additionalData` | `json.RawMessage` | <span class="badge-optional">Optional</span> |
| `userId` | `string` | <span class="badge-optional">Optional</span> |
| `email` | `string` | <span class="badge-optional">Optional</span> |
| `postalAddress` | `string` | <span class="badge-optional">Optional</span> |
| `authCode` | `string` | <span class="badge-optional">Optional</span> |
| `grantType` | `string` | <span class="badge-optional">Optional</span> |
| `isBindAndPay` | `string` | <span class="badge-optional">Optional</span> |
| `lang` | `string` | <span class="badge-optional">Optional</span> |
| `locale` | `string` | <span class="badge-optional">Optional</span> |
| `merchantId` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `msisdn` | `string` | <span class="badge-optional">Optional</span> |
| `otp` | `string` | <span class="badge-optional">Optional</span> |
| `phoneNo` | `string` | <span class="badge-optional">Optional</span> |
| `platformType` | `string` | <span class="badge-optional">Optional</span> |
| `redirectUrl` | `string` | <span class="badge-optional">Optional</span> |
| `referenceId` | `string` | <span class="badge-optional">Optional</span> |
| `refreshToken` | `string` | <span class="badge-optional">Optional</span> |
| `successParams` | `*BindingSuccessParams` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

{{< details title="BindingSuccessParams fields" >}}
The request-side `successParams` object.

| Field | Type | Presence |
|---|---|---|
| `accountId` | `string` | <span class="badge-optional">Optional</span> |
| `terminalId` | `string` | <span class="badge-optional">Optional</span> |
| `tokenRequestorId` | `string` | <span class="badge-optional">Optional</span> |
{{< /details >}}

**Response &mdash; `AccountBindingResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `accountToken` | `string` | <span class="badge-optional">Optional</span> |
| `accessTokenInfo` | `*BindingAccessTokenInfo` | <span class="badge-optional">Optional</span> |
| `linkId` | `string` | <span class="badge-optional">Optional</span> |
| `nextAction` | `string` | <span class="badge-optional">Optional</span> |
| `linkageToken` | `string` | <span class="badge-optional">Optional</span> |
| `params` | `json.RawMessage` | <span class="badge-optional">Optional</span> |
| `pinWebViewUrl` | `string` | <span class="badge-optional">Optional</span> |
| `redirectToDeeplink` | `string` | <span class="badge-optional">Optional</span> |
| `redirectUrl` | `string` | <span class="badge-optional">Optional</span> |
| `userInfo` | `*BindingUserInfo` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

{{< details title="BindingAccessTokenInfo fields" >}}
The response-side `accessTokenInfo` object. `expiresIn`/`reExpiresIn` here are ISO 8601 datetime strings — a different shape from the B2B/B2B2C access-token endpoints' `Token.ExpiresIn` (a duration parsed from a seconds count). Same field name, different endpoint, different meaning.

| Field | Type | Presence |
|---|---|---|
| `accessToken` | `string` | <span class="badge-optional">Optional</span> |
| `expiresIn` | `string` | <span class="badge-optional">Optional</span> |
| `refreshToken` | `string` | <span class="badge-optional">Optional</span> |
| `reExpiresIn` | `string` | <span class="badge-optional">Optional</span> |
| `tokenStatus` | `string` | <span class="badge-optional">Optional</span> |
{{< /details >}}

{{< details title="BindingUserInfo fields" >}}
The response-side `userInfo` object.

| Field | Type | Presence |
|---|---|---|
| `publicUserId` | `string` | <span class="badge-optional">Optional</span> |
{{< /details >}}


---

### `AccountBindingInquiry`

Looks up a bound account's details (Service Code 08).

```go
func AccountBindingInquiry(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AccountBindingInquiryRequest) (AccountBindingInquiryResponse, error)
```

**Request &mdash; `AccountBindingInquiryRequest`**

The standard doesn't define an account-identifier field for this call; if your PJP needs one, put it in `AdditionalInfo`.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `AccountBindingInquiryResponse`**

Flatter than `AccountBindingResponse` — no `accessTokenInfo`/`userInfo` nesting. `accountTransactionLimit` is `json.RawMessage` since the standard doesn't guarantee it's always sent as a quoted string across every PJP.

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `accountCurrency` | `string` | <span class="badge-optional">Optional</span> |
| `accountName` | `string` | <span class="badge-optional">Optional</span> |
| `accountNo` | `string` | <span class="badge-optional">Optional</span> |
| `accountTransactionLimit` | `json.RawMessage` | <span class="badge-optional">Optional</span> |
| `endDatePeriod` | `string` | <span class="badge-optional">Optional</span> |
| `startDatePeriod` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |


---

### `AccountUnbinding`

Removes an account binding (Service Code 09).

Not idempotent. On retry, reuse the same `X-EXTERNAL-ID`.

```go
func AccountUnbinding(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req AccountUnbindingRequest) (AccountUnbindingResponse, error)
```

**Request &mdash; `AccountUnbindingRequest`**

`MerchantID` is the only Mandatory field. `LinkID` and `TokenID` — which actually identify the binding to remove — are both Optional per the standard; this package doesn't enforce that at least one is set, since that's a business rule, not a wire-shape rule.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `linkId` | `string` | <span class="badge-optional">Optional</span> |
| `merchantId` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `tokenId` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `AccountUnbindingResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `merchantId` | `string` | <span class="badge-optional">Optional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `linkId` | `string` | <span class="badge-optional">Optional</span> |
| `unlinkResult` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |


---

### `OTP`

Triggers OTP delivery, e.g. SMS (Service Code 81).

Triggers a real external side effect. On retry, reuse the same `X-EXTERNAL-ID` — a fresh one risks a duplicate OTP delivery.

```go
func OTP(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req OTPRequest) (OTPResponse, error)
```

**Request &mdash; `OTPRequest`**

`JourneyID` is the only Mandatory field. For a B2B2C-shaped call, set `HeaderBuilder.B2B2C` (and `AuthorizationCustomer`/`DeviceID`) the same as for any other B2B2C endpoint — no special field is needed here. `BankCardToken` is Conditional.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `journeyId` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `merchantId` | `string` | <span class="badge-optional">Optional</span> |
| `subMerchant` | `string` | <span class="badge-optional">Optional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Optional</span> |
| `trxDateTime` | `string` | <span class="badge-optional">Optional</span> |
| `bankCardToken` | `string` | Conditional |
| `otpTrxCode` | `string` | <span class="badge-optional">Optional</span> |
| `otpReasonCode` | `string` | <span class="badge-optional">Optional</span> |
| `otpReasonMessage` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `OTPResponse`**

`chargeToken` is Mandatory here (it's Optional on `CardRegistrationResponse` — same field name, different endpoint).

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `chargeToken` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |


---

### `VerifyOTP`

Verifies a previously issued OTP (Service Code 04, Direct Integration).

Not idempotent — verifying consumes server-side state (invalidates the OTP, likely counts as an attempt). On retry, reuse the same `X-EXTERNAL-ID` — a fresh one risks burning an extra attempt or re-processing an already-completed call.

```go
func VerifyOTP(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req VerifyOTPRequest) (VerifyOTPResponse, error)
```

**Request &mdash; `VerifyOTPRequest`**

Every field is Optional.

| Field | Type | Presence |
|---|---|---|
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `action` | `string` | <span class="badge-optional">Optional</span> |
| `merchantId` | `string` | <span class="badge-optional">Optional</span> |
| `otp` | `string` | <span class="badge-optional">Optional</span> |
| `chargeToken` | `string` | <span class="badge-optional">Optional</span> |
| `type` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `VerifyOTPResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `originalReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `originalPartnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `accountNo` | `string` | <span class="badge-optional">Optional</span> |
| `bankCardToken` | `string` | <span class="badge-optional">Optional</span> |
| `cardPan` | `string` | <span class="badge-optional">Optional</span> |
| `customerId` | `string` | <span class="badge-optional">Optional</span> |
| `email` | `string` | <span class="badge-optional">Optional</span> |
| `expiredDatetime` | `string` | <span class="badge-optional">Optional</span> |
| `expiryDate` | `string` | <span class="badge-optional">Optional</span> |
| `identificationNo` | `string` | <span class="badge-optional">Optional</span> |
| `linkageToken` | `string` | <span class="badge-optional">Optional</span> |
| `phoneNo` | `string` | <span class="badge-optional">Optional</span> |
| `qParamsURL` | `string` | <span class="badge-optional">Optional</span> |
| `qParams` | `json.RawMessage` | <span class="badge-optional">Optional</span> |
| `sendOtpFlag` | `string` | <span class="badge-optional">Optional</span> |
| `subscribeDatetime` | `string` | <span class="badge-optional">Optional</span> |
| `tokenExpiryTime` | `string` | <span class="badge-optional">Optional</span> |
| `transactionTimestamp` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |


---

### `CardRegistration`

Registers a card and mints a `BankCardToken` (Service Code 01).

Not idempotent — it mints a new token each call. On retry, reuse the same `X-EXTERNAL-ID` — a fresh one risks a duplicate card bind.

```go
func CardRegistration(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req CardRegistrationRequest) (CardRegistrationResponse, error)
```

**Request &mdash; `CardRegistrationRequest`**

`BankCardNo` and `CustIDMerchant` are the two Mandatory fields. `CardData` and `Limit` are `json.RawMessage` — the standard allows a non-string JSON form (a bare object or number) for both. If you're assigning a Go string, quote it yourself first (e.g. `json.RawMessage(`"1000000"`)`, not `json.RawMessage(limitStr)`) so it matches the expected wire shape.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `accountName` | `string` | <span class="badge-optional">Optional</span> |
| `cardData` | `json.RawMessage` | <span class="badge-optional">Optional</span> |
| `bankAccountNo` | `string` | <span class="badge-optional">Optional</span> |
| `bankCardNo` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `bankCardType` | `string` | <span class="badge-optional">Optional</span> |
| `dateOfBirth` | `string` | <span class="badge-optional">Optional</span> |
| `email` | `string` | <span class="badge-optional">Optional</span> |
| `expiredDatetime` | `string` | <span class="badge-optional">Optional</span> |
| `expiryDate` | `string` | <span class="badge-optional">Optional</span> |
| `identificationNo` | `string` | <span class="badge-optional">Optional</span> |
| `identificationType` | `string` | <span class="badge-optional">Optional</span> |
| `custIdMerchant` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `isBindAndPay` | `string` | <span class="badge-optional">Optional</span> |
| `merchantId` | `string` | <span class="badge-optional">Optional</span> |
| `terminalId` | `string` | <span class="badge-optional">Optional</span> |
| `journeyId` | `string` | <span class="badge-optional">Optional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `externalStoreId` | `string` | <span class="badge-optional">Optional</span> |
| `limit` | `json.RawMessage` | <span class="badge-optional">Optional</span> |
| `merchantLogoUrl` | `string` | <span class="badge-optional">Optional</span> |
| `phoneNo` | `string` | <span class="badge-optional">Optional</span> |
| `sendOtpFlag` | `string` | <span class="badge-optional">Optional</span> |
| `type` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `CardRegistrationResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `bankCardToken` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `chargeToken` | `string` | <span class="badge-optional">Optional</span> |
| `randomString` | `string` | <span class="badge-optional">Optional</span> |
| `tokenExpiryTime` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |


---

### `CardRegistrationInquiry`

Looks up registered card accounts by merchant customer ID (Service Code 03). This is the package's only read-only GET endpoint; `custIDMerchant` is passed as a URL path segment, validated and safely joined onto `hb.EndpointURL`.

```go
func CardRegistrationInquiry(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, custIDMerchant string) (CardRegistrationInquiryResponse, error)
```

This endpoint takes no typed request body beyond the call parameters shown above.

**Response &mdash; `CardRegistrationInquiryResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `accountList` | `[]CardRegistrationInquiryAccount` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

{{< details title="CardRegistrationInquiryAccount fields" >}}
One entry in `accountList`, wrapping the nested `accountData` object.

| Field | Type | Presence |
|---|---|---|
| `accountData` | `CardRegistrationInquiryAccountData` | <span class="badge-mandatory">Mandatory</span> |
{{< /details >}}

{{< details title="CardRegistrationInquiryAccountData fields" >}}
The nested `accountData` object. `maxLimit` and `credentialNo` are masked/formatted display strings (e.g. `"************0750"`), not raw values.

| Field | Type | Presence |
|---|---|---|
| `accountId` | `string` | <span class="badge-optional">Optional</span> |
| `createdDate` | `string` | <span class="badge-optional">Optional</span> |
| `credentialNo` | `string` | <span class="badge-optional">Optional</span> |
| `credentialType` | `string` | <span class="badge-optional">Optional</span> |
| `maxLimit` | `string` | <span class="badge-optional">Optional</span> |
| `status` | `string` | <span class="badge-optional">Optional</span> |
{{< /details >}}


---

### `CardRegistrationSetLimit`

Sets a spending limit on a registered card (Service Code 02).

```go
func CardRegistrationSetLimit(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req CardRegistrationSetLimitRequest) (CardRegistrationSetLimitResponse, error)
```

**Request &mdash; `CardRegistrationSetLimitRequest`**

`BankCardToken` is the only Mandatory field. `Limit` is `json.RawMessage` for the same reason as in `CardRegistrationRequest` — quote a Go string yourself before assigning it (e.g. `json.RawMessage(`"1000000"`)`).

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `bankAccountNo` | `string` | <span class="badge-optional">Optional</span> |
| `bankCardNo` | `string` | <span class="badge-optional">Optional</span> |
| `limit` | `json.RawMessage` | <span class="badge-optional">Optional</span> |
| `bankCardToken` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `otp` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `CardRegistrationSetLimitResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |


---

### `CardRegistrationUnbinding`

Removes a card registration (Service Code 05).

Not idempotent. On retry, reuse the same `X-EXTERNAL-ID`.

```go
func CardRegistrationUnbinding(ctx context.Context, t *snap.Transport, hb snap.HeaderBuilder, req CardRegistrationUnbindingRequest) (CardRegistrationUnbindingResponse, error)
```

**Request &mdash; `CardRegistrationUnbindingRequest`**

`Token` is the only Mandatory field.

| Field | Type | Presence |
|---|---|---|
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `token` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `bankCardNo` | `string` | <span class="badge-optional">Optional</span> |
| `type` | `string` | <span class="badge-optional">Optional</span> |
| `part` | `string` | <span class="badge-optional">Optional</span> |
| `merchantId` | `string` | <span class="badge-optional">Optional</span> |
| `subMerchantId` | `string` | <span class="badge-optional">Optional</span> |
| `terminalId` | `string` | <span class="badge-optional">Optional</span> |
| `tokenRequestorId` | `string` | <span class="badge-optional">Optional</span> |
| `journeyId` | `string` | <span class="badge-optional">Optional</span> |
| `transactionDate` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

**Response &mdash; `CardRegistrationUnbindingResponse`**

| Field | Type | Presence |
|---|---|---|
| `responseCode` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `responseMessage` | `string` | <span class="badge-mandatory">Mandatory</span> |
| `referenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `partnerReferenceNo` | `string` | <span class="badge-optional">Optional</span> |
| `message` | `string` | <span class="badge-optional">Optional</span> |
| `customerId` | `string` | <span class="badge-optional">Optional</span> |
| `unsubscribeDate` | `string` | <span class="badge-optional">Optional</span> |
| `additionalInfo` | `json.RawMessage` | <span class="badge-optional">Optional</span> |

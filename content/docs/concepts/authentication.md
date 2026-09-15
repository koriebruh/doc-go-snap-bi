---
weight: 4
title: "Authentication"
description: "Fetching and caching a B2B/B2B2C SNAP access token with TokenManager"
---

Every transaction request carries an `Authorization: Bearer <token>`
header. `TokenManager` fetches and, for B2B, caches that token — access
requests are always asymmetric-signed regardless of your transaction
signing mode (see [Signing](/docs/concepts/signing/)).

## `TokenManager`

```go
type TokenManager struct {
	BaseURL    string
	ClientKey  string
	Signer     crypto.Signer
	HTTPClient *http.Client
	Profile    Profile
	Now        func() time.Time // optional; nil means time.Now
}
```

`HTTPClient` defaults to an internal client with a sane timeout when left
nil. `Profile` defaults to `DefaultProfile{}`. `Now` is only for tests.

## B2B: `client_credentials`

```go
func (m *TokenManager) AccessTokenB2B(ctx context.Context) (string, error)
```

Returns a cached `client_credentials` access token, fetching (and caching)
a new one if none is cached or the cached one is at or past its computed
expiry.

```go
tm := &snap.TokenManager{
	BaseURL:   "https://partner.example.com",
	ClientKey: clientKey,
	Signer:    rsaPrivateKey,
}
token, err := tm.AccessTokenB2B(ctx)
```

If several goroutines call this at once while the token is expired, only
one HTTP request goes out — the rest wait and share its result. That
request runs on its own context, so one caller cancelling doesn't break
the result for everyone else waiting on it.

Caching uses the server-reported `expiresIn` minus a small safety margin
(refetch slightly before actual expiry), floored at half of `expiresIn` so
an unusually small value can't make the margin swallow the entire cache
window.

## B2B2C: authorization code / refresh token

```go
func (m *TokenManager) AccessTokenB2B2C(ctx context.Context, grantType GrantType, code string) (Token, error)
```

B2B2C tokens are **not cached** — each call is a fresh exchange, since the
grant is tied to one specific customer/code rather than the integration as
a whole.

```go
type GrantType string

const (
	GrantTypeClientCredentials GrantType = "client_credentials"
	GrantTypeAuthorizationCode GrantType = "AUTHORIZATION_CODE"
	GrantTypeRefreshToken      GrantType = "REFRESH_TOKEN"
)
```

{{< callout type="default" >}}
The casing above is the standard's own wire format, not a typo —
`client_credentials` is lowercase-snake while the B2B2C grants are
upper-snake. Values are transmitted exactly as declared.
{{< /callout >}}

```go
type Token struct {
	AccessToken  string
	TokenType    string
	ExpiresIn    time.Duration
	RefreshToken string // set for B2B2C only
}
```

Pass `code` as either the OAuth authorization code (for
`GrantTypeAuthorizationCode`, typically obtained via the flow started by
`registration.GetOAuthURL`) or the previously-issued refresh token (for
`GrantTypeRefreshToken`).

## Next

{{< cards >}}
  {{< card title="Headers & Signing" icon="key" link="../headers/" subtitle="Using the token you got here to build a signed transaction request." >}}
  {{< card title="Registration" icon="id-card" link="../../reference/registration/" subtitle="`GetOAuthURL` and `AccountBinding` — the B2B2C onboarding flow." >}}
{{< /cards >}}

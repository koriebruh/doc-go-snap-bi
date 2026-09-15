---
weight: 5
title: "Transport"
description: "How a signed request is actually sent, and how the response is decoded"
---

`Transport` is the thin HTTP layer every domain package's calling function
uses to send a `HeaderBuilder`-built request and decode its response.

## `Transport`

```go
type Transport struct {
	HTTPClient *http.Client
}
```

```go
func (t *Transport) Do(ctx context.Context, hb HeaderBuilder) (Envelope, error)
```

`Do` signs `hb` (via `hb.Build()`), sends it, and decodes the response body
into an `Envelope`. It does **not** retry, rate-limit, or interpret a
non-2xx `responseCode` as a Go error — only transport-level failures
(header-build error, network error, non-JSON body, context cancellation)
come back as `error`. Interpreting a decoded response as success/failure is
the caller's job, via `snap.CheckResponseStatus` (see [Errors](/docs/concepts/errors/)).

When `HTTPClient` is left nil, `Transport` builds one with a default
timeout that **never follows redirects**. This matters: Go's default HTTP
client forwards most headers (including your signed `X-SIGNATURE`,
`X-CLIENT-KEY`, `X-PARTNER-ID`) — and, for a 307/308, the full body — to
whatever host a redirect points at. No SNAP endpoint has a legitimate
reason to redirect, so `Do` treats one like any other failed request
instead of following it.

Response bodies are capped at a fixed size while reading, so a misbehaving
or malicious server can't force unbounded memory use.

## `Envelope`

```go
type Envelope struct {
	StatusCode      int
	ResponseCode    string
	ResponseMessage string
	Raw             json.RawMessage
}
```

`Envelope` is the generic decoded response: the transport-level HTTP
`StatusCode` plus whatever SNAP envelope fields the body carried. Each
domain package's calling function unmarshals `Raw` into its own typed
response.

`StatusCode` matters because `ResponseCode` is only reliable when the
server actually returned SNAP's own error shape — a body from a proxy,
WAF, or gateway in front of it may carry no `ResponseCode` at all. A
binding with no `ResponseCode` to fall back on should key off `StatusCode`
instead, the same pattern `TokenManager` uses internally.

## Next

{{< cards >}}
  {{< card title="Errors" icon="triangle-alert" link="../errors/" subtitle="Turning an `Envelope` into a definitive success/failure and a typed error." >}}
  {{< card title="Verifying inbound requests" icon="shield-check" link="../webhooks/" subtitle="The receiving side, for endpoints where this package's caller is the server." >}}
{{< /cards >}}

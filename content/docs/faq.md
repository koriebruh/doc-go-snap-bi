---
weight: 5
title: "FAQ"
description: "Common questions when integrating go-snap-bi"
---

  {{< details title="Which signing mode should I use — Symmetric or Asymmetric?" >}}
Whichever your partner (the PJP on the other side) agreed with you at
registration time — this package doesn't choose for you. Set
`HeaderBuilder.Symmetric` to match: `true` with `ClientSecret` for
HMAC-SHA512, or `false` with `Signer` for SHA256withRSA. See
[Signing](/docs/concepts/signing/).
{{< /details >}}
  {{< details title="Do I need a database to use TokenManager?" >}}
No. `TokenManager.AccessTokenB2B` caches the token in memory for the
life of the `*TokenManager` value — there's no external store. If you
run multiple processes/instances, each keeps its own cache and fetches
its own token independently. See [Authentication](/docs/concepts/authentication/).
{{< /details >}}
  {{< details title="Is it safe to retry a failed call?" >}}
Check that endpoint's reference page first — most write endpoints are
**not idempotent** (retrying doesn't just "try again safely," it can
trigger the transaction twice). The server detects duplicates by
`X-EXTERNAL-ID`, so a genuine retry should reuse the *same*
`X-EXTERNAL-ID`, never a fresh one. See [Errors](/docs/concepts/errors/).
{{< /details >}}
  {{< details title="A field I need is typed json.RawMessage instead of string — why?" >}}
The SNAP standard documents that field's shape ambiguously (e.g. shown
as a bare JSON number in one worked example and a quoted string in
another). Decoding it as a fixed Go type would reject a legitimate
response under one of the two shapes; `json.RawMessage` accepts either
without loss. See [Core Conventions](/docs/concepts/conventions/).
{{< /details >}}
  {{< details title="Why does an endpoint's request table show all fields as Optional when the doc paragraph says some are Conditional?" >}}
Optional and Conditional both compile to Go's `omitempty` — there's no
wire-level difference, so the table can't distinguish them. Read the
prose paragraph above the table (reproduced from the source's own doc
comment) for which Optional fields are actually Conditional. See
[Core Conventions](/docs/concepts/conventions/).
{{< /details >}}
  {{< details title="How do I handle a payment notification/callback?" >}}
Verify it first with `snap.ServerVerifier` — never unmarshal an inbound
body before checking its signature. Each "Inbound only" section on a
reference page names the exact `...NotificationRequest` type to decode
into and the `...NotificationResponse` shape to reply with. See
[Verifying inbound requests](/docs/concepts/webhooks/).
{{< /details >}}
  {{< details title="Does this package retry or rate-limit requests for me?" >}}
No. `snap.Transport.Do` sends exactly one request and returns — no
retries, no backoff, no rate-limiting. Build that in your own calling
code if you need it, using each endpoint's idempotency note to decide
what's safe to retry. See [Transport](/docs/concepts/transport/).
{{< /details >}}
  {{< details title="What Go version do I need?" >}}
Go 1.21 or later, per [`go.mod`](https://github.com/koriebruh/go-snap-bi/blob/main/go.mod).
{{< /details >}}
  {{< details title="Does this package have any third-party dependencies?" >}}
No — everything is Go standard library (`net/http`, `crypto/rsa`,
`crypto/hmac`, `encoding/json`, and so on).
{{< /details >}}

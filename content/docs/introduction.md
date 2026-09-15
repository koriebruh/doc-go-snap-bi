---
weight: 1
title: "Introduction"
description: "A Go implementation of Bank Indonesia's SNAP payment standard"
---

<div style="text-align: center; padding: 1.5rem 0 0.5rem">
  <img src="/images/snap-logo.png" alt="SNAP — terstandar, terintegrasi" style="height: 72px" />
  <div style="height: 3px; width: 120px; margin: 1.25rem auto 0; border-radius: 2px; background: linear-gradient(90deg, #145B91 0%, #145B91 45%, #FFFFFF 45%, #FFFFFF 55%, #DC2626 55%, #DC2626 100%)" />
</div>

**go-snap-bi** is a Go implementation of Bank Indonesia's **SNAP** (Standar
Nasional Open API Pembayaran) payment standard — **document version 1.0.2
(September 2024)** — covering every API Service category published on the
[ASPI SNAP Developer Site](https://apidevportal.aspi-indonesia.or.id/api-services).

{{< callout type="info" >}}
This SDK targets **SNAP standard version 1.0.2**, published September
2024. If ASPI/Bank Indonesia release a newer document version, check the
[GitHub repository](https://github.com/koriebruh/go-snap-bi) before
assuming a field or endpoint here still matches the latest spec.
{{< /callout >}}

<p style="text-align: center; font-size: 0.8rem; color: var(--gray-500, #6B7280)">
  Independent, unofficial implementation of the standard published by Bank
  Indonesia and [ASPI](https://apidevportal.aspi-indonesia.or.id/api-services) —
  not affiliated with or endorsed by either.
</p>

```bash
go get github.com/koriebruh/go-snap-bi
```

## Status

All 7 of the portal's API Service categories are accounted for — **79
typed endpoint bindings** across 5 domain packages, plus the shared
signing/token/transport core.

| Portal category | Package | Service Codes | Endpoints |
|---|---|---|---|
| Registrasi | [`registration`](/docs/reference/registration/) | 01–10, 81 | 11 |
| Informasi Saldo | [`balanceinfo`](/docs/reference/balance-info/) | 11 | 1 |
| Riwayat Transaksi | [`transactionhistory`](/docs/reference/transaction-history/) | 12–14 | 3 |
| Transfer Kredit | [`transfercredit`](/docs/reference/transfer-credit/account-inquiry/) | 15–53, 75–78 | 43 |
| Transfer Debit | [`transferdebit`](/docs/reference/transfer-debit/auth-payment/) | 54–72, 79–80 | 21 |
| Keamanan | root `snap` package ([Authentication](/docs/concepts/authentication/)) | 73–74 | — |
| Administrasi | *(no API endpoints on the portal — onboarding docs only)* | — | — |

Keamanan's Access Token endpoints live in the root package instead of
their own subpackage: every other package needs them just to get a
token, so they're infrastructure, not a peer domain.

## Design

{{< cards >}}
  {{< card title="One core, five domain packages" icon="layers" subtitle="The root `snap` package holds only what every domain package needs: request signing, the access-token lifecycle, inbound-request verification, header assembly, response-code parsing, and the shared `Money` type. Each domain package maps 1:1 to an ASPI portal category." >}}
  {{< card title="One shape per endpoint" icon="shapes" subtitle="Every calling function follows the same pattern: marshal the typed request, sign and send it, check the response status (HTTP status is authoritative over the SNAP `responseCode` body, never the other way around), and unmarshal into a typed response." >}}
  {{< card title="Wire-shape fidelity over convenience" icon="file-check" subtitle="Mandatory/Optional/Conditional field markers from the standard are preserved exactly as `omitempty` presence; genuinely ambiguous or unspecified-shape fields are modeled as `json.RawMessage` rather than guessed at." >}}
  {{< card title="Zero third-party dependencies" icon="box" subtitle="Everything is Go standard library — `net/http`, `crypto/rsa`, `crypto/hmac`, `encoding/json`." >}}
{{< /cards >}}

## Where to go next

{{< cards >}}
  {{< card title="Quickstart" icon="rocket" link="/docs/quickstart/" subtitle="Install the module and make your first signed request." >}}
  {{< card title="Core conventions" icon="book" link="/docs/concepts/conventions/" subtitle="The one-shape-per-endpoint pattern, field presence, and error handling rules shared by every package." >}}
{{< /cards >}}

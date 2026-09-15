---
title: "Concepts"
weight: 3
---

The rules and primitives shared by every domain package — read these once
and every endpoint reference page becomes predictable.

{{< cards >}}
  {{< card link="conventions/" title="Core Conventions" icon="book" subtitle="The one-shape-per-endpoint pattern, field presence, and the shared Money type." >}}
  {{< card link="headers/" title="Headers & Signing" icon="key" subtitle="How HeaderBuilder assembles and signs a request." >}}
  {{< card link="signing/" title="Signing" icon="signature" subtitle="HMAC and RSA signing primitives, and the string-to-sign formulas." >}}
  {{< card link="authentication/" title="Authentication" icon="id-card" subtitle="TokenManager, B2B and B2B2C access tokens." >}}
  {{< card link="transport/" title="Transport" icon="server" subtitle="How a signed request is actually sent, and its response decoded." >}}
  {{< card link="errors/" title="Errors" icon="triangle-alert" subtitle="Response codes, sentinel errors, and the HTTP-status-wins rule." >}}
  {{< card link="webhooks/" title="Verifying Inbound Requests" icon="shield-check" subtitle="ServerVerifier and KeyStore for the receiving side." >}}
  {{< card link="glossary/" title="Glossary" icon="book" subtitle="SNAP and payments-domain terms used throughout this documentation." >}}
  {{< card link="faq/" title="FAQ" icon="info" subtitle="Common questions when integrating go-snap-bi." >}}
{{< /cards >}}

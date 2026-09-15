---
title: "go-snap-bi"
layout: hextra-home
---

<div class="hx:mt-6 hx:mb-6 hx:flex hx:justify-center">
  <img src="/images/snap-logo.png" alt="SNAP" style="height: 84px" />
</div>

{{< hextra/hero-headline >}}
go-snap-bi
{{< /hextra/hero-headline >}}

{{< hextra/hero-subtitle >}}
A Go implementation of Bank Indonesia's SNAP payment standard&nbsp;<br class="hx:sm:block hx:hidden" />79 typed endpoint bindings, zero third-party dependencies
{{< /hextra/hero-subtitle >}}

<div class="hx:mt-6 hx:mb-6 hx:flex hx:justify-center hx:gap-4">
  {{< hextra/hero-button text="Get Started" link="/docs/quickstart/" >}}
  {{< hextra/hero-button text="API Reference" link="/docs/reference/registration/" >}}
</div>

<div class="hx:mt-12"></div>

{{< cards cols="2" >}}
  {{< card link="/docs/introduction/" title="SNAP v1.0.2 (Sep 2024)" icon="badge-check" tag="latest" tagColor="orange" subtitle="Targets the September 2024 SNAP standard document, covering every ASPI API Service category." >}}
  {{< card link="/docs/concepts/conventions/" title="One shape per endpoint" icon="shapes" subtitle="Every calling function follows the same signature and the same HTTP-status-wins error rule." >}}
  {{< card link="/docs/concepts/signing/" title="Symmetric & asymmetric signing" icon="key" subtitle="HMAC-SHA512 or SHA256withRSA, matching whatever your partner agreed at registration." >}}
  {{< card link="/docs/concepts/webhooks/" title="Inbound notification verification" icon="shield-check" subtitle="ServerVerifier validates signatures on payment callbacks before you trust the body." >}}
{{< /cards >}}

<p class="hx:mt-12 hx:text-center hx:text-sm hx:text-gray-500">
Independent, unofficial implementation of the standard published by Bank Indonesia and <a href="https://apidevportal.aspi-indonesia.or.id/api-services">ASPI</a> — not affiliated with or endorsed by either.
</p>

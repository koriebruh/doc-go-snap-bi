---
title: "go-snap-bi"
layout: hextra-home
---

<h1 style="position:absolute;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0,0,0,0);white-space:nowrap;border:0">go-snap-bi</h1>

<div class="hx:mt-6 hx:mb-6 hx:flex hx:justify-center hero-logo-lg">

![go-snap-bi](/images/GO-SNAP-hero.png)

</div>

{{< hextra/hero-subtitle >}}
Implementasi Go untuk standar pembayaran SNAP milik Bank Indonesia&nbsp;<br class="hx:sm:block hx:hidden" />79 binding endpoint bertipe, tanpa dependensi pihak ketiga
{{< /hextra/hero-subtitle >}}

<div class="hx:mt-6 hx:mb-6 hx:flex hx:justify-center hx:gap-4">
  {{< hextra/hero-button text="Mulai" link="docs/quickstart/" >}}
  {{< hextra/hero-button text="API Reference" link="docs/reference/registration/" >}}
</div>

<div class="hx:mt-12"></div>

{{< cards cols="2" >}}
  {{< card link="docs/introduction/" title="SNAP v1.0.2 (Sep 2024)" icon="badge-check" tag="terbaru" tagColor="orange" subtitle="Menargetkan dokumen standar SNAP September 2024, mencakup seluruh kategori API Service ASPI." >}}
  {{< card link="docs/concepts/conventions/" title="Satu bentuk per endpoint" icon="shapes" subtitle="Setiap fungsi pemanggil memakai signature yang sama dan aturan HTTP-status-menang yang sama." >}}
  {{< card link="docs/concepts/signing/" title="Signing symmetric & asymmetric" icon="key" subtitle="HMAC-SHA512 atau SHA256withRSA, sesuai kesepakatan dengan partner saat registrasi." >}}
  {{< card link="docs/concepts/webhooks/" title="Verifikasi notifikasi masuk" icon="shield-check" subtitle="ServerVerifier memvalidasi signature pada callback pembayaran sebelum Anda memercayai isinya." >}}
{{< /cards >}}

<p class="hx:mt-12 hx:text-center hx:text-sm hx:text-gray-500">
Implementasi independen dan tidak resmi dari standar yang dipublikasikan oleh Bank Indonesia dan <a href="https://apidevportal.aspi-indonesia.or.id/api-services">ASPI</a> — tidak berafiliasi dengan atau didukung oleh keduanya.
</p>

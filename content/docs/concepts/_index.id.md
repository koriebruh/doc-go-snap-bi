---
title: "Konsep"
weight: 3
---

Aturan dan primitif yang dipakai bersama setiap package domain — pelajari
sekali, dan setiap halaman referensi endpoint jadi mudah ditebak.

{{< cards >}}
  {{< card link="conventions/" title="Konvensi Inti" icon="book" subtitle="Pola satu-bentuk-per-endpoint, presence field, dan tipe Money yang dipakai bersama." >}}
  {{< card link="headers/" title="Headers & Signing" icon="key" subtitle="Bagaimana HeaderBuilder menyusun dan menandatangani sebuah request." >}}
  {{< card link="signing/" title="Signing" icon="signature" subtitle="Primitif signing HMAC dan RSA, serta formula string-to-sign." >}}
  {{< card link="authentication/" title="Authentication" icon="id-card" subtitle="TokenManager, access token B2B dan B2B2C." >}}
  {{< card link="transport/" title="Transport" icon="server" subtitle="Bagaimana request yang sudah ditandatangani benar-benar dikirim dan responsnya didekode." >}}
  {{< card link="errors/" title="Errors" icon="triangle-alert" subtitle="Kode respons, sentinel error, dan aturan status-HTTP-menang." >}}
  {{< card link="webhooks/" title="Verifying Inbound Requests" icon="shield-check" subtitle="ServerVerifier dan KeyStore untuk sisi penerima." >}}
  {{< card link="glossary/" title="Glossary" icon="book" subtitle="Istilah SNAP dan domain pembayaran yang dipakai di seluruh dokumentasi ini." >}}
{{< /cards >}}

# go-snap-bi docs

Mintlify documentation site for [`go-snap-bi`](https://github.com/koriebruh/go-snap-bi),
a Go implementation of Bank Indonesia's SNAP payment standard.

Bilingual (English default, Bahasa Indonesia under `id/`), covering the
core concepts (signing, authentication, transport, errors, verifying
inbound requests) and all 79 endpoint bindings across 5 domain packages.

## Local preview

```bash
npx mint@latest dev
```

Opens at `http://localhost:3000`.

## Structure

- `introduction.mdx`, `quickstart.mdx` — getting started
- `concepts/` — core conventions, signing, headers, auth, transport, errors, webhooks, glossary, FAQ
- `reference/` — API reference, one page (or group of pages) per SNAP portal category
- `id/` — Indonesian mirror of every page above, same structure
- `docs.json` — Mintlify site config (nav, theme, colors, fonts)
- `images/` — logo and favicon assets

## Validating changes

```bash
npx mint@latest broken-links
```

Checks every page parses and every internal link resolves before you push.

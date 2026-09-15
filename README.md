# go-snap-bi docs

Hugo (Hextra theme) documentation site for [`go-snap-bi`](https://github.com/koriebruh/go-snap-bi),
a Go implementation of Bank Indonesia's SNAP payment standard.

Bilingual (English default, Bahasa Indonesia via `.id.md` files), covering the
core concepts (signing, authentication, transport, errors, verifying
inbound requests) and all 79 endpoint bindings across 5 domain packages.

Body font is Plus Jakarta Sans, code font is JetBrains Mono.

## Local preview

```bash
hugo server
```

Opens at `http://localhost:1313/doc-go-snap-bi/`. Requires the extended
Hugo binary (uses Hugo Modules — network access needed on first run to
fetch the Hextra theme).

## Structure

- `content/docs/introduction.md`, `content/docs/quickstart.md` — getting started
- `content/docs/concepts/` — core conventions, signing, headers, auth, transport, errors, webhooks, glossary, FAQ
- `content/docs/reference/` — API reference, one page (or group of pages) per SNAP portal category
- `content/**/*.id.md` — Indonesian translation of the page next to it (Hugo filename-suffix multilingual)
- `content/_index.md` / `content/_index.id.md` — homepage hero
- `hugo.toml` — site config (nav, theme, languages)
- `assets/css/custom.css` — fonts and primary color overrides
- `data/icons.yaml` — Lucide/Simple Icons SVGs used by cards and shortcodes
- `static/images/` — logo and favicon assets

## Validating changes

```bash
hugo --printPathWarnings --gc
```

Fails the build on broken shortcodes/icons and prints duplicate-path or
dangling-path warnings before you push.

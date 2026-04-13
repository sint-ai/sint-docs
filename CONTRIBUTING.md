# Contributing to sint-docs

Docs for [docs.sint.gg](https://docs.sint.gg).

## Setup

```bash
npm i -g mintlify
git clone https://github.com/sint-ai/sint-docs
cd sint-docs
mintlify dev     # → http://localhost:3000
```

## Adding a page

1. Create the `.mdx` file under the appropriate directory.
2. Add YAML frontmatter with at least `title` and `description`.
3. Add the page path to `mint.json` `navigation`.
4. `mintlify dev` should hot-reload it.

## Required frontmatter

```yaml
---
title: "Page title (short)"
description: "One-sentence description shown on cards and in search."
---
```

## Style

- Short paragraphs. Three sentences is often enough.
- No "we are excited to announce." Just announce.
- Code samples are TypeScript unless the content is explicitly cross-language.
- Tables over prose when comparing.
- Link to every related page from each page. Don't leave dead ends.

## Anti-regression rules (enforced in CI)

- **Pivot-era terminology** (`tokenomics`, `$SINT`, `airdrop`, `ASI-1 Mini`, `Fetch.ai`, `Agentverse`, `Trust Wallet`, `MetaMask`, "SINT token", "our token") is allowed **only** in `origin.mdx` and `INK-TEARDOWN.md`. Anywhere else, CI fails.
- **OpenClaw** must not appear in any outbound-shaped content. It can be mentioned on `founder`-style pages and the `trust.mdx` page as proof of dogfooding, nowhere else.
- Every `.mdx` file must have `title:` in its frontmatter. CI enforces.
- `mintlify broken-links` must pass.

## Reviews

One maintainer review for content changes. Two for `mint.json` structural changes or `origin.mdx` edits.

## Deploy

`main` auto-deploys via the Mintlify GitHub app. After deploy, `.github/workflows/deploy.yml` runs `verify-redirects.sh` and `verify-pages.sh` against `https://docs.sint.gg`.

## Security

Never include tokens, secrets, or per-tenant data in example code. Use placeholders (`acme`, `your-tenant`, `...`).

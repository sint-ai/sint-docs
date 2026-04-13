# APPLY.md — How to ship this

**Order of operations.** Do these in sequence; each step builds on the previous.

## 1. Create the repo and push

```bash
# Create github.com/sint-ai/sint-docs (private first, flip to public after verify)
cd /path/to/working-dir
git init sint-docs
cd sint-docs

# Copy the bundle contents
cp -r /path/to/this/bundle/. .

git add .
git commit -S -m "docs: initial rewrite for sint.gg post-pivot"
git remote add origin git@github.com:sint-ai/sint-docs.git
git push -u origin main
```

## 2. Connect Mintlify

- Mintlify dashboard → **New deployment** → **GitHub** → pick `sint-ai/sint-docs`
- Set custom domain to `docs.sint.gg`
- Mintlify will give you a CNAME target — add it in your DNS provider (replaces whatever `docs.sint.gg` currently points to)
- Wait for DNS + SSL (~5 min)

## 3. Verify the new site

```bash
# In the repo:
./scripts/verify-pages.sh
# All pages in mint.json should return 200
```

## 4. Apply legacy redirects

Pick one path from `REDIRECT-IMPLEMENTATION.md`:
- **Option 1 (easiest):** Already configured in `mint.json`. Nothing to do beyond step 2.
- **Option 2 (most robust):** Cloudflare Bulk Redirects. See the CSV in `REDIRECT-IMPLEMENTATION.md` §Option 2.

Then verify:

```bash
./scripts/verify-redirects.sh
```

Expected: 19 redirects, 0 misses.

## 5. Tear down `ink.sint.gg`

Follow `INK-TEARDOWN.md`. Recommended: Option A (hard teardown).

## 6. Request Google re-crawl

From Google Search Console:
- Submit new sitemap: `https://docs.sint.gg/sitemap.xml`
- Request indexing on the top-20 new pages (origin, overview pages, flagship Operator pages)
- Use the **Removals** tool on the top-20 old URLs (the ones `site:docs.sint.gg` currently returns)

## 7. Sweep inbound references

```bash
# From your main dev workspace
for repo in ~/sint-ai-workspace/*; do
  grep -RIn "docs.sint.gg/whitepaper\|docs.sint.gg/tokenomics\|docs.sint.gg/airdrop\|docs.sint.gg/asi\|docs.sint.gg/mcp-marketplace\|docs.sint.gg/sintasibridge\|ink.sint.gg" "$repo" 2>/dev/null
done
```

Replace any hit with the new canonical path (or remove if no longer relevant).

## 8. Enable CI

After the first green deploy, turn on branch protection on `main`:
- Require PR review (1 reviewer)
- Require status checks: `pr-check`, `validate`
- Require signed commits

## 9. Ship log entry

Add a single line to the ship log:

> Docs rebuild shipped. `docs.sint.gg` now reflects the post-pivot SINT Labs (Protocol + Operators + Platform + Face). 19 legacy paths 301 to `/origin` or new canonical destinations. `ink.sint.gg` decommissioned. Google re-crawl requested.

---

## What you get

72 files. ~33,000 words of production MDX content. Every page in the ecosystem is covered: Protocol (5 layers + 5 invariants + reference), Operators (6 flagship + anatomy + safety envelope + telemetry), Platform (Console, Commons, Memory, Cron, Canon, Pipelines — all with sub-pages), Face (5 pages), Research (2 papers), Resources (changelog, trust, press, support). Plus: the ink teardown procedure, the redirect implementation guide with three host-specific options, two verify scripts, and two CI workflows.

## What still requires you

- DNS change pointing `docs.sint.gg` at Mintlify
- Cloudflare Bulk Redirect list (if you go with Option 2)
- ink.sint.gg teardown (DNS change + host-side cleanup per INK-TEARDOWN.md)
- Google Search Console re-indexing request
- Domain-level verification of SSO/OIDC if you later wire that up for Console

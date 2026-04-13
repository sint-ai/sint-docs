# INK-TEARDOWN.md — `ink.sint.gg` removal

**Objective:** Remove the `ink.sint.gg` subdomain from the public internet so no Web3-era "SINT Game" content remains reachable or indexable.

**Outcome criteria (all four must be true before this is marked done):**

1. `curl -I https://ink.sint.gg/` returns 410 Gone (or the whole host is NXDOMAIN at the DNS layer — either is acceptable)
2. `curl -I https://ink.sint.gg/<any-subpath>` returns 410 Gone (or NXDOMAIN)
3. Google `site:ink.sint.gg` returns zero results within ~2 weeks (after resubmission — see step 5)
4. Internet Archive / archive.today snapshots of ink.sint.gg are delisted from public discovery surfaces where possible (note: the archive copies themselves cannot be deleted; see step 6)

There are two valid paths — pick **Option A** if you don't need the subdomain back for any future purpose, **Option B** if you might. A is cleaner; B preserves optionality.

---

## Pre-flight (10 minutes)

1. **Identify the current host.** Run:
   ```bash
   dig +short ink.sint.gg
   dig +short CNAME ink.sint.gg
   curl -sI https://ink.sint.gg/ | head -20
   ```
   The combination of A/AAAA/CNAME records plus the `Server` and `CF-Ray` / platform-specific headers tells you who hosts it. Most likely one of: Vercel, Netlify, Cloudflare Pages, GitHub Pages, or a bespoke VPS.

2. **Confirm DNS registrar.** The domain `sint.gg` — find your DNS provider (likely Cloudflare or Namecheap). All DNS changes happen there.

3. **Screenshot the current site for archive.** Before anything is torn down:
   ```bash
   curl -sL https://ink.sint.gg/ -o /tmp/ink-index.html
   curl -sL https://ink.sint.gg/sitemap.xml -o /tmp/ink-sitemap.xml   # if it exists
   ```
   Save these in the SINT Labs internal archive for the record. You will want this if anyone ever asks, years later, what was there.

4. **Enumerate every URL Google has indexed** so you can confirm teardown:
   ```
   site:ink.sint.gg
   ```
   Save the list. These are the URLs you'll check in step 5.

5. **Check for inbound links from sint.gg, docs.sint.gg, GitHub, or social.** Search:
   ```bash
   grep -RIn "ink.sint.gg" <path to sint.gg source>
   grep -RIn "ink.sint.gg" <path to docs.sint.gg source>
   ```
   Any match is a dangling link that must be removed in the same deploy cycle as the teardown, or the 410 will surface as a broken link.

---

## Option A — Hard teardown (recommended)

Removes the subdomain entirely. No DNS record, no site, no possibility of accidental revival.

### Step A1 — Remove the application deployment

Depending on the host:

- **Vercel:** Dashboard → the project hosting `ink.sint.gg` → Settings → Domains → remove `ink.sint.gg`. Then Settings → Advanced → Delete Project (optional; you can also just detach the domain and leave the project around).
- **Netlify:** Dashboard → the site → Domain management → Custom domains → remove `ink.sint.gg`. Then Site configuration → Delete this site (optional).
- **Cloudflare Pages:** Workers & Pages → the project → Custom domains → remove `ink.sint.gg`. Then delete the project.
- **GitHub Pages:** The repo's Settings → Pages → set Source to "None". Then Settings → Danger Zone → delete or archive the repo.
- **Bespoke VPS:** Stop the service (`systemctl stop <svc>`), remove the nginx/Caddy config for `ink.sint.gg`, reload the web server.

### Step A2 — Remove the DNS record

In your DNS provider:

- Delete any A / AAAA / CNAME record for `ink` in the `sint.gg` zone.
- If Cloudflare proxied (orange cloud), also remove the Cloudflare-side origin mapping before the DNS removal.

### Step A3 — Verify NXDOMAIN

```bash
dig +short ink.sint.gg            # should return empty
curl -sI https://ink.sint.gg/     # should fail at the TLS/DNS layer
```

---

## Option B — Soft teardown (preserves the subdomain for future use)

Keeps the subdomain resolvable but serves `410 Gone` on every path.

`410 Gone` is the right response (not 404, not 301). It tells Google and other crawlers that the content is permanently removed; Google de-indexes 410s faster than 404s. You don't want to 301 to docs.sint.gg because the content has nothing to do with the new docs — we're not trying to preserve inbound SEO equity, we're trying to terminate it.

### Step B1 — Pick the 410 destination

Easiest paths, in order of preference:

1. **Cloudflare Worker** (if Cloudflare proxies the subdomain):

   ```javascript
   // Worker attached to route: ink.sint.gg/*
   export default {
     async fetch(request) {
       return new Response("Gone. See https://sint.gg/origin for context.\n", {
         status: 410,
         headers: {
           "Content-Type": "text/plain; charset=utf-8",
           "X-Robots-Tag": "noindex, nofollow",
           "Cache-Control": "public, max-age=86400",
         },
       });
     },
   };
   ```

   Attach: Cloudflare dashboard → sint.gg zone → Workers Routes → add route `ink.sint.gg/*` → select the Worker above.

2. **Cloudflare Page Rule / Bulk Redirect with custom response** (if you don't want a Worker):

   Cloudflare → sint.gg zone → Rules → Transform Rules → Rewrite URL:
   - When: `(http.host eq "ink.sint.gg")`
   - Then: Static Response → 410 Gone, body `"Gone. See https://sint.gg/origin for context."`

3. **Static host serving a single page** (Vercel / Netlify / Pages):

   Deploy a one-file repo with a single `index.html`:

   ```html
   <!doctype html>
   <html>
     <head>
       <meta charset="utf-8">
       <meta name="robots" content="noindex, nofollow">
       <title>Gone</title>
     </head>
     <body>
       <p>This subdomain has been retired. See <a href="https://sint.gg/origin">sint.gg/origin</a> for context.</p>
     </body>
   </html>
   ```

   And — critically — configure the host to return HTTP 410 rather than 200. On Netlify this is done via `_headers` and `_redirects` (return 410 on every path); on Vercel via `vercel.json`:

   ```json
   {
     "routes": [
       { "src": "/.*", "status": 410, "dest": "/index.html" }
     ]
   }
   ```

   Cloudflare Pages or plain nginx: serve the static body with `return 410;` on every location.

### Step B2 — Verify

```bash
curl -sI https://ink.sint.gg/                    # → HTTP/2 410
curl -sI https://ink.sint.gg/game                # → HTTP/2 410
curl -sI https://ink.sint.gg/anything/you/like   # → HTTP/2 410
```

Every path must return 410.

---

## Step 5 — Trigger search engine re-crawl

Both options require this to remove the content from SERPs in reasonable time.

### Google Search Console

1. Go to [search.google.com/search-console](https://search.google.com/search-console)
2. Verify ownership of `ink.sint.gg` (DNS TXT record verification — same `sint.gg` DNS provider)
3. URL Inspection → submit each known URL (from your pre-flight list) → "Request Indexing" will fail (good, that's the point — Google sees it's gone)
4. Removals → Temporary removals → New request → paste URLs → submit. This suppresses them from SERPs within 24 hours while Google confirms the 410/NXDOMAIN for permanent removal (typically 2–6 weeks).
5. Sitemaps → if a sitemap was ever submitted for `ink.sint.gg`, remove it.

### Bing Webmaster Tools

1. Same verification flow at [bing.com/webmasters](https://www.bing.com/webmasters).
2. Configure My Site → Block URLs → add `ink.sint.gg/*`.

### Other crawlers

Most follow Google's lead; no manual action needed for DuckDuckGo, Yandex, etc.

---

## Step 6 — Archives (Wayback Machine, archive.today, Glama etc.)

You **cannot delete** Internet Archive (Wayback Machine) copies of public pages — that's policy. What you can do:

1. **Submit a removal request** at archive.org/help/exclude — they evaluate case-by-case. For a corporate pivot where old content actively misleads, they often comply. Evidence they accept: a statement from the domain owner (you, illia@sint.gg) that the content is out of date and no longer reflects the entity.

2. **For archive.today**: email the maintainer as documented on [archive.ph](https://archive.ph/faq). Success rate is lower than Internet Archive.

3. **For Glama.ai and other MCP / AI directories**: they already have your current listing. Contact them directly and confirm the current listing is what you want indexed; ask them to remove any legacy SINT entries that link to ink.sint.gg.

Archive removal is best-effort; treat the Wayback copy as immutable and work on making the current signals dominant.

---

## Step 7 — Sweep remaining references

Places to scrub:

- [ ] `sint.gg` — grep the source for `ink.sint.gg`, remove
- [ ] `docs.sint.gg` (this repo) — grep for `ink.sint.gg`, remove
- [ ] `github.com/sint-ai/*` and `github.com/pshkv/*` — grep every repo for `ink.sint.gg` in READMEs, docs, code
- [ ] LinkedIn company page — remove any link
- [ ] X / Twitter bio — remove
- [ ] Crunchbase, Pitchbook, any directory listing — update
- [ ] Press kit / PDFs on sint.gg — re-export any that mention the old subdomain

```bash
# Quick audit from a local workspace
for repo in ~/sint-ai-workspace/*; do
  echo "=== $repo ==="
  grep -RIn "ink.sint.gg" "$repo" 2>/dev/null || echo "clean"
done
```

---

## Step 8 — Ship log entry

After the teardown is complete (Option A or Option B, verified), add a ship log entry to document the decommission. A terse one is fine:

> `ink.sint.gg` decommissioned. Subdomain removed from DNS (or: returning 410 Gone on every path). Google Search Console removal requested; Bing blocked. Internal references swept across sint.gg, docs.sint.gg, and `sint-ai` / `pshkv` GitHub orgs. Archive submissions filed with Internet Archive.

---

## Recommendation

**Use Option A** unless you already have a concrete future plan for the subdomain. A is less operational surface to maintain and makes the cutoff unambiguous. B is reversible, which is also its risk — a future teammate or deploy can accidentally re-publish to a subdomain that the internet still remembers as "SINT Game."

If Option B, set a calendar reminder to revisit in 12 months: if the subdomain still isn't reused, downgrade to A.

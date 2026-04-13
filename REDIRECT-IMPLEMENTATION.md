# REDIRECT-IMPLEMENTATION.md — Legacy `docs.sint.gg/*` 301s

Applies the 301 redirect map from `03-DOCS-REWRITE.md §4` and the `redirects` block in `mint.json`. Pick the path that matches where `docs.sint.gg` actually runs.

---

## The redirect map (authoritative)

| From (legacy path) | To (new path) |
|---|---|
| `/introduction` | `/origin` |
| `/whitepaper` | `/origin` |
| `/whitepaper/*` | `/origin` |
| `/security` | `/protocol/security` |
| `/mcp-marketplace` | `/origin` |
| `/sintbridge` | `/protocol/layers/bridge` |
| `/sintasibridge` | `/origin` |
| `/presskit` | `/press` |
| `/tokenomics` | `/origin` |
| `/tokenomics/*` | `/origin` |
| `/marketplace` | `/origin` |
| `/marketplace/*` | `/origin` |
| `/airdrop` | `/origin` |
| `/token` | `/origin` |
| `/asi` | `/origin` |
| `/agents/trading` | `/origin` |
| `/agents/defi` | `/origin` |
| `/agents/social` | `/origin` |

All redirects are **HTTP 301** (permanent). Not 302, not 308 — 301 is the one that transfers SEO equity cleanly and is universally supported.

---

## Option 1 — Mintlify built-in redirects (simplest)

**Use when:** `docs.sint.gg` is deployed via the Mintlify GitHub app from this repo.

Already configured. The `redirects` array in `mint.json` contains the full map. On deploy, Mintlify generates a `_redirects` file in the build output; its CDN returns 301 on every legacy path.

**Action:** merge this repo to `main`. The Mintlify app deploys within ~60 seconds. Then verify:

```bash
./scripts/verify-redirects.sh
```

**Limitation:** Mintlify's `redirects` block handles everything docs-domain-side. It does **not** redirect paths that are now being served by a different host (e.g. anything that was at `docs.sint.gg/<path>` but needs to go to `sint.gg/<path>`). For those, use Option 2 or 3.

---

## Option 2 — Cloudflare Bulk Redirects (most robust)

**Use when:** Cloudflare proxies `docs.sint.gg` (orange cloud). This is the strongest option — redirects fire at the edge before the origin is touched, so they work even if the docs origin is down or misconfigured.

### Step 1 — Create a Bulk Redirect list

Cloudflare dashboard → **Account Home** → **Bulk Redirects** → **Lists** → **Create new list**.

- Name: `sint-legacy-docs`
- Type: **Redirects**

Add rows (one-by-one UI, or upload the CSV below):

```csv
source,target,status,preserve_query_string,include_subdomains,subpath_matching
https://docs.sint.gg/introduction,https://docs.sint.gg/origin,301,true,false,false
https://docs.sint.gg/whitepaper,https://docs.sint.gg/origin,301,true,false,false
https://docs.sint.gg/whitepaper/*,https://docs.sint.gg/origin,301,true,false,true
https://docs.sint.gg/security,https://docs.sint.gg/protocol/security,301,true,false,false
https://docs.sint.gg/mcp-marketplace,https://docs.sint.gg/origin,301,true,false,false
https://docs.sint.gg/sintbridge,https://docs.sint.gg/protocol/layers/bridge,301,true,false,false
https://docs.sint.gg/sintasibridge,https://docs.sint.gg/origin,301,true,false,false
https://docs.sint.gg/presskit,https://docs.sint.gg/press,301,true,false,false
https://docs.sint.gg/tokenomics,https://docs.sint.gg/origin,301,true,false,false
https://docs.sint.gg/tokenomics/*,https://docs.sint.gg/origin,301,true,false,true
https://docs.sint.gg/marketplace,https://docs.sint.gg/origin,301,true,false,false
https://docs.sint.gg/marketplace/*,https://docs.sint.gg/origin,301,true,false,true
https://docs.sint.gg/airdrop,https://docs.sint.gg/origin,301,true,false,false
https://docs.sint.gg/token,https://docs.sint.gg/origin,301,true,false,false
https://docs.sint.gg/asi,https://docs.sint.gg/origin,301,true,false,false
https://docs.sint.gg/agents/trading,https://docs.sint.gg/origin,301,true,false,false
https://docs.sint.gg/agents/defi,https://docs.sint.gg/origin,301,true,false,false
https://docs.sint.gg/agents/social,https://docs.sint.gg/origin,301,true,false,false
```

### Step 2 — Create a Bulk Redirect rule

Cloudflare → your account → **Bulk Redirects** → **Bulk Redirect Rules** → **Create rule**.

- Name: `docs-sint-legacy-301s`
- Expression (auto-generated): uses the list `sint-legacy-docs`
- Enable → Deploy

### Step 3 — Verify

```bash
DOCS_HOST=https://docs.sint.gg ./scripts/verify-redirects.sh
```

**Note on precedence:** If both Mintlify and Cloudflare rules fire, Cloudflare wins (edge before origin). Pick one; keeping both risks drift. Recommended: use Cloudflare for legacy paths (Option 2) **or** Mintlify (Option 1), not both.

---

## Option 3 — Vercel / Netlify / custom origin

**Use when:** `docs.sint.gg` is on Vercel, Netlify, or a custom host that isn't Mintlify and isn't proxied by Cloudflare.

### Vercel (`vercel.json`)

```json
{
  "redirects": [
    { "source": "/introduction",        "destination": "/origin",                  "permanent": true },
    { "source": "/whitepaper",          "destination": "/origin",                  "permanent": true },
    { "source": "/whitepaper/:path*",   "destination": "/origin",                  "permanent": true },
    { "source": "/security",            "destination": "/protocol/security",       "permanent": true },
    { "source": "/mcp-marketplace",     "destination": "/origin",                  "permanent": true },
    { "source": "/sintbridge",          "destination": "/protocol/layers/bridge",  "permanent": true },
    { "source": "/sintasibridge",       "destination": "/origin",                  "permanent": true },
    { "source": "/presskit",            "destination": "/press",                   "permanent": true },
    { "source": "/tokenomics",          "destination": "/origin",                  "permanent": true },
    { "source": "/tokenomics/:path*",   "destination": "/origin",                  "permanent": true },
    { "source": "/marketplace",         "destination": "/origin",                  "permanent": true },
    { "source": "/marketplace/:path*",  "destination": "/origin",                  "permanent": true },
    { "source": "/airdrop",             "destination": "/origin",                  "permanent": true },
    { "source": "/token",               "destination": "/origin",                  "permanent": true },
    { "source": "/asi",                 "destination": "/origin",                  "permanent": true },
    { "source": "/agents/trading",      "destination": "/origin",                  "permanent": true },
    { "source": "/agents/defi",         "destination": "/origin",                  "permanent": true },
    { "source": "/agents/social",       "destination": "/origin",                  "permanent": true }
  ]
}
```

`permanent: true` emits HTTP 308 by default in some Vercel versions; explicitly configure 301 in the project settings if SEO equity matters (it does here).

### Netlify (`_redirects`)

```
/introduction           /origin                       301!
/whitepaper             /origin                       301!
/whitepaper/*           /origin                       301!
/security               /protocol/security            301!
/mcp-marketplace        /origin                       301!
/sintbridge             /protocol/layers/bridge       301!
/sintasibridge          /origin                       301!
/presskit               /press                        301!
/tokenomics             /origin                       301!
/tokenomics/*           /origin                       301!
/marketplace            /origin                       301!
/marketplace/*          /origin                       301!
/airdrop                /origin                       301!
/token                  /origin                       301!
/asi                    /origin                       301!
/agents/trading         /origin                       301!
/agents/defi            /origin                       301!
/agents/social          /origin                       301!
```

The `!` makes the redirect take precedence even if a file exists at that path.

### nginx (custom origin)

```nginx
server {
  listen 443 ssl http2;
  server_name docs.sint.gg;

  location = /introduction     { return 301 /origin; }
  location = /whitepaper       { return 301 /origin; }
  location ~ ^/whitepaper/     { return 301 /origin; }
  location = /security         { return 301 /protocol/security; }
  location = /mcp-marketplace  { return 301 /origin; }
  location = /sintbridge       { return 301 /protocol/layers/bridge; }
  location = /sintasibridge    { return 301 /origin; }
  location = /presskit         { return 301 /press; }
  location = /tokenomics       { return 301 /origin; }
  location ~ ^/tokenomics/     { return 301 /origin; }
  location = /marketplace      { return 301 /origin; }
  location ~ ^/marketplace/    { return 301 /origin; }
  location = /airdrop          { return 301 /origin; }
  location = /token            { return 301 /origin; }
  location = /asi              { return 301 /origin; }
  location = /agents/trading   { return 301 /origin; }
  location = /agents/defi      { return 301 /origin; }
  location = /agents/social    { return 301 /origin; }

  # ... rest of server block
}
```

---

## Post-deploy verification (mandatory, all options)

```bash
./scripts/verify-redirects.sh
```

Expected:

```
  ✓ /introduction  →  /origin  (301)
  ✓ /whitepaper  →  /origin  (301)
  ...
Passed: 19   Missed: 0
```

If any miss: re-check the host-specific config for that path pattern (wildcards are the most common failure mode — Mintlify uses `:slug*`, Vercel uses `:path*`, Netlify uses `*`, nginx uses regex).

---

## Post-deploy — force Google to re-crawl

1. **Google Search Console** → verify `docs.sint.gg` (DNS TXT or HTML file) if not already
2. Submit a new sitemap pointing to the new structure: `https://docs.sint.gg/sitemap.xml` (Mintlify auto-generates)
3. URL Inspection on 3–5 high-traffic legacy URLs → "Test Live URL" → confirm Google sees the 301 → "Request Indexing" (on the *destination* URLs, not the legacy ones)
4. **Removals** → submit the legacy URLs as "old content" requests to speed up SERP cleanup

Typical SERP cleanup window: 2–6 weeks. High-traffic pages move faster.

---

## Recommendation

If this repo is live on Mintlify: **Option 1** is already done via `mint.json`, no further action needed beyond merge to `main` and `./scripts/verify-redirects.sh`.

If `docs.sint.gg` is on a different host and/or Cloudflare is in front: layer **Option 2 (Cloudflare Bulk Redirects)** on top for edge-level redundancy. This survives origin misconfigurations.

For belt-and-suspenders: do both. Cloudflare will fire first; Mintlify's is the fallback if the Cloudflare rule is ever disabled.

# SINT Labs Documentation

Source for **docs.sint.gg** — the technical documentation for SINT Labs (PSHKV Inc.).

Built with [Mintlify](https://mintlify.com/). Deploys on push to `main`.

## What's documented here

- **SINT Protocol** — open-source 5-layer governance standard
- **SINT Operators** — autonomous workflow systems
- **SINT Operator Platform** — Console, Commons, Memory, Cron, Canon, YAML Pipelines
- **SINT Face** — voice-first 3D agent interface
- **Research** — ROSClaw (IROS 2026), MCP Security Analysis
- **Origin** — how SINT got here (the pivot story)

For the company itself, see **[sint.gg](https://sint.gg)**. For the Protocol source, see **[github.com/sint-ai/sint-protocol](https://github.com/sint-ai/sint-protocol)**.

## Local development

```bash
# Prereqs: Node.js >= 18
npm i -g mintlify
mintlify dev      # → http://localhost:3000
```

## Editing

- All content is `.mdx` under page paths matching `mint.json` `navigation`.
- Add a new page: create the `.mdx` file, then add the path to `mint.json`.
- Add a redirect: append to `redirects` in `mint.json`.

## Deployment

`main` auto-deploys via the Mintlify GitHub app. Verify after deploy with:

```bash
./scripts/verify-redirects.sh
./scripts/verify-pages.sh
```

## Contributing

PRs welcome. Two rules:

1. Never reintroduce Web3 / tokenomics / ASI framing. The pivot is permanent. See [`origin.mdx`](origin.mdx) for the canonical story.
2. Anything you ship in docs that doesn't ship in code is a bug. If you write a doc for a feature that doesn't exist, mark it `status="planned"` in the frontmatter.

## License

Documentation content: CC BY 4.0.
Code samples in docs: Apache 2.0.

## Contact

- General: hello@sint.gg
- Security: security@sint.gg
- Founder: illia@sint.gg

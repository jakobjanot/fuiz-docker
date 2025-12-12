# Fuiz self-host notes (GitHub Pages + Docker)

This workspace contains a **deployment wrapper** for Fuiz.

Fuiz is split into 3 components:
- `website` (SvelteKit UI)
- `hosted-server` (Rust game backend; HTTP + WebSocket)
- `corkboard` (Rust media server)

## Key constraint: GitHub Pages is static only
GitHub Pages can only serve static files. It **cannot** run:
- WebSockets (required by `hosted-server`)
- any server-side SvelteKit routes (`+page.server.ts`, `+server.ts`)

So, the realistic combinations are:

### Option A (most common): GitHub Pages for UI + VPS for backends
- Host **UI** on GitHub Pages *if you make the website static*.
- Host **`hosted-server` + `corkboard`** on a VPS (or any Docker-capable host).

Notes:
- The upstream `website` currently uses `@sveltejs/adapter-cloudflare` and has several server routes for stats/library/publish/auth that use Cloudflare D1/KV/R2.
- If you only care about “join game / play / display”, you can usually fork `website` and switch to `@sveltejs/adapter-static` (or SPA mode) and disable the Cloudflare-only features.

### Option B (full-feature self-host): run everything on your own server
- Run `website` as a server (not GitHub Pages), e.g. SvelteKit `adapter-node` behind Caddy/Nginx.
- You’ll still need to **replace or disable** Cloudflare D1/KV/R2 integrations used by auth/library/publish.

### Option C: keep website on a non-Cloudflare platform
- Use a SvelteKit adapter for your target (Vercel/Netlify/Node).
- Still host `hosted-server` + `corkboard` somewhere reachable.

## What this repo gives you
- `scripts/fetch-upstream.sh` to pull the upstream repos into `./upstream/`
- `docker/*.Dockerfile` to build the two Rust services
- `compose.yaml` to run them locally or on a server

## Quick start (local)

```bash
./scripts/fetch-upstream.sh
docker compose up --build
```

Services:
- Game backend: http://localhost:8787 (container listens on 8080)
- Media server: http://localhost:43907 (container listens on 5040)

## Docker images (multi-arch)

The GitHub release workflow builds and pushes GHCR images for:
- `linux/amd64`
- `linux/arm64` (Apple Silicon)

Workflow: `.github/workflows/release-images.yml`.

## Website configuration you must set (wherever it’s hosted)
The `website` expects these build-time public env vars:
- `PUBLIC_BACKEND_URL` (e.g. `https://api.yourdomain.com`)
- `PUBLIC_WS_URL` (e.g. `wss://api.yourdomain.com`)
- `PUBLIC_CORKBOARD_URL` (e.g. `https://corkboard.yourdomain.com`)

## Recommended repo strategy
- **Fork `website`** (very likely), because you’ll need to change adapter/config to run on GitHub Pages (static) or on Node.
- For `hosted-server` and `corkboard`, you *can* avoid forking if you don’t need patches:
  - pin to a commit/tag via your own submodules, or
  - keep using this wrapper repo + `scripts/fetch-upstream.sh`.

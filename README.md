# Fuiz self-host

This workspace contains a **deployment wrapper** for Fuiz.

Fuiz is split into 3 components:
- `website` (SvelteKit UI)
- `hosted-server` (Rust game backend; HTTP + WebSocket)
- `corkboard` (Rust media server)

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

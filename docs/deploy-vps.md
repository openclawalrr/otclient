# VPS deployment

This repo ships the client side, and the VPS stack adds the backend pieces that are not in this repo:

- MariaDB
- Canary game server
- `opentibiabr/login-server`
- nginx serving the browser client

## Build and run

```bash
docker compose -f docker-compose.vps.yml up -d --build
```

Default exposed ports:

- `8090` browser client
- `8088` login webservice
- `7171` login/status
- `7172` game

Override the web port with:

```bash
TIBIAOT_WEB_PORT=8090 docker compose -f docker-compose.vps.yml up -d --build
```

The image serves the Emscripten browser artifacts through nginx with the headers required for cross-origin isolation:

- `Cross-Origin-Opener-Policy: same-origin`
- `Cross-Origin-Embedder-Policy: require-corp`
- `Cross-Origin-Resource-Policy: same-origin`

Those headers are required because the browser build uses pthreads/shared memory.

The browser bundle also ships precompressed `*.gz` artifacts for the large `otclient.js`, `otclient.wasm`, and `otclient.data` files so first load is much faster on slower links.

## Connecting a local client to the VPS API

Yes. The desktop client can point directly at the VPS endpoints by changing the `Services` block in `init.lua` or by creating a site-specific config override.

By default this repo now boots in `vps` mode. If you want to force local endpoints for development, set:

```bash
TIBIAOT_PROFILE=local
```

For example, point these URLs at your VPS domain:

- `Services.updater`
- `Services.status` to the login webservice, for example `http://your-vps:8088/login`
- `Services.websites`
- `Services.createAccount`
- `Services.getCoinsUrl`

If the browser client and API are hosted under the same public origin, the browser build is simpler because it avoids CORS issues. If they are on different domains, your API must allow the browser origin explicitly.

You can also override the VPS base URL without editing Lua:

```bash
TIBIAOT_VPS_BASE_URL=http://your-domain-or-ip:8090
```

## What this compose does not include

The repo does not implement the backend API itself. The compose file wires external backend images together with the web client and the database, but the world, account, and store configuration still need to be set up for your game.

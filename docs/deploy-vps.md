# VPS deployment

This repo ships the client side, and the VPS stack adds the backend pieces that are not in this repo:

- MariaDB
- Canary game server
- `opentibiabr/login-server`
- MyAAC account service for `clientcreateaccount.php`
- nginx serving the browser client

## Build and run

```bash
docker compose -f docker-compose.vps.yml up -d --build
```

Default exposed ports:

- `8090` browser client
- `8088` login webservice
- `8089` account creation webservice
- `7171` login/status
- `7172` game

Override the web port with:

```bash
TIBIAOT_WEB_PORT=8090 docker compose -f docker-compose.vps.yml up -d --build
```

Override the account service port with:

```bash
MYAAC_HTTP_PORT=8089 docker compose -f docker-compose.vps.yml up -d --build
```

The image serves the Emscripten browser artifacts through nginx with the headers required for cross-origin isolation:

- `Cross-Origin-Opener-Policy: same-origin`
- `Cross-Origin-Embedder-Policy: require-corp`
- `Cross-Origin-Resource-Policy: same-origin`

Those headers are required because the browser build uses pthreads/shared memory.

The browser bundle also ships precompressed `*.gz` artifacts for the large `otclient.js`, `otclient.wasm`, and `otclient.data` files so first load is much faster on slower links.

The browser bundle lives on `8090`, the login API stays on `8088`, and the MyAAC account service lives on `8089`.

- `Services.status` resolves against `TIBIAOT_API_BASE_URL` and points to `login.php` on `8088`
- `Services.websites` and `Services.createAccount` resolve against `TIBIAOT_ACCOUNT_BASE_URL` and point to MyAAC on `8089`
- `Services.getCoinsUrl` also uses the account base so the top menu and shop links land on the same site

The MyAAC container bootstraps its own schema into the shared `canary` database on first start, so you do not need to run the MyAAC installer manually on the VPS.

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

You can also override the VPS API base URL without editing Lua:

```bash
TIBIAOT_API_BASE_URL=http://your-domain-or-ip:8088
```

And the MyAAC/account base separately:

```bash
TIBIAOT_ACCOUNT_BASE_URL=http://your-domain-or-ip:8089
```

## What this compose does not include

The repo does not implement the game backend itself. The compose file wires external backend images together with the web client, MyAAC, and the database, but the world and account configuration still need to be set up for your game.

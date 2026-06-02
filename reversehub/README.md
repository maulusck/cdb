# reversehub

A tiny, config-driven nginx reverse proxy. Define your backends in
`services.json`; reversehub generates the nginx config on startup and serves a
minimal dashboard listing every route.

Two proxy modes per service:

- **path** — proxied under a subpath of the hub (`hub.lan/grafana/`).
- **host** — proxied at its own hostname, root path untouched
  (`jellyfin.lan`). Use this for apps that refuse to live under a subpath.

## Build

```sh
podman build -t reversehub .
```

## Run

The `rh` script does kill + build + start in one step:

```sh
./rh           # rootless, binds 0.0.0.0:8080
sudo ./rh 80   # rootful, binds 0.0.0.0:80
```

Or run it manually:

```sh
podman run -d --name reversehub --rm \
    --network host \
    -e RH_PORT=8080 \
    -v "$PWD/services.json":/usr/share/nginx/html/services.json:ro \
    reversehub
```

`--network host` is required so the proxy can reach backends on the host's own
`127.0.0.1` / LAN addresses.

## Configuration

### RH_PORT

Listen port. Default `8080`. Set at run time with `-e RH_PORT=...` (or as the
first arg to `./rh`). Use `80`/`443` only in rootful mode.

### services.json

Bind-mounted read-only into the container. Edit it, then restart the container
to apply (`./rh` or `podman restart reversehub`) — the config regenerates on
every startup.

Each entry:

| field           | mode        | description                                   |
|-----------------|-------------|-----------------------------------------------|
| `name`          | both        | display name                                  |
| `description`   | both        | optional blurb                                |
| `mode`          | both        | `path` (default) or `host`                    |
| `upstream`      | both        | backend `host:port`                           |
| `upstream_path` | both        | path on the backend (default `/`)             |
| `proxy_path`    | path        | subpath served by the hub                     |
| `domain`        | host        | hostname (`server_name`) to match             |

Example:

```json
[
  {
    "name": "Grafana",
    "mode": "path",
    "upstream": "10.0.0.5:3000",
    "upstream_path": "/grafana/",
    "proxy_path": "/grafana/"
  },
  {
    "name": "Jellyfin",
    "mode": "host",
    "domain": "jellyfin.myserver.lan",
    "upstream": "127.0.0.1:8096",
    "upstream_path": "/"
  }
]
```

For **host** mode, point the hostname at the box (DNS or `/etc/hosts`). The hub
itself is the default server and answers any unmatched hostname.

## Files

| file             | role                                            |
|------------------|-------------------------------------------------|
| `Containerfile`  | Alpine + nginx + jq image                       |
| `entrypoint.sh`  | generates proxy config, launches nginx          |
| `nginx.conf`     | base config; includes generated blocks          |
| `services.json`  | your service definitions                         |
| `index.html`     | dashboard                                        |
| `rh`             | build + run helper                              |

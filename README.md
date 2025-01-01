# ExtCloud (Extensible Cloud)

A scalable and easy-to-deploy self-hosting cloud service architecture template.
I use this template for the current version of the cloud stack that powers my digital life.

Features:
- **modularity** - each service is strictly separated from the rest of the stack
- **scalability** - services can be added/removed quickly without changes to the rest of the stack
- **maintainability** - structured files allow for easy maintenance

What do I use it for?
- [Nextcloud](https://nextcloud.com/) ([`nextcloud/`](./nextcloud/)) - Cloud - file sync, collab, calendar, contacts, and much much more
- [Jellyfin](https://jellyfin.org/) ([`jellyfin/`](./jellyfin/)) - Stream my music, shows, and downloads from any device
- [Searxng](https://github.com/searxng/searxng) metasearch engine ([`searxng/`](./searxng/)) that I use all the time
- [Huginn](https://github.com/huginn/huginn) ([`huginn/`](./huginn/)) - Agents that monitor and act on my behalf, e.g., daily email digests, notifications, and more
- Password manager vault ([`vault/`](./vault/))
- Personal [Overleaf](https://www.overleaf.com/) server ([`overleaf/`](./overleaf/)) with no limitations and some enterprise features available
- Personal [matrix](https://matrix.org/) server ([`matrix/`](./matrix/))
- Personal mailserver used by other services to send emails ([`mail/`](./mail/))
- Anonymous file sharing via [PrivateBin](https://privatebin.info/) ([`privatebin/`](./privatebin)) and [Send](https://github.com/timvisee/send) ([`send/`](./send))
- RSS feed bridges ([`rss/`](./rss))
- *and much more* :)

It took me a while to make these things work, and I think sharing what I found could be helpful to people wanting to give selfhosting a go.
I included many sample configurations for popular services in this repository, so feel free to browse around!
Please make sure to **read** and **modify** the files before using them, as you might need to edit them to suit your needs.

## Orchestration

Control of the stack is meant to be performed using the [ctl](./ctl) script.
It will synthesize all the relevant configuration and run docker-compose commands for you.
With it, you can command separate or multiple services as follows:
```bash
$ ./ctl up -d searxng
```
Shortcut scripts are also available for common actions:
```bash
$ ./ctl-up searxng
```

## Architecture

The core of the architecture is a modular docker-compose and reverse-proxy configuration file structure.
It consists of a shared root configuration, a reverse-proxy configuration, and service configurations.
The service stack configuration is then synthesized using `ctl` scripts, which generate a global reverse-proxy config and operate on the service stack.

Shared configuration goes into the root directory, under [root.env](./root.env):
```bash
# Shared env variables for all services
export DOMAIN=my.domain.com
export TZ=Europe/Berlin
# ...
```

Reverse proxy (using [Caddy](https://caddyserver.com/)) configuration is defined in a directory ([caddy](./caddy/)), with the following structure:
```
.
├── caddy.env
├── Caddyfile
├── caddy.yml
├── certs       // generated
├── config      // generated
├── data        // generated
└── sites       // generated
```

Each service is then contained in a folder with the following structure:
```
.
├── data/           // service data volume, usually a bind-mount
├── Caddyfile       // reverse proxy configuration
├── proxy.env       // additional environment variables for the reverse proxy configuration
├── service.env     // service configuration
└── service.yml     // service docker-compose file
```

### Depeding on other services (e.g. VPN or mailserver)

A neat feature of this architecture is that you can easily depend on other services in the stack without changing their configuration!
An example for [https://github.com/qdm12/gluetun](https://github.com/qdm12/gluetun)] is included in this repository, check out [gluetun/](./gluetun) and [qbittorrent/](./qbittorrent) configurations for a concrete example.

- `qbittorrent.yml`
```bash
services:

  # Extensions to the gluetun service configuration
  gluetun:
    ports:
      - $TORRENT_WEBUI_PORT:$TORRENT_WEBUI_PORT
      - 6881:6881
      - 6881:6881/udp

  # Actual qbittorrent configuration
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    restart: unless-stopped
    network_mode: "service:gluetun"         # Uses gluetun
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=$TZ
      - WEBUI_PORT=$TORRENT_WEBUI_PORT
    volumes:
      - ./qbittorrent/data:/config
      - $TORRENT_DIR:/downloads
    depends_on:
      caddy:
        condition: service_started
      gluetun:
        condition: service_healthy
```

### Redirects

See [website](./website) for a simple redirect example that redirects `https://mydomain.com` to `https://web.mydomain.com`.


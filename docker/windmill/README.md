# Windmill Docker Compose

This directory contains separate Compose stacks for a Windmill master and remote workers.

## Host directories

Create these directories on the master:

```sh
sudo mkdir -p /srv/db /srv/data/windmill /srv/data/caddy /srv/config
```

Copy `Caddyfile` to `/srv/config/Caddyfile`, and copy `master.env.example` to `master.env`:

```sh
sudo install -d -m 0755 /srv/db /srv/data /srv/config
sudo install -m 0644 Caddyfile /srv/config/Caddyfile
cp master.env.example master.env
```

Set a strong `POSTGRES_PASSWORD` in `master.env`, then start the master stack:

```sh
cp master.env.example master.env
docker compose --env-file master.env -f docker-compose.master.yml up -d
```

The master PostgreSQL listener is published on port `5432`, which is required for remote workers. Restrict this port in the host firewall or reverse this setup to a private Docker/network database endpoint.

## Workers

On every worker machine, create `/srv/data` and `/srv/config`:

```sh
sudo mkdir -p /srv/data/windmill /srv/config
cp worker.env.example worker.env
```

Set `DATABASE_URL` in `worker.env` to the master machine's reachable address, using the same PostgreSQL username and password from `master.env`. Start the worker stack:

```sh
docker compose --env-file worker.env -f docker-compose.worker.yml up -d
```

Workers do not mount `/srv/db`; they connect to PostgreSQL over the network.

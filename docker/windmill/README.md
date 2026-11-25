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

## Docker-test worker

A separate Docker-test worker provides Docker access to a dedicated worker pool without mounting the worker host's Docker socket or publishing Docker TCP on the Proxmox network.

Create the worker directories and copy the environment file:

```sh
sudo mkdir -p /srv/data/windmill/docker-cache /srv/data/windmill/docker-logs /srv/config
cp docker-worker.env.example docker-worker.env
```

Set `DATABASE_URL` in `docker-worker.env`, then start the stack:

```sh
docker compose --env-file docker-worker.env -f docker-compose.worker-docker.yml up -d
```

The stack creates an isolated Docker daemon in a privileged DIND sidecar. Its Docker API is available only on the `docker-control` Compose network, and is not published to the host or Proxmox network. The worker has two networks: `docker-control` for Docker API traffic and `docker-egress` for PostgreSQL and any required worker egress. The DIND daemon also needs `docker-egress` to pull images.

The DIND data volume is isolated by Compose and is retained across restarts:

- `docker-test-daemon-data` stores DIND image and container state.
- `/srv/data/windmill/docker-cache` stores Windmill's dependency cache.
- `/srv/data/windmill/docker-logs` stores Windmill's logs.

The worker joins the `docker-test` worker group and listens to the `docker-test` tag by default. Assign that tag to Docker-testing scripts or flow steps in Windmill. Override `DOCKER_WORKER_GROUP` and `DOCKER_WORKER_TAGS` in `docker-worker.env` if required.

The DIND daemon is a trusted execution boundary with root-equivalent daemon access. Run Docker-test scripts only on this worker and only allow trusted users to create or edit them. Published test-container ports are reachable from the worker through `docker-test-daemon:<published-port>` while the container is running.

A Bash script can start and clean up a test container with:

```bash
CID=$(docker run -d --pull=missing --name "wm-test-$$" "$IMAGE")
trap 'docker rm -f "$CID" >/dev/null 2>&1 || true' EXIT

# Publish a port explicitly for testing:
CID=$(docker run -d --pull=missing --name "wm-test-$$" -p 0:8080 "$IMAGE")
PORT=$(docker port "$CID" 8080/tcp | head -n1 | sed 's/.*://')
curl --fail --retry 30 --retry-delay 1 "http://docker-test-daemon:$PORT/health"
```

Always set test-container memory, CPU, PID, and elapsed-time limits appropriate to the workload, and clean up containers in an `EXIT` trap.

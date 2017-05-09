# Lowcal

**A lightweight toolkit for local development with Docker**

_Lowcal_ is essentially a wrapper around a set of `docker-compose`
configurations that make it easy to up a local/offline development
environment for Docker. It's an ideal choice for those that don't wish
to run a full container management or orchestration platform on their
workstation.

## Core Services

* **[Dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html)** enables
  DNS lookups for the `lowcal.dev` and your own custom domain.
* **[Consul](https://consul.io)** is used for service discovery. When
  you register a service via the
  **[Consul Agent HTTP API](https://www.consul.io/api/agent.html)**, it
  will automatically get picked up by `traefik`.
* **[Traefik](https://traefik.io)** is a reverse proxy (and load
  balancer). It "listens" to Docker and Consul, automatically updating
  its configuration when you start a new Docker container, or register a
  service with the Consul Agent.
* **[cAdvisor](https://github.com/google/cadvisor)** provides a web UI
  for analyzing the resource usage and performance characteristics of
  running containers.

## Requirements

* Bash
* Make
* Docker
* Docker Compose

## Usage

**Make sure you don't have any other containers exposing or local
services running on ports 80 or 443.**

### Traefik Port Overrides (optional)

If you must run _Traefik_ on different ports, export the following
environment variables with the ports of your choice:

```bash
export TRAEFIK_HTTP_PORT=8880
export TRAEFIK_HTTPS_PORT=8843
```

### Installation

1. Clone this repository
2. Run `cd lowcal && make install`
   * On OS X, you'll be asked for your password

### Help

* `make help`
* `./lowcal help`

### Web UIs

* **Consul:** http://consul.lowcal.dev
* **Traefik:** http://traefik.lowcal.dev
* **cAdvisor:** http://cadvisor.lowcal.dev

### Configuration

#### Custom Domain

_TODO_

##### HTTPS with Let's Encrypt

Example configuration:

```bash
export TRAEFIK_ACME=true
#export TRAEFIK_ACME_STAGING=true
export TRAEFIK_ACME_LOGGING=true
export TRAEFIK_ACME_DNSPROVIDER=route53
export TRAEFIK_ACME_EMAIL=you@example.com
export TRAEFIK_ACME_ONDEMAND=false
export TRAEFIK_ACME_ONHOSTRULE=true

export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXX
export AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXX
export AWS_REGION=us-east-1
```

#### Docker Compose Projects

If your project uses `docker-compose`, here's an example
`docker-compose.yml`:

```yaml
version: '2'
services:
  app:
    build: .
    environment:
      - TERM=xterm
    labels:
      - "traefik.backend=app"
      - "traefik.port=9000"
      - "traefik.frontend.rule=Host:app.example.com"
      - "traefik.frontend.entryPoints=http" # add ',https' for HTTPS support
      - "traefik.docker.network=lowcal"
      - "traefik.tags=lowcal"
    ports:
      - "9000:9000"
    volumes:
      - .:/app

networks:
  default:
    external:
      name: lowcal
```

1. You'll need to specify all the `traefik.*` labels for your web
   service, customizing the `backend`, `port`, and `frontend` labels
   accordingly.
2. Then copy/paste the `networks` block to the bottom of your
   `docker-compose.yml`.

### Removal

* Run `make clean`
  * On OS X, you'll be asked for your password

## Optional Services

* Run `./lowcal services:list` to get a list of the included optional
  services.
* Run `./lowcal (service):help` to get help for a particular service.

## TODO

* Finish support for custom domain
* Add ssh-agent (https://github.com/whilp/ssh-agent)
* Support HTTPS with static certificates

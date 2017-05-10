# Lowcal

**A lightweight toolkit for local development with
[Docker](https://www.docker.com/)**

_Lowcal_ is essentially a wrapper around a set of
[Docker Compose](https://docs.docker.com/compose/) configurations that
make it easy to run a local/offline development environment for Docker.
It's an ideal choice for those that don't wish to run a full container
management or orchestration platform on their workstation. _Lowcal_ has
been tested with [Docker for Mac](https://www.docker.com/docker-mac) and
[Docker Toolbox](https://www.docker.com/products/docker-toolbox) on
MacOS, though due to
[I/O performance issues with Docker for Mac](https://docs.docker.com/docker-for-mac/osxfs/#performance-issues-solutions-and-roadmap),
you may find the best experience using Docker Machine with [Parallels
Desktop Pro/Business](http://www.parallels.com/products/desktop/) and
the
[corresponding Docker Machine driver](https://github.com/Parallels/docker-machine-parallels).

## Pro Tip

This is a tool for convenience, and it should not be used to substitute
knowledge of how to use Docker or `docker-compose`.

## Requirements

* Bash (`bash`)
* Make (`make`)
* Docker (`docker`)
* Docker Compose (`docker-compose`)

## Core Services

_Lowcal_ provides the following core services that are essential to its
operation:

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
   * On MacOS, you'll be asked for your password

### Help

* `make help`
* `./lowcal help`

### Web UIs

* **Consul:** http://consul.lowcal.dev
* **Traefik:** http://traefik.lowcal.dev
* **cAdvisor:** http://cadvisor.lowcal.dev

### Configuration

#### Environment Variables

_Lowcal_ uses environment variables exclusively for all configuration
parameters, many of which are passed directly to the underlying
containers.

For details, explore the [`docker-compose.yml`](docker-compose.yml) at
the root of this repository, and the `.yml` files for each included
service in `services/*`.

#### Custom Domain

You can configure _Lowcal_ to use your own domain:

```bash
export CUSTOM_DOMAIN="example.com"
```

##### HTTPS with Let's Encrypt (Internet connection required)

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

Refer to
[Traefik's documentation](https://docs.traefik.io/toml/#acme-lets-encrypt-configuration)
for more information.

##### HTTPS with static (or self-signed) certificates

_TODO_

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
  * On MacOS, you'll be asked for your password

## Supporting Services

For your convenience, _Lowcal_ includes a handful of `docker-compose`
configurations for commonly used databases, DevOps tools, etc:

* MySQL
* [LocalStack](https://bitbucket.org/atlassian/localstack) (Local AWS
  cloud stack)

### Controlling services

* Run `./lowcal services:list` to get a list of the included services.
* Run `./lowcal (service):help` to get help for a particular service.


## TODO

* Support HTTPS with static certificates
* Add Services:
  * ssh-agent (https://github.com/whilp/ssh-agent)
  * Couchbase + provisioner
  * MailHog
  * ELK Stack
  * Postgres
* Consul + Traefik tips

## Contributing

PRs are welcome 🙂
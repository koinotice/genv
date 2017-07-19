# Configuration

## Environment Variables

_Harpoon_ uses environment variables exclusively for all configuration
parameters, many of which are passed directly to the underlying
containers.

For details, explore the
[`docker-compose.yml`](../../docker-compose.yml) at the root of this
repository, and the `.yml` files for each included service in
`services/*`.

## `harpoon.env.sh`

Harpoon will look for and `source` files named `harpoon.env.sh` in the
following directories:

* The directory where Harpoon is located (`$HARPOON_ROOT`)
* `/etc`
* `$PWD`
* `$HOME`

## Custom Domains

_Harpoon_ uses `harpoon.dev` as its default domain. You can configure your own domains with the `CUSTOM_DOMAINS` array:

```bash
CUSTOM_DOMAINS[0]=example.com
CUSTOM_DOMAINS[1]=example.net
export CUSTOM_DOMAINS
```

If you would like to use HTTPS, you may choose _one_ of the following
options:

### HTTPS with Let's Encrypt

_Internet connection required_

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

### HTTPS with Static (or self-signed) Certificates

_Works offline_

For each of your custom domains, copy the certificate (`.crt`) and key (`.key`) files to
`core/traefik/certs`. The filenames should be based on the domain name, for example:

* `example.com.crt`
* `example.com.key`


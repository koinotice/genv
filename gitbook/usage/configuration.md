# Configuration

## Environment Variables

_Harpoon_ uses environment variables exclusively for all configuration
parameters, many of which are passed directly to the underlying
containers.

For details, explore the [`docker-compose.yml`](../../docker-compose.yml) at
the root of this repository, and the `.yml` files for each included
service in `services/*`.

## Custom Domain

You can configure _Harpoon_ to use your own domain:

```bash
export CUSTOM_DOMAIN="example.com"
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

1. Copy your certificate and key files to `core/traefik/certs`.
2. Set the following environment variables, replacing the values with
   the appropriate file names:

   ```bash
   export TRAEFIK_TLS_CERTFILE=example.crt
   export TRAEFIK_TLS_KEYFILE=example.key
   ```
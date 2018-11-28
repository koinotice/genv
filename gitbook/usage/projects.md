# Projects

## Temp Directory

_Genv_ will create a directory named `.genv` in your current
working directory. You should add this to your `.gitignore`.

## Docker Compose

If your project uses `docker-compose`, here's an example
`docker-compose.yml`:

```yaml
version: '3.4'
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
      - "traefik.docker.network=genv"
      - "traefik.tags=genv"
    ports:
      - "9000:9000"
    volumes:
      - .:/app

networks:
  default:
    external:
      name: genv
```

1. You'll need to specify all the `traefik.*` labels for your web
   service, customizing the `backend`, `port`, and `frontend` labels
   accordingly.
2. Then copy/paste the `networks` block to the bottom of your
   `docker-compose.yml`.

## Tasks

_Genv_ provides a simple task running engine, which you can customize
for your project. In the root of your project, just add a `tasks.sh`
like the following:

```bash
#!/usr/bin/env bash

welcome() {
    printf " Welcome to Macintosh."
}

case "$command" in
    welcome) ## <args...> %% Welcomes you
        welcome ;;
    *)
        genv help ;;
esac
```

This is just like any other `bash` script, so you have full access to
your shell.

Custom environment variables, especially those that you're overriding
from Genv's defaults, should go in your project root in
[`genv.env.sh` or `genv.boot.sh`](configuration.md).

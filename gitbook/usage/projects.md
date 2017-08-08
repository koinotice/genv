# Projects

## Temp Directory

_Harpoon_ will create a directory named `.harpoon` in your current
working directory. You should add this to your `.gitignore`.

## Docker Compose

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
      - "traefik.docker.network=harpoon"
      - "traefik.tags=harpoon"
    ports:
      - "9000:9000"
    volumes:
      - .:/app

networks:
  default:
    external:
      name: harpoon
```

1. You'll need to specify all the `traefik.*` labels for your web
   service, customizing the `backend`, `port`, and `frontend` labels
   accordingly.
2. Then copy/paste the `networks` block to the bottom of your
   `docker-compose.yml`.

## Tasks

_Harpoon_ provides a simple task running engine, which you can customize
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
        harpoon help ;;
esac
```

This is just like any other `bash` script, so you have full access to
your shell.

Custom environment variables, especially those that you're overriding
from Harpoon's defaults, should go in your project root in
[`harpoon.env.sh` or `harpoon.boot.sh`](configuration.md).

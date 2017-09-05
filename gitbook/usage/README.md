# Usage

**Make sure you don't have any other containers exposing or local
services running on ports 80 or 443.**

## Traefik Port Overrides (optional)

If you must run _Traefik_ on different ports, export the following
environment variables with the ports of your choice:

```bash
export TRAEFIK_HTTP_PORT=8880
export TRAEFIK_HTTPS_PORT=8843
```

## Installation

1. curl
   https://raw.githubusercontent.com/wheniwork/harpoon/master/install.sh
   | bash
2. _Optional:_ Load completion scripts by adding `which harpoon >
   /dev/null && . "$(harpoon initpath)"` to your profile (`~/.bashrc`,
   `~/.bash_profile`, `~/.zshrc`).

## Help

* `harpoon help [<task> | <service>]`

## Web UIs

* **Consul:** http://consul.harpoon.dev
* **Traefik:** http://traefik.harpoon.dev

## Removal

* Run `harpoon clean`
  * On MacOS, you'll be asked for your password


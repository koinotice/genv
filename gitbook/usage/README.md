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

1. Clone this repository
2. Run `cd harpoon && make install`
   * On MacOS, you'll be asked for your password
3. Optional: add `harpoon` to your `$PATH`. Edit your `.bash_profile`,
   `.bashrc`, or `.zshrc` accordingly.
4. _Optional:_ Load completion scripts by adding `which harpoon > /dev/null && . "$(harpoon initpath)"` to your profile.

## Help

* `./harpoon help`
* (`make help`)

## Web UIs

* **Consul:** http://consul.harpoon.dev
* **Traefik:** http://traefik.harpoon.dev
* **cAdvisor:** http://cadvisor.harpoon.dev

## Removal

* Run `make clean`
  * On MacOS, you'll be asked for your password


# Harpoon

**A lightweight toolkit for local development with
[Docker](https://www.docker.com/)**

_Harpoon_ is essentially a wrapper around a set of
[Docker Compose](https://docs.docker.com/compose/) configurations that
make it easy to run a local/offline development environment for Docker.
It's an ideal choice for those that don't wish to run a full container
management or orchestration platform on their workstation. _Harpoon_ has
been tested with [Docker for Mac](https://www.docker.com/docker-mac) and
[Docker Toolbox](https://www.docker.com/products/docker-toolbox) on
MacOS.

## Quick Start

1. Clone this repository
2. Run `cd harpoon && make install`
   * On MacOS, you'll be asked for your password
3. _Optional:_ add `harpoon` to your `$PATH`.

## [Documentation](https://wheniwork.github.io/harpoon/)

## TODO

* Consul + Traefik tips
* Test with Linux

## Contributing

* If you experience an issue and are relatively certain that `harpoon` is
  the culprit, please report it.
  * Issues requesting support specifically for any of the core or
    supporting services will not be processed.
* PRs are welcome 🙂

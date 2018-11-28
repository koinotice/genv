# <a href='http://koinotice.github.io/genv'><img src='https://cloud.githubusercontent.com/assets/202546/26421606/407b9eb8-408c-11e7-8fc4-9ed0c61afcc7.png' height='75'></a>


**A lightweight toolkit for local development with
[Docker](https://www.docker.com/)**

[![Build Status](https://travis-ci.org/koinotice/genv.svg?branch=master)](https://travis-ci.org/koinotice/genv)
[![Coverage Status](https://coveralls.io/repos/github/koinotice/genv/badge.svg?branch=master)](https://coveralls.io/github/koinotice/genv?branch=master)
[![codecov](https://codecov.io/gh/koinotice/genv/branch/master/graph/badge.svg)](https://codecov.io/gh/koinotice/genv)

_Genv_ makes it easy to run a local/offline development environment
composed of Docker containers. It's an ideal choice for those that don't
wish to run a full container management or orchestration platform on
their workstation.

At its core, _Genv_ is a set of `bash` scripts that provide an
interface for running project-related tasks. _Genv_ includes a
collection of common services, which are essentially wrappers around
[Docker Compose](https://docs.docker.com/compose/) configurations. All
Genv services are designed to work together on a Docker network
(named `genv` by default), with web-based services registering
automatically with a proxy server (Traefik). The use of `dnsmasq`
enables accessing services "externally" via one or more domains
(`.genv` by default). Internal name resolution and service discovery
(`.service.int.genv`) is supported with Consul and Registrator, as
well as Docker's own internal DNS server.

_Genv_ has been tested with:
* [Docker for Mac](https://www.docker.com/docker-mac)
* [Docker Toolbox](https://www.docker.com/products/docker-toolbox) on
  MacOS
* Ubuntu Desktop 16.04

## Requirements

* Bash 4 (`bash`) or ZSH (`zsh`)
  * macOS users should upgrade bash with [Homebrew](https://brew.sh/): `brew install bash`
* Docker (`docker`)
* Docker Compose (`docker-compose`)

## Quick Start

1. curl
   https://raw.githubusercontent.com/koinotice/genv/master/install.sh
   | bash
2. _Optional:_ Load completion scripts by adding `which genv >
   /dev/null && . "$(genv initpath)"` to your profile (`~/.bashrc`,
   `~/.bash_profile`, `~/.zshrc`).

## [Documentation](https://koinotice.github.io/genv/)

## TODO

* Consul + Traefik tips
* Documentation
  * Plugins
  * Bundled tasks

## Contributing

* If you experience an issue and are relatively certain that `genv`
  is the culprit, please report it.
  * Issues requesting support specifically for any of the core or
    supporting services will not be processed.
* PRs are welcome 🙂

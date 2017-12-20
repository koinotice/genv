# <a href='http://wheniwork.github.io/harpoon'><img src='https://cloud.githubusercontent.com/assets/202546/26421606/407b9eb8-408c-11e7-8fc4-9ed0c61afcc7.png' height='75'></a>


**A lightweight toolkit for local development with
[Docker](https://www.docker.com/)**

[![Build Status](https://travis-ci.org/wheniwork/harpoon.svg?branch=master)](https://travis-ci.org/wheniwork/harpoon)
[![Coverage Status](https://coveralls.io/repos/github/wheniwork/harpoon/badge.svg?branch=master)](https://coveralls.io/github/wheniwork/harpoon?branch=master)
[![codecov](https://codecov.io/gh/wheniwork/harpoon/branch/master/graph/badge.svg)](https://codecov.io/gh/wheniwork/harpoon)

_Harpoon_ makes it easy to run a local/offline development environment
composed of Docker containers. It's an ideal choice for those that don't
wish to run a full container management or orchestration platform on
their workstation.

At its core, _Harpoon_ is a set of `bash` scripts that provide an
interface for running project-related tasks. _Harpoon_ includes a
collection of common services, which are essentially wrappers around
[Docker Compose](https://docs.docker.com/compose/) configurations. All
Harpoon services are designed to work together on a Docker network
(named `harpoon` by default), with web-based services registering
automatically with a proxy server (Traefik). The use of `dnsmasq`
enables accessing services via one or more domains (`harpoon.dev` by
default).

_Harpoon_ has been tested with:
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
   https://raw.githubusercontent.com/wheniwork/harpoon/master/install.sh
   | bash
2. _Optional:_ Load completion scripts by adding `which harpoon >
   /dev/null && . "$(harpoon initpath)"` to your profile (`~/.bashrc`,
   `~/.bash_profile`, `~/.zshrc`).

## [Documentation](https://wheniwork.github.io/harpoon/)

## TODO

* Consul + Traefik tips
* Documentation
  * Plugins
  * Bundled tasks

## Contributing

* If you experience an issue and are relatively certain that `harpoon`
  is the culprit, please report it.
  * Issues requesting support specifically for any of the core or
    supporting services will not be processed.
* PRs are welcome 🙂

# Harpoon Changes

## 01/01/2018

* Removed `harpoon.dev` domain, now defaulting to `.harpoon` for
  external ingress traffic.
* Added [Registrator](http://gliderlabs.github.io/registrator) and
  integrated with Consul
* Reconfigured Consul to support service discovery and internal ingress
  traffic via the `service.int.harpoon` domain.
* Added static route from local OS to Docker host, enabling direct
  access to containers at their IP addresses.
* Upgraded images
  * Traefik 1.4.x
  * Consul 1.0.2
* Updating docker-compose configurations to version 3.4.

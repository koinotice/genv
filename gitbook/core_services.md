# Core Services

_Genv_ provides the following core services that are essential to its
operation:

* **[Dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html)** enables
  DNS lookups for `.genv` and your own custom domain.
* **[Consul](https://consul.io)** is used for service discovery. When
  you register a service via the
  **[Consul Agent HTTP API](https://www.consul.io/api/agent.html)**, it
  will automatically get picked up by `traefik`.
* **[Traefik](https://traefik.io)** is a reverse proxy (and load
  balancer). It "listens" to Docker and Consul, automatically updating
  its configuration when you start a new Docker container, or register a
  service with the Consul Agent.
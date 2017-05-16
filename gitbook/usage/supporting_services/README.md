# Supporting Services

For your convenience, _Harpoon_ includes a handful of `docker-compose`
configurations for commonly used databases, DevOps tools, etc:

## [Couchbase](https://hub.docker.com/_/couchbase/)

**Environment Variables (with defaults):**

```bash
export COUCHBASE_VERSION="latest"
```

### Admin Web UI

* **URL:** http://couchbase.harpoon.dev
* **Username:** Administrator
* **Password:** abc123

## [LocalStack](https://bitbucket.org/atlassian/localstack)

Local AWS cloud stack

## [MySQL](https://hub.docker.com/_/mysql/)

**Environment Variables (with defaults):**

```bash
export MYSQL_VERSION=5
export MYSQL_ROOT_PASSWORD="abc123"
export MYSQL_DATABASE="harpoon"
export MYSQL_PORT=3306 # exposed to Docker host
```

## [ssh-agent](https://github.com/whilp/ssh-agent)

1. Run: `./harpoon ssh-agent:up`
2. Add your key: `./harpoon ssh-agent:add <filename>`, where `<filename>` is located in `~/.ssh/`.

# Service Management

* Run `./harpoon services:list` to get a list of the included services.
* Run `./harpoon (service):help` to get help for a particular service.


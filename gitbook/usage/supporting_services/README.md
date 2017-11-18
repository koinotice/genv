# Supporting Services

For your convenience, _Harpoon_ includes a handful of `docker-compose`
configurations for commonly used databases, DevOps tools, etc:

## [Beanstalk Console](https://github.com/ptrofimov/beanstalk_console)

* **Web UI:** http://beanstalk-console.harpoon.dev

## [Blackfire](https://blackfire.io/)

PHP profiler

## [cAdvisor](https://github.com/google/cadvisor)

Provides a web UI for analyzing the resource usage and performance
characteristics of running containers.

* **Web UI:** http://cadvisor.harpoon.dev

## [Couchbase](https://hub.docker.com/_/couchbase/)

**Environment Variables (with defaults):**

```bash
export COUCHBASE_VERSION="latest"
```

### Admin Web UI

* **URL:** http://couchbase.harpoon.dev
* **Username:** Administrator
* **Password:** abc123

## [DynamoDB Admin](https://github.com/wheniwork/dynamodb-admin)

* **Web UI:** http://ddbadmin.harpoon.dev

## [Elastic (ELK) Stack](https://www.elastic.co)

### Elasticsearch

* **URL:** http://es.harpoon.dev

### Logstash

* **URL:** http://ls.harpoon.dev

#### Input
* **TCP**
  * **Port:** `12345`
  * **Codec:** `json`
* **UDP**
  * **Port:** `12345`
  * **Codec:** `json`

#### Output
* **Elasticsearch**

### Kibana

* **Web UI:** http://kibana.harpoon.dev


## [LaunchDarkly Relay Proxy](https://github.com/launchdarkly/ld-relay)

**Docker Image:** https://hub.docker.com/r/wheniwork/ld-relay/

**API:** http://ldrelay.harpoon.dev

**Environment Variables:**

* `LD_RELAY_REDIS_HOST`: Default is `harpoon_redis`.
* `LD_RELAY_REDIS_PORT`: Default is `6379`.
* `LD_RELAY_PORT`: The HTTP port of the service as published to the
  Docker host. Default is `8030`.
* `LD_ENV_dev`: The value should be the api key for the desired
  environment.
* `LD_PREFIX_dev`: This variable is optional. Configures a Redis prefix
  for the desired environment.
* `USE_REDIS`: This variable is optional. If set to `1`, Redis
  configuration will be added.
* `REDIS_HOST`: This variable is optional. Sets the hostname of the
  Redis server. The default value is `harpoon_redis`.
* `REDIS_PORT`: This variable is optional. Sets the port of the Redis
  server. The default value is `6379`.
* `REDIS_TTL`: This variable is optional. Sets the TTL in milliseconds,
  defaults to `30000`.
* `USE_EVENTS`: This variable is optional. If set to `1`, enables event
  buffering.
* `EVENTS_HOST`: This variable is optional. URI of the LaunchDarkly
  events endpoint, defaults to `https://events.launchdarkly.com`.
* `EVENTS_SEND`: This variable is optional. Defaults to `true`.
* `EVENTS_FLUSH_INTERVAL`: This variable is optional. Sets how often
  events are flushed, defaults to `5` (seconds).
* `EVENTS_SAMPLING_INTERVAL`: This variable is optional. Defaults to
  `10000`.


## [LocalStack](https://github.com/localstack/localstack)

Local AWS cloud stack

* **Web UI:** http://localstack.harpoon.dev
* **AWS CLI:** `harpoon localstack:aws <arg...>`

## [Logspout](https://github.com/gliderlabs/logspout)

* Sends (raw) JSON to the `harpoon_logstash` container via `udp:12345`

## [Mailhog](https://hub.docker.com/r/mailhog/mailhog/)

Web and API based SMTP testing

* **Web UI:** http://mailhog.harpoon.dev

## [MySQL](https://hub.docker.com/_/mysql/)

MySQL is a widely used, open-source relational database management
system (RDBMS).

**Environment Variables (with defaults):**

```bash
export MYSQL_VERSION=5
export MYSQL_ROOT_PASSWORD="abc123"
export MYSQL_DATABASE="harpoon"
export MYSQL_PORT=3306 # exposed to Docker host
```

## [Portainer](https://portainer.io)

Container management UI

* **Web UI:** http://portainer.harpoon.dev

## [Postgres](https://hub.docker.com/_/postgres/)

The PostgreSQL object-relational database system provides reliability
and data integrity.

## [Redis](https://hub.docker.com/_/redis/)

Redis is an open source key-value store that functions as a data
structure server.

## [Redis Commander](https://github.com/joeferner/redis-commander)

* **Web UI:** http://redis-commander.harpoon.dev

## [SQS-admin](https://github.com/wheniwork/sqs-admin)

* **Web UI:** http://sqsadmin.harpoon.dev

## SSH Agent

1. Run: `harpoon ssh-agent:up`
2. Add your key: `harpoon ssh-agent:add <filename>`, where `<filename>`
   is located in `~/.ssh/`.

# Service Management

* Run `harpoon services:list` to get a list of the supporting services.
* Run `harpoon services:status` to display the state of all supporting
  services.
* Run `harpoon (service):help` to get help for a particular service.


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

## [ELK Stack](https://hub.docker.com/r/sebp/elk/)

* Elasticsearch, Logstach, & Kibana
* http://elk-docker.readthedocs.io/

## [LocalStack](https://github.com/localstack/localstack)

Local AWS cloud stack

* **Web UI:** http://localstack.harpoon.dev
* **AWS CLI:** `harpoon localstack:aws <arg...>`

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


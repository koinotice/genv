# Service Plugins

You can create your own custom service configurations and use them with
_Genv_. For example, let's create a custom service for running
MariaDB.

1. Create a directory for your _plugin_ project.
2. Inside your project directory, create a directory named `mariadb`.
3. In the `mariadb` directory:
   1. Create a file named `mariadb.yml`. The contents is just like any
      other `docker-compose.yml`, but with some _Genv_-driven
      environment variables:

      ```yaml
      version: '2'
        
      services:
        mariadb:
          container_name: genv_mariadb
          image: mariadb:${MARIADB_VERSION}
          environment:
            - MYSQL_ALLOW_EMPTY_PASSWORD=yes
            - MYSQL_DATABASE=${MARIADB_DATABASE}
          ports:
            - "${MARIADB_PORT}:3306"
          volumes:
            - mariadb:/var/lib/mysql
        
      networks:
        default:
          external:
            name: ${GENV_DOCKER_NETWORK}
        
      volumes:
        mariadb:
          external: true
      ```

   2. Create a file named `bootstrap.sh`. _Genv_ will use this to
      load any custom environment variables you'd like to set. You can
      also provide "hook" functions, which _Genv_ will call at
      various states of your service's lifecycle. (Examine
      [`services/services.sh`](../../../services/services.sh) for more
      details.)

      ```bash
      #!/usr/bin/env bash

      if [ ! -v MARIADB_VERSION ]; then
           export MARIADB_VERSION="10.1"
      fi

      if [ ! -v MARIADB_DATABASE ]; then
          export MARIADB_DATABASE="genv"
      fi

      if [ ! -v MARIADB_PORT ]; then
          export MARIADB_PORT=3306
      fi

      export MARIADB_VOLUME_NAME=mariadb

      mariadb_pre_up() {
        local volumeCreated=$(docker volume ls | grep ${MARIADB_VOLUME_NAME}) || true

        if [[ "${volumeCreated}" == "" ]]; then
            printInfo "Creating docker volume named '${MARIADB_VOLUME_NAME}'..."
            docker volume create --name=${MARIADB_VOLUME_NAME}
        fi
      }

      mariadb_remove_volume() {
        local volumeCreated=$(docker volume ls | grep ${MARIADB_VOLUME_NAME}) || true

        if [[ "${volumeCreated}" != "" ]]; then
            printInfo "Removing docker volume named '${MARIADB_VOLUME_NAME}'..."
            docker volume rm ${MARIADB_VOLUME_NAME}
        fi
      }

      mariadb_post_destroy() {
          mariadb_remove_volume
      }

      mariadb_post_clean() {
          mariadb_remove_volume
      }
      ```

   3. Create a file named `handler.sh`. _Genv_ will use this to
      handle any custom commands for your service.

      ```bash
      #!/usr/bin/env bash
      
      case "${command}" in
          mariadb:client) ## [<arg>...] %% MySQL Client
              $(serviceDockerComposeExec mariadb) mariadb mysql -uroot "${args}" ;;
      
          mariadb:wait) ## %% Wait for MySQL to startup and finish initializing
              echo -e "Waiting for MySQL to start...\n"
      
              retries=30
              while [[ "$retries" > 0 ]]; do
                  $(serviceDockerComposeExec mariadb) mariadb mysql -uroot "-e SELECT 1" && break
                  let "retries=retries-1"
                  sleep 2
              done
              ;;
      
          mariadb:backup) ## %% Backup all databases in the mariadb container
              echo -e "Backing up all databases...\n"
              $(serviceDockerComposeExec mariadb) mariadb mysqldump -A --add-drop-database --add-drop-table -e -uroot > mariadb_backup.sql
              ;;
      
          mariadb:restore) ## %% Restore databases from mariadb_backup.sql in the current directory
              echo -e "Restoring from mariadb_backup.sql...\n"
              docker cp $PWD/mariadb_backup.sql genv_mariadb:/mariadb_backup.sql
              $(serviceDockerCompose mariadb) exec -T mariadb bash -c "mysql < /mariadb_backup.sql && rm -f /mariadb_backup.sql"
              ;;
      
          *)
              serviceHelp mariadb ;;
      esac
      ```

      * Be sure to use the `$(serviceDockerComposeExec <service-name>)`,
        and `$(serviceDockerCompose <service-name>)` functions for
        any calls you need to make to docker-compose with your
        configuration.
      * Also note the use of the `## [<arg>...] %% Your description`
        comment convention. _Genv_ will use this to automatically add
        your custom commands to the `help` output.

   4. Create a `Dockerfile` containing metadata that _Genv_ will use
      for installation.

      ```dockerfile
      FROM scratch
      
      COPY mariadb /mariadb
      
      LABEL genv_name=mariadb
      LABEL genv_type=service
      ```

   5. Build, tag, and push your plugin to any Docker registry.

      ```bash
      docker build -t mariadb .
      docker tag mariadb <repository>/mariadb
      docker push <repository>/mariadb
      ```

4. Install your plugin

   ```bash
   genv plug:in <repository>/mariadb
   ```

This service can now be managed with `genv mariadb:*`. Try `genv
mariadb:help` 😁

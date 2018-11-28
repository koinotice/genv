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
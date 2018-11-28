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
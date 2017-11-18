#!/usr/bin/env bash

#% 🔺 ES_VERSION %% Elasticsearch Docker image version %% 6.0.0
if [ ! -v ES_VERSION ]; then
	export ES_VERSION=6.0.0
fi

#% 🔺 LOGSTASH_VERSION %% Logstash Docker image version %% 6.0.0
if [ ! -v LOGSTASH_VERSION ]; then
	export LOGSTASH_VERSION=6.0.0
fi

#% 🔺 KIBANA_VERSION %% Kibana Docker image version %% 6.0.0
if [ ! -v KIBANA_VERSION ]; then
	export KIBANA_VERSION=6.0.0
fi

#% 🔹 ES_VOLUME_NAME %% ELK Docker volume name %% esdata
export ES_VOLUME_NAME=esdata

# ELK hostnames
if [ ! -v KIBANA_SERVER_NAME ]; then
	export KIBANA_SERVER_NAME=kibana.harpoon.dev
fi

if [ ! -v ELASTICSEARCH_URL ]; then
	export ELASTICSEARCH_URL=http://es.harpoon.dev
fi

if [ ! -v TRAEFIK_ACME ]; then
	export ES_HOSTS=es.harpoon.dev,elasticsearch.harpoon.dev
	export LOGSTASH_HOSTS=logstash.harpoon.dev,ls.harpoon.dev
	export KIBANA_HOSTS=kibana.harpoon.dev
fi

if [ -v CUSTOM_DOMAINS ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		export ES_HOSTS+=",es.${i},elasticsearch.${i}"
		export LOGSTASH_HOSTS+=",logstash.${i},ls.${i}"
		export KIBANA_HOSTS+=",kibana.${i}"
	done
fi

elk_pre_up() {
	local volumeCreated=$(docker volume ls | grep ${ES_VOLUME_NAME}) || true

	if [[ "${volumeCreated}" == "" ]]; then
		printInfo "Creating docker volume named '${ES_VOLUME_NAME}'..."
		docker volume create --name=${ES_VOLUME_NAME}
	fi
}

esRemoveVolume() {
	local volumeCreated=$(docker volume ls | grep ${ES_VOLUME_NAME}) || true

	if [[ "${volumeCreated}" != "" ]]; then
		printInfo "Removing docker volume named '${ES_VOLUME_NAME}'..."
		docker volume rm ${ES_VOLUME_NAME}
	fi
}

elk_post_destroy() {
	esRemoveVolume
}

elk_post_clean() {
	esRemoveVolume
}


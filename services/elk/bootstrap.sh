#!/usr/bin/env bash

#% 🔺 ES_VERSION %% Elasticsearch Docker image version %% 6.0.2
if [ ! -v ES_VERSION ]; then
	export ES_VERSION=6.0.2
fi

#% 🔺 LOGSTASH_VERSION %% Logstash Docker image version %% 6.0.2
if [ ! -v LOGSTASH_VERSION ]; then
	export LOGSTASH_VERSION=6.0.2
fi

#% 🔺 KIBANA_VERSION %% Kibana Docker image version %% 6.0.2
if [ ! -v KIBANA_VERSION ]; then
	export KIBANA_VERSION=6.0.2
fi

#% 🔺 FILEBEAT_VERSION %% Filebeat Docker image version %% 6.0.2
if [ ! -v FILEBEAT_VERSION ]; then
	export FILEBEAT_VERSION=6.0.2
fi

#% 🔹 ES_VOLUME_NAME %% ELK Docker volume name %% esdata
export ES_VOLUME_NAME=esdata

# ELK hostnames
if [ ! -v KIBANA_SERVER_NAME ]; then
	export KIBANA_SERVER_NAME=kibana.service.int.harpoon
fi

if [ ! -v ELASTICSEARCH_URL ]; then
	export ELASTICSEARCH_URL=http://es.service.int.harpoon:9200
fi

if [ ! -v TRAEFIK_ACME ]; then
	export ES_HOSTS=es.harpoon,elasticsearch.harpoon
	export LOGSTASH_HOSTS=logstash.harpoon,ls.harpoon
	export KIBANA_HOSTS=kibana.harpoon
fi

if [ -v CUSTOM_DOMAINS ]; then
	for i in "${CUSTOM_DOMAINS[@]}"; do
		export ES_HOSTS+=",es.${i},elasticsearch.${i}"
		export LOGSTASH_HOSTS+=",logstash.${i},ls.${i}"
		export KIBANA_HOSTS+=",kibana.${i}"
	done
fi

elk_post_up() {
	printInfo "Waiting 30 seconds for ElasticSearch..."
	sleep 30
	printInfo "Creating Filebeat dashboards in Kibana..."
	serviceExec elk "filebeat filebeat setup --dashboards"
}


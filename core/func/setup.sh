#!/usr/bin/env bash

up() {
	speak_info "Installing Harpoon core services..."

	config_dns

	config_docker

	config_os

	speak_success "\nHarpoon is good to go!" " 😁\n"
	print_info "Your services will be available at the following domain(s):"

	if [ -v CUSTOM_DOMAINS ]; then
		for i in "${CUSTOM_DOMAINS[@]}"; do
			echo -e "\t$i"
		done
		echo -e "\tharpoon.dev"
	else
		echo -e "\tharpoon.dev"
	fi
	echo ""
}

config_dns() {
	echo -e "$(cat ${HARPOON_ROOT}/core/dnsmasq/dnsmasq.conf.template | sed "s/NAMESERVER_IP/${NAMESERVER_IP}/")" > ${HARPOON_ROOT}/core/dnsmasq/dnsmasq.conf
}

config_docker() {
	${HARPOON_DOCKER_COMPOSE} pull
	config_docker_network
}

config_docker_network() {
	docker network ls -f driver=bridge | grep ${HARPOON_DOCKER_NETWORK} >> /dev/null || DOCKER_NETWORK_MISSING=true

	if [ -v DOCKER_NETWORK_MISSING ]; then
		docker network create ${HARPOON_DOCKER_NETWORK} --subnet 10.254.254.0/24 || true
	fi
}

config_os() {
	# Add fixed loopback alias for container connectivity to services running locally (when running Docker for Mac)
	if [[ $(uname) == 'Darwin' ]]; then
		sudo mkdir -p /etc/resolver
		echo "nameserver ${NAMESERVER_IP}" | sudo tee /etc/resolver/harpoon.dev
		echo "nameserver ${NAMESERVER_IP}" | sudo tee /etc/resolver/consul
		echo "port 8600" | sudo tee -a /etc/resolver/consul

		if [ -v CUSTOM_DOMAINS ]; then
			for i in "${CUSTOM_DOMAINS[@]}"; do
				echo -e "\naddress=/${i}/${NAMESERVER_IP}" >> ${HARPOON_ROOT}/core/dnsmasq/dnsmasq.conf
				echo "nameserver ${NAMESERVER_IP}" | sudo tee /etc/resolver/${i}
			done
		fi

		sudo ifconfig lo0 alias 10.254.253.1/32 || true
		${HARPOON_DOCKER_COMPOSE} up -d dnsmasq consul
	elif [[ $(uname) == 'Linux' ]]; then
		sudo ifconfig lo:0 10.254.253.1/32
		${HARPOON_DOCKER_COMPOSE} up -d consul
		sudo ln -fs ${HARPOON_ROOT}/core/dnsmasq/dnsmasq.conf /etc/NetworkManager/dnsmasq.d/harpoon
		sudo systemctl restart NetworkManager
	fi

	${HARPOON_DOCKER_COMPOSE} up -d traefik
}

cleanup() {
	if [[ $(uname) == 'Darwin' ]]; then
		sudo rm -f /etc/resolver/harpoon.dev
		sudo rm -f /etc/resolver/consul

		if [ -v CUSTOM_DOMAINS ]; then
			for i in  "${CUSTOM_DOMAINS[@]}"; do
				sudo rm -f /etc/resolver/${i}
			done
		fi
	fi

	if [[ $(uname) == 'Linux' ]]; then
		sudo rm /etc/NetworkManager/dnsmasq.d/harpoon
		sudo systemctl restart NetworkManager
	fi

	rm -f ${HARPOON_ROOT}/core/dnsmasq/dnsmasq.conf
}

down() {
	if [[ "${1:-}" == "all" ]]; then
		speak_info "Stopping and removing all Harpoon core and supporting services..."
	else
		speak_info "Stopping and removing Harpoon core services..."
	fi

	${HARPOON_DOCKER_COMPOSE} down -v

	if [[ "${1:-}" == "all" ]]; then
		for s in $(services); do
			print_info "Removing ${s}..."
			harpoon ${s}:down-if-up
		done
	fi

	cleanup

	if [[ "${1:-}" == "all" ]]; then
		speak_success "\nAll Harpoon core and supporting services have been shutdown and removed." " 😵\n"
	else
		speak_success "\nHarpoon core services have been shutdown and removed." " 😵\n"
	fi
}

clean() {
	if [[ "${1:-}" == "all" ]]; then
		speak_info "Completely uninstalling Harpoon and all supporting services..."
	else
		speak_info "Completely uninstalling Harpoon core services..."
	fi

	${HARPOON_DOCKER_COMPOSE} down -v --rmi all

	if [[ "${1:-}" == "all" ]]; then
		for s in $(services); do
			print_info "Completely removing ${s}..."
			harpoon ${s}:clean-if-up
		done
	fi

	docker network rm ${HARPOON_DOCKER_NETWORK} || true

	cleanup

	if [[ "${1:-}" == "all" ]]; then
		speak_success "\nAll Harpoon core and supporting services have been completely removed." " 😢\n"
	else
		speak_success "\nHarpoon core services have been completely removed." " 😢\n"
	fi
}

self_update() {
	speak_info "Updating Harpoon...\n"

	export HARPOON_SPEECH=false

	INSTALL_TMP=/tmp/harpoon-install

	down

	docker pull ${HARPOON_IMAGE}

	CID=$(docker create ${HARPOON_IMAGE})

	mkdir -p ${INSTALL_TMP}
	docker cp ${CID}:/harpoon ${INSTALL_TMP}
	docker rm -f ${CID}

	# only overwrite vendor and plugins and env/boot if included in image
	rm -fr ${HARPOON_ROOT}/{completion,core,docs,logos,modules,services,tests,docker*,harpoon}
	cp -a ${INSTALL_TMP}/harpoon/{completion,core,docs,logos,modules,services,tests,docker*,harpoon} ${HARPOON_ROOT}

	if [[ -d ${INSTALL_TMP}/harpoon/vendor && -f ${INSTALL_TMP}/harpoon/plugins.txt ]]; then
		print_info "Replacing plugins..."
		rm -fr ${HARPOON_ROOT}/{vendor,plugins.txt}
		cp -a ${INSTALL_TMP}/harpoon/{vendor,plugins.txt} ${HARPOON_ROOT}/
	fi

	if [ -f ${INSTALL_TMP}/harpoon/harpoon.env.sh ]; then
		print_info "Replacing harpoon.env.sh..."
		rm -f ${HARPOON_ROOT}/harpoon.env.sh
		cp ${INSTALL_TMP}/harpoon/harpoon.env.sh ${HARPOON_ROOT}/
	fi

	if [ -f ${INSTALL_TMP}/harpoon/harpoon.boot.sh ]; then
		print_info "Replacing harpoon.boot.sh..."
		rm -f ${HARPOON_ROOT}/harpoon.boot.sh
		cp ${INSTALL_TMP}/harpoon/harpoon.boot.sh ${HARPOON_ROOT}/
	fi

	rm -fr ${INSTALL_TMP}

	up

	export HARPOON_SPEECH=true

	speak_success "Harpoon has been updated!" " 👌\n"
	print_info "\tSome Harpoon supporting services may need to be restarted." " 🔄\n"
}
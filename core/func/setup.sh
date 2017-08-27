#!/usr/bin/env bash

up() {
	speakInfo "Installing Harpoon core services..."

	install

	speakSuccess "\nHarpoon is good to go!" " 😁\n"
	printInfo "Your services will be available at the following domain(s):"

	if [ -v CUSTOM_DOMAINS ]; then
		for i in "${CUSTOM_DOMAINS[@]}"; do
			echo -e "\t$i"
		done
		echo -e "\tharpoon.dev"
	else
		echo -e "\tharpoon.dev"
	fi
	echo ""

	speakGreeting
}

install() {
	generateDnsmasqConfig

	configDocker

	configOS
}

generateDnsmasqConfig() {
	printInfo "Generating dnsmasq configuration..."

	echo -e "$(cat ${HARPOON_ROOT}/core/dnsmasq/dnsmasq.conf.template | sed "s/HARPOON_DOCKER_HOST_IP/${HARPOON_DOCKER_HOST_IP}/")" > ${HARPOON_ROOT}/core/dnsmasq/dnsmasq.conf

	if [ -v CUSTOM_DOMAINS ]; then
		for i in "${CUSTOM_DOMAINS[@]}"; do
			echo -e "\naddress=/${i}/${HARPOON_DOCKER_HOST_IP}" >> ${HARPOON_ROOT}/core/dnsmasq/dnsmasq.conf
		done
	fi
}

configDocker() {
	if [ ! -x "$(command -v docker-compose)" ]; then
		printPanic "\nPlease install docker-compose!\n"
	fi

	${HARPOON_DOCKER_COMPOSE} pull
	configDockerNetwork
}

configDockerNetwork() {
	docker network ls -f driver=bridge | grep ${HARPOON_DOCKER_NETWORK} >> /dev/null || DOCKER_NETWORK_MISSING=true

	if [ -v DOCKER_NETWORK_MISSING ]; then
		docker network create ${HARPOON_DOCKER_NETWORK} --subnet ${HARPOON_DOCKER_SUBNET} || true
	fi
}

configOS() {
	if [[ $(uname) == 'Darwin' ]]; then
		configMacOS
	elif [[ $(uname) == 'Linux' ]]; then
		configLinux
	fi

	${HARPOON_DOCKER_COMPOSE} up -d traefik
}

configMacOS() {
	sudo mkdir -p /etc/resolver
	echo "nameserver ${HARPOON_DOCKER_HOST_IP}" | sudo tee /etc/resolver/harpoon.dev
	echo "nameserver ${HARPOON_DOCKER_HOST_IP}" | sudo tee /etc/resolver/consul
	echo "port 8600" | sudo tee -a /etc/resolver/consul

	if [ -v CUSTOM_DOMAINS ]; then
		for i in "${CUSTOM_DOMAINS[@]}"; do
			echo "nameserver ${HARPOON_DOCKER_HOST_IP}" | sudo tee /etc/resolver/${i}
		done
	fi

	sudo ifconfig lo0 alias ${HARPOON_LOOPBACK_ALIAS_IP}/32 || true
	${HARPOON_DOCKER_COMPOSE} up -d dnsmasq consul
}

configLinux() {
	if [ ! -v RUNNING_IN_CONTAINER ]; then
		sudo ifconfig lo:0 ${HARPOON_LOOPBACK_ALIAS_IP}/32 || true

		if [ -d /etc/NetworkManager ]; then
			sudo ln -fs ${HARPOON_ROOT}/core/dnsmasq/dnsmasq.conf /etc/NetworkManager/dnsmasq.d/harpoon
			sudo systemctl restart NetworkManager
		elif [ -d /etc/dnsmasq.d ]; then
			configDnsmasqLinux
		else
			printInfo "Installing dnsmasq..."
			sudo apt-get install dnsmasq
			configDnsmasqLinux
		fi

		${HARPOON_DOCKER_COMPOSE} up -d consul
	else
		${HARPOON_DOCKER_COMPOSE} up -d dnsmasq consul
	fi
}

configDnsmasqLinux() {
	printInfo "Configuring dnsmasq..."

	grep "^#conf-dir=/etc/dnsmasq.d$" /etc/dnsmasq.conf || CONF_DIR_EXISTS=true

	if [ ! -v CONF_DIR_EXISTS ]; then
		sed -r "s/^#conf-dir=\/etc\/dnsmasq.d$/conf-dir=\/etc\/dnsmasq.d/" /etc/dnsmasq.conf | sudo tee /etc/dnsmasq.conf
	fi

	sudo ln -fs ${HARPOON_ROOT}/core/dnsmasq/dnsmasq.conf /etc/dnsmasq.d/harpoon
	sudo service dnsmasq restart
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

	if [[ $(uname) == 'Linux' && ! -v RUNNING_IN_CONTAINER ]]; then
		if [ -d /etc/NetworkManager ]; then
			sudo rm -f /etc/NetworkManager/dnsmasq.d/harpoon
			sudo systemctl restart NetworkManager
		elif [ -d /etc/dnsmasq.d ]; then
			sudo rm -f /etc/dnsmasq.d/harpoon
			sudo service dnsmasq restart
		else
			printInfo "Uninstalling dnsmasq..."
			sudo rm -f /etc/dnsmasq.d/harpoon
			sudo apt-get purge dnsmasq
		fi
	fi

	rm -f ${HARPOON_ROOT}/core/dnsmasq/dnsmasq.conf
}

uninstall() {
	${HARPOON_DOCKER_COMPOSE} down -v

	if [[ "${1:-}" == "all" ]]; then
		for s in $(listServices); do
			printInfo "Removing ${s}..."
			harpoon ${s}:down-if-up
		done
	fi
}

down() {
	if [[ "${1:-}" == "all" ]]; then
		speakInfo "Stopping and removing all Harpoon core and supporting services..."
	else
		speakInfo "Stopping and removing Harpoon core services..."
	fi

	uninstall ${1:-}

	cleanup

	if [[ "${1:-}" == "all" ]]; then
		speakSuccess "\nAll Harpoon core and supporting services have been shutdown and removed." " 😵\n"
	else
		speakSuccess "\nHarpoon core services have been shutdown and removed." " 😵\n"
	fi
}

clean() {
	if [[ "${1:-}" == "all" ]]; then
		speakInfo "Completely uninstalling Harpoon and all supporting services..."
	else
		speakInfo "Completely uninstalling Harpoon core services..."
	fi

	${HARPOON_DOCKER_COMPOSE} down -v --rmi all

	if [[ "${1:-}" == "all" ]]; then
		for s in $(services); do
			printInfo "Completely removing ${s}..."
			harpoon ${s}:clean-if-up
		done
	fi

	docker network rm ${HARPOON_DOCKER_NETWORK} || true

	cleanup

	if [[ "${1:-}" == "all" ]]; then
		speakSuccess "\nAll Harpoon core and supporting services have been completely removed." " 😢\n"
	else
		speakSuccess "\nHarpoon core services have been completely removed." " 😢\n"
	fi
}

reset() {
	speakInfo "Resetting Harpoon core services...\n"

	uninstall
	install

	speakSuccess "\nHarpoon core services have been reset." " 🤘\n"
}

selfUpdate() {
	speakInfo "Updating Harpoon...\n"

	local installTemp=/tmp/harpoon-install

	uninstall

	docker pull ${HARPOON_IMAGE}

	local containerID=$(docker create ${HARPOON_IMAGE})

	mkdir -p ${installTemp}
	docker cp ${containerID}:/harpoon ${installTemp}
	docker rm -f ${containerID}

	# remove deprecated 'modules' directory
	rm -fr ${HARPOON_ROOT}/modules > /dev/null || true

	# only overwrite vendor and plugins and env/boot if included in image
	rm -fr ${HARPOON_ROOT}/{completion,core,docs,logos,tasks,services,tests,docker*,harpoon}
	cp -a ${installTemp}/harpoon/{completion,core,docs,logos,tasks,services,tests,docker*,harpoon} ${HARPOON_ROOT}

	if [[ -d ${installTemp}/harpoon/vendor && -f ${installTemp}/harpoon/plugins.txt ]]; then
		printInfo "Replacing plugins..."
		rm -fr ${HARPOON_ROOT}/{vendor,plugins.txt}
		cp -a ${installTemp}/harpoon/{vendor,plugins.txt} ${HARPOON_ROOT}/
	fi

	if [ -f ${installTemp}/harpoon/harpoon.env.sh ]; then
		printInfo "Replacing harpoon.env.sh..."
		rm -f ${HARPOON_ROOT}/harpoon.env.sh
		cp ${installTemp}/harpoon/harpoon.env.sh ${HARPOON_ROOT}/
	fi

	if [ -f ${installTemp}/harpoon/harpoon.boot.sh ]; then
		printInfo "Replacing harpoon.boot.sh..."
		rm -f ${HARPOON_ROOT}/harpoon.boot.sh
		cp ${installTemp}/harpoon/harpoon.boot.sh ${HARPOON_ROOT}/
	fi

	if [ -d ${installTemp}/harpoon/images ]; then
		printInfo "Replacing images..."
		rm -fr ${HARPOON_IMAGES_ROOT}
		cp -a ${installTemp}/harpoon/images ${HARPOON_ROOT}/
	fi

	rm -fr ${installTemp}

	install

	if [ -d ${HARPOON_IMAGES_ROOT} ]; then
		harpoon docker:load
	fi

	harpoon docker:prune

	speakSuccess "\nHarpoon has been updated!" " 👌\n"
	printInfo "\tSome Harpoon supporting services may need to be restarted." " 🔄\n"
}
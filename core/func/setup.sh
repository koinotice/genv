#!/usr/bin/env bash

up() {
	speakInfo "Installing Genv core services..."

	install

	speakSuccess "\nGenv is good to go!" " 😁\n"
	printInfo "Your services will be available at the following domain(s):"

	if [ -v CUSTOM_DOMAINS ]; then
		for i in "${CUSTOM_DOMAINS[@]}"; do
			echo -e "\t$i (resolves to Traefik container IP)"
		done
	fi
	echo -e "\t.${GENV_DOMAIN} (resolves to Traefik container IP)"
	echo -e "\t${GENV_INT_DOMAIN} (resolves to container IPs)"
	echo ""
	echo ${GENV_DOMAIN}

	speakGreeting
}

install() {
	generateDnsmasqConfig

	configDocker

	configOS
}

test(){
     echo ${GENV_DOMAIN}
    echo "FUCK"
}

generateDnsmasqConfig() {


	printInfo "Generating dnsmasq configuration..."


	cp ${GENV_ROOT}/core/dnsmasq/dnsmasq.conf.template ${GENV_ROOT}/core/dnsmasq/dnsmasq.conf


	#echo -e "\nserver=/${GENV_INT_DOMAIN}/${GENV_CONSUL_IP}#8600" >> ${GENV_ROOT}/core/dnsmasq/dnsmasq.conf

    #echo -e "\naddress=/${GENV_DOMAIN}/${GENV_TRAEFIK_IP}" >> ${GENV_ROOT}/core/dnsmasq/dnsmasq.conf
    if [[ $(uname) == 'Darwin' ]]; then
		GENV_IP=127.0.0.1
		echo -e "\ninterface=eth0" >> ${GENV_ROOT}/core/dnsmasq/dnsmasq.conf

	elif [[ $(uname) == 'Linux' ]]; then
		GENV_IP=${GENV_TRAEFIK_IP}
	fi

    echo -e "\nserver=/${GENV_INT_DOMAIN}/${GENV_IP}#8600" >> ${GENV_ROOT}/core/dnsmasq/dnsmasq.conf

    echo -e "\naddress=/${GENV_DOMAIN}/${GENV_IP}" >> ${GENV_ROOT}/core/dnsmasq/dnsmasq.conf


	if [ -v CUSTOM_DOMAINS ]; then
		for i in "${CUSTOM_DOMAINS[@]}"; do
			echo -e "\naddress=/${i}/${GENV_IP}" >> ${GENV_ROOT}/core/dnsmasq/dnsmasq.conf
		done
	fi
}

configDocker() {
	if [ ! -x "$(command -v docker-compose)" ]; then
		printPanic "\nPlease install docker-compose!\n"
	fi

	${GENV_DOCKER_COMPOSE} pull
	configDockerNetwork
}

configDockerNetwork() {

	docker network ls -f driver=bridge | grep ${GENV_DOCKER_NETWORK} >> /dev/null || DOCKER_NETWORK_MISSING=true
	DOCKER_NETWORK_MISSING=true
 	if [ -v DOCKER_NETWORK_MISSING ]; then

		docker network create ${GENV_DOCKER_NETWORK} --subnet ${GENV_DOCKER_SUBNET} || true
	fi
}

configOS() {
	if [[ $(uname) == 'Darwin' ]]; then
		configMacOS
	elif [[ $(uname) == 'Linux' ]]; then
		configLinux
	fi

	${GENV_DOCKER_COMPOSE} up -d consul registrator traefik
}

configMacOS() {
	printInfo "Configuring network routes..."

	sudo ifconfig lo0 alias ${GENV_LOOPBACK_ALIAS_IP}/32 || true

	if [[ "$GENV_DOCKER_HOST_IP" != "$GENV_LOOPBACK_ALIAS_IP" ]]; then
		sudo route add -net ${GENV_DOCKER_SUBNET} ${GENV_DOCKER_HOST_IP}
	fi

	printInfo "Configuring DNS..."

	sudo mkdir -p /etc/resolver
	echo -e "nameserver 127.0.0.1" | sudo tee /etc/resolver/${GENV_DOMAIN}
	#echo "nameserver ${GENV_DNSMASQ_IP}" | sudo >> /etc/resolver/genv.com
    #echo ${CUSTOM_DOMAINS}asdfdsfadf
	if [ -v CUSTOM_DOMAINS ]; then
		for i in "${CUSTOM_DOMAINS[@]}"; do
			echo "nameserver 127.0.0.1" | sudo tee /etc/resolver/${i}
		done
	fi

	${GENV_DOCKER_COMPOSE} up -d dnsmasq
}

configLinux() {
	if [ ! -v RUNNING_IN_CONTAINER ]; then
		sudo ifconfig lo:0 ${GENV_LOOPBACK_ALIAS_IP}/32 || true

		printInfo "Configuring DNS..."

		if [ -d /etc/NetworkManager ]; then
			sudo ln -fs ${GENV_ROOT}/core/dnsmasq/dnsmasq.conf /etc/NetworkManager/dnsmasq.d/genv
			sudo systemctl restart NetworkManager
		elif [ -d /etc/dnsmasq.d ]; then
			grep "^#conf-dir=/etc/dnsmasq.d$" /etc/dnsmasq.conf || CONF_DIR_EXISTS=true

			if [ ! -v CONF_DIR_EXISTS ]; then
				sed -r "s/^#conf-dir=\/etc\/dnsmasq.d$/conf-dir=\/etc\/dnsmasq.d/" /etc/dnsmasq.conf | sudo tee /etc/dnsmasq.conf
			fi

			sudo ln -fs ${GENV_ROOT}/core/dnsmasq/dnsmasq.conf /etc/dnsmasq.d/genv
			sudo service dnsmasq restart
		else
			${GENV_DOCKER_COMPOSE} up -d dnsmasq
		fi
	else
		${GENV_DOCKER_COMPOSE} up -d dnsmasq
	fi

}

cleanup() {
	if [[ $(uname) == 'Darwin' ]]; then
		sudo rm -f /etc/resolver/*genv*

		if [ -v CUSTOM_DOMAINS ]; then
			for i in  "${CUSTOM_DOMAINS[@]}"; do
				sudo rm -f /etc/resolver/${i}
			done
		fi

		if [[ "$GENV_DOCKER_HOST_IP" != "$GENV_LOOPBACK_ALIAS_IP" ]]; then
			sudo route delete -net ${GENV_DOCKER_SUBNET}
		fi
	fi

	if [[ $(uname) == 'Linux' && ! -v RUNNING_IN_CONTAINER ]]; then
		if [ -d /etc/NetworkManager ]; then
			sudo rm -f /etc/NetworkManager/dnsmasq.d/genv
			sudo systemctl restart NetworkManager
		elif [ -d /etc/dnsmasq.d ]; then
			sudo rm -f /etc/dnsmasq.d/genv
			sudo service dnsmasq restart
		else
			printInfo "Uninstalling dnsmasq..."
			sudo rm -f /etc/dnsmasq.d/genv
			sudo apt-get purge dnsmasq
		fi
	fi

	rm -f ${GENV_ROOT}/core/dnsmasq/dnsmasq.conf
}

uninstall() {
	${GENV_DOCKER_COMPOSE} down -v

	if [[ "${1:-}" == "all" ]]; then
		local services=$(listServices)
		for s in ${services}; do
			printInfo "Removing ${s}..."
			genv ${s}:down-if-up
		done
	fi
}

down() {
	if [[ "${1:-}" == "all" ]]; then
		speakInfo "Stopping and removing all Genv core and supporting services..."
	else
		speakInfo "Stopping and removing Genv core services..."
	fi

	uninstall ${1:-}

	cleanup

	if [[ "${1:-}" == "all" ]]; then
		speakSuccess "\nAll Genv core and supporting services have been shutdown and removed." " 😵\n"
	else
		speakSuccess "\nGenv core services have been shutdown and removed." " 😵\n"
	fi
}

clean() {
	if [[ "${1:-}" == "all" ]]; then
		speakInfo "Completely uninstalling Genv and all supporting services..."
	else
		speakInfo "Completely uninstalling Genv core services..."
	fi

	${GENV_DOCKER_COMPOSE} down -v --rmi all

	if [[ "${1:-}" == "all" ]]; then
		local services=$(services)
		for s in ${services}; do
			printInfo "Completely removing ${s}..."
			genv ${s}:clean-if-up
		done
	fi

	docker network rm ${GENV_DOCKER_NETWORK} || true

	cleanup

	if [[ "${1:-}" == "all" ]]; then
		speakSuccess "\nAll Genv core and supporting services have been completely removed." " 😢\n"
	else
		speakSuccess "\nGenv core services have been completely removed." " 😢\n"
	fi
}

reset() {
	speakInfo "Resetting Genv core services...\n"

	uninstall
	install

	speakSuccess "\nGenv core services have been reset." " 🤘\n"
}

selfUpdate() {
	speakInfo "Updating Genv...\n"

	local installTemp=/tmp/genv-install

	uninstall

	docker pull ${GENV_IMAGE}

	local containerID=$(docker create ${GENV_IMAGE})

	mkdir -p ${installTemp}
	docker cp ${containerID}:/genv ${installTemp}
	docker rm -f ${containerID}

	# only overwrite vendor and plugins and env/boot if included in image
	rm -fr ${GENV_ROOT}/{completion,core,docs,logos,tasks,services,tests,docker*,genv}
	cp -a ${installTemp}/genv/{completion,core,docs,logos,tasks,services,tests,docker*,genv} ${GENV_ROOT}

	if [[ -d ${installTemp}/genv/vendor && -f ${installTemp}/genv/plugins.txt ]]; then
		printInfo "Replacing plugins..."
		rm -fr ${GENV_ROOT}/{vendor,plugins.txt}
		cp -a ${installTemp}/genv/{vendor,plugins.txt} ${GENV_ROOT}/

		plugins=$(cat ${GENV_ROOT}/plugins.txt)

		for p in ${plugins}; do
			[[ ${p} =~ ^# ]] && continue
			docker pull ${p} || printError "Failed to pull Docker image for ${p}"
		done
	fi

	if [ -f ${installTemp}/genv/genv.env.sh ]; then
		printInfo "Replacing genv.env.sh..."
		rm -f ${GENV_ROOT}/genv.env.sh
		cp ${installTemp}/genv/genv.env.sh ${GENV_ROOT}/
	fi

	if [ -f ${installTemp}/genv/genv.boot.sh ]; then
		printInfo "Replacing genv.boot.sh..."
		rm -f ${GENV_ROOT}/genv.boot.sh
		cp ${installTemp}/genv/genv.boot.sh ${GENV_ROOT}/
	fi

	if [ -d ${installTemp}/genv/images ]; then
		printInfo "Replacing images..."
		rm -fr ${GENV_IMAGES_ROOT}
		cp -a ${installTemp}/genv/images ${GENV_ROOT}/
	fi

	rm -fr ${installTemp}

	install

	if [ -d ${GENV_IMAGES_ROOT} ]; then
		genv docker:load
	fi

	genv docker:prune

	speakSuccess "\nGenv has been updated!" " 👌\n"
	printInfo "\tSome Genv supporting services may need to be restarted." " 🔄\n"
}
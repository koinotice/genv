.PHONY: all
.DEFAULT_GOAL := help

install: ## Install lowcal
	./lowcal install

env: ## Show environment variables
	./lowcal env

show-nameserver-ip: ## Display the lowcal nameserver IP
	@./lowcal show-nameserver-ip

stop: ## Stop all services
	./lowcal dc stop

start: ## Start all services
	./lowcal dc start

restart: ## Restart all services
	./lowcal dc restart

rm: ## Remove all services
	./lowcal dc rm -f -v

refresh:
	./lowcal dc stop
	./lowcal dc rm -f -v
	./lowcal dc up -d

logs: ## Tail output from containers
	./lowcal dc logs -f

ps: ## List containers
	./lowcal dc ps

clean: ## Uninstall lowcal
	./lowcal clean

uninstall: clean ## Uninstall lowcal

list-services: ## List services available in lowcal
	./lowcal services:list

sh-dns: ## Enter a shell on the dnsmasq container
	./tasks dc exec dnsmasq sh

help: ## Print usage
	@for i in $(MAKEFILE_LIST); do grep -E '^[a-zA-Z_-]+:.*?## .*$$' $${i} | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'; done

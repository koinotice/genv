.PHONY: all
.DEFAULT_GOAL := help

install: ## Install harpoon
	./harpoon install

env: ## Show environment variables
	./harpoon env

show-nameserver-ip: ## Display the harpoon nameserver IP
	@./harpoon show-nameserver-ip

stop: ## Stop all services
	./harpoon dc stop

start: ## Start all services
	./harpoon dc start

restart: ## Restart all services
	./harpoon dc restart

rm: ## Remove all services
	./harpoon dc rm -f -v

refresh:
	./harpoon dc stop
	./harpoon dc rm -f -v
	./harpoon dc up -d

logs: ## Tail output from containers
	./harpoon dc logs -f

ps: ## List containers
	./harpoon dc ps

clean: ## Uninstall harpoon
	./harpoon clean

uninstall: clean ## Uninstall harpoon

list-services: ## List services available in harpoon
	./harpoon services:list

sh-dns: ## Enter a shell on the dnsmasq container
	./tasks dc exec dnsmasq sh

docs-build:
	gitbook build gitbook docs

docs-serve:
	gitbook serve gitbook docs

help: ## Print usage
	@for i in $(MAKEFILE_LIST); do grep -E '^[a-zA-Z_-]+:.*?## .*$$' $${i} | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'; done

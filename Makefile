.PHONY: all
.DEFAULT_GOAL := help

help: ## Print usage
	@for i in $(MAKEFILE_LIST); do grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $${i} | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'; done

docs-build:
	gitbook build gitbook docs

docs-serve:
	gitbook serve gitbook docs

build:
	docker build -t genv .

push:
    docker tag genv:latest koinotice/genv:latest
    docker push koinotice/genv:latest
sh:
	docker exec -ti genv bash

test:
	./build.sh test

test-dind:
	./build.sh test:dind

test-local:
	./build.sh test:local

show-metadata:
	@echo "REF: $$REF"
	@echo "TAG: $$TAG"

copy-local:
	cp -a completion ~/genv/
	cp -a core ~/genv/
	cp -a lib ~/genv/
	cp -a services ~/genv/
	cp -a tasks ~/genv/
	cp genv docker-compose.yml ~/genv/

push:
	./build.sh push

hook-gitlab:
	curl -s -X POST $${GITLAB_WEBHOOK_ROOT}$${REF}/trigger/pipeline?token=$${GITLAB_CI_TOKEN}

deploy: show-metadata push hook-gitlab

clean:
	docker rmi genv

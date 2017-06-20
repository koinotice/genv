.PHONY: all
.DEFAULT_GOAL := help

install: ## Install harpoon
	./harpoon install

clean: ## Uninstall harpoon
	./harpoon clean

uninstall: clean ## Uninstall harpoon

docs-build:
	gitbook build gitbook docs

docs-serve:
	gitbook serve gitbook docs

help: ## Print usage
	@for i in $(MAKEFILE_LIST); do grep -E '^[a-zA-Z_-]+:.*?## .*$$' $${i} | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'; done

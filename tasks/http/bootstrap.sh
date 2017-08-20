#!/usr/bin/env bash

httpie() {
	print_debug "httpie args: $@"
	docker_run -i alpine/httpie $@
}

httpie_no_input() {
	print_debug "httpie args: $@"
	docker_run alpine/httpie $@
}
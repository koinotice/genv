#!/usr/bin/env bats

setup() {
	load helper
	unset GENV_DEBUG
}

@test "initpath" {
	run ./genv initpath
	[ "$status" -eq 0 ]
	egrep "completion/init.sh" <<< "$output"
}

@test "parse module" {
	genvLoad core/parse.sh
	run parseModule "foo:bar"
	[ "$status" -eq 0 ]
	[ "$output" = "foo" ]
}

@test "parse sub-command" {
	genvLoad core/parse.sh
	run parseSubCmd "foo:bar"
	[ "$status" -eq 0 ]
	[ "$output" = "bar" ]
}

@test "compose config" {
	run ./genv compose config
	[ "$status" -eq 0 ]
}

@test "cmplt" {
	run ./genv cmplt
	[ "$status" -eq 0 ]
}

@test "generate dnsmasq config" {
	run ./genv gen-dnsmasq
	[ "$status" -eq 0 ]
}

@test "config docker" {
	run ./genv config-docker
	[ "$status" -eq 0 ]
	run bash -c "docker network ls | grep $(./genv env | grep 'GENV_DOCKER_NETWORK' | cut -d '=' -f 2)"
	[ "$status" -eq 0 ]
}

@test "env" {
	env=$(unset ${PAGER} && ./genv env 2>&1)
	[ $? -eq 0 ]
	echo -e "$env" | grep "DEPLOY_ENV"
	echo -e "$env" | grep "GENV_DIND_EXEC"
	echo -e "$env" | grep "GENV_"
	echo -e "$env" | grep "PROJECT="
	echo -e "$env" | grep "PROJECT_"
	echo -e "$env" | grep "DOCKER_RUN"
	echo -e "$env" | grep "TRAEFIK_"
	echo -e "$env" | grep "VCS_"
}

@test "help" {
	run bash -c "./genv help | head -n 3"
	[ "$status" -eq 0 ]
	help=$(cat <<HELP
Usage:
  genv <command> [<arg>...]
  genv -h|--help
HELP
)
	[ "$output" = "$help" ]
}

@test "show docker host ip" {
	run ./genv show-docker-host-ip
	[ "$status" -eq 0 ]
}

@test "status down" {
	./genv compose down
	run ./genv status
	[ "$status" -eq 1 ]
	egrep "dnsmasq\s+?" <<< "$output"
	egrep "consul\s+?" <<< "$output"
	egrep "traefik\s+?" <<< "$output"
}

@test "status up" {
	./genv compose up -d
	run ./genv status
	[ "$status" -eq 0 ]
	egrep "dnsmasq\s+?" <<< "$output"
	egrep "consul\s+?" <<< "$output"
	egrep "traefik\s+?" <<< "$output"
}

@test "status up - no emoji" {
	./genv compose up -d
	export GENV_USE_EMOJI=false
	run ./genv status
	[ "$status" -eq 0 ]
	egrep "dnsmasq\s+Up" <<< "$output"
	egrep "consul\s+Up" <<< "$output"
	egrep "traefik\s+Up" <<< "$output"
}

@test "tasks list" {
	run ./genv tasks:list
	[ "$status" -eq 0 ]
	grep "aws" <<< "$output"
	grep "deploy" <<< "$output"
	grep "dind" <<< "$output"
	grep "docker" <<< "$output"
	grep "git" <<<"$output"
	grep "http" <<<"$output"
	grep "image" <<<"$output"
	grep "info" <<<"$output"
	grep "jp" <<< "$output"
	grep "jq" <<< "$output"
	grep "notify" <<< "$output"
	grep "plug" <<< "$output"
	grep "tf" <<< "$output"
}

@test "services list" {
	run ./genv services:list
	[ "$status" -eq 0 ]
	grep "beanstalk-console" <<< "$output"
	grep "blackfire" <<< "$output"
	grep "cadvisor" <<< "$output"
	grep "couchbase" <<< "$output"
	grep "dynamodb-admin" <<< "$output"
	grep "elk" <<< "$output"
	grep "localstack" <<< "$output"
	grep "mailhog" <<< "$output"
	grep "mysql" <<< "$output"
	grep "portainer" <<< "$output"
	grep "postgres" <<< "$output"
	grep "redis" <<< "$output"
	grep "ssh-agent" <<< "$output"
}
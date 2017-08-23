#!/usr/bin/env bats

setup() {
	load helper
}

@test "initpath" {
	run ./harpoon initpath
	[ "$status" -eq 0 ]
	egrep "completion/init.sh" <<< "$output"
}

@test "parse module" {
	harpoon_load core/parse.sh
	run parse_module "foo:bar"
	[ "$status" -eq 0 ]
	[ "$output" = "foo" ]
}

@test "parse sub-command" {
	harpoon_load core/parse.sh
	run parse_subcmd "foo:bar"
	[ "$status" -eq 0 ]
	[ "$output" = "bar" ]
}

@test "compose config" {
	run ./harpoon compose config
	[ "$status" -eq 0 ]
}

@test "cmplt" {
	run ./harpoon cmplt
	[ "$status" -eq 0 ]
}

@test "generate dnsmasq config" {
	run ./harpoon gen-dnsmasq
	[ "$status" -eq 0 ]
}

@test "config docker" {
#	skip_when_no_docker
	run ./harpoon config-docker
	[ "$status" -eq 0 ]
	run bash -c "docker network ls | grep $(./harpoon env | grep 'HARPOON_DOCKER_NETWORK' | cut -d '=' -f 2)"
	[ "$status" -eq 0 ]
}

@test "env" {
	env=$(unset ${PAGER} && ./harpoon env 2>&1)
	[ $? -eq 0 ]
	echo -e "$env" | grep "DEPLOY_ENV"
	echo -e "$env" | grep "DIND_EXEC"
	echo -e "$env" | grep "HARPOON_"
	echo -e "$env" | grep "PROJECT="
	echo -e "$env" | grep "PROJECT_"
	echo -e "$env" | grep "DOCKER_RUN"
	echo -e "$env" | grep "TRAEFIK_"
	echo -e "$env" | grep "VCS_"
}

@test "help" {
	run bash -c "./harpoon help | head -n 3"
	[ "$status" -eq 0 ]
	help=$(cat <<HELP
Usage:
  harpoon <command> [<arg>...]
  harpoon -h|--help
HELP
)
	[ "$output" = "$help" ]
}

@test "show-nameserver-ip" {
	run ./harpoon show-nameserver-ip
	[ "$status" -eq 0 ]
}

@test "status down" {
#	skip_when_no_docker

	./harpoon compose down
	run ./harpoon status
	[ "$status" -eq 1 ]
	egrep "dnsmasq\s+?" <<< "$output"
	egrep "consul\s+?" <<< "$output"
	egrep "traefik\s+?" <<< "$output"
}

@test "status up" {
#	skip_when_no_docker

	./harpoon compose up -d
	run ./harpoon status
	[ "$status" -eq 0 ]
	egrep "dnsmasq\s+?" <<< "$output"
	egrep "consul\s+?" <<< "$output"
	egrep "traefik\s+?" <<< "$output"
}

@test "status up - no emoji" {
#	skip_when_no_docker

	./harpoon compose up -d
	export HARPOON_USE_EMOJI=false
	run ./harpoon status
	[ "$status" -eq 0 ]
	egrep "dnsmasq\s+Up" <<< "$output"
	egrep "consul\s+Up" <<< "$output"
	egrep "traefik\s+Up" <<< "$output"
}

@test "tasks list" {
	run ./harpoon tasks:list
	[ "$status" -eq 0 ]
	grep "aws" <<< "$output"
	grep "dind" <<< "$output"
	grep "docker" <<< "$output"
	grep "http" <<<"$output"
	grep "jp" <<< "$output"
	grep "jq" <<< "$output"
	grep "tf" <<< "$output"
}

@test "services list" {
	run ./harpoon services:list
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
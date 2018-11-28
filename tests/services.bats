#!/usr/bin/env bats

setup() {
	load helper
	export GENV_USE_EMOJI=false
}

@test "service exists" {
	setGenvRoots
	genvLoad services/services.sh
	svcRoot=$(serviceRoot mysql)
	[ $? -eq 0 ]
	[ "$svcRoot" != "" ]
}

@test "mysql help" {
	run ./genv mysql:help
	[ "$status" -eq 0 ]
	grep "MySQL Client" <<< "$output"
}

@test "service status - up" {
	run ./genv cadvisor:up
	[ "$status" -eq 0 ]
	run ./genv cadvisor:status
	[ "$status" -eq 0 ]
	egrep "cadvisor\s+Up" <<< "$output"
	run ./genv services:status
	[ "$status" -eq 0 ]
	egrep "cadvisor\s+Up" <<< "$output"
}

@test "service reset" {
	run ./genv cadvisor:reset
	[ "$status" -eq 0 ]
	run ./genv cadvisor:status
	[ "$status" -eq 0 ]
	egrep "cadvisor\s+Up" <<< "$output"
}

@test "service status - down" {
	run ./genv cadvisor:down
	[ "$status" -eq 0 ]
	run ./genv cadvisor:status
	[ "$status" -eq 1 ]
	egrep "cadvisor\s+Down" <<< "$output"
	run ./genv services:status
	[ "$status" -eq 0 ]
	egrep "cadvisor\s+Down" <<< "$output"
}

@test "service destroy" {
	run ./genv redis:up
	[ "$status" -eq 0 ]
	run ./genv redis:destroy
	[ "$status" -eq 0 ]
	run ./genv redis:status
	[ "$status" -eq 1 ]
	egrep "redis\s+Down" <<< "$output"
}

@test "service clean" {
	run ./genv redis:up
	[ "$status" -eq 0 ]
	run ./genv redis:clean
	[ "$status" -eq 0 ]
	run ./genv redis:status
	[ "$status" -eq 1 ]
	egrep "redis\s+Down" <<< "$output"
}

@test "multiple service statuses - up" {
	run ./genv service up portainer mailhog
	[ "$status" -eq 0 ]
	run ./genv service status portainer
	[ "$status" -eq 0 ]
	egrep "portainer\s+Up" <<< "$output"
	run ./genv service status mailhog
	[ "$status" -eq 0 ]
	egrep "mailhog\s+Up" <<< "$output"
	run ./genv service status portainer mailhog
	[ "$status" -eq 0 ]
	egrep "portainer\s+Up" <<< "$output"
	egrep "mailhog\s+Up" <<< "$output"
}

@test "multiple service statuses - down" {
	run ./genv service down portainer mailhog
	[ "$status" -eq 0 ]
	run ./genv service status portainer
	[ "$status" -eq 0 ]
	egrep "portainer\s+Down" <<< "$output"
	run ./genv service status mailhog
	[ "$status" -eq 0 ]
	egrep "mailhog\s+Down" <<< "$output"
	run ./genv service status portainer mailhog
	[ "$status" -eq 0 ]
	egrep "portainer\s+Down" <<< "$output"
	egrep "mailhog\s+Down" <<< "$output"
}

@test "multiple services: up-if-down" {
	run ./genv service up-if-down portainer mailhog
	[ "$status" -eq 0 ]
	run ./genv service status portainer mailhog
	[ "$status" -eq 0 ]
	egrep "portainer\s+Up" <<< "$output"
	egrep "mailhog\s+Up" <<< "$output"
}

@test "multiple services: down-if-up" {
	run ./genv service down-if-up portainer mailhog
	[ "$status" -eq 0 ]
	run ./genv service status portainer mailhog
	[ "$status" -eq 0 ]
	egrep "portainer\s+Down" <<< "$output"
	egrep "mailhog\s+Down" <<< "$output"
}

@test "multiple services: reset-if-up" {
	run ./genv service up beanstalk-console dynamodb-admin
	[ "$status" -eq 0 ]
	run ./genv service reset-if-up beanstalk-console dynamodb-admin
	[ "$status" -eq 0 ]
	run ./genv service status beanstalk-console dynamodb-admin
	[ "$status" -eq 0 ]
	egrep "beanstalk-console\s+Up" <<< "$output"
	egrep "dynamodb-admin\s+Up" <<< "$output"
}

@test "multiple services: destroy-if-up" {
	run ./genv service destroy-if-up beanstalk-console dynamodb-admin
	[ "$status" -eq 0 ]
	run ./genv service status beanstalk-console dynamodb-admin
	[ "$status" -eq 0 ]
	egrep "beanstalk-console\s+Down" <<< "$output"
	egrep "dynamodb-admin\s+Down" <<< "$output"
}

@test "multiple services: clean-if-up" {
	run ./genv service up sqs-admin ssh-agent
	[ "$status" -eq 0 ]
	run ./genv service clean-if-up sqs-admin ssh-agent
	[ "$status" -eq 0 ]
	run ./genv service status sqs-admin ssh-agent
	[ "$status" -eq 0 ]
	egrep "sqs-admin\s+Down" <<< "$output"
	egrep "ssh-agent\s+Down" <<< "$output"
}
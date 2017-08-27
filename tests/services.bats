#!/usr/bin/env bats

setup() {
	load helper
	export HARPOON_USE_EMOJI=false
}

@test "service exists" {
	setHarpoonRoots
	harpoonLoad services/services.sh
	svcRoot=$(serviceRoot mysql)
	[ $? -eq 0 ]
	[ "$svcRoot" != "" ]
}

@test "mysql help" {
	run ./harpoon mysql:help
	[ "$status" -eq 0 ]
	grep "MySQL Client" <<< "$output"
}

@test "service status - up" {
	run ./harpoon cadvisor:up
	[ "$status" -eq 0 ]
	run ./harpoon cadvisor:status
	[ "$status" -eq 0 ]
	egrep "cadvisor\s+Up" <<< "$output"
	run ./harpoon services:status
	[ "$status" -eq 0 ]
	egrep "cadvisor\s+Up" <<< "$output"
}

@test "service reset" {
	run ./harpoon cadvisor:reset
	[ "$status" -eq 0 ]
	run ./harpoon cadvisor:status
	[ "$status" -eq 0 ]
	egrep "cadvisor\s+Up" <<< "$output"
}

@test "service status - down" {
	run ./harpoon cadvisor:down
	[ "$status" -eq 0 ]
	run ./harpoon cadvisor:status
	[ "$status" -eq 1 ]
	egrep "cadvisor\s+Down" <<< "$output"
	run ./harpoon services:status
	[ "$status" -eq 0 ]
	egrep "cadvisor\s+Down" <<< "$output"
}

@test "service destroy" {
	run ./harpoon redis:up
	[ "$status" -eq 0 ]
	run ./harpoon redis:destroy
	[ "$status" -eq 0 ]
	run ./harpoon redis:status
	[ "$status" -eq 1 ]
	egrep "redis\s+Down" <<< "$output"
}

@test "service clean" {
	run ./harpoon redis:up
	[ "$status" -eq 0 ]
	run ./harpoon redis:clean
	[ "$status" -eq 0 ]
	run ./harpoon redis:status
	[ "$status" -eq 1 ]
	egrep "redis\s+Down" <<< "$output"
}

@test "multiple service statuses - up" {
	run ./harpoon service up portainer mailhog
	[ "$status" -eq 0 ]
	run ./harpoon service status portainer
	[ "$status" -eq 0 ]
	egrep "portainer\s+Up" <<< "$output"
	run ./harpoon service status mailhog
	[ "$status" -eq 0 ]
	egrep "mailhog\s+Up" <<< "$output"
	run ./harpoon service status portainer mailhog
	[ "$status" -eq 0 ]
	egrep "portainer\s+Up" <<< "$output"
	egrep "mailhog\s+Up" <<< "$output"
}

@test "multiple service statuses - down" {
	run ./harpoon service down portainer mailhog
	[ "$status" -eq 0 ]
	run ./harpoon service status portainer
	[ "$status" -eq 0 ]
	egrep "portainer\s+Down" <<< "$output"
	run ./harpoon service status mailhog
	[ "$status" -eq 0 ]
	egrep "mailhog\s+Down" <<< "$output"
	run ./harpoon service status portainer mailhog
	[ "$status" -eq 0 ]
	egrep "portainer\s+Down" <<< "$output"
	egrep "mailhog\s+Down" <<< "$output"
}

@test "multiple services: up-if-down" {
	run ./harpoon service up-if-down portainer mailhog
	[ "$status" -eq 0 ]
	run ./harpoon service status portainer mailhog
	[ "$status" -eq 0 ]
	egrep "portainer\s+Up" <<< "$output"
	egrep "mailhog\s+Up" <<< "$output"
}

@test "multiple services: down-if-up" {
	run ./harpoon service down-if-up portainer mailhog
	[ "$status" -eq 0 ]
	run ./harpoon service status portainer mailhog
	[ "$status" -eq 0 ]
	egrep "portainer\s+Down" <<< "$output"
	egrep "mailhog\s+Down" <<< "$output"
}

@test "multiple services: reset-if-up" {
	run ./harpoon service up beanstalk-console dynamodb-admin
	[ "$status" -eq 0 ]
	run ./harpoon service reset-if-up beanstalk-console dynamodb-admin
	[ "$status" -eq 0 ]
	run ./harpoon service status beanstalk-console dynamodb-admin
	[ "$status" -eq 0 ]
	egrep "beanstalk-console\s+Up" <<< "$output"
	egrep "dynamodb-admin\s+Up" <<< "$output"
}

@test "multiple services: destroy-if-up" {
	run ./harpoon service destroy-if-up beanstalk-console dynamodb-admin
	[ "$status" -eq 0 ]
	run ./harpoon service status beanstalk-console dynamodb-admin
	[ "$status" -eq 0 ]
	egrep "beanstalk-console\s+Down" <<< "$output"
	egrep "dynamodb-admin\s+Down" <<< "$output"
}

@test "multiple services: clean-if-up" {
	run ./harpoon service up sqs-admin ssh-agent
	[ "$status" -eq 0 ]
	run ./harpoon service clean-if-up sqs-admin ssh-agent
	[ "$status" -eq 0 ]
	run ./harpoon service status sqs-admin ssh-agent
	[ "$status" -eq 0 ]
	egrep "sqs-admin\s+Down" <<< "$output"
	egrep "ssh-agent\s+Down" <<< "$output"
}
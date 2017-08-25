#!/usr/bin/env bats

setup() {
	load helper
}

@test "task exists" {
	setHarpoonRoots
	harpoonLoad tasks/tasks.sh
	taskExists aws
	[ $? -eq 0 ]
	[ "${TASK_ROOT}" != "" ]
}

@test "aws help" {
	run ./harpoon help aws
	[ "$status" -eq 0 ]
	grep "AWS CLI" <<< "$output"
}
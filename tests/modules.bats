#!/usr/bin/env bats

setup() {
	load helper
}

@test "task exists" {
	set_harpoon_roots
	harpoon_load tasks/tasks.sh
	task_exists aws
	[ $? -eq 0 ]
	[ "${TASK_ROOT}" != "" ]
}

@test "aws help" {
	run ./harpoon help aws
	[ "$status" -eq 0 ]
	grep "AWS CLI" <<< "$output"
}
#!/usr/bin/env bats

setup() {
	load helper
}

@test "task exists" {
	setGenvRoots
	genvLoad tasks/tasks.sh
	taskExists aws
	[ $? -eq 0 ]
	[ "${TASK_ROOT}" != "" ]
}

@test "aws help" {
	run ./genv help aws
	[ "$status" -eq 0 ]
	grep "AWS CLI" <<< "$output"
}

@test "jq args" {
	run ./genv jq -c -r '. | keys_unsorted' <<< '{"a":1}'
	[ "$status" -eq 0 ]
	grep '["a"]' <<< "$output"
}

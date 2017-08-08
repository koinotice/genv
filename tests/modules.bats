#!/usr/bin/env bats

setup() {
	load helper
}

@test "module exists" {
	set_harpoon_roots
	harpoon_load modules/modules.sh
	module_exists aws
	[ $? -eq 0 ]
	[ "${MODULE_ROOT}" != "" ]
}

@test "aws help" {
	run ./harpoon help aws
	[ "$status" -eq 0 ]
	grep "AWS CLI" <<< "$output"
}
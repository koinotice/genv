#!/usr/bin/env bash

httpie() {
	printDebug "httpie args: $@"
	dockerRun -i alpine/httpie $@
}

httpie_no_input() {
	printDebug "httpie args: $@"
	dockerRun alpine/httpie $@
}
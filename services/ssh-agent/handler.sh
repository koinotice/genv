#!/usr/bin/env bash

set -e

case "$command" in
	ssh-agent:add) ## <key-filename> %% Add SSH key to agent
		docker run -u 1001 --rm -v sshagent_ssh:/ssh -v $HOME:$HOME -it whilp/ssh-agent:latest ssh-add $HOME/.ssh/${2} ;;
esac

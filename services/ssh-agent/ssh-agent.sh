#!/usr/bin/env bash

set -e

ssh-agent:add() {
	docker run -u 1001 --rm -v sshagent_ssh:/ssh -v $HOME:$HOME -it whilp/ssh-agent:latest ssh-add $HOME/.ssh/${2}
}
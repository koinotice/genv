#!/usr/bin/env bash
echo 333${command}333
case "${command}" in

	gocron:cli) ## [<arg>...] %% Redis CLI
		$(serviceDockerComposeExec gocron) gocron  ${args} ;;

	gocron:node)
	    echo 333${command}333

	    nohup ./gocron-node & ;;

	*)
        serviceHelp gocron


esac

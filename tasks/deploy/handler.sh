#!/usr/bin/env bash

ecsDeployWait() {
	local ecsWait="ecs wait services-stable --cluster ${1} --services ${2}"

	if [ ! ${AWS_REGION:-} ]; then
		aws_cli --region us-east-1 ${ecsWait}
	else
		aws_cli ${ecsWait}
	fi
}

case "${command}" in
	deploy:ecs:wait) ## <cluster-name> <service-name> %% ⌚️  Wait for an ECS service to become stable
		ecsDeployWait ${args} ;;

	*)
		taskHelp
esac

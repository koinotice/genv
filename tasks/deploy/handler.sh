#!/usr/bin/env bash

ecs_deploy_wait() {
	ECS_WAIT="ecs wait services-stable --cluster ${1} --services ${2}"

	if [ ! ${AWS_REGION:-} ]; then
		aws_cli --region us-east-1 ${ECS_WAIT}
	else
		aws_cli ${ECS_WAIT}
	fi
}

case "${command}" in
	deploy:ecs:wait) ## <cluster-name> <service-name> %% ⌚️  Wait for an ECS service to become stable
		ecs_deploy_wait ${args} ;;

	*)
		task_help
esac

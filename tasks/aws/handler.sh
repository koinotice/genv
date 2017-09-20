#!/usr/bin/env bash

stop_all_tasks() {
	cluster_name="${1}"
	task_arns="$(aws_cli ecs list-tasks --cluster "${cluster_name}" | jq_cli -r '.taskArns[]' )"
	if [[ "${task_arns}" ]]; then
		for arn in ${task_arns}; do
			aws_cli ecs stop-task --cluster "${cluster_name}" --task "$arn"
		done
	fi
}

case "${command}" in
	aws) ## [options] <command> <subcommand> [<subcommand> ...] [parameters] %% AWS CLI
		aws_cli "${args}" ;;
	aws:ecs:stop-all-tasks) ## <cluster-name> %% Stop all running tasks in an ECS cluster
		stop_all_tasks "${args}" ;;
esac

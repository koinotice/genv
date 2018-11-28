#!/usr/bin/env bash

case "${command}" in
	localstack:aws) ## [options] <command> <subcommand> [<subcommand> ...] [parameters] %% AWS CLI (with endpoint-url set based on command)
		printInfo "AWS Region: ${AWS_REGION}"

		IFS=', ' read -r -a argsarray <<< "$args"

		if [ ! ${argsarray:-} ]; then
			aws_cli help
			exit 1
		fi

		HAS_OPTIONS=$(echo ${argsarray:0} | grep -e '^--') || true

		if [ ${HAS_OPTIONS} ]; then
			COMMAND=${argsarray:1}
		else
			COMMAND=${argsarray:0}
		fi

		ENDPOINT_URL="http://localstack.${GENV_INT_DOMAIN}:"

		case "${COMMAND}" in
			apigateway)
				ENDPOINT_URL+=4567 ;;

			kinesis)
				ENDPOINT_URL+=4568 ;;

			dynamodb)
				ENDPOINT_URL+=4569 ;;

			dynamodbstreams)
				ENDPOINT_URL+=4570 ;;

			es)
				ENDPOINT_URL+=4571 ;;

			s3)
				ENDPOINT_URL+=4572 ;;

			firehose)
				ENDPOINT_URL+=4573 ;;

			lambda)
				ENDPOINT_URL+=4574 ;;

			sns)
				ENDPOINT_URL+=4575 ;;

			sqs)
				ENDPOINT_URL+=4576 ;;

			redshift)
				ENDPOINT_URL+=4577 ;;

			ses)
				ENDPOINT_URL+=4579 ;;

			route53)
				ENDPOINT_URL+=4580 ;;

			cloudformation)
				ENDPOINT_URL+=4581 ;;

			cloudwatch)
				ENDPOINT_URL+=4582 ;;

			*)
		esac

		printInfo "Endpoint URL: ${ENDPOINT_URL}\n"

		aws_cli --endpoint-url ${ENDPOINT_URL} --region ${AWS_REGION} ${args}
		;;

	*)
		serviceHelp localstack
esac

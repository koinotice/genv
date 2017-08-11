#!/usr/bin/env bash

export LS_AWS="docker run --rm -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_REGION -v $HOME/.aws:/root/.aws -v $PWD:$PWD -w $PWD cgswong/aws:aws"

case "${command:-}" in
	localstack:aws) ## [options] <command> <subcommand> [<subcommand> ...] [parameters] %% AWS CLI (with endpoint-url set based on command)
		print_info "AWS Region: ${AWS_REGION}"

		IFS=', ' read -r -a argsarray <<< "$args"

		if [ ! ${argsarray:-} ]; then
			${LS_AWS} help
			exit 1
		fi

		HAS_OPTIONS=$(echo ${argsarray:0} | grep -e '^--') || true

		if [ ${HAS_OPTIONS} ]; then
			COMMAND=${argsarray:1}
		else
			COMMAND=${argsarray:0}
		fi

		ENDPOINT_URL='http://localstack.harpoon:'

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

		print_info "Endpoint URL: ${ENDPOINT_URL}\n"

		${LS_AWS} --endpoint-url ${ENDPOINT_URL} --region ${AWS_REGION} ${args}
		;;

	*)
		service_help localstack
esac

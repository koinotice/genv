#!/usr/bin/env bash

# todo: validate SLACK_WEBHOOK_URL and DATADOG_API_KEY are set

DATADOG_EVENTS_URL="https://app.datadoghq.com/api/v1/events?api_key=${DATADOG_API_KEY}"

deploy_msg_text() {
	echo "\``whoami`\` deployed \`${PROJECT}\` version \`${PROJECT_VERSION}\` to *\`${DEPLOY_ENV}\`*\nBranch: \`${1}\`\nCommit: \`${VCS_REVISION}\`\nBuild Number: \`${BUILD_NUMBER}\`"
}

notify_rollbar() {
	curl https://api.rollbar.com/api/1/deploy/ \
	-F access_token=${ROLLBAR_ACCESS_TOKEN} \
	-F environment=${DEPLOY_ENV} \
	-F revision=${VCS_REVISION} \
	-F local_username=`whoami` \
	-F comment="Build Number: ${BUILD_NUMBER}, Project Version: ${PROJECT_VERSION}"
}

notify_datadog() {
	case "$1" in
		start)
			title="Deployment Started..."
			alert_type="info"
			;;
		success)
			title="Deployment Success!"
			alert_type="success"
			;;
		failure)
			title="Deployment FAILURE!"
			alert_type="error"
			;;
		*)
			title="Deployment Unknown State!?"
			alert_type="warning"
	esac

	TEXT=$(deploy_msg_text ${VCS_BRANCH})

	DD_MSG=$(cat <<-END
	{
    	"title": "${title}",
    	"text": "${TEXT}",
    	"tags": ["env:${DEPLOY_ENV}", "project:${PROJECT}"],
    	"alert_type": "${alert_type}",
    	"aggregation_key": "${VCS_REVISION}"
	}
	END
	)

	echo "${DD_MSG}" | harpoon http ${DATADOG_EVENTS_URL}
}

notify_slack() {
	case "$1" in
		start)
			msg="Deployment Started... :continue:"
			color="#447EA6"
			;;
		success)
			msg="Deployment Success! :successful:"
			color="good"
			;;
		failure)
			msg="Deployment FAILURE! :failed:"
			color="danger"
			;;
		*)
			msg="Deployment Unknown State!? :unknown:"
			color="warning"
	esac

	FALLBACK=$(deploy_msg_text ${VCS_BRANCH})
	SLACK_TEXT="\"text\": \"${FALLBACK}\""

	SLACK_MSG=$(cat <<-END
	"attachments": [
		{
			"fallback": "${FALLBACK}",
			"color": "${color}",
			"title": "${PROJECT_TITLE} ${msg}",
			"fields": [
				{
					"title": "Environment",
					"value": "<https://${VCS_HOST}/${REPO_ROOT}/environments|${DEPLOY_ENV}>",
					"short": true
				},
				{
					"title": "Version",
					"value": "${PROJECT_VERSION}",
					"short": true
				},
				{
					"title": "Build Number",
					"value": "<https://${VCS_HOST}/${REPO_ROOT}/pipelines/${BUILD_NUMBER}|${BUILD_NUMBER}>",
					"short": true
				},
				{
					"title": "Branch",
					"value": "<https://${VCS_HOST}/${REPO_ROOT}/tree/${VCS_BRANCH}|${VCS_BRANCH}>",
					"short": false
				},
				{
					"title": "Commit",
					"value": "<https://${VCS_HOST}/${REPO_ROOT}/commit/${VCS_REVISION}|${VCS_REVISION}>",
					"short": false
				}
			]
		}
	]
	END
	)

	if [ "$DEPLOY_ENV" == "production" ]; then
		# notify #deployments
		echo "{${SLACK_MSG}}" | harpoon http ${SLACK_WEBHOOK_URL}
	fi

	if [ "$DEPLOY_ENV" == "staging" ]; then
		echo "{\"channel\": \"#deployments-staging\", ${SLACK_MSG}}" | harpoon http ${SLACK_WEBHOOK_URL}
	fi

	echo "{\"channel\": \"${SLACK_CHANNEL}\", ${SLACK_MSG}}" | harpoon http ${SLACK_WEBHOOK_URL}
}

case "${command:-}" in
	notify:rollbar) ## %% 📣  Send a deployment notification to Rollbar
		notify_rollbar ;;

	notify:datadog) ## <start | success | failure> %% 📣  Send a deployment notification to Datadog
		notify_datadog ${args} ;;

	notify:slack) ## <start | success | failure> %% 📣  Send deployment notifications to the appropriate Slack channels
		notify_slack ${args} ;;

	*)
		module_help
esac

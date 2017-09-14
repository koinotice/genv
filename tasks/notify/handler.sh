#!/usr/bin/env bash

# todo: validate SLACK_WEBHOOK_URL and DATADOG_API_KEY are set

DATADOG_EVENTS_URL="https://app.datadoghq.com/api/v1/events?api_key=${DATADOG_API_KEY}"

deployMsgText() {
	echo "\``whoami`\` deployed \`${PROJECT}\` version \`${PROJECT_VERSION}\` to *\`${DEPLOY_ENV}\`*\nBranch: \`${1}\`\nCommit: \`${VCS_REVISION}\`\nBuild Number: \`${BUILD_NUMBER}\`"
}

notifyRollbar() {
	curl https://api.rollbar.com/api/1/deploy/ \
	-F access_token=${ROLLBAR_ACCESS_TOKEN} \
	-F environment=${DEPLOY_ENV} \
	-F revision=${VCS_REVISION} \
	-F local_username=`whoami` \
	-F comment="Build Number: ${BUILD_NUMBER}, Project Version: ${PROJECT_VERSION}"
}

notifyDatadog() {
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

	local text=$(deployMsgText ${VCS_BRANCH})

	local ddMsg=$(cat <<-END
	{
    	"title": "${title}",
    	"text": "${text}",
    	"tags": ["env:${DEPLOY_ENV}", "project:${PROJECT}"],
    	"alert_type": "${alert_type}",
    	"aggregation_key": "${VCS_REVISION}"
	}
	END
	)

	echo "${ddMsg}" | httpie ${DATADOG_EVENTS_URL}
}

notifySlack() {
	case "$1" in
		start)
			local msg="Deployment Started... :continue:"
			local color="#447EA6"
			;;
		success)
			local msg="Deployment Success! :successful:"
			local color="good"
			;;
		failure)
			local msg="Deployment FAILURE! :failed:"
			local color="danger"
			;;
		*)
			local msg="Deployment Unknown State!? :unknown:"
			local color="warning"
	esac

	local fallback=$(deployMsgText ${VCS_BRANCH})
	local slackText="\"text\": \"${fallback}\""

	local slackMsg=$(cat <<-END
	"attachments": [
		{
			"fallback": "${fallback}",
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

	#todo create map of environments to slack channels and allow customization

	if [ "$DEPLOY_ENV" == "production" ]; then
		# notify #deployments
		echo "{${slackMsg}}" | httpie ${SLACK_WEBHOOK_URL}
	fi

	if [ "$DEPLOY_ENV" == "staging" ]; then
		echo "{\"channel\": \"#deployments-staging\", ${slackMsg}}" | httpie ${SLACK_WEBHOOK_URL}
	fi

	if [ "$DEPLOY_ENV" == "acceptance" ]; then
		echo "{\"channel\": \"#deployments-accept\", ${slackMsg}}" | httpie ${SLACK_WEBHOOK_URL}
	fi

	echo "{\"channel\": \"${SLACK_CHANNEL}\", ${slackMsg}}" | httpie ${SLACK_WEBHOOK_URL}
}

case "${command}" in
	notify:rollbar) ## %% 📣  Send a deployment notification to Rollbar
		notifyRollbar ;;

	notify:datadog) ## <start | success | failure> %% 📣  Send a deployment notification to Datadog
		notifyDatadog ${args} ;;

	notify:slack) ## <start | success | failure> %% 📣  Send deployment notifications to the appropriate Slack channels
		notifySlack ${args} ;;

	*)
		taskHelp
esac

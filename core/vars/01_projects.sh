#!/usr/bin/env bash

export NOW=$(date -u +"%Y-%m-%dT%H-%M-%SZ")

if [ ! -v HARPOON_TEMP ]; then
	export HARPOON_TEMP=$PWD/.harpoon
fi

printDebug "HARPOON_TEMP: $HARPOON_TEMP"

export IS_GIT_REPO=$(git status > /dev/null 2>&1 && echo true || echo false)

printDebug "IS_GIT_REPO: $IS_GIT_REPO"

if [[ ! -v REPO_ROOT && ${IS_GIT_REPO} == true ]]; then
	export REPO_ROOT=$(git remote show -n origin | grep Push | awk -F: '{print $3}' | sed 's/.git$//g')
fi

printDebug "REPO_ROOT: ${REPO_ROOT:-}"

if [[ ! -v REPO_NAME && ${IS_GIT_REPO} == true ]]; then
	export REPO_NAME=$(echo ${REPO_ROOT} | awk -F '/' '{print $NF}')
fi

printDebug "REPO_NAME: ${REPO_NAME:-}"

if [ ! -v PROJECT ]; then
	if [[ ${IS_GIT_REPO} == true ]]; then
		export PROJECT=${REPO_NAME:-}
	else
		export PROJECT=$(basename $PWD)
	fi
fi

printDebug "PROJECT: $PROJECT"

if [ ! -v PROJECT_TITLE ]; then
	export PROJECT_TITLE="${REPO_ROOT:-}"
fi

printDebug "PROJECT_TITLE: $PROJECT_TITLE"

if [ ! -v ROOT_TASKS_FILE ]; then
	if [ -f "./tasks.sh" ]; then
		export ROOT_TASKS_FILE="./tasks.sh"
	elif [ -f "../tasks.sh" ]; then
		export ROOT_TASKS_FILE="../tasks.sh"
	fi
fi

printDebug "ROOT_TASKS_FILE: ${ROOT_TASKS_FILE:-}"

if [ ! -v PROJECT_TASK_PREFIX ]; then
	export PROJECT_TASK_PREFIX=t
fi

printDebug "PROJECT_TASK_PREFIX: $PROJECT_TASK_PREFIX"

if [ -v GITLAB_USER_EMAIL ]; then
	export ME="${GITLAB_USER_EMAIL}"
elif [[ ${IS_GIT_REPO} == true ]]; then
	export ME=$(git config --get user.name)
else
	export ME=""
fi

printDebug "ME: $ME"

if [[ ${IS_GIT_REPO} != false ]]; then
	export GIT_TAG=$(git describe --exact-match --tags 2>/dev/null)
	printDebug "GIT_TAG: $GIT_TAG"

	export GIT_BRANCH=$(git branch | grep \* | cut -d ' ' -f2)
	printDebug "GIT_BRANCH: $GIT_BRANCH"

	export GIT_REVISION=$(git rev-parse --short HEAD)
	printDebug "GIT_REVISION: $GIT_REVISION"
fi

# set vcs_branch
if [ -v CI_COMMIT_REF_NAME ]; then
	export VCS_BRANCH=${CI_COMMIT_REF_NAME}
elif [ -v GIT_BRANCH ]; then
	export VCS_BRANCH=${GIT_BRANCH}
else
	export VCS_BRANCH='n/a'
fi

printDebug "VCS_BRANCH: $VCS_BRANCH"

# set tag_name (for docker images)
if [ -v TAG_WITH_LATEST_GIT_TAG ]; then
  # Detect the latest git version tag and go one higher
  export TAG_NAME="$(git fetch --tags && git tag | sort -s -t- -k 2,2nr | sort -t. -s -k 1,1nr -k 2,2nr -k 3,3nr -k 4,4nr | head -1)"
  [[ "${TAG_NAME}" ]] || export TAG_NAME='0.0.1'
  export NEXT_GIT_TAG="$(echo "${TAG_NAME}" | awk -F. -v OFS=. '{print $1,$2,++$3}')"

elif [ -v TAG_WITH_GIT_REVISION ]; then
	export TAG_NAME=${GIT_REVISION}

elif [ -v CI_COMMIT_REF_SLUG ]; then
	export TAG_NAME=${CI_COMMIT_REF_SLUG}

elif [[ "${GIT_TAG:-}" != "" ]]; then
	export TAG_NAME=${GIT_TAG}

elif [ -v GIT_BRANCH ]; then
	# lowercase, and replace '/' and '_' with '-' (like CI_COMMIT_REF_SLUG)
	export TAG_NAME=$(echo "${GIT_BRANCH,,}" | sed -e 's/[\/_]/-/g')

else
	export TAG_NAME=${NOW}
fi

printDebug "TAG_NAME: $TAG_NAME"

# set build_number
if [ -v CI_PIPELINE_ID ]; then
	export BUILD_NUMBER=${CI_PIPELINE_ID}
else
	export BUILD_NUMBER='n/a'
fi

printDebug "BUILD_NUMBER: $BUILD_NUMBER"

# set project_version
if [ -v CI_COMMIT_TAG ]; then
	export PROJECT_VERSION=${CI_COMMIT_TAG}
elif [ -v GIT_TAG ]; then
	export PROJECT_VERSION=${GIT_TAG}
else
	export PROJECT_VERSION='n/a'
fi

printDebug "PROJECT_VERSION: $PROJECT_VERSION"

# set vcs_revision
if [ -v CI_COMMIT_SHA ]; then
	export VCS_REVISION=${CI_COMMIT_SHA}
elif [ -v GIT_REVISION ]; then
	export VCS_REVISION=${GIT_REVISION}
else
	export VCS_REVISION='UNKNOWN'
fi

printDebug "VCS_REVISION: $VCS_REVISION"

# Set docker-compose project name
# We MUST differentiate between environments where we need to support concurrent compose instances for the same project
if [ -v CI_SERVER ]; then
	export COMPOSE_PROJECT_NAME=$(echo "${PROJECT}${CI_PIPELINE_ID:-}" | sed -e 's/[-_]//g')
else
	export COMPOSE_PROJECT_NAME=$(echo "${PROJECT}" | sed -e 's/[-_]//g')
fi

printDebug "COMPOSE_PROJECT_NAME: $COMPOSE_PROJECT_NAME"

if [ ! -v DEPLOY_ENV ]; then
	export DEPLOY_ENV=development
fi

printDebug "DEPLOY_ENV: $DEPLOY_ENV"

if [ ! -v OPS_ROOT ]; then
	export OPS_ROOT=$PWD
fi

printDebug "OPS_ROOT: $OPS_ROOT"

if [ ! -v SECRETS_DIR ]; then
	export SECRETS_DIR=${OPS_ROOT}/secrets/${DEPLOY_ENV}
fi

printDebug "SECRETS_DIR: $SECRETS_DIR"

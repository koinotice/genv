#!/usr/bin/env bash

#% 🔺 NOW %% The current datetime %% date -u +"%Y-%m-%dT%H-%M-%SZ"
export NOW=$(date -u +"%Y-%m-%dT%H-%M-%SZ")

#% 🔺 HARPOON_TEMP %% Path to Harpoon temp directory %% $PWD/.harpoon
if [ ! -v HARPOON_TEMP ]; then
	export HARPOON_TEMP=$PWD/.harpoon
fi

printDebug "HARPOON_TEMP: $HARPOON_TEMP"

#% 🔹 IS_GIT_REPO %% Is the current working directory a git repo? %% false
export IS_GIT_REPO=$(git status > /dev/null 2>&1 && echo true || echo false)

printDebug "IS_GIT_REPO: $IS_GIT_REPO"

#% 🔺 REPO_ROOT %% Relative path to git repository from $VCS_HOST
if [[ ! -v REPO_ROOT && ${IS_GIT_REPO} == true ]]; then
	export REPO_ROOT=$(git remote show -n origin | grep Push | awk -F: '{print $3}' | sed 's/.git$//g')
fi

printDebug "REPO_ROOT: ${REPO_ROOT:-}"

#% 🔺 REPO_NAME %% Name of the git repository as served from $VCS_HOST
if [[ ! -v REPO_NAME && ${IS_GIT_REPO} == true ]]; then
	export REPO_NAME=$(echo ${REPO_ROOT} | awk -F '/' '{print $NF}')
fi

printDebug "REPO_NAME: ${REPO_NAME:-}"

#% 🔺 PROJECT %% Machine-readable project name %% $REPO_NAME | basename $PWD
if [ ! -v PROJECT ]; then
	if [[ ${IS_GIT_REPO} == true ]]; then
		export PROJECT=${REPO_NAME:-}
	else
		export PROJECT=$(basename $PWD)
	fi
fi

printDebug "PROJECT: $PROJECT"

#% 🔺 PROJECT_TITLE %% Human-friendly project name %% $REPO_ROOT | ""
if [ ! -v PROJECT_TITLE ]; then
	export PROJECT_TITLE="${REPO_ROOT:-}"
fi

printDebug "PROJECT_TITLE: $PROJECT_TITLE"

#% 🔺 ROOT_TASKS_FILE %% Path and filename of shell script containing project tasks %% ./tasks.sh
if [ ! -v ROOT_TASKS_FILE ]; then
	if [ -f "./tasks.sh" ]; then
		export ROOT_TASKS_FILE="./tasks.sh"
	elif [ -f "../tasks.sh" ]; then
		export ROOT_TASKS_FILE="../tasks.sh"
	fi
fi

printDebug "ROOT_TASKS_FILE: ${ROOT_TASKS_FILE:-}"

#% 🔺 PROJECT_TASK_PREFIX %% Command prefix for project tasks %% t
if [ ! -v PROJECT_TASK_PREFIX ]; then
	export PROJECT_TASK_PREFIX=t
fi

printDebug "PROJECT_TASK_PREFIX: $PROJECT_TASK_PREFIX"

#% 🔹 ME %% Name of current user %% $GITLAB_USER_EMAIL | git config user.name | ""
if [ -v GITLAB_USER_EMAIL ]; then
	export ME="${GITLAB_USER_EMAIL}"
elif [[ ${IS_GIT_REPO} == true ]]; then
	export ME=$(git config --get user.name)
else
	export ME=""
fi

printDebug "ME: $ME"

if [[ ${IS_GIT_REPO} != false ]]; then

#% 🔹 GIT_TAG %% Current git tag
	export GIT_TAG=$(git describe --exact-match --tags 2>/dev/null)
	printDebug "GIT_TAG: $GIT_TAG"

#% 🔹 GIT_BRANCH %% Current git branch
	export GIT_BRANCH=$(git branch | grep \* | cut -d ' ' -f2)
	printDebug "GIT_BRANCH: $GIT_BRANCH"

#% 🔹 GIT_REVISION %% Current git revision (hash)
	export GIT_REVISION=$(git rev-parse --short HEAD)
	printDebug "GIT_REVISION: $GIT_REVISION"
fi

# set vcs_branch
#% 🔹 VCS_BRANCH %% Current git branch as recognized by CI system %% n/a
if [ -v CI_COMMIT_REF_NAME ]; then
	export VCS_BRANCH=${CI_COMMIT_REF_NAME}

elif [ -v TRAVIS ]; then
	export VCS_BRANCH=${TRAVIS_PULL_REQUEST_BRANCH:-$TRAVIS_BRANCH}

elif [ -v GIT_BRANCH ]; then
	export VCS_BRANCH=${GIT_BRANCH}

else
	export VCS_BRANCH='n/a'
fi

printDebug "VCS_BRANCH: $VCS_BRANCH"

# set tag_name (for docker images)
#% 🔹 TAG_NAME %% Tag name for use when building Docker images %% $GIT_TAG | $NOW
#% 🔺 TAG_WITH_LATEST_GIT_TAG %% Use next semantic version when tagging Docker images
if [ -v TAG_WITH_LATEST_GIT_TAG ]; then
  # Detect the latest git version tag and go one higher
  export TAG_NAME="$(git fetch --tags && git tag | sort -s -t- -k 2,2nr | sort -t. -s -k 1,1nr -k 2,2nr -k 3,3nr -k 4,4nr | head -1)"
  [[ "${TAG_NAME}" ]] || export TAG_NAME='0.0.1'
  export NEXT_GIT_TAG="$(echo "${TAG_NAME}" | awk -F. -v OFS=. '{print $1,$2,++$3}')"

#% 🔺 TAG_WITH_GIT_REVISION %% Use git revision tagging Docker images
elif [ -v TAG_WITH_GIT_REVISION ]; then
	export TAG_NAME=${GIT_REVISION}

elif [ -v CI_COMMIT_TAG ]; then
	export TAG_NAME=${CI_COMMIT_TAG}

elif [ -v CI_COMMIT_REF_SLUG ]; then
	export TAG_NAME=${CI_COMMIT_REF_SLUG}

elif [ -v TRAVIS ]; then
	export TAG_NAME=${TRAVIS_TAG:-$VCS_BRANCH}

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
#% 🔹 BUILD_NUMBER %% Current git branch as recognized by CI system %% $NOW
if [ -v CI_PIPELINE_ID ]; then
	export BUILD_NUMBER=${CI_PIPELINE_ID}
elif [ -v TRAVIS_BUILD_NUMBER ]; then
	export BUILD_NUMBER=${TRAVIS_BUILD_NUMBER}
else
	export BUILD_NUMBER='n/a'
fi

printDebug "BUILD_NUMBER: $BUILD_NUMBER"

# set project_version
#% 🔹 PROJECT_VERSION %% Current project version as recognized by CI system or git %% $GIT_TAG | n/a
if [ -v CI_COMMIT_TAG ]; then
	export PROJECT_VERSION=${CI_COMMIT_TAG}
elif [ -v TRAVIS_BRANCH ]; then
	export PROJECT_VERSION=${TRAVIS_BRANCH}
elif [ -v GIT_TAG ]; then
	export PROJECT_VERSION=${GIT_TAG}
else
	export PROJECT_VERSION='n/a'
fi

printDebug "PROJECT_VERSION: $PROJECT_VERSION"

# set vcs_revision
#% 🔹 VCS_REVISION %% Current VCS revision as recognized by CI system or git %% $GIT_REVISION | UNKNOWN
if [ -v CI_COMMIT_SHA ]; then
	export VCS_REVISION=${CI_COMMIT_SHA}
elif [ -v TRAVIS_COMMIT ]; then
	export VCS_REVISION=${TRAVIS_COMMIT}
elif [ -v GIT_REVISION ]; then
	export VCS_REVISION=${GIT_REVISION}
else
	export VCS_REVISION='UNKNOWN'
fi

printDebug "VCS_REVISION: $VCS_REVISION"

# Set docker-compose project name
# We MUST differentiate between environments where we need to support concurrent compose instances for the same project
#% 🔹 COMPOSE_PROJECT_NAME %% Docker Compose project name %% $PROJECT (without dashes or underscores)
if [ -v CI_SERVER ]; then
	export COMPOSE_PROJECT_NAME=$(echo "${PROJECT}${CI_PIPELINE_ID:-}" | sed -e 's/[-_]//g')
else
	export COMPOSE_PROJECT_NAME=$(echo "${PROJECT}" | sed -e 's/[-_]//g')
fi

printDebug "COMPOSE_PROJECT_NAME: $COMPOSE_PROJECT_NAME"

#% 🔺 DEPLOY_ENV %% Deployment environment %% development
if [ ! -v DEPLOY_ENV ]; then
	export DEPLOY_ENV=development
fi

printDebug "DEPLOY_ENV: $DEPLOY_ENV"

#% 🔺 OPS_ROOT %% Root directory for ops-related files %% $PWD
if [ ! -v OPS_ROOT ]; then
	export OPS_ROOT=$PWD
fi

printDebug "OPS_ROOT: $OPS_ROOT"

#% 🔺 SECRETS_DIR %% Directory for secret files (to be encrypted) %% $OPS_ROOT/secrets/$DEPLOY_ENV
if [ ! -v SECRETS_DIR ]; then
	export SECRETS_DIR=${OPS_ROOT}/secrets/${DEPLOY_ENV}
fi

printDebug "SECRETS_DIR: $SECRETS_DIR"

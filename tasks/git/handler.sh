#!/usr/bin/env bash

# Derive an SSH url for the origin
#% 🔹 ORIGIN_SSH_URL %% SSH URL for the git 'origin' remote
export ORIGIN_SSH_URL="$( git remote show origin | grep Push | awk '{print $3}' | sed 's/https:.*@/git@/' | sed 's|\.com/|.com:|' | sed 's|\.git/|.git|' )"

gitAddSSHOrigin() {
  git remote remove sshorigin || true
  git remote add sshorigin "${ORIGIN_SSH_URL}" || printPanic "Failed to add remote ${ORIGIN_SSH_URL}!"
  git fetch sshorigin || printPanic "Failed to fetch remote ${ORIGIN_SSH_URL}!" 
  git fetch sshorigin --tags || printPanic "Failed to fetch remote tags!"
}

gitAutoIncrementTag() {
  gitAddSSHOrigin || printPanic "Failed to add ssh remote!"
	git tag "${NEXT_GIT_TAG}" || printPanic "Failed to tag ${NEXT_GIT_TAG}!"
	git push sshorigin --tags || printPanic "Failed to push tags!"
}

case "${command}" in
	git:auto-increment-tag) ## %% 🏗  Auto increment the latest git tag
		gitAutoIncrementTag ;;

	git:add-ssh-origin) ## %% 🏗  Add an ssh remote for the origin
		gitAddSSHOrigin ;;

	*)
		taskHelp
esac

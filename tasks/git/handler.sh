#!/usr/bin/env bash

# Derive an SSH url for the origin
export ORIGIN_SSH_URL="$( git remote show origin | grep Push | awk '{print $3}' | sed 's/https:.*@/git@/' | sed 's|\.com/|.com:|' | sed 's|\.git/|.git|' )"

git_add_ssh_origin() {
  git remote remove sshorigin || true
  git remote add sshorigin "${ORIGIN_SSH_URL}" || { print_panic "Failed to add remote ${ORIGIN_SSH_URL}!" }
  git fetch sshorigin || { print_panic "Failed to fetch remote ${ORIGIN_SSH_URL}!"  }
  git fetch sshorigin --tags || { print_panic "Failed to fetch remote tags!" }
}

git_auto_increment_tag() {
  git_add_ssh_origin || { print_panic "Failed to add ssh remote!" }
	git tag "${NEXT_GIT_TAG}" || { print_panic "Failed to tag ${NEXT_GIT_TAG}!" }
	git push sshorigin --tags || { print_panic "Failed to push tags!" }
}

case "${command:-}" in
	git:auto-increment-tag) ## %% 🏗  Auto increment the latest git tag
		git_auto_increment_tag ;;

	git:add-ssh-origin) ## %% 🏗  Add an ssh remote for the origin
		git_add_ssh_origin ;;

	*)
		task_help
esac

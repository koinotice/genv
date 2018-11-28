#!/usr/bin/env bash

set -euo pipefail

if [ ! -v GENV_IMAGE ]; then
	export GENV_IMAGE=koinotice/genv:latest
fi

genv uninstall all

docker rmi ${GENV_IMAGE}

rm -fr $HOME/genv
sudo rm -f /usr/local/bin/genv

echo -e "\nIf you enabled tab completion, remove the following from your .bashrc, .bash_profile, or .zshrc:"
echo -e "\n\twhich genv > /dev/null && . \"\$(genv initpath)\"\n"
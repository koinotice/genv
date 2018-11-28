#!/usr/bin/env bash

set -euo pipefail

if [ ! -v GENV_IMAGE ]; then
	export GENV_IMAGE=koinotice/genv:latest
fi

docker pull ${GENV_IMAGE}

CID=$(docker create ${GENV_IMAGE})

docker cp ${CID}:/genv $HOME
docker rm -f ${CID}

sudo ln -fs $HOME/genv/genv /usr/local/bin/genv

genv install

if [ -d $HOME/genv/images ]; then
	genv docker:load
fi

echo -e "\nIf you would like to enable tab completion, add the following to your .bashrc, .bash_profile, or .zshrc:"
echo -e "\n\twhich genv > /dev/null && . \"\$(genv initpath)\"\n"
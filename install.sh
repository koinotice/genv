#!/usr/bin/env bash

set -euo pipefail

if [ ! -v HARPOON_IMAGE ]; then
	export HARPOON_IMAGE=wheniwork/harpoon:master
fi

docker pull ${HARPOON_IMAGE}

CID=$(docker create ${HARPOON_IMAGE})

docker cp ${CID}:/harpoon $HOME
docker rm -f ${CID}

sudo ln -fs $HOME/harpoon/harpoon /usr/local/bin/harpoon

harpoon install

if [ -d $HOME/harpoon/images ]; then
	harpoon docker:load
fi

echo -e "\nIf you would like to enable tab completion, add the following to your .bashrc, .bash_profile, or .zshrc:"
echo -e "\n\twhich harpoon > /dev/null && . \"\$(harpoon initpath)\"\n"
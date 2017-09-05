#!/usr/bin/env bash

set -euo pipefail

if [ ! -v HARPOON_IMAGE ]; then
	export HARPOON_IMAGE=wheniwork/harpoon:master
fi

harpoon uninstall all

docker rmi ${HARPOON_IMAGE}

rm -fr $HOME/harpoon
sudo rm -f /usr/local/bin/harpoon

echo -e "\nIf you enabled tab completion, remove the following from your .bashrc, .bash_profile, or .zshrc:"
echo -e "\n\twhich harpoon > /dev/null && . \"\$(harpoon initpath)\"\n"
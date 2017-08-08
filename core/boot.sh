#!/usr/bin/env bash

if [ -f ${HARPOON_ROOT}/harpoon.boot.sh ]; then
	source ${HARPOON_ROOT}/harpoon.boot.sh
fi

if [ -f /etc/harpoon.boot.sh ]; then
	source /etc/harpoon.boot.sh
fi

if [ -f $PWD/harpoon.boot.sh ]; then
	source $PWD/harpoon.boot.sh
fi

if [ -f $HOME/harpoon.boot.sh ]; then
	source $HOME/harpoon.boot.sh
fi
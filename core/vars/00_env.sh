#!/usr/bin/env bash

if [ -f ${HARPOON_ROOT}/harpoon.env.sh ]; then
	source ${HARPOON_ROOT}/harpoon.env.sh
fi

if [ -f /etc/harpoon.env.sh ]; then
	source /etc/harpoon.env.sh
fi

if [ -f $PWD/harpoon.env.sh ]; then
	source $PWD/harpoon.env.sh
fi

if [ -f $HOME/harpoon.env.sh ]; then
	source $HOME/harpoon.env.sh
fi
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
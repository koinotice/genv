#!/usr/bin/env bash

set -euo pipefail

HARPOON_IMAGE=wheniwork/harpoon:master

docker pull ${HARPOON_IMAGE}

CID=$(docker create ${HARPOON_IMAGE})

docker cp ${CID}:/harpoon $HOME
docker rm -f ${CID}

sudo ln -fs $HOME/harpoon/harpoon /usr/local/bin/harpoon

harpoon install
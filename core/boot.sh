#!/usr/bin/env bash

if [ -f ${GENV_ROOT}/genv.boot.sh ]; then
	source ${GENV_ROOT}/genv.boot.sh
fi

if [ -f /etc/genv.boot.sh ]; then
	source /etc/genv.boot.sh
fi

if [ -f $PWD/genv.boot.sh ]; then
	source $PWD/genv.boot.sh
fi

if [ -f $PWD/../genv.boot.sh ]; then
	source $PWD/../genv.boot.sh
fi

if [ -f $HOME/genv.boot.sh ]; then
	source $HOME/genv.boot.sh
fi
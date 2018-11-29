#!/usr/bin/env bash

if [ -f ${GENV_ROOT}/genv.env.sh ]; then
	source ${GENV_ROOT}/genv.env.sh
fi

if [ -f /etc/genv.env.sh ]; then
	source /etc/genv.env.sh
fi

if [ -f $PWD/genv.env.sh ]; then
	source $PWD/genv.env.sh
fi

if [ -f $PWD/../genv.env.sh ]; then
	source $PWD/../genv.env.sh
fi

if [ -f $HOME/genv.env.sh ]; then
    echo "${HOME}/genv.env.sh"
	source $HOME/genv.env.sh

fi
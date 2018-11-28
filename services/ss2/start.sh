#!/bin/bash
docker run -p 4430:12222 --restart=always -d koinotice/ss2 -s "ss://aes-256-cfb:biying2018@0.0.0.0:12222" -verbose
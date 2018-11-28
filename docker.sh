#!/usr/bin/env bash
docker build -t genv .

docker tag genv:latest koinotice/genv:latest
docker push koinotice/genv:latest
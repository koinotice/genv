FROM docker:stable-dind

RUN apk update && \
apk add bash make git openssh-client curl && \
apk add --no-cache py-pip && \
pip install docker-compose && \
rm -rf /var/cache/apk/* /var/tmp/* /tmp/* && \
touch /.genv-container

COPY . /genv

ENV PATH /genv:$PATH
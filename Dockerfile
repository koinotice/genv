FROM docker:stable-dind

RUN apk update && \
apk add bash git openssh-client && \
apk add --no-cache py-pip && \
pip install docker-compose && \
rm -rf /var/cache/apk/* /var/tmp/* /tmp/*

COPY . /harpoon

ENV PATH /harpoon:$PATH
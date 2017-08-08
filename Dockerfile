FROM docker:stable-dind

RUN apk update && \
apk add bash make git openssh-client curl && \
apk add --no-cache py-pip && \
pip install docker==2.4.2 && \
pip install docker-compose && \
rm -rf /var/cache/apk/* /var/tmp/* /tmp/*

COPY . /harpoon

ENV PATH /harpoon:$PATH
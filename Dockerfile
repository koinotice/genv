FROM docker:stable-dind

RUN apk update && \
apk add bash && \
apk add --no-cache py-pip && \
pip install docker-compose && \
rm -rf /var/cache/apk/* /var/tmp/* /tmp/*

COPY . /harpoon

ENV PATH /harpoon:$PATH
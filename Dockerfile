FROM docker:stable-dind

RUN apk update && mkdir -p /var/run /var/log/supervisor && \
apk add bash make git openssh-client curl supervisor dnsmasq && \
apk add --no-cache py-pip && \
pip install docker==2.4.2 && \
pip install docker-compose && \
rm -rf /var/cache/apk/* /var/tmp/* /tmp/* && \
touch /.harpoon-container

COPY . /harpoon

ENV PATH /harpoon:$PATH
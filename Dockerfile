FROM docker:stable-dind

RUN apk update && mkdir -p /etc/supervisor /var/log/supervisor && \
apk add bash make git openssh-client curl supervisor dnsmasq && \
apk add --no-cache py-pip && \
pip install docker==2.4.2 && \
pip install docker-compose && \
rm -rf /var/cache/apk/* /var/tmp/* /tmp/* && \
touch /.harpoon-container

COPY . /harpoon
COPY supervisord.conf /etc/supervisor/supervisord.conf

ENV PATH /harpoon:$PATH
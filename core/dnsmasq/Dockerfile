FROM jpillora/dnsmasq

RUN apk update && apk add --no-cache gettext

COPY dnsmasq.conf.template /etc/

CMD ["/bin/sh", "-c", "export NAMESERVER_IP=${NAMESERVER_IP} && envsubst < /etc/dnsmasq.conf.template > /etc/dnsmasq.conf && webproc --config /etc/dnsmasq.conf -- dnsmasq --no-daemon"]
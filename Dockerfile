FROM docker:17.03

ENV CUSTOM_DOMAIN

RUN apk update && \
apk add bash && \
apk add --no-cache py-pip && \
pip install docker-compose && \
rm -rf /var/cache/apk/* /var/tmp/* /tmp/*

COPY . /harpoon

WORKDIR /harpoon

ENTRYPOINT ["bash", "-c", "./harpoon"]
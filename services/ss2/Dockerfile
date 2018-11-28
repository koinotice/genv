
FROM golang:1.10.3-alpine3.8 AS builder

RUN apk upgrade --update \
    && apk add git \
    && go get github.com/riobard/go-shadowsocks2

FROM alpine:3.8

LABEL maintainer="mritd <mritd1234@gmail.com>"

ARG TZ="Asia/Shanghai"

ENV TZ ${TZ}

RUN apk upgrade --update \
    && apk add bash tzdata \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && rm -rf /var/cache/apk/*

COPY --from=builder /go/bin/go-shadowsocks2 /usr/bin/shadowsocks

ENTRYPOINT ["shadowsocks"]

#WORKDIR /app/shadowsocks
#CMD ["python", "-m", "shadowsocks.server", "-c", "config.json"]

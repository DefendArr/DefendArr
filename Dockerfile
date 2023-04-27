# Dockerfile
FROM alpine:latest

RUN apk update && apk add docker-cli curl jq

COPY ./check_leaks.sh /check_leaks.sh

ENTRYPOINT ["/bin/sh", "/check_leaks.sh"]

# Dockerfile
FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    curl \
    jq \
    docker.io

COPY check_leaks.sh /check_leaks.sh
RUN chmod +x /check_leaks.sh

ENTRYPOINT ["/check_leaks.sh"]

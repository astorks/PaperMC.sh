FROM ubuntu:20.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    jq \
    openjdk-11-jre \
  && rm -rf /var/lib/apt/lists/*

COPY ./papermc.sh /usr/local/bin

RUN chmod +x /usr/local/bin/papermc.sh

RUN useradd --create-home --shell /bin/bash minecraft \
 && mkdir -p /opt/papermc /var/opt/papermc \
 && chown -R minecraft /var/opt/papermc/

USER minecraft
WORKDIR /var/opt/papermc
VOLUME /var/opt/papermc
EXPOSE 25565

ENV PAPERMC_VERSION="1.16.3"
ENV PAPERMC_JAR_NAME="paperclip.jar"
ENV PAPERMC_MIN_MEMORY="1G"
ENV PAPERMC_MAX_MEMORY="1G"
ENV PAPERMC_HOST="0.0.0.0"
ENV PAPERMC_PORT=25565
ENV PAPERMC_MAX_PLAYERS=20
ENV PAPERMC_PLUGIN_DIR="./plugins/"
ENV PAPERMC_WORLD_DIR="./worlds/"
ENV PAPERMC_UPDATE_SECONDS=86400

ENTRYPOINT [ "papermc.sh" ]
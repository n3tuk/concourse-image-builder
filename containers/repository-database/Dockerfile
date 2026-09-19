FROM dhi.io/debian-base:trixie-debian13-dev

COPY common/assets/99-force-confdef /etc/apt/apt.conf.d/99-force-confdef
RUN apt-get update && apt-get upgrade --yes && apt-get clean
RUN apt-get install --no-install-recommends --assume-yes awscli-2 jq bsdutils uuid-runtime && apt-get clean

RUN mkdir -p /opt/resource /opt/lib
COPY scripts/bin/repository-database-check /opt/resource/check
COPY scripts/bin/empty-out /opt/resource/out
COPY scripts/bin/repository-database-in /opt/resource/in
COPY scripts/lib /opt/lib

ENTRYPOINT ["/opt/resource/in"]

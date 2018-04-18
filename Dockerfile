FROM alpine:latest

ARG FM_VERSION="584-30649a49030f8d2ebd016b634ed3239316b38f0a"
ARG FM_RCON_PASSWORD

LABEL FIVEM_VERSION=${FM_VERSION}

RUN if [ -z "${FM_RCON_PASSWORD}" ]; then (&>2 echo "Argument FM_RCON_PASSWORD is not set."); exit 1; else : ; fi
RUN if [ -z "${FM_VERSION}" ]; then (&>2 echo "Argument FM_VERSION is not set."); exit 1; else : ; fi

ENV TCP_ENDPOINT_ADDR=0.0.0.0
ENV UDP_ENDPOINT_ADDR=0.0.0.0
ENV TCP_ENDPOINT_PORT=30120
ENV UDP_ENDPOINT_PORT=30120
ENV SCRIPT_HOOK_ALLOWED=1
ENV RCON_PASSWORD="${FM_RCON_PASSWORD}"
ENV SERVER_TAGS="dev,test"
ENV SERVER_NAME="Development Server"
# REQUIRED: Checked in entrypoint
ENV SERVER_LICENSE_KEY=""

WORKDIR /server

RUN apk update && apk upgrade && \
  apk add bash curl git python py2-pip

RUN pip install --upgrade pip && pip install j2cli && pip install j2cli[yaml]
RUN curl --silent https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/${FM_VERSION}/fx.tar.xz --output fx.tar.xz && \
  tar xf fx.tar.xz && \
  cd /tmp && \
  git clone https://github.com/citizenfx/cfx-server-data.git && \
  mv /tmp/cfx-server-data/resources /server/resources && \
	rm -rf /var/cache/apk/*

COPY server.cfg.j2 ./
RUN j2 server.cfg.j2 > server.cfg

CMD ["/server/entrypoint.sh", "+exec", "server.cfg"]

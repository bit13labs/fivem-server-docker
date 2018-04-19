#!/usr/bin/env bash
set -e;

if [[ -z "${RCON_PASSWORD// }" ]]; then (&>2 echo "Envrionment Variable RCON_PASSWORD is not set."); exit 1; else : ; fi
if [[ -z "${SERVER_LICENSE_KEY// }" ]]; then (&>2 echo "Envrionment Variable SERVER_LICENSE_KEY is not set."); exit 1; else : ; fi
if [[ -z "${SERVER_NAME// }" ]]; then (&>2 echo "Envrionment Variable SERVER_NAME is not set."); exit 1; else : ; fi
if [[ -z "${SERVER_TAGS// }" ]]; then (&>2 echo "Envrionment Variable SERVER_NAME is not set."); exit 1; else : ; fi


j2 server.cfg.j2 > server.cfg;

/server/run.sh "$@";

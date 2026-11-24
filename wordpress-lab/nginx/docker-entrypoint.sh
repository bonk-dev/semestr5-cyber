#!/bin/sh
set -e

CONF=/etc/crowdsec/bouncers/crowdsec-nginx-bouncer.conf

if [ -f "$CONF" ]; then
  sed -i "s#^API_URL=.*#API_URL=${CROWDSEC_LAPI_URL:-http://crowdsec:8080}#" "$CONF"
  sed -i "s#^API_KEY=.*#API_KEY=${CROWDSEC_BOUNCER_KEY}#" "$CONF"
fi

# sanity check configu przed startem
nginx -t

exec "$@"

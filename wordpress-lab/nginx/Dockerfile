FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      curl gnupg ca-certificates apt-transport-https \
 && curl -s https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.deb.sh | bash \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      nginx libnginx-mod-http-lua lua5.1 libnginx-mod-http-lua luarocks gettext-base lua-cjson crowdsec-nginx-bouncer \
 && rm -rf /var/lib/apt/lists/*

COPY default.conf /etc/nginx/conf.d/default.conf
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN unlink /etc/nginx/sites-enabled/default
RUN sed -i 's|^APPSEC_URL=.*|APPSEC_URL=http://crowdsec:7422|' /etc/crowdsec/bouncers/crowdsec-nginx-bouncer.conf
COPY docker_resolver.conf /etc/nginx/conf.d/00_docker_resolver.conf
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]

ARG ALPINE_VERSION="3.6.2"
FROM epoelke/alpine-$ALPINE_VERSION
COPY ./scripts/pg-build.sh /pg-build.sh
COPY ./scripts/pg-init.sh /usr/local/bin/pg-init.sh
COPY ./scripts/consul-template.sh /consul-template.sh
COPY ./scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
ARG PG_VERSION="9.6.3"
ARG CONSUL_TEMPLATE_VERSION="0.19.0"
RUN /sbin/apk update && \
  /sbin/apk add bash tar gzip build-base readline-dev openssl \
    openssl-dev zlib-dev libxml2-dev glib-lang wget ca-certificates \ 
    libssl1.0 && \
  /bin/mkdir -p /usr/local/bin && \
  /bin/mkdir -p /data && \
  /bin/chown -R 70:70 /data && \
  /bin/bash /pg-build.sh -v $PG_VERSION && \
  /bin/bash /consul-template.sh -v $CONSUL_TEMPLATE_VERSION && \
  /bin/rm /pg-build.sh && \
  /bin/rm /consul-template.sh && \
  /sbin/apk --purge del bash tar gzip build-base openssl openssl-dev \
    zlib-dev libxml2-dev wget ca-certificates && \
  /bin/rm -rf /var/cache/apk/* && \
  /bin/chmod +x /usr/local/bin/entrypoint.sh && \
  /bin/mkdir -p /var/lib/postgresql && \
  /bin/chown -R postgres:postgres /var/lib/postgresql
USER postgres
ARG CMD=/usr/local/bin/entrypoint.sh
CMD $CMD

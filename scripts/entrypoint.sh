#!/bin/sh
if [ ! -f /data/.dbinit ]; then
  /usr/local/bin/initdb -D /data
  touch /data/.dbinit
fi

consul-template \
  -consul-addr $CONSUL_ADDR \
  -template "/usr/local/templates/pg_hba.tmpl:/usr/local/etc/postgres/pg_hba.conf" \
  -template "/usr/local/templates/postgresql.tmpl:/usr/local/etc/postgres/postgresql.conf" \
  -once

exec /usr/local/bin/postgres \
  --config_file=/usr/local/etc/postgres/postgresql.conf \
  --hba_file=/usr/local/etc/postgres/pg_hba.conf \
  -D /data >/data/pg.log 2>&1

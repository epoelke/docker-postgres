#!/bin/sh
exec /usr/local/bin/postgres -D /data >/data/pg.log 2>&1

#!/bin/bash
# Build a basic container with rkt and alpine 3.6.  
set -e

TEMP_DIR="/pg-tmp"

while getopts “v:” OPTION; do
  case $OPTION in
    v)
      PG_VERSION=$OPTARG
      ;;
  esac
done

function strcat() {
  local IFS=" "
  echo "$*"
}

function err_exit() {
  echo "$(strcat Command \'$BASH_COMMAND\' failed)"
  exit 1
}

function clean() {
  /bin/rm -rf ${TEMP_DIR}
}

function prep() {
  if [ -d "${TEMP_DIR}" ]; then
    /bin/rm -rf ${TEMP_DIR}
  fi
  /bin/mkdir ${TEMP_DIR}
  /usr/bin/wget \
    http://ftp.postgresql.org/pub/source/v${PG_VERSION}/postgresql-${PG_VERSION}.tar.bz2 \
    -O ${TEMP_DIR}/postgresql-${PG_VERSION}.tar.bz2 -q
  /bin/tar xvfj ${TEMP_DIR}/postgresql-${PG_VERSION}.tar.bz2 -C ${TEMP_DIR}
}

function generate_certs() {
  [ ! -d /etc/ssl ] && /bin/mkdir -p /etc/ssl
  /usr/bin/openssl req -new \
    -newkey rsa:4096 \
    -days 3650 \
    -nodes \
    -x509 \
    -subj "/C=US/ST=CA/L=San Francisco/O=HSDP/CN=*.dev.pcftest.com" \
    -keyout /etc/ssl/server.key \
    -out /etc/ssl/server.crt
  /bin/chmod 600 /etc/ssl/server.key
  /bin/chown 70:70 /etc/ssl/server.key
}

function main() {
  cd ${TEMP_DIR}/postgresql-${PG_VERSION}
  ./configure \
    --enable-integer-datetimes \
    --enable-thread-safety \
    --prefix=/usr/local \
    --with-libedit-preferred \
    --with-openssl
  /usr/bin/make world
  /usr/bin/make install world
  /usr/bin/make -C contrib install
  cd ${TEMP_DIR}/postgresql-${PG_VERSION}/contrib
  /usr/bin/make
  /usr/bin/make install 
}

trap 'err_exit' 1 2 3 15 ERR
prep
main
generate_certs
clean


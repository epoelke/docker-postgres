#!/bin/bash
set -e

TEMP_DIR="/consul-tmp"
CONSUL_URL="https://releases.hashicorp.com/consul-template"

while getopts “v:” OPTION; do
  case $OPTION in
    v)
      CONSUL_TEMPLATE_VERSION=$OPTARG
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

function main() {
  if [ -d "${TEMP_DIR}" ]; then
    /bin/rm -rf ${TEMP_DIR}
  fi
  /bin/mkdir ${TEMP_DIR}
  /usr/bin/wget \
    ${CONSUL_URL}/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.tgz \
    -O ${TEMP_DIR}/consul-template.tar.gz
  /bin/tar xzvf ${TEMP_DIR}/consul-template.tar.gz -C /usr/local/bin
}

trap 'err_exit' 1 2 3 15 ERR
main
clean


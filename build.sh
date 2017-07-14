#!/bin/bash
set -e
set -x

while getopts “v:” OPTION; do
  case $OPTION in
    v)
      VERSION=$OPTARG
      ;;
  esac
done

if [ -f ./${VERSION}/vars.sh ]; then
  source ./${VERSION}/vars.sh

  if [ -z "${ALPINE_VERSION}" ]; then
    echo "ALPINE_VERSION not set in vars.sh!"
    exit 1
  fi

  if [ -z "${PG_VERSION}" ]; then
    echo "PG_VERSION not set in vars.sh!"
    exit 1 
  fi 

  if [ -z "${CONSUL_TEMPLATE_VERSION}" ]; then
    echo "CONSUL_TEMPLATE_VERSION not set in vars.sh!"
    exit 1 
  fi 

  if [ -z "${CMD}" ]; then
    echo "CMD not set in vars.sh!"
    exit 1 
  fi 

else
  echo "./${VERSION}/vars.sh does not exist!"
  exit 1
fi

function strcat() {
  local IFS=" "
  echo "$*"
}

function clean() {
  docker rm $(docker ps -a -q)
  docker rmi $(docker images -a -q)
}

function err_exit() {
  echo "$(strcat Command \'${BASH_COMMAND}\' failed)"
  clean
  exit 1
}

function dockerbuild() {
  docker build --build-arg ALPINE_VERSION=${ALPINE_VERSION} \
    --build-arg PG_VERSION=${PG_VERSION} \
    --build-arg CONSUL_TEMPLATE_VERSION=${CONSUL_TEMPLATE_VERSION} \
    --build-arg CMD="${CMD}" \
    --tag epoelke/postgres:$PG_VERSION .
  docker run --name new_build epoelke/postgres:$PG_VERSION echo 'new build' 
  docker export new_build | docker import -c "CMD ${CMD}" \
    -c "USER postgres" - epoelke/postgres:$PG_VERSION
  docker push epoelke/postgres:$PG_VERSION
}

function main() {
  dockerbuild
  clean
}

trap 'err_exit' 1 2 3 15 ERR
main


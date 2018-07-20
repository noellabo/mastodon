#!/bin/bash

cd $(dirname $0)/..

uri=$1
sec=$(($2 * 2))
protocol=$(echo $uri | cut -d ":" -f1)

case $protocol in
  "tcp" ) ;;
  "http" ) ;;
  * ) exit 1 ;;
esac

host_and_port=$(echo $uri | sed -e "s/^.*:\/\/\([0-9\.]*:[0-9]*\).*$/\1/")
host=$(echo $host_and_port | cut -d ":" -f1)
port=$(echo $host_and_port | cut -d ":" -f2)

check() {
  case $protocol in
    "tcp" )
      nc -z $host $port
      ;;
    "http" )
      curl -fsv $uri
      ;;
    * )
      return 1
      ;;
  esac
  return $?
}

for i in $(seq $sec); do
  check
  if [ $? = 0 ]; then
    exit 0
  fi
  sleep 0.5
done
exit 1

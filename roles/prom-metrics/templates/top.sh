#!/bin/bash

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
# shellcheck disable=SC2034
instance_id=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id -m 1 | base64)
instance_id=${instance_id:-=}
# shellcheck disable=SC2034
private_host=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-hostname -m 1 | base64)
private_host=${private_host:-=}
HOST="http://localhost:9091/metrics/job/top/instance@base64/$instance_id/host@base64/$private_host"

while sleep 5; do
  cpu=""
  mem=""
  z=$(ps axo pid,pgid,user,pcpu,pmem,cmd)
  while read -r z; do
    var=$(awk '{printf "cpu_usage{pid=\""$1"\", pgid=\""$2"\", user=\""$3"\", cmd=\""$6; for(i=7;i<=NF;i++){printf " %s", $i} print "\"}" $4z}')
    var="${var//\\/\\\\\\}"
    cpu="$cpu$var"
  done <<<"$z"
  echo -e "$cpu" | curl --data-binary @- "$HOST"

  z=$(ps axo pid,pgid,user,pcpu,pmem,cmd)
  while read -r z; do
    var=$(awk '{printf "mem_usage{pid=\""$1"\", pgid=\""$2"\", user=\""$3"\", cmd=\""$6; for(i=7;i<=NF;i++){printf " %s", $i} print "\"}" $5z}')
    var="${var//\\/\\\\\\}"
    mem="$mem$var"
  done <<<"$z"
  echo -e "$mem" | curl --data-binary @- "$HOST"

done
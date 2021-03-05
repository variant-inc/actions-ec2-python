#!/bin/bash

while sleep 5; do
  # shellcheck disable=SC2034
  instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id -m 1)
  instance_id=${instance_id:-instance_id}
  # shellcheck disable=SC2034
  private_host=$(curl -s http://169.254.169.254/latest/meta-data/local-hostname -m 1)
  private_host=${private_host:-private_host}
  # shellcheck disable=SC2034
  public_host=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname -m 1)
  public_host=${public_host:-public_host}
  echo "$public_host"
  z=$(ps aux)
  while read -r z; do
    cpu=$cpu$(awk '{print "cpu_usage{instance_id=\"'"$instance_id"'\", node_name=\"'"$private_host"'\", external_dns=\"'"$public_host"'\", process=\""$11"\", pid=\""$2"\"}", $3z}')
  done <<<"$z"
  echo "$cpu"
  curl -X POST -H "Content-Type: text/plain" --data "$cpu
  " http://localhost:9091/metrics/job/top/instance/machine
  z=$(ps aux)
  while read -r z; do
    mem=$mem$(awk '{print "mem_usage{instance_id=\"'"$instance_id"'\", node_name=\"'"$private_host"'\", external_dns=\"'"$public_host"'\", process=\""$11"\", pid=\""$2"\"}", $4z}')
  done <<<"$z"
  echo "$mem"
  curl -X POST -H "Content-Type: text/plain" --data "$mem
  " http://localhost:9091/metrics/job/top/instance/machine
done

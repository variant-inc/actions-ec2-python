#!/bin/bash
set -ex
set -u

echo "Setting up watches for {{ dir }}"
# shellcheck disable=SC2162
inotifywait -e modify,moved_from,create,delete --timefmt '%d/%m/%y %H:%M' -m --format '%e %T %f %w%f' \
"{{ dir }}" | while read event date time fname file; do
  echo "INFO: Event:${event}: At ${time} on ${date}: file ${fname}"
  if [ "$event" == "CREATE" ] || [ "$event" == "MODIFY" ]; then
    aws s3 cp "$file" "s3://{{ bucket_name }}$file"
  fi
  if [ "$event" == "DELETE" ] || [ "$event" == "MOVED_FROM" ]; then
    aws s3api delete-object --bucket "{{ bucket_name }}" --key "${file:1}"
  fi
done

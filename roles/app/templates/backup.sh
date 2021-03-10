#!/bin/bash
set -ex
set -u

FILE_PATH=$(realpath "{{ dir }}")
echo "Setting up watches for $FILE_PATH"
# shellcheck disable=SC2162
inotifywait -e modify,moved_from,create,delete,moved_to --timefmt '%d/%m/%y %H:%M' -m --format '%e %T %f %w%f' \
"$FILE_PATH" | while read event date time fname file; do
  echo "INFO: Event:${event}: At ${time} on ${date}: file ${fname}"
  if [ "$event" == "CREATE" ] || [ "$event" == "MODIFY" ] || [ "$event" == "MOVED_TO" ]; then
    aws s3 cp "$file" "s3://{{ bucket_name }}/{{bucket_folder}}/$fname"
  fi
  if [ "$event" == "CREATE,ISDIR" ] || [ "$event" == "MODIFY,ISDIR" ] || [ "$event" == "MOVED_TO,ISDIR" ]; then
    aws s3 cp "$file" "s3://{{ bucket_name }}/{{bucket_folder}}/$fname" --recursive
  fi
  # if [ "$event" == "DELETE" ] || [ "$event" == "MOVED_FROM" ]; then
  #   aws s3api delete-object --bucket "{{ bucket_name }}" --key "{{bucket_folder}}$file"
  # fi
done

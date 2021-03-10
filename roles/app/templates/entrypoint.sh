#!/bin/bash

set -e

PYTHON_MANAGER="{{ python.manager }}"
if [ "$PYTHON_MANAGER" == "conda" ]; then
  # shellcheck disable=SC1091
  source "/opt/conda3/etc/profile.d/conda.sh"
  conda activate "{{ python.env_name }}"
fi
if [ "$PYTHON_MANAGER" == "pip" ]; then
  # shellcheck disable=SC1091
  source "/home/{{ instance_user }}/{{ clone_dir }}/{{ python.env_name }}/bin/activate"
fi

mkdir -p "/home/{{ instance_user }}/logs/{{ type }}"

touch "/home/{{ instance_user }}/logs/{{ type }}/{{ name }}.error.log"

# trap handler: print location of last error and process it further
function handle_err() {
  MYSELF="$0"   # equals to my script name
  LASTERR="$1"  # argument 1: error code of last command
  echo -e "$(date) ${MYSELF}: line ${LASTLINE}\n${BASH_COMMAND}\nexit status of command: ${LASTERR}" \
    >>"/home/{{ instance_user }}/logs/{{ type }}/{{ name }}.error.log"
}

# trap commands with non-zero exit code
trap 'handle_err $?' ERR

# shellcheck disable=SC1009,SC1054,SC1056,SC1072,SC1073,SC1083
cd /home/{{ instance_user }}/{{ clone_dir }} && {{ entrypoint }} >/home/{{ instance_user }}/logs/{{ type }}/{{ name }}.log

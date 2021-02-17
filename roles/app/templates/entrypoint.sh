#!/bin/bash

set -x

PYTHON_MANAGER="{{ python.manager }}"
if [ "$PYTHON_MANAGER" == "conda" ]; then
  # shellcheck disable=SC1091
  source "/opt/conda3/etc/profile.d/conda.sh"
fi
if [ "$PYTHON_MANAGER" == "pip" ]; then
  # shellcheck disable=SC1091
  source "/home/{{ instance_user }}/app/venv/bin/activate"
fi

mkdir -p "/home/{{ instance_user }}/logs/{{ type }}"

touch "/home/{{ instance_user }}/logs/{{ type }}/{{ name }}.error.log"

# trap handler: print location of last error and process it further
function handle_err() {
  MYSELF="$0"   # equals to my script name
  LASTLINE="$1" # argument 1: last line of error occurence
  LASTERR="$2"  # argument 2: error code of last command
  echo -e "${MYSELF}: line ${LASTLINE}\n ${BASH_COMMAND}\n exit status of last command: ${LASTERR}" \
    >>"/home/{{ instance_user }}/logs/{{ type }}/{{ name }}.error.log"
}

# trap commands with non-zero exit code
trap 'handle_err ${LINENO} $?' ERR

rm "/home/{{ instance_user }}/logs/{{ type }}/{{ name }}.log" || true
cd "/home/{{ instance_user }}/app" && bash -c "{{ entrypoint }}" \
  >>"/home/{{ instance_user }}/logs/{{ type }}/{{ name }}.log"

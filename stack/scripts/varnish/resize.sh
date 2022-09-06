#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purpose

# Load libraries
. /opt/bitnami/scripts/libvarnish.sh
. /opt/bitnami/scripts/libos.sh

# Load Varnish environment
. /opt/bitnami/scripts/varnish-env.sh

machine_size="$(get_machine_size "$@")"
ln -sf "bitnami/memory-${machine_size}.conf" "${VARNISH_CONF_DIR}/memory.conf"

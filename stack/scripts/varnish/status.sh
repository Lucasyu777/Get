#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitnami/scripts/libvarnish.sh
. /opt/bitnami/scripts/liblog.sh

# Load Varnish environment variables
. /opt/bitnami/scripts/varnish-env.sh

if is_varnish_running; then
    info "varnish is already running"
else
    info "varnish is not running"
fi

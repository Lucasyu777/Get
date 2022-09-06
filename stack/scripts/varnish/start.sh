#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitnami/scripts/libvarnish.sh
. /opt/bitnami/scripts/libos.sh
. /opt/bitnami/scripts/liblog.sh

# Load Varnish environment variables
. /opt/bitnami/scripts/varnish-env.sh

error_code=0

if is_varnish_not_running; then
    declare -a varnish_args
    read -r -a varnish_args <<< "$(varnish_opts "$@")"
    "${VARNISH_SBIN_DIR}/varnishd" "${varnish_args[@]}"
    if ! retry_while "is_varnish_running"; then
        error "varnish did not start"
        error_code=1
    else
        info "varnish started"
    fi
else
    info "varnish is already running"
fi

exit "$error_code"

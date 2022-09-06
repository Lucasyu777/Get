#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purpose

# Load libraries
. /opt/bitnami/scripts/libvarnish.sh
. /opt/bitnami/scripts/liblog.sh
. /opt/bitnami/scripts/libos.sh

# Load Varnish environment
. /opt/bitnami/scripts/varnish-env.sh

declare -a varnish_args
read -r -a varnish_args <<< "$(varnish_opts "-F" "$@")"

info "** Starting Varnish **"
exec "${VARNISH_SBIN_DIR}/varnishd" "${varnish_args[@]}"

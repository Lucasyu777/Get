#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purpose

# Load libraries
. /opt/bitnami/scripts/libvarnish.sh

# Load Varnish environment
. /opt/bitnami/scripts/varnish-env.sh

# Ensure Varnish environment variables are valid
varnish_validate

# Ensure Varnish is initialized
varnish_initialize

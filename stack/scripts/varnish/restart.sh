#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/bitnami/scripts/libvarnish.sh

# Load Varnish environment variables
. /opt/bitnami/scripts/varnish-env.sh

/opt/bitnami/scripts/varnish/stop.sh
/opt/bitnami/scripts/varnish/start.sh

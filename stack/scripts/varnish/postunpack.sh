#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purpose

# Load libraries
. /opt/bitnami/scripts/libvarnish.sh
. /opt/bitnami/scripts/libfs.sh
. /opt/bitnami/scripts/libos.sh

# Load Varnish environment
. /opt/bitnami/scripts/varnish-env.sh

# Ensure non-root user has write permissions on a set of directories
for dir in "$VARNISH_CONF_DIR" "$VARNISH_TMP_DIR"; do
    ensure_dir_exists "$dir"
    chmod -R g+rwX "$dir"
done

# Enable Varnish configuration file
[[ ! -f "$VARNISH_DEFAULT_CONF_FILE" ]] && cp "${VARNISH_BASE_DIR}/share/doc/varnish/builtin.vcl" "$VARNISH_DEFAULT_CONF_FILE"

# Configure default backend
varnish_backend_configuration="$(cat <<EOF
vcl 4.0;

backend default {
    .host = "${VARNISH_DEFAULT_BACKEND_ADDRESS}";
    .port = "${VARNISH_DEFAULT_BACKEND_PORT_NUMBER}";
}
EOF
)"
ensure_varnish_configuration_exists $'\n'"$varnish_backend_configuration" "backend default"

# Load additional required libraries
# shellcheck disable=SC1091
. /opt/bitnami/scripts/libos.sh
. /opt/bitnami/scripts/liblog.sh
. /opt/bitnami/scripts/libfile.sh
. /opt/bitnami/scripts/libservice.sh

info "Creating Varnish daemon user"
ensure_user_exists "$VARNISH_DAEMON_USER" --group "$VARNISH_DAEMON_GROUP"

# Update default value for environment variables, if set (they're empty by default)
# Varnish does not have any configuration file for setting runtime values, so they must be set as command-line arguments
# Since we don't have a metadata store for such values, we will instead rely on the 'varnish-env.sh' file for defaults
for env in VARNISH_LISTEN_ADDRESS VARNISH_PORT_NUMBER VARNISH_CONF_FILE; do
    [[ -z "${!env}" ]] && continue
    replace_in_file /opt/bitnami/scripts/varnish-env.sh "^export ${env}=.*" "export ${env}=\"\${${env}:-${!env}}\""
done

# Enable extra service management configuration
# Varnish does not create any log file that can be rotated, so the Logrotate configuration is skipped
if is_boolean_yes "$VARNISH_DISABLE_BY_DEFAULT"; then
    generate_monit_conf "varnish" "$VARNISH_PID_FILE" /opt/bitnami/scripts/varnish/start.sh /opt/bitnami/scripts/varnish/stop.sh --disable
else
    generate_monit_conf "varnish" "$VARNISH_PID_FILE" /opt/bitnami/scripts/varnish/start.sh /opt/bitnami/scripts/varnish/stop.sh
fi

# Create configuration files for setting Varnish optimization parameters depending on the instance size
# Memory will be set to 1/8th of the system total amount of memory
# - Threads will be set to double the amount of CPU cores in the instance type
# Default to micro configuration until a resize is performed
ensure_dir_exists "${VARNISH_CONF_DIR}/bitnami"
ln -sf "bitnami/memory-micro.conf" "${VARNISH_CONF_DIR}/memory.conf"
read -r -a supported_machine_sizes <<< "$(get_supported_machine_sizes)"
for machine_size in "${supported_machine_sizes[@]}"; do
    case "$machine_size" in
        micro)
            malloc=64M
            ;;
        small)
            malloc=128M
            ;;
        medium)
            malloc=256M
            ;;
        large)
            malloc=512M
            ;;
        xlarge)
            malloc=1024M
            ;;
        2xlarge)
            malloc=2048M
            ;;
        *)
            error "Unknown machine size '${machine_size}'"
            exit 1
            ;;
        esac
    cat >"${VARNISH_CONF_DIR}/bitnami/memory-${machine_size}.conf" <<EOF
# Bitnami memory configuration for Varnish
#
# Note: This will be modified on server size changes

export VARNISH_STORAGE=malloc,${malloc}
EOF
done

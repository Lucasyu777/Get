#!/bin/bash
#
# Environment configuration for varnish

# The values for all environment variables will be set in the below order of precedence
# 1. Custom environment variables defined below after Bitnami defaults
# 2. Constants defined in this file (environment variables with no default), i.e. BITNAMI_ROOT_DIR
# 3. Environment variables overridden via external files using *_FILE variables (see below)
# 4. Environment variables set externally (i.e. current Bash context/Dockerfile/userdata)

# Load logging library
# shellcheck disable=SC1090,SC1091
. /opt/bitnami/scripts/liblog.sh

export BITNAMI_ROOT_DIR="/opt/bitnami"
export BITNAMI_VOLUME_DIR="/bitnami"

# Logging configuration
export MODULE="${MODULE:-varnish}"
export BITNAMI_DEBUG="${BITNAMI_DEBUG:-false}"

# By setting an environment variable matching *_FILE to a file path, the prefixed environment
# variable will be overridden with the value specified in that file
varnish_env_vars=(
    VARNISH_CONF_FILE
    VARNISH_LISTEN_ADDRESS
    VARNISH_PORT_NUMBER
    VARNISH_ADMIN_LISTEN_ADDRESS
    VARNISH_ADMIN_PORT_NUMBER
    VARNISH_BACKEND_ADDRESS
    VARNISH_BACKEND_PORT_NUMBER
    VARNISH_STORAGE
)
for env_var in "${varnish_env_vars[@]}"; do
    file_env_var="${env_var}_FILE"
    if [[ -n "${!file_env_var:-}" ]]; then
        if [[ -r "${!file_env_var:-}" ]]; then
            export "${env_var}=$(< "${!file_env_var}")"
            unset "${file_env_var}"
        else
            warn "Skipping export of '${env_var}'. '${!file_env_var:-}' is not readable."
        fi
    fi
done
unset varnish_env_vars

# Load environment variables specified in user-data
[[ ! -f "${BITNAMI_ROOT_DIR}/var/user-data-env.sh" ]] || . "${BITNAMI_ROOT_DIR}/var/user-data-env.sh"

# Paths
export VARNISH_BASE_DIR="${BITNAMI_ROOT_DIR}/varnish"
export VARNISH_SBIN_DIR="${VARNISH_BASE_DIR}/sbin"
export VARNISH_BIN_DIR="${VARNISH_BASE_DIR}/bin"
export VARNISH_CONF_DIR="${VARNISH_BASE_DIR}/etc/varnish"
export VARNISH_TMP_DIR="${VARNISH_BASE_DIR}/var/varnish"
export VARNISH_DEFAULT_CONF_FILE="${VARNISH_CONF_DIR}/default.vcl"
export VARNISH_CONF_FILE="${VARNISH_CONF_FILE:-/opt/bitnami/varnish/etc/varnish/default.vcl}"
export VARNISH_PID_FILE="${VARNISH_TMP_DIR}/varnishd.pid"
export VARNISH_SECRET_FILE="${VARNISH_CONF_DIR}/secret"
export PATH="${VARNISH_SBIN_DIR}:${VARNISH_BIN_DIR}:${BITNAMI_ROOT_DIR}/common/bin:${PATH}"

# System users (when running with a privileged user)
export VARNISH_DAEMON_USER="varnish"
export VARNISH_DAEMON_GROUP="varnish"
export VARNISH_DISABLE_BY_DEFAULT="yes" # only used at build time
export VARNISH_DEFAULT_BACKEND_ADDRESS="127.0.0.1" # only used at build time
export VARNISH_DEFAULT_BACKEND_PORT_NUMBER="80" # only used at build time

# Varnish configuration
export VARNISH_LISTEN_ADDRESS="${VARNISH_LISTEN_ADDRESS:-}"
export VARNISH_PORT_NUMBER="${VARNISH_PORT_NUMBER:-81}"
export VARNISH_ADMIN_LISTEN_ADDRESS="${VARNISH_ADMIN_LISTEN_ADDRESS:-127.0.0.1}"
export VARNISH_ADMIN_PORT_NUMBER="${VARNISH_ADMIN_PORT_NUMBER:-6082}"
export VARNISH_BACKEND_ADDRESS="${VARNISH_BACKEND_ADDRESS:-}"
export VARNISH_BACKEND_PORT_NUMBER="${VARNISH_BACKEND_PORT_NUMBER:-}"
export VARNISH_STORAGE="${VARNISH_STORAGE:-}"

# Load memory configuration
[[ ! -f "${VARNISH_CONF_DIR}/memory.conf" ]] || . "${VARNISH_CONF_DIR}/memory.conf"

# Custom environment variables may be defined below

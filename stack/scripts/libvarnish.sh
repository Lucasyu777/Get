#!/bin/bash
#
# Bitnami Varnish library

# shellcheck disable=SC1091

# Load Generic Libraries
. /opt/bitnami/scripts/libfs.sh
. /opt/bitnami/scripts/liblog.sh
. /opt/bitnami/scripts/libos.sh
. /opt/bitnami/scripts/libvalidations.sh
. /opt/bitnami/scripts/libservice.sh

########################
# Validate settings in VARNISH_* env vars
# Globals:
#   VARNISH_*
# Arguments:
#   None
# Returns:
#   None
#########################
varnish_validate() {
    debug "Validating settings in VARNISH_* environment variables..."
    local error_code=0

    # Auxiliary functions
    print_validation_error() {
        error "$1"
        error_code=1
    }

    check_allowed_port() {
        local port_var="${1:?missing port variable}"
        local -a validate_port_args=()
        ! am_i_root && validate_port_args+=("-unprivileged")
        validate_port_args+=("${!port_var}")
        if ! err=$(validate_port "${validate_port_args[@]}"); then
            print_validation_error "An invalid port was specified in the environment variable ${port_var}: ${err}."
        fi
    }

    check_conflicting_ports() {
        local -r total="$#"
        for i in $(seq 1 "$((total - 1))"); do
            for j in $(seq "$((i + 1))" "$total"); do
                if (( "${!i}" == "${!j}" )); then
                    print_validation_error "${!i} and ${!j} are bound to the same port"
                fi
            done
        done
    }

    is_file_writable "$VARNISH_CONF_FILE" || warn "The Varnish configuration file '${VARNISH_CONF_FILE}' is not writable. Configurations based on environment variables will not be applied."
    is_file_writable "$VARNISH_SECRET_FILE" || warn "The Varnish shared-secret file '${VARNISH_SECRET_FILE}' is not writable. Varnish will run without any configured secret file."

    [[ -n "$VARNISH_PORT_NUMBER" ]] && check_allowed_port VARNISH_PORT_NUMBER
    [[ -n "$VARNISH_ADMIN_PORT_NUMBER" ]] && check_allowed_port VARNISH_ADMIN_PORT_NUMBER
    [[ -n "$VARNISH_PORT_NUMBER" && -n "$VARNISH_ADMIN_PORT_NUMBER" ]] && check_conflicting_ports VARNISH_PORT_NUMBER VARNISH_ADMIN_PORT_NUMBER

    return "$error_code"
}

########################
# Ensure Varnish is initialized
# Globals:
#   VARNISH_*
# Arguments:
#   None
# Returns:
#   None
#########################
varnish_initialize() {
    if is_file_writable "$VARNISH_CONF_FILE"; then
        [[ -n "$VARNISH_BACKEND_ADDRESS" ]] && info "Overriding default backend address" && replace_in_file "$VARNISH_CONF_FILE" ".host\s*=\s*\"([^\"]*)\"\s*;" ".host = \"${VARNISH_BACKEND_ADDRESS}\""
        [[ -n "$VARNISH_BACKEND_PORT_NUMBER" ]] && info "Overriding default backend port" && replace_in_file "$VARNISH_CONF_FILE" ".port\s*=\s*\"([^\"]*)\"\s*;" ".port = \"${VARNISH_BACKEND_PORT_NUMBER}\""
    fi

    # Generate the secret file
    # See: https://varnish-cache.org/docs/trunk/users-guide/run_security.html#cli-interface-authentication
    is_file_writable "$VARNISH_SECRET_FILE" && dd if=/dev/urandom of="$VARNISH_SECRET_FILE" count=1 2>/dev/null

    # Avoid exit code of previous commands to affect the result of this function
    true
}

########################
# Stop Varnish
# Globals:
#   VARNISH_*
# Arguments:
#   None
# Returns:
#   None
#########################
varnish_stop() {
    is_varnish_not_running && return
    stop_service_using_pid "$VARNISH_PID_FILE"
}

########################
# Check if Varnish is running
# Globals:
#   VARNISH_PID_FILE
# Arguments:
#   None
# Returns:
#   Whether Varnish is running
########################
is_varnish_running() {
    local pid
    pid="$(get_pid_from_file "$VARNISH_PID_FILE")"
    if [[ -n "$pid" ]]; then
        is_service_running "$pid"
    else
        false
    fi
}

########################
# Check if Varnish is running
# Globals:
#   VARNISH_PID_FILE
# Arguments:
#   None
# Returns:
#   Whether Varnish is not running
########################
is_varnish_not_running() {
    ! is_varnish_running
}

########################
# Ensure configuration gets added to the main Varnish configuration file
# Globals:
#   VARNISH_*
# Arguments:
#   $1 - configuration string
#   $2 - pattern to use for checking if the configuration already exists (default: $1)
# Returns:
#   None
########################
ensure_varnish_configuration_exists() {
    local -r conf="${1:?conf missing}"
    local -r pattern="${2:-"$conf"}"
    # Enable configuration by appending to httpd.conf
    if ! grep -E -q "$pattern" "$VARNISH_CONF_FILE"; then
        if is_file_writable "$VARNISH_CONF_FILE"; then
            cat >> "$VARNISH_CONF_FILE" <<< "$conf"
        else
            error "Could not add the following configuration to '${VARNISH_CONF_FILE}:"
            error ""
            error "$(indent "$conf" 4)"
            error ""
            error "Include the configuration manually and try again."
            return 1
        fi
    fi
}

########################
# Prints the list of arguments that will be used to run Varnish
# Globals:
#   VARNISH_*
# Arguments:
#   None
# Returns:
#   None
########################
varnish_opts() {
    local -a args

    # Enable Varnish jail mechanism when running as root ("-j" must be the first argument)
    am_i_root && args+=("-j" "unix,user=${VARNISH_DAEMON_USER},ccgroup=${VARNISH_DAEMON_GROUP}")

    # Construct argument list to pass to Varnish
    args+=(
        "-a" "${VARNISH_LISTEN_ADDRESS}:${VARNISH_PORT_NUMBER}"
        "-f" "$VARNISH_CONF_FILE"
        "-P" "$VARNISH_PID_FILE"
    )

    # Check if the secret file was enabled
    [[ -f "$VARNISH_SECRET_FILE" ]] && args+=("-S" "$VARNISH_SECRET_FILE")

    # Memory allocation configuration
    [[ -n "$VARNISH_STORAGE" ]] && args+=("-s" "$VARNISH_STORAGE")

    # Allow passing extra arguments to Varnish
    args+=("$@")

    echo "${args[@]}"
}

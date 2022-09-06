#!/bin/bash

# Load libraries
. /opt/bitnami/scripts/libos.sh
. /opt/bitnami/scripts/liblog.sh

if ! am_i_root; then
    error "Please run this script as a superuser, to be able to execute WordPress CLI with the proper user"
    exit 1
fi

export WP_CLI_CONFIG_PATH="{{WP_CLI_CONF_FILE}}"
export WP_CLI_CACHE_DIR="{{WP_CLI_BASE_DIR}}/.cache"
export WP_CLI_PACKAGES_DIR="{{WP_CLI_BASE_DIR}}/.packages"
export WP_CLI_PHP_USED="{{PHP_BIN_DIR}}/php"

command -v less > /dev/null || export PAGER=cat

exec {{BITNAMI_ROOT_DIR}}/common/bin/gosu {{WP_CLI_DAEMON_USER}} {{PHP_BIN_DIR}}/php {{WP_CLI_BIN_DIR}}/wp-cli.phar "$@"

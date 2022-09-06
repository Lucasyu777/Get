#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purpose

# Load libraries
. /opt/bitnami/scripts/libapache.sh

# Load Apache environment
. /opt/bitnami/scripts/apache-env.sh
. /opt/bitnami/scripts/php-env.sh

# Enable required Apache modules
declare -a enable_modules=(
    actions_module
    http2_module
    mpm_event_module
    proxy_fcgi_module
)
for module in "${enable_modules[@]}"; do
    apache_enable_module "$module"
done

# Add libphp with the sole purpose of including it in the 'httpd.conf' configuration file, it will be disabled below
php_module="php7_module"
apache_enable_module "$php_module" "modules/libphp7.so"

# Disable incompatible Apache modules
declare -a disable_modules=(
    mpm_prefork_module
    "$php_module"
)
for module in "${disable_modules[@]}"; do
    apache_disable_module "$module"
done

# Write Apache configuration
apache_php_fpm_conf_file="${APACHE_CONF_DIR}/bitnami/php-fpm.conf"
cat >"$apache_php_fpm_conf_file" <<EOF
DirectoryIndex index.html index.htm index.php
<IfDefine USE_PHP_FPM>
  <Proxy "unix:${PHP_TMP_DIR}/www.sock|fcgi://www-fpm" timeout=300>
  </Proxy>
  <FilesMatch \.php$>
    <If "-f %{REQUEST_FILENAME}">
      SetHandler "proxy:fcgi://www-fpm"
    </If>
  </FilesMatch>
</IfDefine>
EOF
apache_conf_add="# This enables PHP-FPM when mod_php is disabled
<IfModule !${php_module}>
  AddType application/x-httpd-php .php
  Action application/x-httpd-php \"/bitnami-error-php-fpm-did-not-handle-the-connection\"
  Define USE_PHP_FPM
  Include \"${apache_php_fpm_conf_file}\"
</IfModule>"
ensure_apache_configuration_exists "$apache_conf_add" "Define USE_PHP_FPM"

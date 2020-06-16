# Demyx
# https://demyx.sh

demyx_env() {
    demyx_app_config

    DEMYX_APP_ID="${DEMYX_APP_ID:-$(demyx util --id --raw)}"
    DEMYX_APP_CONTAINER="${DEMYX_APP_CONTAINER:-${DEMYX_TARGET//[^a-z 0-9 A-Z]/_}}"
    DEMYX_APP_COMPOSE_PROJECT="${DEMYX_APP_COMPOSE_PROJECT:-${DEMYX_TARGET//[^a-z 0-9 A-Z -]/}}"
    DEMYX_APP_AUTH_USERNAME=${DEMYX_APP_AUTH_USERNAME:-$(demyx util --user --raw)}
    DEMYX_APP_AUTH_PASSWORD=${DEMYX_APP_AUTH_PASSWORD:-$(demyx util --pass --raw)}

    [[ -n "$DEMYX_RUN_SSL" ]] && DEMYX_APP_SSL="$DEMYX_RUN_SSL"
    [[ -n "$DEMYX_RUN_USER" ]] && WORDPRESS_USER="$DEMYX_RUN_USER"
    [[ -n "$DEMYX_RUN_PASSWORD" ]] && WORDPRESS_USER_PASSWORD="$DEMYX_RUN_PASSWORD"
    [[ -n "$DEMYX_RUN_EMAIL" ]] && WORDPRESS_USER_EMAIL="$DEMYX_RUN_EMAIL"
    [[ -n "$DEMYX_RUN_STACK" ]] && DEMYX_APP_STACK="$DEMYX_RUN_STACK"
    [[ -n "$DEMYX_RUN_CLOUDFLARE" ]] && DEMYX_APP_CLOUDFLARE="$DEMYX_RUN_CLOUDFLARE"

    if [[ "$DEMYX_RUN_TYPE" = wp || "$DEMYX_APP_TYPE" = wp ]]; then
        echo "# AUTO GENERATED
            # Essentials
            DEMYX_APP_ID=$DEMYX_APP_ID
            DEMYX_APP_TYPE=${DEMYX_APP_TYPE:-wp}
            DEMYX_APP_WP_IMAGE=${DEMYX_APP_WP_IMAGE:-demyx/wordpress}
            DEMYX_APP_STACK=${DEMYX_APP_STACK:-nginx-php}
            DEMYX_APP_BEDROCK_MODE=${DEMYX_APP_BEDROCK_MODE:-production}
            DEMYX_APP_PATH=${DEMYX_APP_PATH:-$DEMYX_WP/$DEMYX_TARGET}
            DEMYX_APP_CONTAINER=$DEMYX_APP_CONTAINER
            DEMYX_APP_COMPOSE_PROJECT=$DEMYX_APP_COMPOSE_PROJECT
            DEMYX_APP_DOMAIN=$DEMYX_TARGET
            DEMYX_APP_SSL=${DEMYX_APP_SSL:-$DEMYX_RUN_SSL}
            DEMYX_APP_RATE_LIMIT=${DEMYX_APP_RATE_LIMIT:-false}
            DEMYX_APP_AUTH=${DEMYX_APP_AUTH:-false}
            DEMYX_APP_AUTH_WP=${DEMYX_APP_AUTH_WP:-false}
            DEMYX_APP_AUTH_USERNAME=$DEMYX_APP_AUTH_USERNAME
            DEMYX_APP_AUTH_PASSWORD=$DEMYX_APP_AUTH_PASSWORD
            DEMYX_APP_AUTH_HTPASSWD=$(demyx util --user="$DEMYX_APP_AUTH_USERNAME" --htpasswd="$DEMYX_APP_AUTH_PASSWORD" --raw)
            DEMYX_APP_CLOUDFLARE=${DEMYX_APP_CLOUDFLARE:-false}
            DEMYX_APP_CACHE=${DEMYX_APP_CACHE:-false}
            DEMYX_APP_DEV=${DEMYX_APP_DEV:-false}
            DEMYX_APP_DEV_PASSWORD=${DEMYX_APP_DEV_PASSWORD:-$(demyx util --pass --raw)}
            DEMYX_APP_HEALTHCHECK=${DEMYX_APP_HEALTHCHECK:-true}
            DEMYX_APP_WP_UPDATE=${DEMYX_APP_WP_UPDATE:-false}
            DEMYX_APP_OLS_ADMIN_PREFIX=${DEMYX_APP_OLS_ADMIN_PREFIX:-true}
            DEMYX_APP_OLS_ADMIN_IP=${DEMYX_APP_OLS_ADMIN_IP:-ALL}
            DEMYX_APP_OLS_ADMIN_USERNAME=${DEMYX_APP_OLS_ADMIN_USERNAME:-$(demyx util --user --raw)}
            DEMYX_APP_OLS_ADMIN_PASSWORD=${DEMYX_APP_OLS_ADMIN_PASSWORD:-$(demyx util --pass --raw)}
            DEMYX_APP_XMLRPC=${DEMYX_APP_XMLRPC:-false}
            DEMYX_APP_WP_CPU=${DEMYX_APP_WP_CPU:-$DEMYX_CPU}
            DEMYX_APP_WP_MEM=${DEMYX_APP_WP_MEM:-$DEMYX_MEM}
            DEMYX_APP_DB_CPU=${DEMYX_APP_DB_CPU:-$DEMYX_CPU}
            DEMYX_APP_DB_MEM=${DEMYX_APP_DB_MEM:-$DEMYX_MEM}
            DEMYX_APP_NX_CONTAINER=${DEMYX_APP_NX_CONTAINER:-${DEMYX_APP_COMPOSE_PROJECT}_nx_${DEMYX_APP_ID}_1}
            DEMYX_APP_WP_CONTAINER=${DEMYX_APP_WP_CONTAINER:-${DEMYX_APP_COMPOSE_PROJECT}_wp_${DEMYX_APP_ID}_1}
            DEMYX_APP_DB_CONTAINER=${DEMYX_APP_DB_CONTAINER:-${DEMYX_APP_COMPOSE_PROJECT}_db_${DEMYX_APP_ID}_1}
            WORDPRESS_USER=${WORDPRESS_USER:-$(demyx util --user --raw)}
            WORDPRESS_USER_PASSWORD=${WORDPRESS_USER_PASSWORD:-$(demyx util --pass --raw)}
            WORDPRESS_USER_EMAIL=${WORDPRESS_USER_EMAIL:-info@$DEMYX_TARGET}
            WORDPRESS_DB_HOST=${WORDPRESS_DB_HOST:-db_${DEMYX_APP_ID}}
            WORDPRESS_DB_NAME="${WORDPRESS_DB_NAME:-$DEMYX_APP_CONTAINER}"
            WORDPRESS_DB_USER=${WORDPRESS_DB_USER:-$(demyx util --user --raw)}
            WORDPRESS_DB_PASSWORD=${WORDPRESS_DB_PASSWORD:-$(demyx util --pass --raw)}
            MARIADB_ROOT_PASSWORD=${MARIADB_ROOT_PASSWORD:-$(demyx util --pass --raw)}

            # Safe to delete and regenerate via demyx refresh <app>
            DEMYX_APP_IP_WHITELIST=${DEMYX_APP_IP_WHITELIST:-false}
            DEMYX_APP_IP_WHITELIST_TYPE=${DEMYX_APP_IP_WHITELIST_TYPE:-login}
            DEMYX_APP_PHP_EMERGENCY_RESTART_THRESHOLD=${DEMYX_APP_PHP_EMERGENCY_RESTART_THRESHOLD:-5}
            DEMYX_APP_PHP_EMERGENCY_RESTART_INTERVAL=${DEMYX_APP_PHP_EMERGENCY_RESTART_INTERVAL:-1m}
            DEMYX_APP_PHP_PROCESS_CONTROL_TIMEOUT=${DEMYX_APP_PHP_PROCESS_CONTROL_TIMEOUT:-10s}
            DEMYX_APP_UPLOAD_LIMIT=${DEMYX_APP_UPLOAD_LIMIT:-128M}
            DEMYX_APP_PHP_MEMORY=${DEMYX_APP_PHP_MEMORY:-256M}
            DEMYX_APP_PHP_MAX_EXECUTION_TIME=${DEMYX_APP_PHP_MAX_EXECUTION_TIME:-300}
            DEMYX_APP_PHP_OPCACHE=${DEMYX_APP_PHP_OPCACHE:-true} 
            DEMYX_APP_PHP_PM=${DEMYX_APP_PHP_PM:-ondemand}
            DEMYX_APP_PHP_PM_MAX_CHILDREN=${DEMYX_APP_PHP_PM_MAX_CHILDREN:-25}
            DEMYX_APP_PHP_PM_START_SERVERS=${DEMYX_APP_PHP_PM_START_SERVERS:-5}
            DEMYX_APP_PHP_PM_MIN_SPARE_SERVERS=${DEMYX_APP_PHP_PM_MIN_SPARE_SERVERS:-5}
            DEMYX_APP_PHP_PM_MAX_SPARE_SERVERS=${DEMYX_APP_PHP_PM_MAX_SPARE_SERVERS:-20}
            DEMYX_APP_PHP_PM_PROCESS_IDLE_TIMEOUT=${DEMYX_APP_PHP_PM_PROCESS_IDLE_TIMEOUT:-3s}
            DEMYX_APP_PHP_PM_MAX_REQUESTS=${DEMYX_APP_PHP_PM_MAX_REQUESTS:-25000}
            DEMYX_APP_OLS_CLIENT_THROTTLE_STATIC=${DEMYX_APP_OLS_CLIENT_THROTTLE_STATIC:-1000}
            DEMYX_APP_OLS_CLIENT_THROTTLE_DYNAMIC=${DEMYX_APP_OLS_CLIENT_THROTTLE_DYNAMIC:-1000}
            DEMYX_APP_OLS_CLIENT_THROTTLE_BANDWIDTH_OUT=${DEMYX_APP_OLS_CLIENT_THROTTLE_BANDWIDTH_OUT:-0}
            DEMYX_APP_OLS_CLIENT_THROTTLE_BANDWIDTH_IN=${DEMYX_APP_OLS_CLIENT_THROTTLE_BANDWIDTH_IN:-0}
            DEMYX_APP_OLS_CLIENT_THROTTLE_SOFT_LIMIT=${DEMYX_APP_OLS_CLIENT_THROTTLE_SOFT_LIMIT:-1500}
            DEMYX_APP_OLS_CLIENT_THROTTLE_HARD_LIMIT=${DEMYX_APP_OLS_CLIENT_THROTTLE_HARD_LIMIT:-2000}
            DEMYX_APP_OLS_CLIENT_THROTTLE_BLOCK_BAD_REQUEST=${DEMYX_APP_OLS_CLIENT_THROTTLE_BLOCK_BAD_REQUEST:-1}
            DEMYX_APP_OLS_CLIENT_THROTTLE_GRACE_PERIOD=${DEMYX_APP_OLS_CLIENT_THROTTLE_GRACE_PERIOD:-30}
            DEMYX_APP_OLS_CLIENT_THROTTLE_BAN_PERIOD=${DEMYX_APP_OLS_CLIENT_THROTTLE_BAN_PERIOD:-60}
            DEMYX_APP_OLS_TUNING_MAX_CONNECTIONS=${DEMYX_APP_OLS_TUNING_MAX_CONNECTIONS:-20000}
            DEMYX_APP_OLS_TUNING_CONNECTION_TIMEOUT=${DEMYX_APP_OLS_TUNING_CONNECTION_TIMEOUT:-300}
            DEMYX_APP_OLS_TUNING_MAX_KEEP_ALIVE=${DEMYX_APP_OLS_TUNING_MAX_KEEP_ALIVE:-1000}
            DEMYX_APP_OLS_TUNING_SMART_KEEP_ALIVE=${DEMYX_APP_OLS_TUNING_SMART_KEEP_ALIVE:-1000}
            DEMYX_APP_OLS_TUNING_KEEP_ALIVE_TIMEOUT=${DEMYX_APP_OLS_TUNING_KEEP_ALIVE_TIMEOUT:-300}
            DEMYX_APP_OLS_PHP_LSAPI_CHILDREN=${DEMYX_APP_OLS_PHP_LSAPI_CHILDREN:-2000}
            DEMYX_APP_OLS_RECAPTCHA_ENABLE=${DEMYX_APP_OLS_RECAPTCHA_ENABLE:-1}
            DEMYX_APP_OLS_RECAPTCHA_TYPE=${DEMYX_APP_OLS_RECAPTCHA_TYPE:-2}
            DEMYX_APP_OLS_RECAPTCHA_CONNECTION_LIMIT=${DEMYX_APP_OLS_RECAPTCHA_CONNECTION_LIMIT:-500}
            DEMYX_APP_MONITOR_THRESHOLD=${DEMYX_APP_MONITOR_THRESHOLD:-3}
            DEMYX_APP_MONITOR_SCALE=${DEMYX_APP_MONITOR_SCALE:-5}
            DEMYX_APP_MONITOR_CPU=${DEMYX_APP_MONITOR_CPU:-25}
            MARIADB_DEFAULT_CHARACTER_SET=${MARIADB_DEFAULT_CHARACTER_SET:-utf8}
            MARIADB_CHARACTER_SET_SERVER=${MARIADB_CHARACTER_SET_SERVER:-utf8}
            MARIADB_COLLATION_SERVER=${MARIADB_COLLATION_SERVER:-utf8_general_ci}
            MARIADB_KEY_BUFFER_SIZE=${MARIADB_KEY_BUFFER_SIZE:-32M}
            MARIADB_MAX_ALLOWED_PACKET=${MARIADB_MAX_ALLOWED_PACKET:-16M}
            MARIADB_TABLE_OPEN_CACHE=${MARIADB_TABLE_OPEN_CACHE:-2000}
            MARIADB_SORT_BUFFER_SIZE=${MARIADB_SORT_BUFFER_SIZE:-4M}
            MARIADB_NET_BUFFER_SIZE=${MARIADB_NET_BUFFER_SIZE:-4M}
            MARIADB_READ_BUFFER_SIZE=${MARIADB_READ_BUFFER_SIZE:-2M}
            MARIADB_READ_RND_BUFFER_SIZE=${MARIADB_READ_RND_BUFFER_SIZE:-1M}
            MARIADB_MYISAM_SORT_BUFFER_SIZE=${MARIADB_MYISAM_SORT_BUFFER_SIZE:-32M}
            MARIADB_SERVER_ID=${MARIADB_SERVER_ID:-1}
            MARIADB_INNODB_DATA_FILE_PATH=${MARIADB_INNODB_DATA_FILE_PATH:-'ibdata1:10M:autoextend'}
            MARIADB_INNODB_BUFFER_POOL_SIZE=${MARIADB_INNODB_BUFFER_POOL_SIZE:-32M}
            MARIADB_INNODB_LOG_FILE_SIZE=${MARIADB_INNODB_LOG_FILE_SIZE:-5M}
            MARIADB_INNODB_LOG_BUFFER_SIZE=${MARIADB_INNODB_LOG_BUFFER_SIZE:-8M}
            MARIADB_INNODB_FLUSH_LOG_AT_TRX_COMMIT=${MARIADB_INNODB_FLUSH_LOG_AT_TRX_COMMIT:-1}
            MARIADB_INNODB_LOCK_WAIT_TIMEOUT=${MARIADB_INNODB_LOCK_WAIT_TIMEOUT:-50}
            MARIADB_INNODB_USE_NATIVE_AIO=${MARIADB_INNODB_USE_NATIVE_AIO:-1}
            MARIADB_READ_BUFFER=${MARIADB_READ_BUFFER:-2M}
            MARIADB_WRITE_BUFFER=${MARIADB_WRITE_BUFFER:-2M}
            MARIADB_MAX_CONNECTIONS=${MARIADB_MAX_CONNECTIONS:-1000}" | sed 's|            ||g' > "$DEMYX_WP"/"$DEMYX_TARGET"/.env
    fi
}
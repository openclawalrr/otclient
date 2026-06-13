#!/usr/bin/env bash
set -euo pipefail

mysql_host="${MYAAC_DB_HOST:-db}"
mysql_port="${MYAAC_DB_PORT:-3306}"
mysql_user="${MYAAC_DB_USER:-canary}"
mysql_pass="${MYAAC_DB_PASSWORD:-change-me-db}"
mysql_db="${MYAAC_DB_NAME:-canary}"

schema_exists() {
  MYSQL_PWD="$mysql_pass" mysql \
    --protocol=tcp \
    -h "$mysql_host" \
    -P "$mysql_port" \
    -u "$mysql_user" \
    -Nse "SELECT 1 FROM information_schema.tables WHERE table_schema='${mysql_db}' AND table_name='myaac_config' LIMIT 1;"
}

until MYSQL_PWD="$mysql_pass" mysqladmin \
  --protocol=tcp \
  -h "$mysql_host" \
  -P "$mysql_port" \
  -u "$mysql_user" \
  ping --silent >/dev/null 2>&1; do
  sleep 2
done

if ! schema_exists | grep -q 1; then
  echo "Bootstrapping MyAAC schema in ${mysql_db}..."
  MYSQL_PWD="$mysql_pass" mysql \
    --protocol=tcp \
    -h "$mysql_host" \
    -P "$mysql_port" \
    -u "$mysql_user" \
    "$mysql_db" < /var/www/html/install/includes/schema.sql
fi

exec "$@"

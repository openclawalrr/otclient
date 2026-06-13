<?php

$config['installed'] = true;
$config['server_path'] = getenv('MYAAC_SERVER_PATH') ?: '/srv/myaac-server/';
$config['database_host'] = getenv('MYAAC_DB_HOST') ?: 'db';
$config['database_port'] = getenv('MYAAC_DB_PORT') ?: '3306';
$config['database_user'] = getenv('MYAAC_DB_USER') ?: 'canary';
$config['database_password'] = getenv('MYAAC_DB_PASSWORD') ?: 'change-me-db';
$config['database_name'] = getenv('MYAAC_DB_NAME') ?: 'canary';
$config['date_timezone'] = getenv('MYAAC_TIMEZONE') ?: 'America/Bahia';
$config['env'] = 'prod';
$config['gzip_output'] = false;
$config['mail_enabled'] = false;
$config['account_mail_verify'] = false;
$config['account_country'] = false;


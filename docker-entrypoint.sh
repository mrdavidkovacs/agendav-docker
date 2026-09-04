#!/bin/sh
set -eu

: "${AGENDAV_CSRF_SECRET:?Set AGENDAV_CSRF_SECRET to a random value}"
: "${AGENDAV_CALDAV_BASEURL:?Set AGENDAV_CALDAV_BASEURL to Baikal's /dav.php/ URL}"

mkdir -p "$AGENDAV_DATA_DIR"
chown -R www-data:www-data "$AGENDAV_DATA_DIR" /app/var

export AGENDAV_DATABASE_PATH="${AGENDAV_DATABASE_PATH:-$AGENDAV_DATA_DIR/agendav.sqlite}"
export AGENDAV_CALDAV_PUBLIC_URL="${AGENDAV_CALDAV_PUBLIC_URL:-$AGENDAV_CALDAV_BASEURL}"
export AGENDAV_TITLE="${AGENDAV_TITLE:-Calendar}"

php -r '
$settings = [
    "site.title" => getenv("AGENDAV_TITLE"),
    "db.options" => ["driver" => "pdo_sqlite", "path" => getenv("AGENDAV_DATABASE_PATH")],
    "csrf.secret" => getenv("AGENDAV_CSRF_SECRET"),
    "caldav.baseurl" => getenv("AGENDAV_CALDAV_BASEURL"),
    "caldav.baseurl.public" => getenv("AGENDAV_CALDAV_PUBLIC_URL"),
    "caldav.authmethod" => "basic",
    "caldav.publicurls" => true,
    "caldav.connect.timeout" => 5,
    "caldav.response.timeout" => 30,
    "defaults.timezone" => getenv("AGENDAV_TIMEZONE"),
    "defaults.language" => getenv("AGENDAV_LANGUAGE"),
    "defaults.date_format" => "dmy",
    "defaults.weekstart" => 1,
    "log.file" => "php://stdout",
];
file_put_contents("/app/config/settings.php", "<?php\nreturn " . var_export($settings, true) . ";\n");
'

php /app/bin/agendavcli migrations:migrate --no-interaction
exec "$@"

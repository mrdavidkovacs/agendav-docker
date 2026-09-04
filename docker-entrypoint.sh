#!/bin/sh
set -eu

: "${AGENDAV_CSRF_SECRET:?Set AGENDAV_CSRF_SECRET to a random value}"
: "${AGENDAV_SESSION_ENCRYPTION_KEY:?Set AGENDAV_SESSION_ENCRYPTION_KEY to 64 random hex characters}"
: "${AGENDAV_CALDAV_BASEURL:?Set AGENDAV_CALDAV_BASEURL to Baikal's /dav.php/ URL}"
: "${AGENDAV_DB_HOST:?Set AGENDAV_DB_HOST}"
: "${AGENDAV_DB_NAME:?Set AGENDAV_DB_NAME}"
: "${AGENDAV_DB_USER:?Set AGENDAV_DB_USER}"
: "${AGENDAV_DB_PASSWORD:?Set AGENDAV_DB_PASSWORD}"

mkdir -p /app/var/cache/twig /app/var/log
chown -R www-data:www-data /app/var

export AGENDAV_TITLE="${AGENDAV_TITLE:-Calendar}"
export AGENDAV_CALDAV_PUBLIC_URL="${AGENDAV_CALDAV_PUBLIC_URL:-$AGENDAV_CALDAV_BASEURL}"
export AGENDAV_TIMEZONE="${AGENDAV_TIMEZONE:-Europe/Vienna}"
export AGENDAV_LANGUAGE="${AGENDAV_LANGUAGE:-de_DE}"
export AGENDAV_CALDAV_AUTHMETHOD="${AGENDAV_CALDAV_AUTHMETHOD:-basic}"
case "$AGENDAV_CALDAV_AUTHMETHOD" in basic|digest) ;; *) echo "AGENDAV_CALDAV_AUTHMETHOD must be basic or digest" >&2; exit 1;; esac

php -r '
$settings = [
  "site.title" => getenv("AGENDAV_TITLE"),
  "db.options" => ["driver" => "pdo_mysql", "host" => getenv("AGENDAV_DB_HOST"), "dbname" => getenv("AGENDAV_DB_NAME"), "user" => getenv("AGENDAV_DB_USER"), "password" => getenv("AGENDAV_DB_PASSWORD"), "charset" => "utf8mb4"],
  "csrf.secret" => getenv("AGENDAV_CSRF_SECRET"),
  "session.encryption.key" => getenv("AGENDAV_SESSION_ENCRYPTION_KEY"),
  "caldav.baseurl" => getenv("AGENDAV_CALDAV_BASEURL"),
  "caldav.baseurl.public" => getenv("AGENDAV_CALDAV_PUBLIC_URL"),
  "caldav.authmethod" => getenv("AGENDAV_CALDAV_AUTHMETHOD"),
  "defaults.timezone" => getenv("AGENDAV_TIMEZONE"),
  "defaults.language" => getenv("AGENDAV_LANGUAGE"),
  "defaults.time_format" => "24",
  "defaults.date_format" => "dmy",
  "defaults.weekstart" => 1,
  "log.file" => "php://stdout",
];
file_put_contents("/app/config/settings.php", "<?php\nreturn " . var_export($settings, true) . ";\n");
'

for version in Version20140812113548 Version20140812200547 Version20140812203419; do
  php /app/bin/agendavcli migrations:version "AgenDAV\\DB\\Migrations\\$version" --add --no-interaction || true
done
php /app/bin/agendavcli migrations:migrate --no-interaction

exec apache2-foreground

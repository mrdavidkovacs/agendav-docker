# AgenDAV Docker image

A minimal, multi-architecture container for [AgenDAV](https://github.com/agendav/agendav), built from its official release archive.

## Image tags

- `ghcr.io/mrdavidkovacs/agendav-docker:3.3.1` — AgenDAV release version
- `ghcr.io/mrdavidkovacs/agendav-docker:latest` — most recently built release

Every push to `main` builds `linux/amd64` and `linux/arm64` images. The release archive SHA-256 is verified during the build.

## Configuration

AgenDAV uses an external MariaDB/MySQL database, as supported by upstream for multi-user production deployments. Required: `AGENDAV_DB_HOST`, `AGENDAV_DB_NAME`, `AGENDAV_DB_USER`, `AGENDAV_DB_PASSWORD`, `AGENDAV_CSRF_SECRET`, `AGENDAV_SESSION_ENCRYPTION_KEY` (64 random hex characters), and `AGENDAV_CALDAV_BASEURL` (the internal Baïkal URL ending in `/dav.php/`).

Optional: `AGENDAV_CALDAV_PUBLIC_URL`, `AGENDAV_CALDAV_AUTHMETHOD` (`basic` by default; use `digest` for Baïkal), `AGENDAV_TITLE`, `AGENDAV_TIMEZONE` (defaults to `Europe/Vienna`) and `AGENDAV_LANGUAGE` (defaults to `de_DE`). Migrations run when the container starts, so the database must be healthy first. Use your deployment's secret mechanism rather than committing values to Compose.

```yaml
services:
  agendav:
    image: ghcr.io/mrdavidkovacs/agendav-docker:3.3.1
    environment:
      AGENDAV_DB_HOST: mariadb
      AGENDAV_DB_NAME: agendav
      AGENDAV_DB_USER: agendav
      AGENDAV_DB_PASSWORD: use-a-secret
      AGENDAV_CSRF_SECRET: use-a-random-secret
      AGENDAV_SESSION_ENCRYPTION_KEY: use-64-random-hex-characters
      AGENDAV_CALDAV_BASEURL: http://baikal:80/dav.php/
      AGENDAV_CALDAV_PUBLIC_URL: https://dav.example.net/dav.php/
      AGENDAV_CALDAV_AUTHMETHOD: digest
    ports:
      - "8080:80"
    restart: unless-stopped
```

Do not expose the container directly to the Internet; put it behind HTTPS reverse proxying. AgenDAV authenticates users against Baïkal using the configured CalDAV authentication method.

## Updates

- Renovate opens dependency updates weekly.
- A weekly workflow reads the official AgenDAV release metadata and opens a PR whenever a newer release exists. It updates both the version and the published SHA-256 checksum.

This repository contains packaging only. AgenDAV is GPL-3.0-or-later; see its [upstream source](https://github.com/agendav/agendav).

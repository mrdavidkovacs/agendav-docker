# AgenDAV Docker image

A minimal, multi-architecture container for [AgenDAV](https://github.com/agendav/agendav), built from its official release archive.

## Image tags

- `ghcr.io/mrdavidkovacs/agendav-docker:3.3.1` — AgenDAV release version
- `ghcr.io/mrdavidkovacs/agendav-docker:latest` — most recently built release

Every push to `main` builds `linux/amd64` and `linux/arm64` images. The release archive SHA-256 is verified during the build.

## Configuration

AgenDAV uses SQLite in `/data`; mount that directory persistently. Its only required settings are a random CSRF secret and Baikal's internal CalDAV endpoint.

```yaml
services:
  agendav:
    image: ghcr.io/mrdavidkovacs/agendav-docker:3.3.1
    environment:
      AGENDAV_CSRF_SECRET: replace-with-a-random-64-hex-character-secret
      AGENDAV_CALDAV_BASEURL: http://dkr01.srv.arpa:5232/dav.php/
      AGENDAV_CALDAV_PUBLIC_URL: https://dav.example.net/dav.php/
      AGENDAV_TITLE: Family calendar
      AGENDAV_TIMEZONE: Europe/Vienna
      AGENDAV_LANGUAGE: de_DE
    volumes:
      - ./data:/data
    ports:
      - "8080:80"
    restart: unless-stopped
```

Do not expose the container directly to the Internet; put it behind HTTPS reverse proxying. AgenDAV authenticates users against Baikal with HTTP Basic authentication, so the Baikal server must use Basic auth.

## Updates

- Renovate opens dependency updates weekly.
- A weekly workflow reads the official AgenDAV release metadata and opens a PR whenever a newer release exists. It updates both the version and the published SHA-256 checksum.

This repository contains packaging only. AgenDAV is GPL-3.0-or-later; see its [upstream source](https://github.com/agendav/agendav).

#!/usr/bin/env python3
"""Update the pinned AgenDAV release archive and its published checksum."""

from __future__ import annotations

import json
import re
import urllib.request
from pathlib import Path

DOCKERFILE = Path(__file__).parents[1] / "Dockerfile"
API_URL = "https://api.github.com/repos/agendav/agendav/releases/latest"


def main() -> None:
    request = urllib.request.Request(API_URL, headers={"Accept": "application/vnd.github+json", "User-Agent": "agendav-docker-updater"})
    with urllib.request.urlopen(request, timeout=30) as response:
        release = json.load(response)

    version = release["tag_name"].removeprefix("v")
    expected_asset = f"agendav-{version}.tar.gz"
    asset = next(item for item in release["assets"] if item["name"] == expected_asset)
    digest = asset.get("digest", "")
    if not digest.startswith("sha256:"):
        raise RuntimeError(f"{expected_asset} has no published SHA-256 digest")

    source = DOCKERFILE.read_text()
    updated = re.sub(r"ARG AGENDAV_VERSION=\S+", f"ARG AGENDAV_VERSION={version}", source)
    updated = re.sub(r"ARG AGENDAV_SHA256=\S+", f"ARG AGENDAV_SHA256={digest.removeprefix('sha256:')}", updated)
    if updated == source:
        print(f"AgenDAV {version} already pinned")
        return
    DOCKERFILE.write_text(updated)
    print(f"Updated AgenDAV to {version}")


if __name__ == "__main__":
    main()

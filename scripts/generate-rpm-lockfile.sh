#!/usr/bin/env bash
# Regenerate the shared Konflux RPM lockfile for x86_64 and aarch64.
# Requires rpm-lockfile-prototype (tested with v0.30.1), skopeo, and network access.
# Installation: https://github.com/konflux-ci/rpm-lockfile-prototype#installation
# Usage: ./scripts/generate-rpm-lockfile.sh
set -euo pipefail

if [[ $# -ne 0 ]]; then
    echo "usage: $0" >&2
    exit 2
fi

if ! command -v rpm-lockfile-prototype >/dev/null 2>&1; then
    echo "error: install rpm-lockfile-prototype; see https://github.com/konflux-ci/rpm-lockfile-prototype#installation" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# All three builds share a base; the input includes the gateway's extra packages.
LOCKFILE_TMP="$(mktemp "$REPO_ROOT/.rpms.lock.XXXXXX")"
trap 'rm -f -- "$LOCKFILE_TMP"' EXIT
rpm-lockfile-prototype \
    --outfile "$LOCKFILE_TMP" \
    rpms.in.yaml
chmod 0644 "$LOCKFILE_TMP"
mv -- "$LOCKFILE_TMP" rpms.lock.yaml

#!/bin/bash
# Runs INSIDE debian:trixie (arm64). Builds upstream Sunshine (+ our patches) and packages a .deb.
set -euxo pipefail
cd /build/sunshine
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y --no-install-recommends git ca-certificates sudo
git config --global --add safe.directory '*'
chmod +x scripts/linux_build.sh
COMMON=(--skip-cuda --sudo-off)
./scripts/linux_build.sh --step=deps  "${COMMON[@]}"
./scripts/linux_build.sh --step=cmake "${COMMON[@]}" \
  --publisher-name='av1acp (sunshine_rpi_400)' \
  --publisher-website='https://github.com/av1acp/sunshine_rpi_400' \
  --publisher-issue-url='https://github.com/av1acp/sunshine_rpi_400/issues'
./scripts/linux_build.sh --step=build   "${COMMON[@]}"
./scripts/linux_build.sh --step=package "${COMMON[@]}"
ls -la build/cpack_artifacts/

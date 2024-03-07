#!/usr/bin/env bash
#
# CI specific build script.
#
set -euo pipefail

channel=${NIXPKGS_CHANNEL:-nixos-unstable}
registry=${CI_REGISTRY:-docker.io}
registry_auth=${CI_REGISTRY_AUTH:-}
image_prefix=${CI_PROJECT_PATH:-nixpkgs}

if [[ $channel == nixos-unstable ]]; then
  image_tag=latest
else
  image_tag=$channel
fi

export NIX_PATH=channel:$channel

banner() {
  echo "========================================================"
  echo "  $*"
  echo "========================================================"
}

cd "$(dirname "$0")"

if [[ $(git rev-parse --abbrev-ref HEAD) != master ]]; then
  banner "Skipping push on non-master branch"
  exit
fi

if [[ -n "${registry_auth}" ]]; then
  banner "docker login"
  ./docker-login "$registry_auth" "$registry"
fi

banner "generate manifests"
./generate-manifests "$registry" "$image_prefix" "$image_tag"

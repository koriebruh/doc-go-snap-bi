#!/usr/bin/env bash

#------------------------------------------------------------------------------
# Builds this Hugo project on Vercel.
#
# baseURL is overridden at build time to whatever domain Vercel actually
# serves this deployment from (production custom domain, or the
# *.vercel.app deployment URL), so the site never ships with the wrong
# baseURL (e.g. the GitHub Pages "/doc-go-snap-bi/" subpath baked into
# hugo.toml for the GH Pages target) baked into every link/asset path.
#------------------------------------------------------------------------------

set -euo pipefail

GO_VERSION=1.27.0
HUGO_VERSION=0.166.0

HUGO_CACHEDIR="${PWD}/.vercel/cache/hugo"

cleanup() {
  if [[ -n "${build_temp_dir:-}" && -d "${build_temp_dir}" ]]; then
    rm -rf "${build_temp_dir}"
  fi
}
trap cleanup EXIT SIGINT SIGTERM

main() {
  export HUGO_CACHEDIR

  build_temp_dir=$(mktemp -d)
  mkdir -p "${HOME}/.local"

  # Hugo Modules (the Hextra theme import) need Go at build time.
  if [[ -f "go.mod" ]]; then
    echo "Installing Go ${GO_VERSION}..."
    curl -sfL --output-dir "${build_temp_dir}" -O "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
    tar -C "${HOME}/.local" -xf "${build_temp_dir}/go${GO_VERSION}.linux-amd64.tar.gz"
    export PATH="${HOME}/.local/go/bin:${PATH}"
  fi

  echo "Installing Hugo ${HUGO_VERSION} (extended)..."
  curl -sfL --output-dir "${build_temp_dir}" -O "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"
  mkdir -p "${HOME}/.local/hugo"
  tar -C "${HOME}/.local/hugo" -xf "${build_temp_dir}/hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"
  export PATH="${HOME}/.local/hugo:${PATH}"

  command -v go &> /dev/null && echo "Go: $(go version)" || echo "Go: not installed"
  echo "Hugo: $(hugo version)"

  git config --global core.quotepath false
  if [[ $(git rev-parse --is-shallow-repository) == true ]]; then
    echo "Fetching full Git history..."
    git fetch --unshallow
  fi

  # Prefer the stable production domain; fall back to this deployment's
  # own preview URL; fall back to hugo.toml's baseURL if neither is set
  # (e.g. building locally).
  if [[ -n "${VERCEL_PROJECT_PRODUCTION_URL:-}" ]]; then
    site_url="https://${VERCEL_PROJECT_PRODUCTION_URL}/"
  elif [[ -n "${VERCEL_URL:-}" ]]; then
    site_url="https://${VERCEL_URL}/"
  else
    site_url=""
  fi

  echo "Building the project..."
  if [[ -n "${site_url}" ]]; then
    echo "Using baseURL: ${site_url}"
    hugo build --gc --minify --baseURL "${site_url}"
  else
    hugo build --gc --minify
  fi
}

main "$@"

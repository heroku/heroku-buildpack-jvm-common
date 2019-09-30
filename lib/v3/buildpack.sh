#!/usr/bin/env bash

bp_layer_rebuild?() {
  local layers_dir="${1:?}"
  local name="${2:?}"
  local metadata="${3:?}"
  
  local layer_dir="${layers_dir}/${name}"
  local layer_metadata="${layer_dir}.toml"
  
  if [ -f "${layer_metadata}" ]; then
    # todo if the same as ${metadata} return 1
    return 0
  fi
  return 0 
}

bp_layer_metadata_create() {
  local launch="${1:-false}"
  local cache="${2:-false}"
  local build="${3:-false}"
  local metadata="${4:-}"

  cat <<EOF
launch = ${launch}
cache = ${cache}
build = ${build}

[metadata]
${metadata}
EOF
}

bp_layer_init() {
  local layers_dir="${1:?}"
  local name="${2:?}"
  local metadata="${3:?}"
  
  local layer_dir="${layers_dir}/${name}"
  local layer_metadata="${layer_dir}.toml"

  mkdir -p "${layer_dir}"
  echo "${metadata}" > "${layer_metadata}"

  echo "${layer_dir}"
}
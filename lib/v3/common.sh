#!/usr/bin/env bash

status() {
  local color="\033[0;35m"
  local no_color="\033[0m"
  echo -e "\n${color}[${1:-""}]${no_color}"
}

info() {
  echo -e "${1:-""}"
}

debug() {
  echo -e "${1:-""}"
}

curl_retry_on_18() {
  local ec=18
  local attempts=0
  while ((ec == 18 && attempts++ < 3)); do
    curl "$@" # -C - would return code 33 if unsupported by server
    ec=$?
  done
  return $ec
}

_jvm_mcount() {
  # placeholder for v3 stdlib
  return 0
}

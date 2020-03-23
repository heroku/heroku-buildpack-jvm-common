#!/usr/bin/env bash

# Support for Spring Data Redis
if [ "${DISABLE_SPRING_REDIS_URL:-}" != "true" ] &&
  [ -z "${SPRING_REDIS_URL:-}" ] &&
  [ -n "${REDIS_URL:-}" ]; then
  export SPRING_REDIS_URL="${REDIS_URL}"
fi

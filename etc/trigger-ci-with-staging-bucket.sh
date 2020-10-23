#!/usr/bin/env bash

set -o pipefail
set -eu

BRANCH="${1:-main}"

echo "$(tput setaf 6)$(tput bold)[Trigger CI with Staging Bucket]$(tput sgr0)"
cat <<EOF
This will trigger a new CI run for branch $(tput setaf 6)$(tput bold)${BRANCH}$(tput sgr0), re-running all regular tests
and also runs additional Hatchet tests while JVM_BUILDPACK_ASSETS_BASE_URL points to the staging bucket. This is useful
for testing assets in the staging bucket before promoting them to production.

EOF

read -r -p "Do you want to continue? [y/N] " continue_response
case "${continue_response}" in
[yY]) ;;
*)
  exit 0
  ;;
esac

payload='{
  "branch": "'${BRANCH}'",
  "parameters": {
    "enable-hatchet-with-staging-bucket": true
  }
}'

curl \
  -u "${CIRCLECI_TOKEN:?This script requires CIRCLECI_TOKEN environment variable to be set!}": \
  --silent \
  -X POST --header "Content-Type: application/json" -d "${payload:?}" \
  https://circleci.com/api/v2/project/github/heroku/heroku-buildpack-jvm-common/pipeline

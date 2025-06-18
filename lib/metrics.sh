#!/usr/bin/env bash

# This is technically redundant, since all consumers of this lib will have enabled these,
# however, it helps Shellcheck realise the options under which these functions will run.
set -euo pipefail

JVM_COMMON_BUILDPACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"

source "${JVM_COMMON_BUILDPACK_DIR}/lib/util.sh"

# Variables shared by this whole module
METRICS_DATA_FILE=""
PREVIOUS_METRICS_DATA_FILE=""

# Must be called before you can use any other methods
metrics::init() {
	local cache_dir="${1}"
	local buildpack_name="${2}"

	METRICS_DATA_FILE="${cache_dir}/metrics-data/${buildpack_name}"
	PREVIOUS_METRICS_DATA_FILE="${cache_dir}/metrics-data/${buildpack_name}-prev"
}

metrics::setup() {
	if [[ -f "${METRICS_DATA_FILE}" ]]; then
		cp "${METRICS_DATA_FILE}" "${PREVIOUS_METRICS_DATA_FILE}"
	fi

	mkdir -p "$(dirname "${METRICS_DATA_FILE}")"
	echo "{}" >"${METRICS_DATA_FILE}"
}

metrics::set_raw() {
	local key="${1}"
	local value="${2}"

	local new_data_file_contents
	new_data_file_contents=$(jq <"${METRICS_DATA_FILE}" --arg key "${key}" --argjson value "${value}" '. + { $key: $value }')

	echo "${new_data_file_contents}" >"${METRICS_DATA_FILE}"
}

metrics::set_string() {
	local key="${1}"
	local value="${2}"

	metrics::set_raw "${key}" "\"${value}\""
}

# Similar to mtime from buildpack-stdlib
metrics::set_time() {
	local key="${1}"
	local start="${2}"
	local end="${3:-$(util::nowms)}"
	local time
	time="$(echo "${start}" "${end}" | awk '{ printf "%.3f", ($2 - $1)/1000 }')"
	metrics::set_raw "${key}" "${time}"
}

metrics::print_bin_report_yaml() {
	jq -r 'keys[] as $key | (.[$key] | tojson) as $value | "\($key): \($value)"' <"${METRICS_DATA_FILE}"
}

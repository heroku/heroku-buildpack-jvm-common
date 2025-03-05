#!/usr/bin/env bash

# Exports configuration variables of a buildpacks ENV_DIR to environment variables.
#
# Only configuration variables which names pass the positive pattern and don't match the negative pattern
# will be exported.
#
# Usage:
# ```
# export_env_dir "./env" "." "FORBIDDEN_ENV"
# ```
util::export_env_dir() {
	local env_dir="${1:?}"
	local positive_pattern="${2:-"."}"
	local negative_pattern="^(PATH|GIT_DIR|CPATH|CPPATH|LD_PRELOAD|LIBRARY_PATH${3:+"|"}${3:-})$"

	for env_file in "${env_dir}"/*; do
		if [[ -f "${env_file}" ]]; then
			local env_name
			env_name="$(basename "${env_file}")"

			if [[ "${env_name}" =~ ${positive_pattern} ]] && ! [[ "${env_name}" =~ ${negative_pattern} ]]; then
				export "${env_name}=$(cat "${env_file}")"
			fi
		fi
	done
}

util::curl_with_defaults() {
	default_args=()

	# Some company-internal users are building their slugs on CentOS where these newer curl commands aren't
	# supported yet. This conditional ensures their builds continue to work.
	if curl --help all | grep -q -- --retry-connrefused; then
		default_args+=("--retry-connrefused" "--connect-timeout" "5")
	fi

	curl "${default_args[@]}" "${@}"
}

util::nowms() {
	date +%s%3N
}

#!/usr/bin/env bash

JVM_COMMON_BUILDPACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"

source "${JVM_COMMON_BUILDPACK_DIR}/lib/output.sh"

# This buildpack did undergo significant changes in 2025. Some internal functions were removed that might be used
# by other buildpacks that use this buildpack as a library. To make their experience less painful, we output an error
# message about this change and exit the shell if one of those functions are being used.
legacy::install_removed_function_handler() {
	for removed_function_name in "${@}"; do
		# Avoid installing the handler if the downstream code defined their own function of the same name
		if ! [[ $(type -t "${removed_function_name}") == function ]]; then
			eval "${removed_function_name}() { legacy::removed_handler \"${removed_function_name}\"; }"
		fi
	done
}

legacy::removed_handler() {
	function_name="${1}"

	output::error <<-EOF
		ERROR: Function ${function_name} no longer exposed

		The buildpack you're using is likely employing Heroku's jvm-common
		buildpack to install OpenJDK.

		Your buildpack is using the bash function ${function_name} which is no
		longer exposed in the latest release of Heroku's jvm-common buildpack.
		If you didn't upgrade anything, it's likely that your buildpack is
		implicitly using the latest release of Heroku's jvm-common buildpack.

		Your buildpack needs changes to continue to work. In most cases

		install_openjdk "\${BUILD_DIR}" "\${BUILDPACK_DIR}"

		should be sufficient to install OpenJDK. Please refer to jvm-commons
		README.md file for a complete usage example:

		https://github.com/heroku/heroku-buildpack-jvm-common
	EOF

	exit 1
}

#!/usr/bin/env bash

export JAVA_HOME="${HOME}/.jdk"
export PATH="${HOME}/.heroku/bin:${PATH}"
export PATH="${JAVA_HOME}/bin:${PATH}"

# Path is OpenJDK version dependent
for path in "${JAVA_HOME}/lib/server" "${JAVA_HOME}/jre/lib/amd64/server"; do
	if [[ -d "${path}" ]]; then
		export LD_LIBRARY_PATH="${path}${LD_LIBRARY_PATH:+":"}${LD_LIBRARY_PATH:-}"
	fi
done

jvm_options() {
	local flags=(
		# Default to UTF-8 encoding when no charset is specified for methods in the Java standard library.
		# This makes programs more predictable and has been a default on Heroku for a many years. For OpenJDK >= 18,
		# setting this is technically no longer necessary as it is the default.
		# See JEP-400 for details: https://openjdk.org/jeps/400
		"-Dfile.encoding=UTF-8"
	)

	local memory_limit_file='/sys/fs/cgroup/memory/memory.limit_in_bytes'

	if [[ -f "${memory_limit_file}" ]]; then
		local memory_limit
		memory_limit=$(cat "${memory_limit_file}")

		# Ignore values above 1TiB RAM, since when using cgroups v1 the limits file reports a
		# bogus value of thousands of TiB RAM when there is no container memory limit set.
		if ((memory_limit > 1099511627776)); then
			unset memory_limit
		fi
	fi

	if [[ -n "${memory_limit}" ]]; then
		# The JVM tries to automatically detect the amount of available RAM for its heuristics. However,
		# the detection has proven to be sometimes inaccurate in certain dyno configurations. MaxRAM is used
		# by the JVM to derive other flags from it.
		flags+=("-XX:MaxRAM=${memory_limit}")
	fi

	case "${memory_limit:-}" in
	# Eco, Basic, 1X (512MiB)
	536870912) flags+=("-Xmx300m" "-Xss512k" "-XX:CICompilerCount=2") ;;
	# 2X, private-s (1GiB)
	1073741824) flags+=("-Xmx671m" "-XX:CICompilerCount=2") ;;
	# Rely on JVM ergonomics for other dyno types, but increase the maximum RAM percentage from 25% to 80%.
	# This is consistent with the historic Heroku defaults for dyno types not listed above.
	*) flags+=("-XX:MaxRAMPercentage=80.0") ;;
	esac

	(
		IFS=" "
		echo "${flags[*]}"
	)
}

jvm_options="$(jvm_options)"
export JAVA_OPTS="${jvm_options}${JAVA_OPTS:+" "}${JAVA_OPTS:-}"

if ! [[ "${DYNO}" =~ ^run\..*$ ]]; then
	# Redirecting to stderr to avoid polluting the application's stdout stream. This is especially important for
	# MCP servers using the stdio transport: https://modelcontextprotocol.io/specification/2025-03-26/basic/transports#stdio
	echo "Setting JAVA_TOOL_OPTIONS defaults based on dyno size. Custom settings will override them." >&2
	export JAVA_TOOL_OPTIONS="${jvm_options}${JAVA_TOOL_OPTIONS:+" "}${JAVA_TOOL_OPTIONS:-}"
fi

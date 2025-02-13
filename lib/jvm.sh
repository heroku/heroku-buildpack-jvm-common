#!/usr/bin/env bash

STACK="${STACK:-"heroku-24"}"

if [ "${STACK}" == "heroku-24" ]; then
	# This should always be the latest OpenJDK LTS major version
	# Next LTS will be OpenJDK 25 with a planned release date of 2025-09-16
	DEFAULT_JDK_VERSION="21"
else
	DEFAULT_JDK_VERSION="1.8"
fi

get_jdk_version() {
	local appDir="${1:?}"

	configuredVersion="$(_get_system_property "${appDir}/system.properties" "java.runtime.version")"
	if [ -n "${configuredVersion}" ]; then
		echo "${configuredVersion}"
	else
		echo "${DEFAULT_JDK_VERSION}"
	fi
}

get_jdk_url() {
	read -d '' -r INVENTORY_QUERY <<-'INVENTORY_QUERY'
		($raw_version_string | capture("((?<stack>[^-]*?)-)?(?<version>.*$)")) as $parsed_raw_version_string |
		(.version_aliases[$parsed_raw_version_string.version] // $parsed_raw_version_string.version) as $version |
		($parsed_raw_version_string.stack // $default_distribution) as $distribution |
		.artifacts[] | select(.version == $version and .metadata.distribution == $distribution and .arch == "amd64" and .os == "linux" and (.metadata.cedar_stack? == null or .metadata.cedar_stack? == $stack))
	INVENTORY_QUERY

	local default_distribution="zulu"
	if [[ "${STACK}" == "heroku-20" ]]; then
		default_distribution="heroku"
	fi

	jq <"${JVM_COMMON_DIR}/inventory.json" \
		--arg raw_version_string "${1}" \
		--arg default_distribution "${default_distribution}" \
		--arg stack "${STACK}" \
		"${INVENTORY_QUERY}" |
		jq -r ".url"
}

install_jdk() {
	local url="${1:?}"
	local dir="${2:?}"
	local bpDir="${3:?}"
	local key="${4:-${bpDir}/.gnupg/lang-jvm.asc}"
	local tarball="/tmp/jdk.tgz"

	curl_with_defaults --retry 3 --silent --show-error --location "${url}" --output "${tarball}"

	tar pxzf "${tarball}" -C "${dir}"
	rm "${tarball}"
}

install_certs() {
	local jdkDir="${1:?}"
	if [ -f "${jdkDir}/jre/lib/security/cacerts" ] && [ -f /etc/ssl/certs/java/cacerts ]; then
		mv "${jdkDir}/jre/lib/security/cacerts" "${jdkDir}/jre/lib/security/cacerts.old"
		ln -s /etc/ssl/certs/java/cacerts "${jdkDir}/jre/lib/security/cacerts"
	elif [ -f "${jdkDir}/lib/security/cacerts" ] && [ -f /etc/ssl/certs/java/cacerts ]; then
		mv "${jdkDir}/lib/security/cacerts" "${jdkDir}/lib/security/cacerts.old"
		ln -s /etc/ssl/certs/java/cacerts "${jdkDir}/lib/security/cacerts"
	fi
}

install_profile() {
	local bpDir="${1:?}"
	local profileDir="${2:?}"

	mkdir -p "$profileDir"
	cp "${bpDir}/opt/jvmcommon.sh" "${profileDir}"
	cp "${bpDir}/opt/jdbc.sh" "${profileDir}"
	cp "${bpDir}/opt/jvm-redis.sh" "${profileDir}"
}

install_jdk_overlay() {
	local jdkDir="${1:?}"
	local appDir="${2:?}"
	local cacertPath="lib/security/cacerts"
	shopt -s dotglob
	if [ -d "${jdkDir}" ] && [ -d "${appDir}/.jdk-overlay" ]; then
		# delete the symlink because a cp will error
		if [ -f "${appDir}/.jdk-overlay/jre/${cacertPath}" ] && [ -f "${jdkDir}/jre/${cacertPath}" ]; then
			rm "${jdkDir}/jre/${cacertPath}"
		elif [ -f "${appDir}/.jdk-overlay/${cacertPath}" ] && [ -f "${jdkDir}/${cacertPath}" ]; then
			rm "${jdkDir}/${cacertPath}"
		fi
		cp -r "${appDir}/.jdk-overlay/"* "${jdkDir}"
	fi
}

install_metrics_agent() {
	local bpDir=${1:?}
	local installDir="${2:?}"
	local profileDir="${3:?}"
	local agentJar="${installDir}/heroku-metrics-agent.jar"

	mkdir -p "${installDir}"
	curl_with_defaults --retry 3 -s -o "${agentJar}" \
		-L "${HEROKU_METRICS_JAR_URL:-"https://repo1.maven.org/maven2/com/heroku/agent/heroku-java-metrics-agent/4.0.1/heroku-java-metrics-agent-4.0.1.jar"}"
	if [ -f "${agentJar}" ]; then
		mkdir -p "${profileDir}"
		cp "${bpDir}/opt/heroku-jvm-metrics.sh" "${profileDir}"
	fi
}

install_jre() {
	local jdkDir="${1:?}"
	local jreDir="${2:?}"

	if [ -d "${jdkDir}/jre" ]; then
		rm -rf "${jreDir}"
		cp -TR "${jdkDir}/jre" "${jreDir}"
		cp -TR "${jdkDir}/release" "${jreDir}/release"
	else
		cp -TR "${jdkDir}" "${jreDir}"
	fi
}

_get_system_property() {
	local file=${1:?}
	local key=${2:?}

	# escape for regex
	local escaped_key
	escaped_key="${key//\./\\.}"

	if [ -f "${file}" ]; then
		grep -E "^${escaped_key}[[:space:]=]+" "${file}" |
			sed -E -e "s/${escaped_key}([\ \t]*=[\ \t]*|[\ \t]+)([_A-Za-z0-9\.-]*).*/\2/g"
	else
		echo ""
	fi
}

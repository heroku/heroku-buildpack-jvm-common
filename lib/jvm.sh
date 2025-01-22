#!/usr/bin/env bash

STACK="${STACK:-"heroku-24"}"

if [ "${STACK}" == "heroku-24" ]; then
	# This should always be the latest OpenJDK LTS major version
	# Next LTS will be OpenJDK 25 with a planned release date of 2025-09-16
	DEFAULT_JDK_VERSION="21"
else
	DEFAULT_JDK_VERSION="1.8"
fi

DEFAULT_JDK_1_8_VERSION="1.8.0_432"
DEFAULT_JDK_11_VERSION="11.0.25"
DEFAULT_JDK_17_VERSION="17.0.13"
DEFAULT_JDK_21_VERSION="21.0.5"
DEFAULT_JDK_23_VERSION="23.0.1"

# EOL Versions
DEFAULT_JDK_1_7_VERSION="1.7.0_352"
DEFAULT_JDK_10_VERSION="10.0.2"
DEFAULT_JDK_13_VERSION="13.0.14"
DEFAULT_JDK_14_VERSION="14.0.2"
DEFAULT_JDK_15_VERSION="15.0.10"
DEFAULT_JDK_16_VERSION="16.0.2"
DEFAULT_JDK_18_VERSION="18.0.2.1"
DEFAULT_JDK_19_VERSION="19.0.2"
DEFAULT_JDK_20_VERSION="20.0.2"
DEFAULT_JDK_22_VERSION="22.0.2"

if [[ -n "${JDK_BASE_URL:-}" ]]; then
	# Support for setting JDK_BASE_URL had the issue that it has to contain the stack name. This makes it hard to
	# override the bucket for testing with staging binaries by using the existing JVM buildpack integration tests that
	# cover all stacks. We will remove support for it in October 2021.
	warning_inline "Support for the JDK_BASE_URL environment variable is deprecated and will be removed October 2021!"
else
	JVM_BUILDPACK_ASSETS_BASE_URL="${JVM_BUILDPACK_ASSETS_BASE_URL:-"https://lang-jvm.s3.us-east-1.amazonaws.com"}"
	JDK_BASE_URL="${JVM_BUILDPACK_ASSETS_BASE_URL%/}/jdk/${STACK}"
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

get_full_jdk_version() {
	# The version argument can potentially have a prefix which denotes the
	# OpenJDK distribution. This function only normalizes the actual version
	# and keeps the prefix intact.
	IFS='-' read -r prefix version <<<"${1:?}"

	if [ -z "${version}" ]; then
		# If the version variable is empty, there is no prefix and the
		# version was stored in the prefix variable.
		version="${prefix}"
	else
		# When there is a prefix, emit it before emitting the normalized
		# version to keep it untouched by this function.
		echo -n "${prefix}-"
	fi

	case "${version}" in
	"7" | "1.7") echo "${DEFAULT_JDK_1_7_VERSION}" ;;
	"8" | "1.8") echo "${DEFAULT_JDK_1_8_VERSION}" ;;
	"10") echo "${DEFAULT_JDK_10_VERSION}" ;;
	"11") echo "${DEFAULT_JDK_11_VERSION}" ;;
	"13") echo "${DEFAULT_JDK_13_VERSION}" ;;
	"14") echo "${DEFAULT_JDK_14_VERSION}" ;;
	"15") echo "${DEFAULT_JDK_15_VERSION}" ;;
	"16") echo "${DEFAULT_JDK_16_VERSION}" ;;
	"17") echo "${DEFAULT_JDK_17_VERSION}" ;;
	"18") echo "${DEFAULT_JDK_18_VERSION}" ;;
	"19") echo "${DEFAULT_JDK_19_VERSION}" ;;
	"20") echo "${DEFAULT_JDK_20_VERSION}" ;;
	"21") echo "${DEFAULT_JDK_21_VERSION}" ;;
	"22") echo "${DEFAULT_JDK_22_VERSION}" ;;
	"23") echo "${DEFAULT_JDK_23_VERSION}" ;;
	*) echo "${version}" ;;
	esac
}

get_jdk_url() {
	local jdkVersion
	jdkVersion="$(get_full_jdk_version "${1:-${DEFAULT_JDK_VERSION}}")"

	case ${jdkVersion} in
	heroku-*) jdkUrl="${JDK_BASE_URL:-}/${jdkVersion//heroku-/openjdk}.tar.gz" ;;
	openjdk-*) jdkUrl="${JDK_BASE_URL:-}/${jdkVersion//openjdk-/openjdk}.tar.gz" ;;
	zulu-*) jdkUrl="${JDK_BASE_URL:-}/${jdkVersion}.tar.gz" ;;
	*)
		if [ "${STACK}" == "heroku-20" ]; then
			jdkUrl="${JDK_BASE_URL:-}/openjdk${jdkVersion}.tar.gz"
		else
			jdkUrl="${JDK_BASE_URL:-}/zulu-${jdkVersion}.tar.gz"
		fi
		;;
	esac

	echo "${jdkUrl}"
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

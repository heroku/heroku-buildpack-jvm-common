#!/usr/bin/env bash

# This script provides common utilities for installing the JDK and JRE. It is used
# by both the v2 and v3 buildpacks.

STACK="${STACK:-$CNB_STACK_ID}"
DEFAULT_JDK_VERSION="1.8"
DEFAULT_JDK_BASE_URL="https://lang-jvm.s3.amazonaws.com/jdk/${STACK:-"heroku-18"}"
JDK_BASE_URL=${JDK_BASE_URL:-$DEFAULT_JDK_BASE_URL}
JDK_URL_13=${JDK_URL_13:-"$JDK_BASE_URL/openjdk13.0.1.tar.gz"}
JDK_URL_12=${JDK_URL_12:-"$JDK_BASE_URL/openjdk12.0.2.tar.gz"}
JDK_URL_11=${JDK_URL_11:-"$JDK_BASE_URL/openjdk11.0.5.tar.gz"}
JDK_URL_10=${JDK_URL_10:-"$JDK_BASE_URL/openjdk10.0.2.tar.gz"}
JDK_URL_1_9=${JDK_URL_1_9:-"$JDK_BASE_URL/openjdk9.0.4.tar.gz"}
JDK_URL_1_8=${JDK_URL_1_8:-"$JDK_BASE_URL/openjdk1.8.0_232.tar.gz"}
JDK_URL_1_7=${JDK_URL_1_7:-"$JDK_BASE_URL/openjdk1.7.0_242.tar.gz"}

get_jdk_version() {
  local appDir="${1:?}"
  if [ -f ${appDir}/system.properties ]; then
    detectedVersion="$(_get_system_property "${appDir}/system.properties" "java.runtime.version")"
    if [ -n "$detectedVersion" ]; then
      echo "$detectedVersion"
    else
      echo "$DEFAULT_JDK_VERSION"
    fi
  else
    echo "$DEFAULT_JDK_VERSION"
  fi
}

get_jdk_url() {
  local jdkVersion=${1:-${DEFAULT_JDK_VERSION}}

  if [ "${jdkVersion}" = "10" ]; then
    local jdkUrl="${JDK_URL_10}"
  elif [ "${jdkVersion}" = "11" ]; then
    local jdkUrl="${JDK_URL_11}"
  elif [ "${jdkVersion}" = "12" ]; then
    local jdkUrl="${JDK_URL_12}"
  elif [ "${jdkVersion}" = "13" ]; then
    local jdkUrl="${JDK_URL_13}"
  elif [ "$(expr "${jdkVersion}" : '^1[0-3]')" != 0 ]; then
    local jdkUrl="${JDK_BASE_URL}/openjdk${jdkVersion}.tar.gz"
  elif [ "$(expr "${jdkVersion}" : '^1.[6-9]$')" != 0 ]; then
    local minorJdkVersion=$(expr "${jdkVersion}" : '1.\([6-9]\)')
    local jdkUrl=$(eval echo \$JDK_URL_1_${minorJdkVersion})
  elif [ "$(expr "${jdkVersion}" : '^[6-9]$')" != 0 ]; then
    local jdkUrl=$(eval echo \$JDK_URL_1_${jdkVersion})
  elif [ "$(expr "${jdkVersion}" : '^1.[6-9]')" != 0 ]; then
    local jdkUrl="${JDK_BASE_URL}/openjdk${jdkVersion}.tar.gz"
  elif [ "${jdkVersion}" = "9+181" ] || [ "${jdkVersion}" = "9.0.0" ]; then
    local jdkUrl="${JDK_BASE_URL}/openjdk9-181.tar.gz"
  elif [ "$(expr "${jdkVersion}" : '^9')" != 0 ]; then
    local jdkUrl="${JDK_BASE_URL}/openjdk${jdkVersion}.tar.gz"
  elif [ "$(expr "${jdkVersion}" : '^zulu-')" != 0 ]; then
    local jdkUrl="${JDK_BASE_URL}/${jdkVersion}.tar.gz"
  elif [ "$(expr "${jdkVersion}" : '^openjdk-')" != 0 ]; then
    local jdkUrl="${JDK_BASE_URL}/$(echo "$jdkVersion" | sed -e 's/k-/k/g').tar.gz"
  fi

  echo "${jdkUrl}"
}

get_jdk_cache_id() {
  local url="${1:?}"

  etagHeader="$(curl --head --retry 3 --silent --show-error --location "${url}" | grep ETag)"
  etag="$(echo "$etagHeader" | sed -e 's/ETag: //g' | sed -e 's/\r//g' | xargs echo)"

  if [ -n "$etag" ]; then
    echo "$etag"
  else
    echo "$(date -u)"
  fi
}

install_jdk() {
  local url="${1:?}"
  local dir="${2:?}"
  local bpDir="${3:?}"
  local key="${4:-${bpDir}/.gnupg/lang-jvm.asc}"
  local tarball="/tmp/jdk.tgz"

  curl --retry 3 --silent --show-error --location "${url}" --output "${tarball}"

  if [ "${HEROKU_GPG_VALIDATION:-0}" != "1" ]; then
    _jvm_mcount "gpg.verify.skip"
  else
    curl --retry 3 --silent --show-error --location "${url}.gpg" --output "${tarball}.gpg"

    gpg --no-tty --batch --import "${key}" > /dev/null 2>&1

    if gpg --no-tty --batch --verify "${tarball}.gpg" "${tarball}" > /dev/null 2>&1
    then
      _jvm_mcount "gpg.verify.success"
    else
      _jvm_mcount "gpg.verify.failed"
      (>&2 echo " !     ERROR: Invalid GPG signature!")
      return 1
    fi
  fi

  tar pxzf "${tarball}" -C "${dir}"
  rm "${tarball}"
}

install_certs() {
  local jdkDir="${1:?}"
  if [ -f ${jdkDir}/jre/lib/security/cacerts ] && [ -f /etc/ssl/certs/java/cacerts ]; then
    mv ${jdkDir}/jre/lib/security/cacerts ${jdkDir}/jre/lib/security/cacerts.old
    ln -s /etc/ssl/certs/java/cacerts ${jdkDir}/jre/lib/security/cacerts
  elif [ -f ${jdkDir}/lib/security/cacerts ] && [ -f /etc/ssl/certs/java/cacerts ]; then
    mv ${jdkDir}/lib/security/cacerts ${jdkDir}/lib/security/cacerts.old
    ln -s /etc/ssl/certs/java/cacerts ${jdkDir}/lib/security/cacerts
  fi
}

install_profile() {
  local bpDir="${1:?}"
  local profileDir="${2:?}"

  mkdir -p "$profileDir"
  cp "${bpDir}/opt/jvmcommon.sh" "${profileDir}"
  cp "${bpDir}/opt/jdbc.sh" "${profileDir}"
}

install_jdk_overlay() {
  local jdkDir="${1:?}"
  local appDir="${2:?}"
  local cacertPath="lib/security/cacerts"
  shopt -s dotglob
  if [ -d ${jdkDir} ] && [ -d ${appDir}/.jdk-overlay ]; then
    # delete the symlink because a cp will error
    if [ -f ${appDir}/.jdk-overlay/jre/${cacertPath} ] && [ -f ${jdkDir}/jre/${cacertPath} ]; then
      rm ${jdkDir}/jre/${cacertPath}
    elif [ -f ${appDir}/.jdk-overlay/${cacertPath} ] && [ -f ${jdkDir}/${cacertPath} ]; then
      rm ${jdkDir}/${cacertPath}
    fi
    cp -r ${appDir}/.jdk-overlay/* ${jdkDir}
  fi
}

install_metrics_agent() {
  local bpDir=${1:?}
  local installDir="${2:?}"
  local profileDir="${3:?}"
  local agentJar="${installDir}/heroku-metrics-agent.jar"

  mkdir -p ${installDir}
  curl --retry 3 -s -o ${agentJar} \
      -L ${HEROKU_METRICS_JAR_URL:-"https://repo1.maven.org/maven2/com/heroku/agent/heroku-java-metrics-agent/3.11/heroku-java-metrics-agent-3.11.jar"}
  if [ -f ${agentJar} ]; then
    mkdir -p ${profileDir}
    cp "${bpDir}/opt/heroku-jvm-metrics.sh" "${profileDir}"
  fi
}

install_jre() {
  local jdkDir="${1:?}"
  local jreDir="${2:?}"

  if [ -d "${jdkDir}/jre" ]; then
    rm -rf "${jreDir}"
    cp -R "${jdkDir}/jre" "${jreDir}"
  else
    cp -R "${jdkDir}" "${jreDir}"
  fi
}

_get_system_property() {
  local file=${1:?}
  local key=${2:?}

  # escape for regex
  local escaped_key=$(echo $key | sed "s/\./\\\./g")

  [ -f $file ] && \
  grep -E ^$escaped_key[[:space:]=]+ $file | \
  sed -E -e "s/$escaped_key([\ \t]*=[\ \t]*|[\ \t]+)([_A-Za-z0-9\.-]*).*/\2/g"
}
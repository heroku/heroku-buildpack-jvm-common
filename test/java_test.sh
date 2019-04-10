#!/usr/bin/env bash

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh
. ${BUILDPACK_HOME}/bin/java
. ${BUILDPACK_HOME}/bin/util
. ${BUILDPACK_HOME}/test/testlib

oneTimeSetUp() {
  export JVM_COMMON_DIR=${BUILDPACK_HOME}
}

testOverlayDir() {
  mkdir -p ${BUILD_DIR}/.jdk/jre/bin
  touch ${BUILD_DIR}/.jdk/jre/bin/java
  mkdir -p ${BUILD_DIR}/.jdk-overlay/jre/lib/security
  mkdir -p ${BUILD_DIR}/.jdk-overlay/jre/bin
  touch ${BUILD_DIR}/.jdk-overlay/jre/lib/security/policy.jar
  echo "." > ${BUILD_DIR}/.jdk-overlay/jre/lib/security/cacerts
  capture jdk_overlay ${BUILD_DIR}
  assertTrue "Files in .jdk-overlay should be copied to .jdk." "[ -f ${BUILD_DIR}/.jdk/jre/lib/security/policy.jar ]"
  assertTrue "Files in .jdk should not be overwritten." "[ -f ${BUILD_DIR}/.jdk/jre/bin/java ]"
}

testDetectJava_default() {
  capture detect_java_version ${BUILD_DIR}
  assertCapturedEquals "1.8"
}

testDetectJava_invalid() {
  echo "java.runtime.version=asd78" >> ${BUILD_DIR}/system.properties
  capture detect_java_version ${BUILD_DIR}
  assertCapturedEquals "asd78"
}

testDetectJava_custom() {
  echo "java.runtime.version=1.7" >> ${BUILD_DIR}/system.properties
  capture detect_java_version ${BUILD_DIR}
  assertCapturedEquals "1.7"
}

testDetectJava_default() {
  echo "maven.version=3.3.9" >> ${BUILD_DIR}/system.properties
  capture detect_java_version ${BUILD_DIR}
  assertCapturedEquals "1.8"
}

test_defaultJdkUrl() {
  capture _get_jdk_download_url "${DEFAULT_JDK_VERSION}"
  assertCapturedSuccess
  assertTrue "The URL should be for the default JDK, ${DEFAULT_JDK_VERSION}." "[ $(cat ${STD_OUT}) = '${JDK_URL_1_8}' ]"
}

test_nonDefaultJdkUrl() {
  capture _get_jdk_download_url "1.7"
  assertCapturedSuccess
  assertTrue "The URL should be for the latest JDK, 1.7." "[ $(cat ${STD_OUT}) = '${JDK_URL_1_7}' ]"
}

test_installJavaWithoutDirectoryFails() {
  capture install_java
  assertCapturedError " !     ERROR: Invalid directory to install java."
}

test_installDefaultJava() {
  unset CI
  unset JAVA_HOME # unsets environment -- shunit doesn't clean environment before each test
  capture install_java ${BUILD_DIR}
  assertCapturedSuccess
  assertTrue "A .jdk directory should be created when installing java." "[ -d ${BUILD_DIR}/.jdk ]"
  assertTrue "The java runtime should be present." "[ -f ${BUILD_DIR}/.jdk/bin/java ]"
  # make sure there's no tarball left in the slug
  assertEquals "$(find ${BUILD_DIR} -name jdk.tar.gz | wc -l | sed 's/ //g')" "0"
  assertEquals "${BUILD_DIR}/.jdk" "${JAVA_HOME}"
  assertContains "${BUILD_DIR}/.jdk/bin" "${PATH}"
  assertTrue "A version file should have been created." "[ -f ${BUILD_DIR}/.jdk/version ]"
  assertEquals "$(cat ${BUILD_DIR}/.jdk/version)" "${DEFAULT_JDK_VERSION}"
  assertEquals "${BUILD_DIR}/.jdk/bin/java" "$(which java)"
  assertTrue "A profile.d file should have been created." "[ -f ${BUILD_DIR}/.profile.d/jvmcommon.sh ]"
  assertTrue "A pgconfig.jar should exist in the JDK" "[ -f ${BUILD_DIR}/.jdk/jre/lib/ext/pgconfig.jar ]"
}

test_installJavaCI() {
  export CI="true"
  unset JAVA_HOME # unsets environment -- shunit doesn't clean environment before each test
  capture install_java ${BUILD_DIR}
  assertCapturedSuccess
  assertTrue "A pgconfig.jar should exist in the JDK" "[ ! -f ${BUILD_DIR}/.jdk/jre/lib/ext/pgconfig.jar ]"
  unset CI
}

test_installJavaWithVersion() {
  unset JAVA_HOME # unsets environment -- shunit doesn't clean environment before each test
  capture install_java ${BUILD_DIR} "1.6"
  assertTrue "A .jdk directory should be created when installing java." "[ -d ${BUILD_DIR}/.jdk ]"
  assertTrue "The java runtime should be present." "[ -f ${BUILD_DIR}/.jdk/bin/java ]"
  assertEquals "${BUILD_DIR}/.jdk" "${JAVA_HOME}"
  assertContains "${BUILD_DIR}/.jdk/bin" "${PATH}"
  assertTrue "A version file should have been created." "[ -f ${BUILD_DIR}/.jdk/version ]"
  assertEquals "$(cat ${BUILD_DIR}/.jdk/version)" "1.6"
  assertEquals "${BUILD_DIR}/.jdk/bin/java" "$(which java)"
  assertTrue "A profile.d file should have been created." "[ -f ${BUILD_DIR}/.profile.d/jvmcommon.sh ]"
}

test_upgradeFrom1_6To1_7() {
  unset JAVA_HOME # unsets environment -- shunit doesn't clean environment before each test
  capture install_java ${BUILD_DIR} "1.6"
  assertCapturedSuccess
  assertTrue "Precondition: JDK6 should have been installed." "[ $(cat ${BUILD_DIR}/.jdk/version) = '1.6' ]"
  assertEquals "${BUILD_DIR}/.jdk/bin/java" "$(which java)"

  capture install_java ${BUILD_DIR} "1.7"
  assertCapturedSuccess
  assertEquals "$(cat ${BUILD_DIR}/.jdk/version)" "1.7"
  assertEquals "${BUILD_DIR}/.jdk/bin/java" "$(which java)"
}

test_upgradeFrom1_7To1_6() {
  unset JAVA_HOME # unsets environment -- shunit doesn't clean environment before each test
  capture install_java ${BUILD_DIR} "1.7"
  assertCapturedSuccess
  assertTrue "Precondition: JDK7 should have been installed." "[ $(cat ${BUILD_DIR}/.jdk/version) = '1.7' ]"
  assertEquals "${BUILD_DIR}/.jdk/bin/java" "$(which java)"

  capture install_java ${BUILD_DIR} "1.6"
  assertCapturedSuccess
  assertEquals "$(cat ${BUILD_DIR}/.jdk/version)" "1.6"
  assertEquals "${BUILD_DIR}/.jdk/bin/java" "$(which java)"
}

test_create_profile_script() {
  unset JAVA_HOME # unsets environment -- shunit doesn't clean environment before each test
  capture _create_profile_script ${BUILD_DIR}
  assertCapturedSuccess
  assertTrue "A profile.d file should have been created." "[ -f ${BUILD_DIR}/.profile.d/jvmcommon.sh ]"
}

test_install_tools() {
  unset JAVA_HOME # unsets environment -- shunit doesn't clean environment before each test
  capture _install_tools ${BUILD_DIR}
  assertCapturedSuccess
  assertTrue "A with_jmap file should have been created." "[ -f ${BUILD_DIR}/.heroku/bin/with_jmap ]"
  assertTrue "The with_jmap file should be executable." "[ -x ${BUILD_DIR}/.heroku/bin/with_jmap ]"
  assertTrue "A with_jmap java file should have been created." "[ -f ${BUILD_DIR}/.heroku/with_jmap/bin/java ]"
  assertTrue "The with_jmap java file should be executable." "[ -x ${BUILD_DIR}/.heroku/with_jmap/bin/java ]"
  assertTrue "A with_jmap file should have been created." "[ -f ${BUILD_DIR}/.heroku/bin/with_jstack ]"
  assertTrue "The with_jmap file should be executable." "[ -x ${BUILD_DIR}/.heroku/bin/with_jstack ]"
}

test_install_metrics_agent() {
  unset JAVA_HOME # unsets environment -- shunit doesn't clean environment before each test
  capture _install_metrics_agent ${BUILD_DIR}
  assertCapturedSuccess
  assertTrue "The heroku-metrics-agent.jar file should have been created." "[ -f ${BUILD_DIR}/.heroku/bin/heroku-metrics-agent.jar ]"
  assertTrue "The heroku-jvm-metrics script should have been created." "[ -f ${BUILD_DIR}/.profile.d/heroku-jvm-metrics.sh ]"
}

test_create_export_script() {
  unset JAVA_HOME # unsets environment -- shunit doesn't clean environment before each test
  capture _create_export_script "/path/to/jdk" ${BUILD_DIR}
  assertCapturedSuccess
  assertTrue "An export file should be created." "[ -f ${BUILD_DIR}/export ]"
  assertContains "export JAVA_HOME=/path/to/jdk" "$(cat ${BUILD_DIR}/export)"
  assertContains "export PATH=\$JAVA_HOME/bin:\$PATH" "$(cat ${BUILD_DIR}/export)"
}

test_invalidJdkURL() {
  capture install_java ${BUILD_DIR} "1.8.0_11"
  assertContains "Did not find error message for invalid JDK version" "Unsupported Java version: 1.8.0_11" "$(cat ${STD_OUT})"
}

test_customJdk() {
  capture install_java ${BUILD_DIR} "1.8.0_121"
  assertCapturedSuccess
}

test_zuluJdk() {
  capture install_java ${BUILD_DIR} "zulu-1.8.0_144"
  assertCapturedSuccess
}

test_openJdk() {
  capture install_java ${BUILD_DIR} "openjdk-1.8.0_144"
  assertCapturedSuccess
}

test_get_jdk_download_url() {
  capture _get_jdk_download_url "10"
  assertCapturedEquals "https://lang-jvm.s3.amazonaws.com/jdk/heroku-16/openjdk10.0.2.tar.gz"

  capture _get_jdk_download_url "9"
  assertCapturedEquals "https://lang-jvm.s3.amazonaws.com/jdk/heroku-16/openjdk9.0.4.tar.gz"

  capture _get_jdk_download_url "9.0.0"
  assertCapturedEquals "https://lang-jvm.s3.amazonaws.com/jdk/heroku-16/openjdk9-181.tar.gz"

  capture _get_jdk_download_url "9+181"
  assertCapturedEquals "https://lang-jvm.s3.amazonaws.com/jdk/heroku-16/openjdk9-181.tar.gz"

  capture _get_jdk_download_url "1.7.0_101"
  assertCapturedEquals "https://lang-jvm.s3.amazonaws.com/jdk/heroku-16/openjdk1.7.0_101.tar.gz"

  capture _get_jdk_download_url "1.7.0_141"
  assertCapturedEquals "https://lang-jvm.s3.amazonaws.com/jdk/heroku-16/openjdk1.7.0_141.tar.gz"
}

test_install_metrics_agent() {
  capture _install_metrics_agent ${BUILD_DIR} ${BUILD_DIR}
  assertNotContains "failed to install metrics agent!" "$(cat ${STD_OUT})"
}

test_fail_install_metrics_agent() {
  export HEROKU_METRICS_JAR_URL="https://89erfhuisffuds.com"
  capture _install_metrics_agent ${BUILD_DIR} ${BUILD_DIR}
  assertContains "failed to install metrics agent!" "$(cat ${STD_OUT})"
  unset HEROKU_METRICS_JAR_URL
}

test_skip_version_cache() {
  assertTrue "Fake dir should not exist." "[ ! -d fake_dir ]"
  capture _cache_version "1.8" "fake_dir"
  assertCapturedSuccess
  assertTrue "Version should not be cached" "[ ! -f fake_dir/system.properties ]"
}

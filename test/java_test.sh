#!/usr/bin/env bash

export JVM_COMMON_DIR="${BUILDPACK_HOME}"

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh
. ${BUILDPACK_HOME}/bin/java
. ${BUILDPACK_HOME}/bin/util
. ${BUILDPACK_HOME}/test/testlib

oneTimeSetUp() {
  export JVM_COMMON_DIR=${BUILDPACK_HOME}
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
  capture install_java ${BUILD_DIR} "1.8.0_212"
  assertTrue "A .jdk directory should be created when installing java." "[ -d ${BUILD_DIR}/.jdk ]"
  assertTrue "The java runtime should be present." "[ -f ${BUILD_DIR}/.jdk/bin/java ]"
  assertEquals "${BUILD_DIR}/.jdk" "${JAVA_HOME}"
  assertContains "${BUILD_DIR}/.jdk/bin" "${PATH}"
  assertTrue "A version file should have been created." "[ -f ${BUILD_DIR}/.jdk/version ]"
  assertEquals "$(cat ${BUILD_DIR}/.jdk/version)" "1.8.0_212"
  assertEquals "${BUILD_DIR}/.jdk/bin/java" "$(which java)"
  assertTrue "A profile.d file should have been created." "[ -f ${BUILD_DIR}/.profile.d/jvmcommon.sh ]"
}

test_upgradeFrom1_7To1_8() {
  unset JAVA_HOME # unsets environment -- shunit doesn't clean environment before each test
  capture install_java ${BUILD_DIR} "1.7"
  assertCapturedSuccess
  assertTrue "Precondition: JDK 7 should have been installed." "[ $(cat ${BUILD_DIR}/.jdk/version) = '1.7' ]"
  assertEquals "${BUILD_DIR}/.jdk/bin/java" "$(which java)"

  capture install_java ${BUILD_DIR} "1.8"
  assertCapturedSuccess
  assertEquals "$(cat ${BUILD_DIR}/.jdk/version)" "1.8"
  assertEquals "${BUILD_DIR}/.jdk/bin/java" "$(which java)"
}

test_upgradeFrom1_8To1_7() {
  unset JAVA_HOME # unsets environment -- shunit doesn't clean environment before each test
  capture install_java ${BUILD_DIR} "1.8"
  assertCapturedSuccess
  assertTrue "Precondition: JDK 8 should have been installed." "[ $(cat ${BUILD_DIR}/.jdk/version) = '1.8' ]"
  assertEquals "${BUILD_DIR}/.jdk/bin/java" "$(which java)"

  capture install_java ${BUILD_DIR} "1.7"
  assertCapturedSuccess
  assertEquals "$(cat ${BUILD_DIR}/.jdk/version)" "1.7"
  assertEquals "${BUILD_DIR}/.jdk/bin/java" "$(which java)"
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

test_skip_version_cache() {
  assertTrue "Fake dir should not exist." "[ ! -d fake_dir ]"
  capture _cache_version "1.8" "fake_dir"
  assertCapturedSuccess
  assertTrue "Version should not be cached" "[ ! -f fake_dir/system.properties ]"
}
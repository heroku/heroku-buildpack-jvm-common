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
  capture jdk_overlay ${BUILD_DIR}
  assertTrue "Files in .jdk-overlay should be copied to .jdk." "[ -f ${BUILD_DIR}/.jdk/jre/lib/security/policy.jar ]"
  assertTrue "Files in .jdk should not be overwritten." "[ -f ${BUILD_DIR}/.jdk/jre/bin/java ]"
}

testDetectJava_default() {
  capture detect_java_version ${BUILD_DIR}
  assertCapturedEquals "1.8"
}

testDetectJava_cedar() {
  export STACK="cedar"
  capture detect_java_version ${BUILD_DIR}
  assertCapturedEquals "1.6"
  unset STACK
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

test_installJavaWithInvalidVersionFails() {
  capture install_java ${BUILD_DIR} "1.5"
  assertCapturedError " !     ERROR: Unsupported Java version: 1.5"
}

test_installDefaultJava() {
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
  assertTrue "A java file should have been created." "[ -f ${BUILD_DIR}/.heroku/bin/java ]"
  assertTrue "The java file should be executable." "[ -x ${BUILD_DIR}/.heroku/bin/java ]"
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

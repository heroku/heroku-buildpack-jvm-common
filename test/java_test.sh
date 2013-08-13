#!/usr/bin/env bash

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh
. ${BUILDPACK_HOME}/bin/java
. ${BUILDPACK_HOME}/test/testlib

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

testDetectJava() {
  echo "java.runtime.version=1.8" >> ${BUILD_DIR}/system.properties
  capture detect_java_version ${BUILD_DIR}
  assertCapturedEquals "1.8"
}

test_defaultJdkUrl() {
  capture _get_jdk_download_url "${DEFAULT_JDK_VERSION}"
  assertCapturedSuccess
  assertTrue "The URL should be for the default JDK, ${DEFAULT_JDK_VERSION}." "[ $(cat ${STD_OUT}) = '${JDK_URL_1_7}' ]"
}

test_installJavaWithoutDirectoryFails() {
  capture install_java
  assertCapturedError
  assertCapturedEquals "Invalid directory to install java."
}

test_installDefaultJava() {
  unset JAVA_HOME # unsets environment -- shunit doesn't clean environment before each test
  capture install_java ${BUILD_DIR}
  assertCapturedSuccess
  assertTrue "A .jdk directory should be created when installing java." "[ -d ${BUILD_DIR}/.jdk ]"
  assertTrue "The java runtime should be present." "[ -f ${BUILD_DIR}/.jdk/$(_get_relative_jdk_bin)/java ]"
  # make sure there's no tarball left in the slug
  assertEquals "$(find ${BUILD_DIR} -name jdk.tar.gz | wc -l | sed 's/ //g')" "0"
  assertEquals "${BUILD_DIR}/.jdk/$(_get_relative_jdk_home)" "${JAVA_HOME}"
  assertContains "${BUILD_DIR}/.jdk/$(_get_relative_jdk_bin)" "${PATH}"
  assertTrue "A version file should have been created." "[ -f ${BUILD_DIR}/.jdk/version ]"
  assertEquals "$(cat ${BUILD_DIR}/.jdk/version)" "${DEFAULT_JDK_VERSION}"
  assertEquals "${BUILD_DIR}/.jdk/$(_get_relative_jdk_bin)/java" "$(which java)"
}

test_installJavaWithVersion() {
  unset JAVA_HOME # unsets environment -- shunit doesn't clean environment before each test
  capture install_java ${BUILD_DIR} "1.6"
  assertTrue "A .jdk directory should be created when installing java." "[ -d ${BUILD_DIR}/.jdk ]"
  assertTrue "The java runtime should be present." "[ -f ${BUILD_DIR}/.jdk/$(_get_relative_jdk_bin)/java ]"
  assertEquals "${BUILD_DIR}/.jdk/$(_get_relative_jdk_home)" "${JAVA_HOME}"
  assertContains "${BUILD_DIR}/.jdk/$(_get_relative_jdk_bin)" "${PATH}"
  assertTrue "A version file should have been created." "[ -f ${BUILD_DIR}/.jdk/version ]"
  assertEquals "$(cat ${BUILD_DIR}/.jdk/version)" "1.6"
  assertEquals "${BUILD_DIR}/.jdk/$(_get_relative_jdk_bin)/java" "$(which java)"
}

test_upgradeFrom1_6To1_7() {
  unset JAVA_HOME # unsets environment -- shunit doesn't clean environment before each test
  capture install_java ${BUILD_DIR} "1.6"
  assertCapturedSuccess
  assertTrue "Precondition: JDK6 should have been installed." "[ $(cat ${BUILD_DIR}/.jdk/version) = '1.6' ]"
  assertEquals "${BUILD_DIR}/.jdk/$(_get_relative_jdk_bin)/java" "$(which java)"

  capture install_java ${BUILD_DIR} "1.7"
  assertCapturedSuccess
  assertEquals "$(cat ${BUILD_DIR}/.jdk/version)" "1.7"
  assertEquals "${BUILD_DIR}/.jdk/$(_get_relative_jdk_bin)/java" "$(which java)"
}

test_upgradeFrom1_7To1_6() {
  unset JAVA_HOME # unsets environment -- shunit doesn't clean environment before each test
  capture install_java ${BUILD_DIR} "1.7"
  assertCapturedSuccess
  assertTrue "Precondition: JDK7 should have been installed." "[ $(cat ${BUILD_DIR}/.jdk/version) = '1.7' ]"
  assertEquals "${BUILD_DIR}/.jdk/$(_get_relative_jdk_bin)/java" "$(which java)"

  capture install_java ${BUILD_DIR} "1.6"
  assertCapturedSuccess
  assertEquals "$(cat ${BUILD_DIR}/.jdk/version)" "1.6"
  assertEquals "${BUILD_DIR}/.jdk/$(_get_relative_jdk_bin)/java" "$(which java)"
}

test_installJavaWith1_5() {
  unset JAVA_HOME # unsets environment -- shunit doesn't clean environment before each test
  capture install_java ${BUILD_DIR} "1.5"
  assertCapturedSuccess
  assertTrue "Precondition: JDK7 should have been installed." "[ $(cat ${BUILD_DIR}/.jdk/version) = '${DEFAULT_JDK_VERSION}' ]"
  assertEquals "${BUILD_DIR}/.jdk/$(_get_relative_jdk_bin)/java" "$(which java)"
}

test_nonEmptyCacert1_6(){
  unset JAVA_HOME
  capture install_java ${BUILD_DIR} "1.6"
  assertCapturedSuccess

  CACERTS_COUNT="$(${BUILD_DIR}/.jdk/$(_get_relative_jdk_bin)/keytool -list -v -keystore ${BUILD_DIR}/.jdk/jre/lib/security/cacerts -storepass changeit | grep "Alias name" | wc -l)"
  assertTrue "Cacert file contains less than 100 domains" "[ $CACERTS_COUNT -gt "100" ]"
}

test_nonEmptyCacert1_7(){
  unset JAVA_HOME
  capture install_java ${BUILD_DIR} "1.7"
  assertCapturedSuccess

  CACERTS_COUNT="$(${BUILD_DIR}/.jdk/$(_get_relative_jdk_bin)/keytool -list -v -keystore ${BUILD_DIR}/.jdk/jre/lib/security/cacerts -storepass changeit | grep "Alias name" | wc -l)"
  assertTrue "Cacert file contains less than 100 domains" "[ $CACERTS_COUNT -gt "100" ]"
}

test_nonEmptyCacert1_8(){
  unset JAVA_HOME
  capture install_java ${BUILD_DIR} "1.8"
  assertCapturedSuccess

  CACERTS_COUNT="$(${BUILD_DIR}/.jdk/$(_get_relative_jdk_bin)/keytool -list -v -keystore ${BUILD_DIR}/.jdk/jre/lib/security/cacerts -storepass changeit | grep "Alias name" | wc -l)"
  assertTrue "Cacert file contains less than 100 domains" "[ $CACERTS_COUNT -gt "100" ]"
}

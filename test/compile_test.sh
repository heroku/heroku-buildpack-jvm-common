#!/usr/bin/env bash

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

# Tests

testCompileWithoutSystemProperties() {
  assertTrue "Precondition" "[ ! -f ${BUILD_DIR}/system.properties ]"

  compile

  assertCapturedSuccess

  assertCaptured "Installing JDK 1.8"
  assertTrue "Java should be present in runtime." "[ -d ${BUILD_DIR}/.jdk ]"
  assertTrue "Java version file should be present." "[ -f ${BUILD_DIR}/.jdk/version ]"
}

testCompileWith_1_8_0_144() {
  echo "java.runtime.version=1.8.0_144" > ${BUILD_DIR}/system.properties

  compile

  assertCapturedSuccess

  assertCaptured "Installing JDK 1.8.0_144"
  assertTrue "Java should be present in runtime." "[ -d ${BUILD_DIR}/.jdk ]"
  assertTrue "Java version file should be present." "[ -f ${BUILD_DIR}/.jdk/version ]"
}

testCompileWith_zulu_1_8_0_144() {
  echo "java.runtime.version=zulu-1.8.0_144" > ${BUILD_DIR}/system.properties

  compile

  assertCapturedSuccess

  assertCaptured "Installing Azul Zulu JDK 1.8.0_144"
  assertTrue "Java should be present in runtime." "[ -d ${BUILD_DIR}/.jdk ]"
  assertTrue "Java version file should be present." "[ -f ${BUILD_DIR}/.jdk/version ]"
}

testCompileWith_openjdk_1_8_0_144() {
  echo "java.runtime.version=openjdk-1.8.0_144" > ${BUILD_DIR}/system.properties

  compile

  assertCapturedSuccess

  assertCaptured "Installing OpenJDK 1.8.0_144"
  assertTrue "Java should be present in runtime." "[ -d ${BUILD_DIR}/.jdk ]"
  assertTrue "Java version file should be present." "[ -f ${BUILD_DIR}/.jdk/version ]"
}

testCompileWith_9_0_1() {
  echo "java.runtime.version=9.0.1" > ${BUILD_DIR}/system.properties

  compile

  assertCapturedSuccess

  assertCaptured "Installing JDK 9.0.1"
  assertTrue "Java should be present in runtime." "[ -d ${BUILD_DIR}/.jdk ]"
  assertTrue "Java version file should be present." "[ -f ${BUILD_DIR}/.jdk/version ]"
}

testCompileWith_zulu_9_0_0() {
  echo "java.runtime.version=zulu-9.0.0" > ${BUILD_DIR}/system.properties

  compile

  assertCapturedSuccess

  assertCaptured "Installing Azul Zulu JDK 9.0.0"
  assertTrue "Java should be present in runtime." "[ -d ${BUILD_DIR}/.jdk ]"
  assertTrue "Java version file should be present." "[ -f ${BUILD_DIR}/.jdk/version ]"
}

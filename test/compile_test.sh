#!/usr/bin/env bash

# shellcheck source=/dev/null
. "${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh"

# Tests

testCompileWithoutSystemProperties() {
  assertTrue "Precondition" "[ ! -f ${BUILD_DIR}/system.properties ]"

  compile

  assertCapturedSuccess

  assertCaptured "Installing OpenJDK 1.8"
  assertTrue "Java should be present in runtime." "[ -d ${BUILD_DIR}/.jdk ]"
  assertTrue "Java version file should be present." "[ -f ${BUILD_DIR}/.jdk/version ]"
}

testCompileWith_1_8_0_144() {
  echo "java.runtime.version=1.8.0_144" >"${BUILD_DIR}/system.properties"

  compile

  assertCapturedSuccess

  assertCaptured "Installing OpenJDK 1.8.0_144"
  assertTrue "Java should be present in runtime." "[ -d ${BUILD_DIR}/.jdk ]"
  assertTrue "Java version file should be present." "[ -f ${BUILD_DIR}/.jdk/version ]"
}

testCompileWith_zulu_1_8_0_144() {
  echo "java.runtime.version=zulu-1.8.0_144" >"${BUILD_DIR}/system.properties"

  compile

  assertCapturedSuccess

  assertCaptured "Installing Azul Zulu OpenJDK 1.8.0_144"
  assertTrue "Java should be present in runtime." "[ -d ${BUILD_DIR}/.jdk ]"
  assertTrue "Java version file should be present." "[ -f ${BUILD_DIR}/.jdk/version ]"
}

testCompileWith_openjdk_1_8_0_144() {
  echo "java.runtime.version=openjdk-1.8.0_144" >"${BUILD_DIR}/system.properties"

  compile

  assertCapturedSuccess

  assertCaptured "Installing Heroku OpenJDK 1.8.0_144"
  assertTrue "Java should be present in runtime." "[ -d ${BUILD_DIR}/.jdk ]"
  assertTrue "Java version file should be present." "[ -f ${BUILD_DIR}/.jdk/version ]"
}

testCompileWith_zulu_11_0_15() {
  echo "java.runtime.version=zulu-11.0.15" >"${BUILD_DIR}/system.properties"

  compile

  assertCapturedSuccess

  assertCaptured "Installing Azul Zulu OpenJDK 11.0.15"
  assertTrue "Java should be present in runtime." "[ -d ${BUILD_DIR}/.jdk ]"
  assertTrue "Java version file should be present." "[ -f ${BUILD_DIR}/.jdk/version ]"
}

test_skip_install_if_java_exists() {
  mkdir -p "${BUILD_DIR}/.jdk/bin"
  touch "${BUILD_DIR}/.jdk/bin/java"

  compile

  assertCapturedSuccess
  assertCaptured "Using provided JDK"
  assertTrue "Java should be present in runtime." "[ -d ${BUILD_DIR}/.jdk ]"
  assertTrue "Java files should not have been installed." "[ ! -f ${BUILD_DIR}/.jdk/jre/lib/amd64/server/libjvm.so ]"
}

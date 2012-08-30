#!/usr/bin/env bash

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh
. ${BUILDPACK_HOME}/bin/java

testGetAppSystemProperty() {
  cat > ${BUILD_DIR}/app.system <<EOF
jvm.major.version=1.8
EOF
  capture get_app_system_value ${BUILD_DIR}/app.system "jvm.major.version"
  assertCapturedEquals "1.8"   
}

testGetAppSystemPropertyWithWhitespace() {
  cat > ${BUILD_DIR}/app.system <<EOF

jvm.major.version    =        1.8


EOF
  capture get_app_system_value ${BUILD_DIR}/app.system "jvm.major.version"
  assertCapturedEquals "1.8"   
}

testGetAppSystemPropertyWithSimilarName() {
  cat > ${BUILD_DIR}/app.system <<EOF
jvm.major.versions=1.8
EOF
  capture get_app_system_value ${BUILD_DIR}/app.system "jvm.major.version"
  assertCapturedEquals ""   
}

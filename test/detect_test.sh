#!/bin/sh

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh

testDetect()
{
  detect

  assertAppDetected "JVM Common"
}

testDetect_OldMavenPlugin()
{
  touch ${BUILD_DIR}/pom.xml
  mkdir ${BUILD_DIR}/target

  detect

  assertAppDetected "heroku-maven-plugin"
}

testDetect_OldSbtPlugin()
{
  touch ${BUILD_DIR}/build.sbt

  detect

  assertAppDetected "sbt-heroku"
}

testDetect_OldLeinPlugin()
{
  touch ${BUILD_DIR}/project.clj

  detect

  assertAppDetected "lein-heroku"
}

testDetect_MavenPlugin()
{
  echo "client=heroku-maven-plugin" > ${BUILD_DIR}/.heroku-deploy
  touch ${BUILD_DIR}/build.sbt

  detect

  assertAppDetected "heroku-maven-plugin"
}

testDetect_GradlePlugin()
{
  echo "client=heroku-gradle" > ${BUILD_DIR}/.heroku-deploy
  mkdir ${BUILD_DIR}/build.sbt

  detect

  assertAppDetected "heroku-gradle"
}

testDetect_GradlePlugin()
{
  echo "client=heroku-cli-deploy" > ${BUILD_DIR}/.heroku-deploy
  mkdir ${BUILD_DIR}/pom.xml

  detect

  assertAppDetected "heroku-cli-deploy"
}

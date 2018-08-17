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
  mkdir -p ${BUILD_DIR}/target/universal/stage

  detect

  assertAppDetected "sbt-heroku"
}

testDetect_OldLeinPlugin()
{
  touch ${BUILD_DIR}/project.clj
  mkdir ${BUILD_DIR}/target

  detect

  assertAppDetected "lein-heroku"
}

testDetect_MavenPlugin()
{
  echo "client=heroku-maven-plugin" > ${BUILD_DIR}/.heroku-deploy

  detect

  assertAppDetected "heroku-maven-plugin"
}

testDetect_GradlePlugin()
{
  echo "client=heroku-gradle" > ${BUILD_DIR}/.heroku-deploy

  detect

  assertAppDetected "heroku-gradle"
}

testDetect_GradlePlugin()
{
  echo "client=heroku-cli-deploy" > ${BUILD_DIR}/.heroku-deploy
  touch ${BUILD_DIR}/pom.xml
  mkdir ${BUILD_DIR}/target

  detect

  assertAppDetected "heroku-cli-deploy"
}

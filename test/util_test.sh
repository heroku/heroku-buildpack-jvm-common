#!/usr/bin/env bash

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh
. ${BUILDPACK_HOME}/bin/util

beforeSetUp() {
  # clean up after prepareEnvDir
  unset GIT_DIR
  unset MAVEN_DIR
  unset EMPTY
  unset MULTILINE
}

prepareEnvDir() {
  echo -n "/lol"  > $ENV_DIR/GIT_DIR
  echo -n "/jars" > $ENV_DIR/MAVEN_DIR
  cat > $ENV_DIR/MULTILINE <<EOF
i'm a cool
multiline
config
var
i even have a trailing new line or two!

EOF
  echo -n ""    > $ENV_DIR/EMPTY
}

test_export_env_dir_unset() {
  prepareEnvDir
  export_env_dir

  assertNull 'GIT_DIR should not be set' "$(env | grep '^GIT_DIR=')"
  assertNull 'MAVEN_DIR should not be set' "$(env | grep '^MAVEN_DIR=')"
}

test_export_env_dir_defaults() {
  prepareEnvDir
  export_env_dir $ENV_DIR

  assertNull 'GIT_DIR should not be set' "$(env | grep '^GIT_DIR=')"
  assertNotNull 'MAVEN_DIR should be set' "$(env | grep '^MAVEN_DIR=')"
  assertEquals 'MAVEN_DIR should be set with value' "/jars" "$MAVEN_DIR"
  assertNotNull 'EMPTY should but without any value' "$(env | grep '^EMPTY=$')"
  assertNotNull 'MULTILINE should be set' "$(env | grep '^MULTILINE=')"
  assertEquals 'MULTILINE should have line breaks without trailing new lines' '4' "$(printf "$MULTILINE" | wc -l)"
}

test_export_env_dir_whitelist() {
  prepareEnvDir
  export_env_dir $ENV_DIR '^MAVEN_DIR$'

  assertNull 'GIT_DIR should not be set' "$(env | grep '^GIT_DIR=')"
  assertNotNull 'MAVEN_DIR should be set' "$(env | grep '^MAVEN_DIR=')"
  assertEquals 'MAVEN_DIR should be set with value' "/jars" "$MAVEN_DIR"
  assertNull 'EMPTY should not be set' "$(env | grep '^EMPTY=$')"
  assertNull 'MULTILINE should not be set' "$(env | grep '^MULTILINE=')"
}

test_export_env_dir_blacklist() {
  prepareEnvDir
  export_env_dir $ENV_DIR '' '^MAVEN_DIR$'

  assertNotNull 'GIT_DIR should be set' "$(env | grep '^GIT_DIR=')"
  assertNull 'MAVEN_DIR should not be set' "$(env | grep '^MAVEN_DIR=')"
  assertNotNull 'EMPTY should be set' "$(env | grep '^EMPTY=$')"
  assertNotNull 'MULTILINE should be set' "$(env | grep '^MULTILINE=')"
}

test_copyDirectories() {
  mkdir -p ${CACHE_DIR}/dir1
  mkdir -p ${CACHE_DIR}/dir2
  copy_directories "dir1 dir2" ${CACHE_DIR} ${BUILD_DIR}
  assertTrue "dir1 should have been copied, but it does not exist in the target directory." "[ -d ${BUILD_DIR}/dir1 ]"
  assertTrue "dir2 should have been copied, but it does not exist in the target directory." "[ -d ${BUILD_DIR}/dir2 ]"
}

test_copyDirectoryThatDoesntExist() {
  mkdir -p ${CACHE_DIR}/dir1
  copy_directories "dir1 dir2" ${CACHE_DIR} ${BUILD_DIR}
  assertTrue "dir1 should have been copied, but it does not exist in the target directory." "[ -d ${BUILD_DIR}/dir1 ]"
  assertTrue "dir2 should not have been copied, but it exists in the target directory." "[ ! -d ${BUILD_DIR}/dir2 ]"
}

test_noDirectories() {
  initialDirectoryCount=$(ls -l | wc -l | sed -E -e 's/\s*//')
  copy_directories "" ${CACHE_DIR} ${BUILD_DIR}
  countDirectories=$(ls -l | wc -l | sed -E -e 's/\s*//')
  assertEquals "${initialDirectoryCount}" "${countDirectories}" 
}

test_invalidBaseDir() {
  directoriesFailure=$(copy_directories "" ${CACHE_DIR}/fake-dir ${BUILD_DIR})
  assertEquals "1" "$?"
  assertEquals "Invalid source directory to copy from. ${CACHE_DIR}/fake-dir" "${directoriesFailure}"
}

test_invalidSourceDir() {
  directoriesFailure=$(copy_directories "" ${CACHE_DIR} ${BUILD_DIR}/fake-dir)
  assertEquals "1" "$?"
  assertEquals "Invalid destination directory to copy to. ${BUILD_DIR}/fake-dir" "${directoriesFailure}"
}

test_sourceDirOverwritesDestDir() {
  mkdir -p ${CACHE_DIR}/dir1
  touch ${CACHE_DIR}/dir1/source
  mkdir -p ${BUILD_DIR}/dir1
  touch ${BUILD_DIR}/dir1/destination
  copy_directories "dir1" ${CACHE_DIR} ${BUILD_DIR}
  assertTrue "dir1 should exist in the source directory, but it does not." "[ -d ${CACHE_DIR}/dir1 ]"
  assertTrue "dir1 should exist in the target directory, but it does not." "[ -d ${BUILD_DIR}/dir1 ]"
  assertTrue "${CACHE_DIR}/dir1/source should exist in the source directory, but it does not." "[ -f ${CACHE_DIR}/dir1/source ]"
  assertTrue "${BUILD_DIR}/dir1/source should exist in the source directory, but it does not." "[ -f ${BUILD_DIR}/dir1/source ]"
  assertTrue "${BUILD_DIR}/dir1/destination should have been removed from the target directory, but it does not." "[ ! -f ${BUILD_DIR}/dir1/destination ]"
}

test_recursiveDirectoriesCopied() {
  mkdir -p ${CACHE_DIR}/dir1/dir2/dir3
  copy_directories "dir1" ${CACHE_DIR} ${BUILD_DIR}
  assertTrue "dir3 should exist in the target directory." "[ -d ${BUILD_DIR}/dir1/dir2/dir3 ]"
}

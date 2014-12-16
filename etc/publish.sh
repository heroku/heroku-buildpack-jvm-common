#!/bin/bash

# fail hard
#set -o pipefail

# fail harder
#set -e

if [ "hot" = "${1:-}" ]; then
  echo "---> Preparing repo. Using current directory."
  SNAPSHOT="-SNAPSHOT"
else
  echo "---> Preparing repo. Using master branch."
  pushd . > /dev/null 2>&1
  cd /tmp
  rm -rf heroku-buildpack-jvm-common
  git clone git@github.com:heroku/heroku-buildpack-jvm-common.git
  cd heroku-buildpack-jvm-common
  git checkout master
  find . ! -name '.' ! -name '..' ! -name 'version.properties' ! -name 'bin' ! -name 'opt' -maxdepth 1 -print0 | xargs -0 rm -rf --
fi

. version.properties
RELEASE_FILE="jvm-buildpack-common-v${VERSION}${SNAPSHOT:=}.tar.gz"

echo "---> Checking uniqueness of version..."
S3_FILE=$(aws s3 ls s3://lang-jvm/$RELEASE_FILE --profile lang-jvm)
if [ -z "$SNAPSHOT" ] && [ -n "$S3_FILE" ]; then
  echo ""
  echo ${S3_FILE}
  echo "A file '$RELEASE_FILE' already exists!"
  exit 1
fi

echo "---> Creating archive..."
tar pczf ../$RELEASE_FILE .
mv ../$RELEASE_FILE .

echo "---> Uploading to S3..."
aws s3 cp $RELEASE_FILE s3://lang-jvm --profile lang-jvm --acl public-read

if [ -z "$SNAPSHOT" ]; then
  popd > /dev/null 2>&1

  echo "---> Cleaning up..."
  rm -rf /tmp/heroku-buildpack-jvm-common

  echo "---> Tagging release..."
  git tag v${VERSION}
  git push --tags origin master

  echo "VERSION=\"$(($VERSION + 1))\"" > version.properties
fi

echo "---> Done."

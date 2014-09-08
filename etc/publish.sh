#!/bin/bash

# fail hard
set -o pipefail
# fail harder
set -eu

if [ "hot" = "$1" ]; then
  echo "---> Preparing repo. Using current directory."
  SNAPSHOT="-SNAPSHOT"
else
  echo "---> Preparing repo. Using master branch."
  pushd . > /dev/null 2>&1
  cd /tmp
  git clone git@github.com:heroku/heroku-buildpack-scala.git
  cd heroku-buildpack-scala
  git checkout master
  find . ! -name 'bin' ! -name 'version.properties' -maxdepth 1 -delete
fi

. version.properties
RELEASE_FILE="jvm-buildpack-common-v${VERSION}${SNAPSHOT}.tar.gz"

echo -n "---> Checking uniqueness of version..."
S3_FILE=$(aws s3 ls s3://lang-jvm/$RELEASE_FILE --profile lang-jvm)
if [ -z "$SNAPSHOT" ] && [ -n "$S3_FILE" ]; then
  echo ""
  echo ${S3_FILE}
  echo "A file '$RELEASE_FILE' already exists!"
  exit 1
fi
echo " done"

echo -n "---> Creating archive..."
tar pczf ../$RELEASE_FILE .
mv ../$RELEASE_FILE .
echo " done"

echo "---> Uploading to S3..."
aws s3 cp $RELEASE_FILE s3://lang-jvm --profile lang-jvm --acl public-read

popd > /dev/null 2>&1

echo -n "---> Cleaning up..."
rm -rf /tmp/heroku-buildpack-scala
echo " done"

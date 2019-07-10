#!/usr/bin/env bash
#
# This script uploads the JVM common to S3.
#
# You should define two environment variable for the S3 upload to work:
#   - S3_ACCESS_KEY
#   - S3_SECRET_KEY
#
# If you need some credentials, go here:
# https://console.aws.amazon.com/iam/home?region=eu-central-1#/users
#
# For the authorization, you need to click "Attach existing policies directly"
# and chose `jvm-common-buildpack`.

set -e
# set -x

print_usage() {
  echo "$0" >&2
}

cur_dir=$(cd $(dirname $0) && pwd)
cd $cur_dir

archive_name="jvm-common.tar.xz"

echo "---> Creating the archive $archive_name"

jvm_common_dir=$(mktemp --tmpdir=/tmp --directory jvm-common-XXXX)
cp -R ./bin ./opt ./CHANGELOG.md ./LICENSE ./buildpack.toml ./README.md \
  ./version.properties $jvm_common_dir
if [[ $? -ne 0 ]]; then
  echo "Fail to copy the files in the temporary directory ($jvm_common_dir)" >&2
  exit -1
fi

tar --create --xz --file ${archive_name} --directory $jvm_common_dir .
if [[ $? -ne 0 ]]; then
  echo "Error when creating the archive" >&2
  exit -1
fi

echo "---> Archive created"

which s3cmd > /dev/null || echo "s3cmd is not available in your PATH" >&2 || echo "Archive not uploaded to S3" >&2 || exit -1
s3_bucket="/jvm-common-buildpack/${stack}/"
s3cmd_cmd="s3cmd --access_key=$S3_ACCESS_KEY --secret_key=$S3_SECRET_KEY"
if [[ -z "$S3_ACCESS_KEY" ]] || [[ -z "$S3_SECRET_KEY" ]]; then
  s3cmd_cmd="s3cmd --config ${HOME}/.s3cfg"
fi

echo "---> Uploading $archive_name to S3 ($s3_bucket)"
echo ""

${s3cmd_cmd} --quiet --acl-public put ${archive_name} s3://$s3_bucket
if [[ $? -ne 0 ]]; then
  echo "Error uploading the archive to S3" >&2
  exit -1
fi

echo "---> Deleting the temporary files"
rm -r $jvm_common_dir $archive_name

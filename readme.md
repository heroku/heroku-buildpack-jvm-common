# Heroku Buildpack for the JDK [![Build Status](https://travis-ci.org/heroku/heroku-buildpack-jvm-common.svg)](https://travis-ci.org/heroku/heroku-buildpack-jvm-common)

This is the official [Heroku buildpack](https://devcenter.heroku.com/articles/buildpacks) for [OpenJDK](http://openjdk.java.net/). It only installs the JDK, and does not build an application. It is used by the [Java](https://github.com/heroku/heroku-buildpack-java), [Scala](https://github.com/heroku/heroku-buildpack-scala), and [Clojure](https://github.com/heroku/heroku-buildpack-clojure) buildpacks.

# Usage from a Buildpack

This is how the buildpack is used from another buildpack:

```bash
# download the buildpack
JVM_COMMON_BUILDPACK=${JVM_COMMON_BUILDPACK:-https://codon-buildpacks.s3.amazonaws.com/buildpacks/heroku/jvm-common.tgz}
mkdir -p /tmp/jvm-common
curl --silent --location $JVM_COMMON_BUILDPACK | tar xzm -C /tmp/jvm-common --strip-components=1
. /tmp/jvm-common/bin/util
. /tmp/jvm-common/bin/java

# install JDK
javaVersion=$(detect_java_version ${BUILD_DIR})
install_java ${BUILD_DIR} ${javaVersion}
```

# Standalone Usage

You may use this buildpack to install the JVM into your slug by running:

```
$ heroku buildpacks:set https://github.com/heroku/heroku-buildpack-jvm-common.git
```

Then it may be used by itself, or with another buildpack using [multiple buildpacks](https://devcenter.heroku.com/articles/using-multiple-buildpacks-for-an-app).

# License

Licensed under the MIT License. See LICENSE file.

test

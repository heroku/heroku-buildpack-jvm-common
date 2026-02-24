# Heroku Buildpack for OpenJDK [![CI](https://github.com/heroku/heroku-buildpack-jvm-common/actions/workflows/ci.yml/badge.svg)](https://github.com/heroku/heroku-buildpack-jvm-common/actions/workflows/ci.yml)

This is the official [Heroku buildpack](https://devcenter.heroku.com/articles/buildpacks) for [OpenJDK](http://openjdk.java.net/). It only installs the JDK, and does not build an application.

## Standalone Usage

> [!WARNING]
> If your app needs to be built with Maven, Gradle, sbt, or Leiningen, use the [Java](https://github.com/heroku/heroku-buildpack-java), [Gradle](https://github.com/heroku/heroku-buildpack-gradle), [Scala](https://github.com/heroku/heroku-buildpack-scala), or [Clojure](https://github.com/heroku/heroku-buildpack-clojure) buildpack instead. Those buildpacks already install OpenJDK and handle the build process for you. It is not necessary to add this buildpack in addition.

This buildpack is useful when your app needs OpenJDK installed but doesn't require a build tool like Maven, Gradle, sbt, or Leiningen. Common use cases include:

- Your app needs OpenJDK as a dependency (for example, to run Java-based tools)
- You're deploying a locally built JAR file to Heroku (see [heroku-jvm-application-deployer](https://github.com/heroku/heroku-jvm-application-deployer))

To set this buildpack for your app:

```
$ heroku buildpacks:set heroku/jvm
```

For more information on managing buildpacks, see the [Heroku Dev Center documentation](https://devcenter.heroku.com/articles/managing-buildpacks).

## Usage from a Buildpack

> [!NOTE]
> This section is for buildpack developers, not buildpack users.

This buildpack can be used as a library by other buildpacks to install OpenJDK. The official Heroku buildpacks for JVM languages and build tools use this buildpack in the same manner. This pattern is useful for third-party buildpacks that need OpenJDK since there is no mechanism to declare buildpack dependencies. Using this buildpack as a library ensures consistent OpenJDK behavior and versioning on Heroku.

```bash
# Determine the root directory of your own (host) buildpack
HOST_BUILDPACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"

JVM_BUILDPACK_URL="https://buildpack-registry.s3.dualstack.us-east-1.amazonaws.com/buildpacks/heroku/jvm.tgz"

mkdir -p /tmp/jvm-common
curl --silent --fail --retry 3 --retry-connrefused --connect-timeout 5 --location "${JVM_BUILDPACK_URL}" | tar xzm -C /tmp/jvm-common --strip-components=1

# Source in a sub-shell to keep your buildpack's environment clean
( source /tmp/jvm-common/bin/java && install_openjdk "${BUILD_DIR}" "${HOST_BUILDPACK_DIR}" )

# Source the export file to get environment variables like JAVA_HOME and PATH
source "${HOST_BUILDPACK_DIR}/export"
```

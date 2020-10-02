# Scalingo Buildpack for the JDK

This is the official [Scalingo
buildpack](https://doc.scalingo.com/platform/deployment/buildpacks) for
[OpenJDK](http://openjdk.java.net/). It only installs the JDK, and does not
build an application. It is used by the
[Java](https://github.com/Scalingo/java-buildpack),
[Java WAR](https://github.com/Scalingo/java-war-buildpack),
[Gradle](https://github.com/Scalingo/gradle-buildpack),
[Play!](https://github.com/Scalingo/play-buildpack),
[Scala](https://github.com/Scalingo/scala-buildpack), and
[Clojure](https://github.com/Scalingo/clojure-buildpack) buildpacks.

## Usage from a Buildpack

This is how the buildpack is used from another buildpack:

```bash
JVM_BUILDPACK_URL="https://buildpacks-repository.s3.eu-central-1.amazonaws.com/jvm-common.tar.xz"
mkdir -p /tmp/jvm-common
curl --silent --location $JVM_BUILDPACK_URL | tar xzm -C /tmp/jvm-common --strip-components=1
source /tmp/jvm-common/bin/util
source /tmp/jvm-common/bin/java

install_java_with_overlay ${BUILD_DIR}
```

## Standalone Usage

You may install the JVM buildpack into your app by running:

```
$ scalingo env-set BUILDPACK_URL=https://github.com/Scalingo/buildpack-jvm-common
```

Then it may be used by itself, or with another buildpack using [multiple
buildpacks](https://doc.scalingo.com/platform/deployment/buildpacks/multi#top-of-page).

## License

Licensed under the MIT License. See LICENSE file.

## Credits

This buildpack is maintained by Heroku: [upstream](https://github.com/heroku/heroku-buildpack-jvm-common)

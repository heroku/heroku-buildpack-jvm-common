# Heroku Buildpack for the JDK [![CircleCI](https://circleci.com/gh/heroku/heroku-buildpack-jvm-common/tree/main.svg?style=shield)](https://circleci.com/gh/heroku/heroku-buildpack-jvm-common/tree/main)

This is the official [Heroku buildpack](https://devcenter.heroku.com/articles/buildpacks) for [OpenJDK](http://openjdk.java.net/). It only installs the JDK, and does not build an application. It is used by the [Java](https://github.com/heroku/heroku-buildpack-java), [Scala](https://github.com/heroku/heroku-buildpack-scala), and [Clojure](https://github.com/heroku/heroku-buildpack-clojure) buildpacks.

## Usage from a Buildpack

This is how the buildpack is used from another buildpack:

```bash
JVM_BUILDPACK_URL="https://buildpack-registry.s3.amazonaws.com/buildpacks/heroku/jvm.tgz"
mkdir -p /tmp/jvm-common
curl --silent --location $JVM_BUILDPACK_URL | tar xzm -C /tmp/jvm-common --strip-components=1
source /tmp/jvm-common/bin/util
source /tmp/jvm-common/bin/java

install_java_with_overlay ${BUILD_DIR}
```

## Standalone Usage

You may install the JVM buildpack into your app by running:


```
$ heroku buildpacks:set heroku/jvm
```

If you want to use the edge version (the code in this repo), run this instead:

```
$ heroku buildpacks:set https://github.com/heroku/heroku-buildpack-jvm-common.git
```

Then it may be used by itself, or with another buildpack using [multiple buildpacks](https://devcenter.heroku.com/articles/using-multiple-buildpacks-for-an-app).

## Run Tests Locally

Tests can be run and debugged locally by using the [Circle CI CLI](https://circleci.com/docs/2.0/local-cli/).

For example, to run [Hatchet](https://github.com/heroku/hatchet) tests on `heroku-18` run:

```
$ circleci local execute --job hatchet-heroku-18 \
    --env HEROKU_API_USER=$(heroku whoami) \
    --env HEROKU_API_KEY=$(heroku auth:token)
```

Available jobs are defined in [.circleci/config.yml](.circleci/config.yml).

### Costs

This command uses the credentials from your local `heroku` configuration. This means your account will be billed for any
cost these tests incur. Proceed with caution.

## License

Licensed under the MIT License. See LICENSE file.

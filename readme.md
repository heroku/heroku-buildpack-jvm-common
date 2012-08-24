#Common JVM Buildpack BASH Functions

This not a buildpack. These are common functions related to
JVM buildpacks. It is formatted as a buildpack in order to
make use of [heroku-buildpack-testrunner](http://github.com/ryanbrainard/heroku-buildpack-testrunner)
test automation.

The most important function these scripts provide are functions
to install the JDK into a at compile time.

These scripts are bundled and stored in a tar ball at:

http://heroku-jvm-common.s3.amazonaws.com/jvm-buildpack-common.tar.gz

#Example Usage

```
curl --silent --location http://heroku-jvm-common.s3.amazonaws.com/jvm-buildpack-common.tar.gz | tar xz

. bin/java

install_java ${BUILD_DIR} "1.7"
```

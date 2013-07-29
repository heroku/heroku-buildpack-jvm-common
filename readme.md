#Common JVM Buildpack BASH Functions

This not a buildpack. These are common functions related to
JVM buildpacks. It is formatted as a buildpack in order to
make use of [heroku-buildpack-testrunner](http://github.com/cloudControl/heroku-buildpack-testrunner)
test automation.

The most important function these scripts provide are functions
to install the JDK into a at compile time.

These scripts are bundled and stored in a tarball.

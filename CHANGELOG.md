# JVM Common Buildpack Changelog

## master

* Added support for JDK 11 EA

## v66

* Upgrade default JDK 7 to 7u181

## v65

* Renamed the files used to attach Heroku JVM Metrics

## v64

* Upgrade default JDKs to 8u171 and 10.0.1

## v63

* Added JDK 10 GA

## v62

* Added JDK 10 early access

## v61

* Upgrade heroku-java-metrics-agent to 3.7
* Upgrade default JDK 8 to 8u161
* Upgrade default JDK 9 to 9.0.4
* Improved tests and CI support

## v60

* Added LD_LIBRARY_PATH to export and profile.d scripts
* Install heroku-java-metrics-agent with all apps
* Convert .profile.d script to work with Dash and Bash

## v41

* Upgrade default JDK 7 to 7u101

## v40

* Upgrade default JDK 8 to 8u92
* Added a guard for cacerts symlink

## v39

* Upgrade default JDK 8 to 8u77

## v38

* Upgrade default JDK 8 to 8u74

## v31

* Upgrade default JDK 8 to 8u66

## v30

* Added support for JDK update versions in system.properties
* Added with_jmap_and_jstack script

## v29

* Added support for MySQL in JDBC_DATABASE_URL

## v26

Improved smart defaults.

* Increased default heap settings for Performance-L dynos
* Added experimental support for JDBC_DATABASE_URL

# JVM Common Buildpack Changelog

## v84

* Update default JDK 7, 8, 11, and 12
* Prevent pgconfig jar from installing in CI

## v83

* Disable postgres sslmode when running in CI

## v82

* Update heroku-java-metrics-agent to 3.11

## v80

* Changed default JDK 7 to 7u201
* Changed default JDK 11 to 11.0.2
* Changed default JDK 8 to 8u201
* Remove Xms from default JAVA_TOOL_OPTIONS

## 73

* Update metrics agent to version 3.9

## v72

* Changed default JDK 11 to GA
* Improved default JVM options in JAVA_OPTS and JAVA_TOOL_OPTIONS

## v71

* Upgrade default JDK 11 to RC build 28

## v70

* Upgrade default JDK 10 to 10.0.2

## v69

* Improve detection for clojure
* Add support for JDBC pgbouncer pool connection

## v68

* Upgrade default JDK to 8u181

## v67

* Added support for JDK 11 EA
* Improve logging when using a provided JDK

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

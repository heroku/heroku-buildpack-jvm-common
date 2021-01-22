# JVM Common Buildpack Changelog

## Main

## v116

* Upgrade default JDKs to 15.0.2, 13.0.6, 11.0.10, 8u282 and 7u292

## v115

* Upgrade default JDKs to 13.0.5.1 and 11.0.9.1

## v114

* Install certs and profile scripts for JRE from CNB

## v113

* Upgrade CNB API compatibility version to 0.4

## v112

* Upgrade default JDKs to 8u275 and 7u285

## v111

* heroku-20 support for CNB
* Fix typos

## v110

* Add support for JVM_BUILDPACK_ASSETS_BASE_URL environment variable (#179)
* Deprecate support for JDK_BASE_URL environment variable (#179)
* Upgrade default JDKs to 15.0.1, 13.0.5, 11.0.9, 8u272 and 7u282 (#177)

## v109

* Add support for heroku-20 stack

## v108

* Upgrade default JDK to 8u265

## v107

* Add support for JDK 15

## v106

* JDBC_DATABASE_URL query parameters are now alphabetically ordered.
* Fix export_env_dir when no environment variables are present. (#148)

## v105

* Upgrade default JDKs to 14.0.2, 13.0.4, 11.0.8, 8u262 and 7u272

## v104

* Add support for BP_JVM_VERSION

## v103

Upgrade default JDK 13 to 13.0.3

## v102

* Upgrade default JDKs to 14.0.1, 11.0.7, 8u252 and 7u262

## v101

* Fix CNB packaging

## v100

* Fix DATABASE_CONNECTION_POOL_URL handling
* JDBC URL transformation no longer crashes silently on unexpected URLs

## v99

* Add support for JDK 14

## v98

* Improve CI and testing setup

## v97

* Enable -XX:+UseContainerSupport on JDK versions > 11

## v96

* Upgrade default JDKs to 13.0.2, 11.0.6, 8u242, and 7u252

## v95

* CNB: Fixed a bug that was cause JRE 11 to be installed incorrectly
* SPRING_REDIS_URL is now automatically set if REDIS_URL is available
* Fix backwards compatibility for users of this buildpack as a library
* CNB: Fix JRE/JDK caching

## v92

* Add support for Cloud Native Buildpack API
* GPG verify JDK binaries before installing
* Update heroku-java-metrics-agent to 3.14

## v91

* Upgrade default JDKs to 13.0.1, 11.0.5, 8u232, and 7u242

## v90

* Add support for JDK 13

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

# JVM Common Buildpack Changelog

## Main

* Upgrade default JDKs to 17.0.8.1 and 11.0.20.1. ([#274](https://github.com/heroku/heroku-buildpack-jvm-common/pull/274))

## v145

* Remove heroku-18 support ([#267](https://github.com/heroku/heroku-buildpack-jvm-common/pull/267))
* Upgrade default JDKs to 20.0.2, 17.0.8, 11.0.20 and 8u382. ([#269](https://github.com/heroku/heroku-buildpack-jvm-common/pull/269))

## v144

* Upgrade default JDKs to 20.0.1, 17.0.7, 11.0.19 and 8u372. ([#265](https://github.com/heroku/heroku-buildpack-jvm-common/pull/265))

## v143

* Add support for Java 20. ([#262](https://github.com/heroku/heroku-buildpack-jvm-common/pull/262))

## v142

* Upgrade default JDKs to 19.0.2, 17.0.6, 15.0.10, 13.0.14, 11.0.18 and 8u362. ([#256](https://github.com/heroku/heroku-buildpack-jvm-common/pull/256))

## v141

* Upgrade [Heroku Java metrics agent](https://github.com/heroku/heroku-java-metrics-agent) to `4.0.1`. ([#254](https://github.com/heroku/heroku-buildpack-jvm-common/pull/254))

## v140

* Upgrade [Heroku Java metrics agent](https://github.com/heroku/heroku-java-metrics-agent) to `4.0.0`. ([#253](https://github.com/heroku/heroku-buildpack-jvm-common/pull/253))

## v139

* Upgrade default JDKs to 19.0.1, 17.0.5, 15.0.9, 13.0.13, 11.0.17 and 8u352. ([#250](https://github.com/heroku/heroku-buildpack-jvm-common/pull/250))

## v138

* Upgrade default Java 18 JDK to `18.0.2.1`. ([#247](https://github.com/heroku/heroku-buildpack-jvm-common/pull/247))
* Add support for Java 19. ([#247](https://github.com/heroku/heroku-buildpack-jvm-common/pull/247))

## v137

* Upgrade default JDKs to `8u345`, `11.0.16.1`, `17.0.4.1`. ([#245](https://github.com/heroku/heroku-buildpack-jvm-common/pull/245))

## v136

* Upgrade default JDKs to 18.0.2, 17.0.4, 15.0.8, 13.0.12, 11.0.16, 8u342, 7u352

## v135

* Only use `--retry-connrefused` on Ubuntu based stacks. ([#243](https://github.com/heroku/heroku-buildpack-jvm-common/pull/243))

## v134

* Adjust curl retry and connection timeout handling. ([#241](https://github.com/heroku/heroku-buildpack-jvm-common/pull/241))
* Switch to the recommended regional S3 domain instead of the global one. ([#240](https://github.com/heroku/heroku-buildpack-jvm-common/pull/240))

## v133

* Allow OpenJDK distribution prefixes to be used in conjunction with major versions. Previously, a specific patch version was required when using a distribution prefix. ([#239](https://github.com/heroku/heroku-buildpack-jvm-common/pull/239)) 

## v132

* Refactor OpenJDK version resolution code. ([#237](https://github.com/heroku/heroku-buildpack-jvm-common/pull/237))
* Drop support for OpenJDK `9` and OpenJDK `12`, both versions are not available on any supported stack. ([#237](https://github.com/heroku/heroku-buildpack-jvm-common/pull/237))
* Add support for `heroku-22` stack. ([#236](https://github.com/heroku/heroku-buildpack-jvm-common/pull/236))
* Change default OpenJDK distribution to [Azul Zulu Builds of OpenJDK](https://www.azul.com/downloads/?package=jdk#download-openjdk) on stacks >= `heroku-22`. ([#236](https://github.com/heroku/heroku-buildpack-jvm-common/pull/236))

## v131

* Remove Cloud Native Buildpack support. Development of Heroku JVM Cloud Native Buildpacks now takes place in a dedicated repository: https://github.com/heroku/buildpacks-jvm

## v130

* Upgrade default JDK for Java 18 to 18.0.1

## v129

* Upgrade default JDKs to 17.0.3, 15.0.7, 13.0.11, 11.0.15, 8u332 and 7u342

## v128

* Add support for Java 18

## v127

* Upgrade default JDK for Java 11 to 11.0.14.1

## v126

* Upgrade default JDKs to 17.0.2, 15.0.6, 13.0.10, 11.0.14, 8u322 and 7u332

## v125
* Upgrade default JDK for Java 7 to 7u322

## v124
* Upgrade default JDK for Java 17 to 17.0.1

## v123
* Upgrade default JDKs to 15.0.5, 13.0.9, 11.0.13, and 8u312 

## v122

* Add support for Java 17
* Updated GPG public key

## v121

* Upgrade default JDK for Java 16 to 16.0.2

## v120

* Remove heroku-16 support
* Upgrade default JDKs to 15.0.4, 13.0.8, 11.0.12, 8u302 and 7u312

## v119

* Upgrade default JDKs to 16.0.1, 15.0.3, 13.0.7, 11.0.11, 8u292 and 7u302

## v118

* Add support for Java 16

## v117

* Zulu Builds of OpenJDK for 15.0.2 are now available

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

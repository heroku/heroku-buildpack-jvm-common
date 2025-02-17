# Changelog

## [Unreleased]


## [v159] - 2025-02-17

### Changed

* New OpenJDK versions now always require a buildpack update. Previously, it was possible to install concrete OpenJDK versions (i.e. `11.0.25`, not `11`) without a buildpack update. The buildpack now utilizes an inventory file that explicitly lists the available versions, supported architectures, checksums and more. If you relied on an older buildpack version but manually updated your `system.properties` files for new OpenJDK versions, you will have to use the previous version (v158) of the buildpack. ([#317](https://github.com/heroku/heroku-buildpack-jvm-common/pull/317))

### Removed

* Support for deprecated `JDK_BASE_URL` and `JVM_BUILDPACK_ASSETS_BASE_URL`. These were used in the testing setup and were never intended to be used by users of this buildpack. Available assets are now recorded in an inventory file. ([#331](https://github.com/heroku/heroku-buildpack-jvm-common/pull/331), [#317](https://github.com/heroku/heroku-buildpack-jvm-common/pull/317))

## [v158] - 2025-02-03

### Changed

* Upgrade default JDKs to 23.0.2, 21.0.6, 17.0.14, 11.0.26 and 8u442. ([#329](https://github.com/heroku/heroku-buildpack-jvm-common/pull/329))

## [v157] - 2024-10-22

### Changed

* Upgrade default JDKs to 23.0.1, 21.0.5, 17.0.13, 11.0.25 and 8u432. ([#315](https://github.com/heroku/heroku-buildpack-jvm-common/pull/315))

## [v156] - 2024-09-26

### Added

* Add support for Java 23. ([#311](https://github.com/heroku/heroku-buildpack-jvm-common/pull/311))

## [v155] - 2024-07-17

### Changed

* The value in `/sys/fs/cgroup/memory/memory.limit_in_bytes` is now explictly passed as `MaxRAM` to the JVM. ([#304](https://github.com/heroku/heroku-buildpack-jvm-common/pull/304))
* Upgrade default JDKs to 22.0.2, 21.0.4, 17.0.12, 11.0.24 and 8u422. ([#307](https://github.com/heroku/heroku-buildpack-jvm-common/pull/307))

## [v154] - 2024-05-29

### Added

* The buildpack now warns when no OpenJDK version is explicitly specified. Users are encouraged to specify a version to ensure future builds use the same OpenJDK version. ([#301](https://github.com/heroku/heroku-buildpack-jvm-common/pull/301))

### Changed

* Default JDK version for the `heroku-24` stack is now always the latest long-term support version, currently `21`. ([#300](https://github.com/heroku/heroku-buildpack-jvm-common/pull/300))

## [v153] - 2024-05-21

* Add support for `heroku-24` stack. ([#298](https://github.com/heroku/heroku-buildpack-jvm-common/pull/298))

## [v152] - 2024-05-01

* Upgrade default JDKs to 22.0.1, 21.0.3, 17.0.11, 11.0.23 and 8u412. ([#296](https://github.com/heroku/heroku-buildpack-jvm-common/pull/296))

## [v151] - 2024-03-22

* Add support for Java 22. ([#292](https://github.com/heroku/heroku-buildpack-jvm-common/pull/292))
* Use `/sys/fs/cgroup/memory/memory.limit_in_bytes` instead of `ulimit -u` for dyno type detection. ([#294](https://github.com/heroku/heroku-buildpack-jvm-common/pull/294))

## [v150] - 2024-01-17

* Upgrade default JDKs to 21.0.2, 17.0.10, 11.0.22 and 8u402. ([#284](https://github.com/heroku/heroku-buildpack-jvm-common/pull/284))

## [v149] - 2024-01-05

* JVM runtime options for Dynos that are **not** `Eco`, `Basic`, `Standard-1X`, `Standard-2X`, `Performance-M` or `Performance-L` (or their Private Spaces equivalents) will no longer default to the options for `Eco` Dynos. Instead, JVM ergonomics will be used in conjunction with `-XX:MaxRAMPercentage=80.0` to ensure sensible defaults for such Dynos. ([#282](https://github.com/heroku/heroku-buildpack-jvm-common/pull/282))

## [v148] - 2023-10-19

* Upgrade default JDKs to 21.0.1, 17.0.9, 11.0.21 and 8u392. ([#280](https://github.com/heroku/heroku-buildpack-jvm-common/pull/280))

## [v147] - 2023-09-20

* Add support for Java 21. ([#276](https://github.com/heroku/heroku-buildpack-jvm-common/pull/276))

## [v146] - 2023-09-19

* Upgrade default JDKs to 17.0.8.1 and 11.0.20.1. ([#274](https://github.com/heroku/heroku-buildpack-jvm-common/pull/274))

## [v145] - 2023-07-24

* Remove heroku-18 support ([#267](https://github.com/heroku/heroku-buildpack-jvm-common/pull/267))
* Upgrade default JDKs to 20.0.2, 17.0.8, 11.0.20 and 8u382. ([#269](https://github.com/heroku/heroku-buildpack-jvm-common/pull/269))

## [v144] - 2023-04-24

* Upgrade default JDKs to 20.0.1, 17.0.7, 11.0.19 and 8u372. ([#265](https://github.com/heroku/heroku-buildpack-jvm-common/pull/265))

## [v143] - 2023-03-23

* Add support for Java 20. ([#262](https://github.com/heroku/heroku-buildpack-jvm-common/pull/262))

## [v142] - 2023-01-18

* Upgrade default JDKs to 19.0.2, 17.0.6, 15.0.10, 13.0.14, 11.0.18 and 8u362. ([#256](https://github.com/heroku/heroku-buildpack-jvm-common/pull/256))

## [v141] - 2022-11-16

* Upgrade [Heroku Java metrics agent](https://github.com/heroku/heroku-java-metrics-agent) to `4.0.1`. ([#254](https://github.com/heroku/heroku-buildpack-jvm-common/pull/254))

## [v140] - 2022-11-08

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

[unreleased]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v159...main
[v159]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v158...v159
[v158]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v157...v158
[v157]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v156...v157
[v156]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v155...v156
[v155]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v154...v155
[v154]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v153...v154
[v153]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v152...v153
[v152]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v151...v152
[v151]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v150...v151
[v150]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v149...v150
[v149]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v148...v149
[v148]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v147...v148
[v147]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v146...v147
[v146]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v145...v146
[v145]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v144...v145
[v144]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v143...v144
[v143]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v142...v143
[v142]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v141...v142
[v141]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v140...v141
[v140]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v139...v140

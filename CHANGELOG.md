# Changelog

## [Unreleased]


## [v178] - 2026-02-24

### Changed

* Changed the S3 URLs used for downloads to use AWS' dual-stack (IPv6 compatible) endpoint. ([#419](https://github.com/heroku/heroku-buildpack-jvm-common/pull/419))

## [v177] - 2026-01-21

### Changed

* Upgrade default JDKs to `25.0.2`, `21.0.10`, `17.0.18`, `11.0.30` and `8u482`. ([#416](https://github.com/heroku/heroku-buildpack-jvm-common/pull/416))

## [v176] - 2025-10-30

### Changed

* Improve documentation in `bin/java` with usage examples, sub-shell best practices, and important notes for maintainers. ([#407](https://github.com/heroku/heroku-buildpack-jvm-common/pull/407))

### Fixed

* Fix "file not found" errors when sourcing the export file in sub-shells with provided JDKs. ([#408](https://github.com/heroku/heroku-buildpack-jvm-common/pull/408))

## [v175] - 2025-10-22

### Changed

* Upgrade default JDKs to `25.0.1`, `21.0.9`, `17.0.17`, `11.0.29` and `8u472`. ([#404](https://github.com/heroku/heroku-buildpack-jvm-common/pull/404))

## [v174] - 2025-09-26

### Added

* Additional internal metrics. ([#400](https://github.com/heroku/heroku-buildpack-jvm-common/pull/400))

## [v173] - 2025-09-19

### Added

* Support for automatic Spring AI configuration mapping from Heroku Managed Inference and Agents (MIA) environment variables. ([#398](https://github.com/heroku/heroku-buildpack-jvm-common/pull/398))

## [v172] - 2025-09-17

### Added

* Support for OpenJDK 25. ([#395](https://github.com/heroku/heroku-buildpack-jvm-common/pull/395))

## Changed

* Default OpenJDK major version on `heroku-24` changed from `21` to `25`. This only applies if no version is specified in `system.properties`. ([#396](https://github.com/heroku/heroku-buildpack-jvm-common/pull/396))

## [v171] - 2025-09-12

* Add version selection hint to unsupported Java version error message. ([#392](https://github.com/heroku/heroku-buildpack-jvm-common/pull/392))

## [v170] - 2025-09-04

* Fix `jdbc.sh` script when used with `set -euo pipefail`. ([#390](https://github.com/heroku/heroku-buildpack-jvm-common/pull/390))

## [v169] - 2025-09-02

* Fix `java_properties::get` function when used with `set -euo pipefail`. ([#386](https://github.com/heroku/heroku-buildpack-jvm-common/pull/386))

## [v168] - 2025-08-04

* Do not log `JAVA_TOOL_OPTIONS` messages on MCP servers. ([#382](https://github.com/heroku/heroku-buildpack-jvm-common/pull/382))

## [v167] - 2025-07-31

* Redirect `JAVA_TOOL_OPTIONS` logging to `stderr` to fix MCP server compatibility. ([#379](https://github.com/heroku/heroku-buildpack-jvm-common/pull/379))

## [v166] - 2025-07-16

* Upgrade default JDKs to `24.0.2`, `21.0.8`, `17.0.16`, `11.0.28` and `8u462`. ([#374](https://github.com/heroku/heroku-buildpack-jvm-common/pull/374))

## [v165] - 2025-07-14

* Remove `heroku-20` support. ([#365](https://github.com/heroku/heroku-buildpack-jvm-common/pull/365))

## [v164] - 2025-04-25

* Upgrade default JDKs to `24.0.1`, `21.0.7`, `17.0.15`, `11.0.27` and `8u452`. ([#362](https://github.com/heroku/heroku-buildpack-jvm-common/pull/362))

## [v163] - 2025-04-23

### Changed

* OpenJDK distributions are now downloaded from `heroku-buildpacks-jvm.s3.us-east-1.amazonaws.com` instead of `lang-jvm.s3.us-east-1.amazonaws.com`. For users of the Heroku platform, this change has no significance. When users use this buildpack outside of the Heroku platform, firewalls might need reconfiguration to allow the OpenJDK downloads from the new location. ([#359](https://github.com/heroku/heroku-buildpack-jvm-common/pull/359))

## [v162] - 2025-03-19

### Changed

* `-XX:+UseContainerSupport` is no longer being set in `JAVA_TOOL_OPTIONS`. This flag is set by default since OpenJDK `10` and `8u191`. All versions supported by this buildpack do have this default - therefore this change has no effect on the final JVM flags. ([#348](https://github.com/heroku/heroku-buildpack-jvm-common/pull/348))
* For `Performance-M` and `Performance-L` dynos, the buildpack no longer sets `-Xmx` to configure the maximum heap size. Instead, `-XX:MaxRAMPercentage=80.0` is used which has the same effect. The effective maximum heap size set for those dynos does not change. When users set `-Xmx` explicitly, it will still take precedence. ([#348](https://github.com/heroku/heroku-buildpack-jvm-common/pull/348))
* Previously, when an app had `-Xmx` in its `JAVA_OPTS` configuration variables, all Heroku default JVM options were not set. This was inconsistent with `JAVA_TOOL_OPTIONS` which didn't have that mechanism. For consistency, all Heroku JVM defaults will now be always applied. Since the buildpack adds its defaults before the ones explicitly set by the user, they can be overridden. In practice, this only affects `Eco`, `Basic`, `Standard-1X` and `Standard-2X` dynos which are the only sizes that have more default flags than just `-Xmx`. All dynos of the aforementioned sizes also have `-XX:CICompilerCount=2` set. `Eco`, `Basic` and `Standard-1X` also set `-Xss512k`. If your app relied on those not being set, you will have to explicitly configure them now. However, we believe these settings are good defaults for apps running on dynos with little RAM and you should not override them unnecessarily. ([#348](https://github.com/heroku/heroku-buildpack-jvm-common/pull/348))

### Added

* The already existing notice about default JVM flags is now always printed when the defaults are applied. Previously, this notice was only printed for `web` process types. The notice looks like this: `Setting JAVA_TOOL_OPTIONS defaults based on dyno size. Custom settings will override them.`. ([#348](https://github.com/heroku/heroku-buildpack-jvm-common/pull/348))
* Support for Java 24. ([#353](https://github.com/heroku/heroku-buildpack-jvm-common/pull/353))

## [v161] - 2025-03-12

### Changed

* Deprecated `install_java_with_overlay` function. Buildpacks using this function should now use `install_openjdk` instead. See `README.md` for a usage example. ([#346](https://github.com/heroku/heroku-buildpack-jvm-common/pull/346))

### Added

* Support for `DATABASE_URL` values that use the `mariadb` scheme. ([#341](https://github.com/heroku/heroku-buildpack-jvm-common/pull/341))

### Removed

* `export_env_dir`, `copy_directories`, `curl_with_defaults` and `nowms` functions from `bin/util`. ([#344](https://github.com/heroku/heroku-buildpack-jvm-common/pull/344))

## [v160] - 2025-02-19

### Removed

* Support for `JDK_URL_1_7`, `JDK_URL_1_8`, `JDK_URL_1_9`, `JDK_URL_10`, `JDK_URL_11`, `JDK_URL_12` environment variables to override OpenJDK download locations. ([#339](https://github.com/heroku/heroku-buildpack-jvm-common/pull/339))

### Changed

* The buildpack output will now explicitly mention the installed OpenJDK version instead of displaying only the major version. ([#339](https://github.com/heroku/heroku-buildpack-jvm-common/pull/339))

## [v159] - 2025-02-17

### Changed

* New OpenJDK versions now always require a buildpack update. Previously, it was possible to install concrete OpenJDK versions (i.e. `11.0.25`, not `11`) without a buildpack update. The buildpack now utilizes an inventory file that explicitly lists the available versions, supported architectures, checksums and more. If you relied on an older buildpack version but manually updated your `system.properties` files for new OpenJDK versions, you will have to use the previous version (v158) of the buildpack. ([#317](https://github.com/heroku/heroku-buildpack-jvm-common/pull/317))

### Removed

* Support for deprecated `JDK_BASE_URL` and `JVM_BUILDPACK_ASSETS_BASE_URL`. These were used in the testing setup and were never intended to be used by users of this buildpack. Available assets are now recorded in an inventory file. ([#331](https://github.com/heroku/heroku-buildpack-jvm-common/pull/331), [#317](https://github.com/heroku/heroku-buildpack-jvm-common/pull/317))

## [v158] - 2025-02-03

### Changed

* Upgrade default JDKs to `23.0.2`, `21.0.6`, `17.0.14`, `11.0.26` and `8u442`. ([#329](https://github.com/heroku/heroku-buildpack-jvm-common/pull/329))

## [v157] - 2024-10-22

### Changed

* Upgrade default JDKs to `23.0.1`, `21.0.5`, `17.0.13`, `11.0.25` and `8u432`. ([#315](https://github.com/heroku/heroku-buildpack-jvm-common/pull/315))

## [v156] - 2024-09-26

### Added

* Add support for Java 23. ([#311](https://github.com/heroku/heroku-buildpack-jvm-common/pull/311))

## [v155] - 2024-07-17

### Changed

* The value in `/sys/fs/cgroup/memory/memory.limit_in_bytes` is now explictly passed as `MaxRAM` to the JVM. ([#304](https://github.com/heroku/heroku-buildpack-jvm-common/pull/304))
* Upgrade default JDKs to `22.0.2`, `21.0.4`, `17.0.12`, `11.0.24` and `8u422`. ([#307](https://github.com/heroku/heroku-buildpack-jvm-common/pull/307))

## [v154] - 2024-05-29

### Added

* The buildpack now warns when no OpenJDK version is explicitly specified. Users are encouraged to specify a version to ensure future builds use the same OpenJDK version. ([#301](https://github.com/heroku/heroku-buildpack-jvm-common/pull/301))

### Changed

* Default JDK version for the `heroku-24` stack is now always the latest long-term support version, currently `21`. ([#300](https://github.com/heroku/heroku-buildpack-jvm-common/pull/300))

## [v153] - 2024-05-21

* Add support for `heroku-24` stack. ([#298](https://github.com/heroku/heroku-buildpack-jvm-common/pull/298))

## [v152] - 2024-05-01

* Upgrade default JDKs to `22.0.1`, `21.0.3`, `17.0.11`, `11.0.23` and `8u412`. ([#296](https://github.com/heroku/heroku-buildpack-jvm-common/pull/296))

## [v151] - 2024-03-22

* Add support for Java 22. ([#292](https://github.com/heroku/heroku-buildpack-jvm-common/pull/292))
* Use `/sys/fs/cgroup/memory/memory.limit_in_bytes` instead of `ulimit -u` for dyno type detection. ([#294](https://github.com/heroku/heroku-buildpack-jvm-common/pull/294))

## [v150] - 2024-01-17

* Upgrade default JDKs to `21.0.2`, `17.0.10`, `11.0.22` and `8u402`. ([#284](https://github.com/heroku/heroku-buildpack-jvm-common/pull/284))

## [v149] - 2024-01-05

* JVM runtime options for Dynos that are **not** `Eco`, `Basic`, `Standard-1X`, `Standard-2X`, `Performance-M` or `Performance-L` (or their Private Spaces equivalents) will no longer default to the options for `Eco` Dynos. Instead, JVM ergonomics will be used in conjunction with `-XX:MaxRAMPercentage=80.0` to ensure sensible defaults for such Dynos. ([#282](https://github.com/heroku/heroku-buildpack-jvm-common/pull/282))

## [v148] - 2023-10-19

* Upgrade default JDKs to `21.0.1`, `17.0.9`, `11.0.21` and `8u392`. ([#280](https://github.com/heroku/heroku-buildpack-jvm-common/pull/280))

## [v147] - 2023-09-20

* Add support for Java 21. ([#276](https://github.com/heroku/heroku-buildpack-jvm-common/pull/276))

## [v146] - 2023-09-19

* Upgrade default JDKs to `17.0.8.1` and `11.0.20.1`. ([#274](https://github.com/heroku/heroku-buildpack-jvm-common/pull/274))

## [v145] - 2023-07-24

* Remove `heroku-18` support. ([#267](https://github.com/heroku/heroku-buildpack-jvm-common/pull/267))
* Upgrade default JDKs to `20.0.2`, `17.0.8`, `11.0.20` and `8u382`. ([#269](https://github.com/heroku/heroku-buildpack-jvm-common/pull/269))

## [v144] - 2023-04-24

* Upgrade default JDKs to `20.0.1`, `17.0.7`, `11.0.19` and `8u372`. ([#265](https://github.com/heroku/heroku-buildpack-jvm-common/pull/265))

## [v143] - 2023-03-23

* Add support for Java 20. ([#262](https://github.com/heroku/heroku-buildpack-jvm-common/pull/262))

## [v142] - 2023-01-18

* Upgrade default JDKs to `19.0.2`, `17.0.6`, `15.0.10`, `13.0.14`, `11.0.18` and `8u362`. ([#256](https://github.com/heroku/heroku-buildpack-jvm-common/pull/256))

## [v141] - 2022-11-16

* Upgrade [Heroku Java metrics agent](https://github.com/heroku/heroku-java-metrics-agent) to `4.0.1`. ([#254](https://github.com/heroku/heroku-buildpack-jvm-common/pull/254))

## [v140] - 2022-11-08

* Upgrade [Heroku Java metrics agent](https://github.com/heroku/heroku-java-metrics-agent) to `4.0.0`. ([#253](https://github.com/heroku/heroku-buildpack-jvm-common/pull/253))

## v139 - 2022-10-19

* Upgrade default JDKs to `19.0.1`, `17.0.5`, `15.0.9`, `13.0.13`, `11.0.17` and `8u352`. ([#250](https://github.com/heroku/heroku-buildpack-jvm-common/pull/250))

## v138 - 2022-09-26

* Upgrade default Java 18 JDK to `18.0.2.1`. ([#247](https://github.com/heroku/heroku-buildpack-jvm-common/pull/247))
* Add support for Java 19. ([#247](https://github.com/heroku/heroku-buildpack-jvm-common/pull/247))

## v137 - 2022-08-29

* Upgrade default JDKs to `8u345`, `11.0.16.1`, `17.0.4.1`. ([#245](https://github.com/heroku/heroku-buildpack-jvm-common/pull/245))

## v136 - 2022-07-26

* Upgrade default JDKs to `18.0.2`, `17.0.4`, `15.0.8`, `13.0.12`, `11.0.16`, `8u342`, `7u352`.

## v135 - 2022-06-28

* Only use `--retry-connrefused` on Ubuntu based stacks. ([#243](https://github.com/heroku/heroku-buildpack-jvm-common/pull/243))

## v134 - 2022-06-14

* Adjust `curl` retry and connection timeout handling. ([#241](https://github.com/heroku/heroku-buildpack-jvm-common/pull/241))
* Switch to the recommended regional S3 domain instead of the global one. ([#240](https://github.com/heroku/heroku-buildpack-jvm-common/pull/240))

## v133 - 2022-06-08

* Allow OpenJDK distribution prefixes to be used in conjunction with major versions. Previously, a specific patch version was required when using a distribution prefix. ([#239](https://github.com/heroku/heroku-buildpack-jvm-common/pull/239))

## v132 - 2022-06-07

* Refactor OpenJDK version resolution code. ([#237](https://github.com/heroku/heroku-buildpack-jvm-common/pull/237))
* Drop support for OpenJDK `9` and OpenJDK `12`, both versions are not available on any supported stack. ([#237](https://github.com/heroku/heroku-buildpack-jvm-common/pull/237))
* Add support for `heroku-22` stack. ([#236](https://github.com/heroku/heroku-buildpack-jvm-common/pull/236))
* Change default OpenJDK distribution to [Azul Zulu Builds of OpenJDK](https://www.azul.com/downloads/?package=jdk#download-openjdk) on stacks >= `heroku-22`. ([#236](https://github.com/heroku/heroku-buildpack-jvm-common/pull/236))

## v131 - 2022-05-18

* Remove Cloud Native Buildpack support. Development of Heroku JVM Cloud Native Buildpacks now takes place in a dedicated repository: https://github.com/heroku/buildpacks-jvm.

## v130 - 2022-04-24

* Upgrade default JDK for Java 18 to `18.0.1`.

## v129 - 2022-04-21

* Upgrade default JDKs to `17.0.3`, `15.0.7`, `13.0.11`, `11.0.15`, `8u332` and `7u342`.

## v128 - 2022-03-23

* Add support for Java 18.

## v127 - 2022-03-02

* Upgrade default JDK for Java 11 to `11.0.14.1`.

## v126 - 2022-01-24

* Upgrade default JDKs to `17.0.2`, `15.0.6`, `13.0.10`, `11.0.14`, `8u322` and `7u332`.

## v125 - 2021-10-28

* Upgrade default JDK for Java 7 to `7u322`.

## v124 - 2021-10-27

* Upgrade default JDK for Java 17 to `17.0.1`.

## v123 - 2021-10-19

* Upgrade default JDKs to `15.0.5`, `13.0.9`, `11.0.13`, and `8u312`.

## v122 - 2021-09-15

* Add support for Java 17.
* Update GPG public key.

## v121 - 2021-07-28

* Upgrade default JDK for Java 16 to `16.0.2`.

## v120 - 2021-07-21

* Remove `heroku-16` support.
* Upgrade default JDKs to `15.0.4`, `13.0.8`, `11.0.12`, `8u302` and `7u312`.

## v119 - 2021-04-29

* Upgrade default JDKs to `16.0.1`, `15.0.3`, `13.0.7`, `11.0.11`, `8u292` and `7u302`.

## v118 - 2021-03-17

* Add support for Java 16.

## v117 - 2021-02-01

* Zulu Builds of OpenJDK for `15.0.2` are now available.

## v116 - 2021-01-22

* Upgrade default JDKs to `15.0.2`, `13.0.6`, `11.0.10`, `8u282` and `7u292`.

## v115 - 2021-01-06

* Upgrade default JDKs to `13.0.5.1` and `11.0.9.1`.

## v114 - 2021-01-05

* Install certs and profile scripts for JRE from CNB.

## v113 - 2020-12-07

* Upgrade CNB API compatibility version to `0.4`.

## v112 - 2020-12-01

* Upgrade default JDKs to `8u275` and `7u285`.

## v111 - 2020-11-17

* Add `heroku-20` support for CNB.
* Fix typos.

## v110 - 2020-10-26

* Add support for `JVM_BUILDPACK_ASSETS_BASE_URL` environment variable. ([#179](https://github.com/heroku/heroku-buildpack-jvm-common/pull/179))
* Deprecate support for `JDK_BASE_URL` environment variable. ([#179](https://github.com/heroku/heroku-buildpack-jvm-common/pull/179))
* Upgrade default JDKs to `15.0.1`, `13.0.5`, `11.0.9`, `8u272` and `7u282`. ([#177](https://github.com/heroku/heroku-buildpack-jvm-common/pull/177))

## v109 - 2020-10-15

* Add support for `heroku-20` stack.

## v108 - 2020-10-13

* Upgrade default JDK to `8u265`.

## v107 - 2020-09-16

* Add support for JDK 15.

## v106 - 2020-08-19

* `JDBC_DATABASE_URL` query parameters are now alphabetically ordered.
* Fix `export_env_dir` when no environment variables are present. ([#148](https://github.com/heroku/heroku-buildpack-jvm-common/pull/148))

## v105 - 2020-07-20

* Upgrade default JDKs to `14.0.2`, `13.0.4`, `11.0.8`, `8u262` and `7u272`.

## v104 - 2020-05-18

* Add support for `BP_JVM_VERSION`.

## v103 - 2020-04-24

* Upgrade default JDK 13 to `13.0.3`.

## v102 - 2020-04-24

* Upgrade default JDKs to `14.0.1`, `11.0.7`, `8u252` and `7u262`.

## v101 - 2020-04-07

* Fix CNB packaging.

## v100 - 2020-03-23

* Fix `DATABASE_CONNECTION_POOL_URL` handling.
* JDBC URL transformation no longer crashes silently on unexpected URLs.

## v99 - 2020-03-17

* Add support for JDK 14.

## v98 - 2020-03-11

* Improve CI and testing setup.

## v97 - 2020-02-10

* Enable `-XX:+UseContainerSupport` on JDK versions > `11`.

## v96 - 2020-02-06

* Upgrade default JDKs to `13.0.2`, `11.0.6`, `8u242`, and `7u252`.

## v95 - 2020-02-04

* CNB: Fix a bug that was cause JRE 11 to be installed incorrectly.
* `SPRING_REDIS_URL` is now automatically set if `REDIS_URL` is available.
* Fix backwards compatibility for users of this buildpack as a library.
* CNB: Fix JRE/JDK caching.

## v92 - 2019-12-16

* Add support for Cloud Native Buildpack API.
* GPG verify JDK binaries before installing.
* Update `heroku-java-metrics-agent` to `3.14`.

## v91 - 2019-09-17

* Upgrade default JDKs to `13.0.1`, `11.0.5`, `8u232`, and `7u242`.

## v90 - 2019-07-18

* Add support for JDK 13.

## v84 - 2019-04-17

* Update default JDK 7, 8, 11, and 12.
* Prevent `pgconfig` jar from installing in CI.

## v83 - 2019-04-09

* Disable postgres `sslmode` when running in CI.

## v82 - 2019-03-27

* Update `heroku-java-metrics-agent` to `3.11`.

## v80 - 2019-02-19

* Change default JDK 7 to `7u201`.
* Change default JDK 11 to `11.0.2`.
* Change default JDK 8 to `8u201`.
* Remove `-Xms` from default `JAVA_TOOL_OPTIONS`.

## v73 - 2018-11-30

* Update metrics agent to version `3.9`.

## v72 - 2018-10-04

* Change default JDK 11 to GA.
* Improve default JVM options in `JAVA_OPTS` and `JAVA_TOOL_OPTIONS`.

## v71 - 2018-09-10

* Upgrade default JDK 11 to RC build 28.

## v70 - 2018-08-21

* Upgrade default JDK 10 to `10.0.2`.

## v69 - 2018-08-20

* Improve detection for Clojure.
* Add support for JDBC `pgbouncer` pool connection.

## v68 - 2018-08-13

* Upgrade default JDK to `8u181`.

## v67 - 2018-08-01

* Add support for JDK 11 EA.
* Improve logging when using a provided JDK.

## v66 - 2018-07-09

* Upgrade default JDK 7 to `7u181`.

## v65 - 2018-05-29

* Rename the files used to attach Heroku JVM Metrics.

## v64 - 2018-05-16

* Upgrade default JDKs to `8u171` and `10.0.1`.

## v63 - 2018-03-21

* Add JDK 10 GA.

## v62 - 2018-02-28

* Add JDK 10 early access.

## v61 - 2018-01-17

* Upgrade `heroku-java-metrics-agent` to `3.7`.
* Upgrade default JDK 8 to `8u161`.
* Upgrade default JDK 9 to `9.0.4`.
* Improve tests and CI support.

## v60 - 2018-01-04

* Add `LD_LIBRARY_PATH` to export and `profile.d` scripts.
* Install `heroku-java-metrics-agent` with all apps.
* Convert `.profile.d` script to work with Dash and Bash.

## v41 - 2016-05-24

* Upgrade default JDK 7 to `7u101`.

## v40 - 2016-05-23

* Upgrade default JDK 8 to `8u92`.
* Add a guard for `cacerts` symlink.

## v39 - 2016-05-18

* Upgrade default JDK 8 to `8u77`.

## v38 - 2016-03-11

* Upgrade default JDK 8 to `8u74`.

## v31 - 2015-10-21

* Upgrade default JDK 8 to `8u66`.

## v30 - 2015-10-19

* Add support for JDK update versions in `system.properties`.
* Add `with_jmap_and_jstack` script.

## v29 - 2015-09-24

* Add support for MySQL in `JDBC_DATABASE_URL`.

## v26 - 2015-08-26

* Increase default heap settings for Performance-L dynos.
* Add experimental support for `JDBC_DATABASE_URL`.

[unreleased]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v178...main
[v178]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v177...v178
[v177]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v176...v177
[v176]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v175...v176
[v175]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v174...v175
[v174]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v173...v174
[v173]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v172...v173
[v172]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v171...v172
[v171]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v170...v171
[v170]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v169...v170
[v169]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v168...v169
[v168]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v167...v168
[v167]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v166...v167
[v166]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v165...v166
[v165]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v164...v165
[v164]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v163...v164
[v163]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v162...v163
[v162]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v161...v162
[v161]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v160...v161
[v160]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v159...v160
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
[v139]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v138...v139
[v138]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v137...v138
[v137]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v136...v137
[v136]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v135...v136
[v135]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v134...v135
[v134]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v133...v134
[v133]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v132...v133
[v132]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v131...v132
[v131]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v130...v131
[v130]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v129...v130
[v129]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v128...v129
[v128]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v127...v128
[v127]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v126...v127
[v126]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v125...v126
[v125]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v124...v125
[v124]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v123...v124
[v123]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v122...v123
[v122]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v121...v122
[v121]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v120...v121
[v120]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v119...v120
[v119]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v118...v119
[v118]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v117...v118
[v117]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v116...v117
[v116]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v115...v116
[v115]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v114...v115
[v114]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v113...v114
[v113]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v112...v113
[v112]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v111...v112
[v111]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v110...v111
[v110]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v109...v110
[v109]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v108...v109
[v108]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v107...v108
[v107]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v106...v107
[v106]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v105...v106
[v105]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v104...v105
[v104]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v103...v104
[v103]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v102...v103
[v102]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v101...v102
[v101]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v100...v101
[v100]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v99...v100
[v99]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v98...v99
[v98]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v97...v98
[v97]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v96...v97
[v96]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v95...v96
[v95]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v92...v95
[v92]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v91...v92
[v91]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v90...v91
[v90]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v84...v90
[v84]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v83...v84
[v83]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v82...v83
[v82]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v80...v82
[v80]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v73...v80
[v73]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v72...v73
[v72]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v71...v72
[v71]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v70...v71
[v70]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v69...v70
[v69]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v68...v69
[v68]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v67...v68
[v67]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v66...v67
[v66]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v65...v66
[v65]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v64...v65
[v64]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v63...v64
[v63]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v62...v63
[v62]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v61...v62
[v61]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v60...v61
[v60]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v41...v60
[v41]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v40...v41
[v40]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v39...v40
[v39]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v38...v39
[v38]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v31...v38
[v31]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v30...v31
[v30]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v29...v30
[v29]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v26...v29
[v26]: https://github.com/heroku/heroku-buildpack-jvm-common/compare/v1.0...v26

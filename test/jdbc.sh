#!/bin/bash

# shellcheck disable=SC2030,SC2031,SC2034

JDBC_SCRIPT_LOCATION="opt/jdbc.sh"

testDefaultDatabaseEnvVar() {
  (
    export DATABASE_URL="postgres://AzureDiamond:hunter2@db.example.com:5432/testdb"

    # shellcheck disable=SC1090
    source "$JDBC_SCRIPT_LOCATION"

    assertEquals "jdbc:postgresql://db.example.com:5432/testdb?user=AzureDiamond&password=hunter2&sslmode=require" "$JDBC_DATABASE_URL"
    assertEquals "AzureDiamond" "$JDBC_DATABASE_USERNAME"
    assertEquals "hunter2" "$JDBC_DATABASE_PASSWORD"
  )
}

testSSLModeDisabledOnCI() {
  (
    export DATABASE_URL="postgres://AzureDiamond:hunter2@db.example.com:5432/testdb"
    export CI="true"

    # shellcheck disable=SC1090
    source "$JDBC_SCRIPT_LOCATION"

    assertEquals "jdbc:postgresql://db.example.com:5432/testdb?user=AzureDiamond&password=hunter2" "$JDBC_DATABASE_URL"
    assertEquals "AzureDiamond" "$JDBC_DATABASE_USERNAME"
    assertEquals "hunter2" "$JDBC_DATABASE_PASSWORD"
  )
}

testColorDatabaseEnvVar() {
  (
    export HEROKU_POSTGRESQL_RED_URL="postgres://red:charmander@db.example.com:5432/fire-pokemon"
    export HEROKU_POSTGRESQL_BLUE_URL="postgres://blue:squirtle@db.example.com:5432/water-pokemon"

    # shellcheck disable=SC1090
    source "$JDBC_SCRIPT_LOCATION"

    assertEquals "" "$JDBC_DATABASE_URL"

    assertEquals "jdbc:postgresql://db.example.com:5432/fire-pokemon?user=red&password=charmander&sslmode=require" "$HEROKU_POSTGRESQL_RED_JDBC_URL"
    assertEquals "red" "$HEROKU_POSTGRESQL_RED_JDBC_USERNAME"
    assertEquals "charmander" "$HEROKU_POSTGRESQL_RED_JDBC_PASSWORD"

    assertEquals "jdbc:postgresql://db.example.com:5432/water-pokemon?user=blue&password=squirtle&sslmode=require" "$HEROKU_POSTGRESQL_BLUE_JDBC_URL"
    assertEquals "blue" "$HEROKU_POSTGRESQL_BLUE_JDBC_USERNAME"
    assertEquals "squirtle" "$HEROKU_POSTGRESQL_BLUE_JDBC_PASSWORD"
  )
}

testMySQLDatabaseEnvVar() {
  (
    export DATABASE_URL="mysql://foo:bar@ec2-0-0-0-0:5432/abc123?reconnect=true"

    # shellcheck disable=SC1090
    source "$JDBC_SCRIPT_LOCATION"

    assertEquals "jdbc:mysql://ec2-0-0-0-0:5432/abc123?user=foo&password=bar&reconnect=true" "$JDBC_DATABASE_URL"
  )
}

testThirdPartyDatabaseUrls() {
  for item in JAWSDB_URL JAWSDB_MARIA_URL CLEARDB_DATABASE_URL; do
    (
      export "$item="mysql://foo:bar@ec2-0-0-0-0:5432/$item?reconnect=true""

      # shellcheck disable=SC1090
      source "$JDBC_SCRIPT_LOCATION"

      assertEquals "jdbc:mysql://ec2-0-0-0-0:5432/$item?user=foo&password=bar&reconnect=true" "$JDBC_DATABASE_URL"
      assertEquals "foo" "$JDBC_DATABASE_USERNAME"
      assertEquals "bar" "$JDBC_DATABASE_PASSWORD"
    )
  done
}

testThirdPartyDatabaseUrlsPriority() {
  for item in JAWSDB_URL JAWSDB_MARIA_URL CLEARDB_DATABASE_URL; do
    (
      export DATABASE_URL="postgres://AzureDiamond:hunter2@db.example.com:5432/regular-database"
      export "$item="mysql://foo:bar@ec2-0-0-0-0:5432/$item?reconnect=true""

      # shellcheck disable=SC1090
      source "$JDBC_SCRIPT_LOCATION"

      assertEquals "jdbc:postgresql://db.example.com:5432/regular-database?user=AzureDiamond&password=hunter2&sslmode=require" "$JDBC_DATABASE_URL"
      assertEquals "AzureDiamond" "$JDBC_DATABASE_USERNAME"
      assertEquals "hunter2" "$JDBC_DATABASE_PASSWORD"
    )
  done
}

testDatabaseConnectionPool() {
  (
    export DATABASE_URL="postgres://AzureDiamond:hunter2@db.example.com:5432/testdb"
    export DATABASE_CONNECTION_POOL_URL="postgres://pooluser:poolpass@pooled.example.com:5432/testdb"

    # shellcheck disable=SC1090
    source "$JDBC_SCRIPT_LOCATION"

    assertEquals "jdbc:postgresql://pooled.example.com:5432/testdb?user=pooluser&password=poolpass&sslmode=require" "$JDBC_DATABASE_URL"
    assertEquals "pooluser" "$JDBC_DATABASE_USERNAME"
    assertEquals "poolpass" "$JDBC_DATABASE_PASSWORD"

    assertEquals "jdbc:postgresql://pooled.example.com:5432/testdb?user=pooluser&password=poolpass&sslmode=require" "$DATABASE_CONNECTION_POOL_JDBC_URL"
    assertEquals "pooluser" "$DATABASE_CONNECTION_POOL_JDBC_USERNAME"
    assertEquals "poolpass" "$DATABASE_CONNECTION_POOL_JDBC_PASSWORD"
  )
}

testDatabaseConnectionPoolWithoutDatabaseUrl() {
  (
    export DATABASE_CONNECTION_POOL_URL="postgres://pooluser:poolpass@pooled.example.com:5432/testdb"

    # shellcheck disable=SC1090
    source "$JDBC_SCRIPT_LOCATION"

    assertEquals "" "$JDBC_DATABASE_URL"
    assertEquals "" "$JDBC_DATABASE_USERNAME"
    assertEquals "" "$JDBC_DATABASE_PASSWORD"

    assertEquals "" "$DATABASE_CONNECTION_POOL_JDBC_URL"
    assertEquals "" "$DATABASE_CONNECTION_POOL_JDBC_USERNAME"
    assertEquals "" "$DATABASE_CONNECTION_POOL_JDBC_PASSWORD"
  )
}

testSpringDataSourceSupport() {
  (
    export DATABASE_URL="postgres://AzureDiamond:hunter2@db.example.com:5432/testdb"

    # shellcheck disable=SC1090
    source "$JDBC_SCRIPT_LOCATION"

    assertEquals "jdbc:postgresql://db.example.com:5432/testdb?user=AzureDiamond&password=hunter2&sslmode=require" "$JDBC_DATABASE_URL"
    assertEquals "AzureDiamond" "$JDBC_DATABASE_USERNAME"
    assertEquals "hunter2" "$JDBC_DATABASE_PASSWORD"

    assertEquals "$JDBC_DATABASE_URL" "$SPRING_DATASOURCE_URL"
    assertEquals "$JDBC_DATABASE_USERNAME" "$SPRING_DATASOURCE_USERNAME"
    assertEquals "$JDBC_DATABASE_PASSWORD" "$SPRING_DATASOURCE_PASSWORD"
  )
}

testSpringDataSourceSupportExplicitlyDisabled() {
  (
    export DATABASE_URL="postgres://AzureDiamond:hunter2@db.example.com:5432/testdb"
    export DISABLE_SPRING_DATASOURCE_URL="true"

    # shellcheck disable=SC1090
    source "$JDBC_SCRIPT_LOCATION"

    assertEquals "jdbc:postgresql://db.example.com:5432/testdb?user=AzureDiamond&password=hunter2&sslmode=require" "$JDBC_DATABASE_URL"
    assertEquals "AzureDiamond" "$JDBC_DATABASE_USERNAME"
    assertEquals "hunter2" "$JDBC_DATABASE_PASSWORD"

    assertEquals "" "$SPRING_DATASOURCE_URL"
    assertEquals "" "$SPRING_DATASOURCE_USERNAME"
    assertEquals "" "$SPRING_DATASOURCE_PASSWORD"
  )
}

testSpringDataSourceSupportImplicitlyDisabled() {
  local originalSpringDatasourceUrl="jdbc:postgresql://db.example.com:5432/testdb?user=AzureDiamondSpring&password=hunter2&sslmode=require"

  (
    export DATABASE_URL="postgres://AzureDiamond:hunter2@db.example.com:5432/testdb"
    export SPRING_DATASOURCE_URL="$originalSpringDatasourceUrl"

    # shellcheck disable=SC1090
    source "$JDBC_SCRIPT_LOCATION"

    assertEquals "jdbc:postgresql://db.example.com:5432/testdb?user=AzureDiamond&password=hunter2&sslmode=require" "$JDBC_DATABASE_URL"
    assertEquals "AzureDiamond" "$JDBC_DATABASE_USERNAME"
    assertEquals "hunter2" "$JDBC_DATABASE_PASSWORD"

    assertEquals "$originalSpringDatasourceUrl" "$SPRING_DATASOURCE_URL"
    assertEquals "" "$SPRING_DATASOURCE_USERNAME"
    assertEquals "" "$SPRING_DATASOURCE_PASSWORD"
  )
}

testCustomDatabaseUrlWithoutPasswordAndPath() {
  (
    # We want to test that the script does not fail hard when executed in a stricter
    # environment such as heroku/java's bin/compile step.
    set -e

    export DATABASE_URL="postgres://test123@ec2-52-13-12"

    # shellcheck disable=SC1090
    source "$JDBC_SCRIPT_LOCATION"

    assertEquals "" "$JDBC_DATABASE_URL"
    assertEquals "" "$JDBC_DATABASE_USERNAME"
    assertEquals "" "$JDBC_DATABASE_PASSWORD"
  )
}

testCustomDatabaseUrlWithFragmentAndQueryParameters() {
  (
    export DATABASE_URL="postgres://AzureDiamond:hunter2@db.example.com:5432/testdb?foo=bar&e=mc^2#fragment"

    # shellcheck disable=SC1090
    source "$JDBC_SCRIPT_LOCATION"

    assertEquals "jdbc:postgresql://db.example.com:5432/testdb?foo=bar&user=AzureDiamond&password=hunter2&sslmode=require&e=mc^2#fragment" "$JDBC_DATABASE_URL"
    assertEquals "AzureDiamond" "$JDBC_DATABASE_USERNAME"
    assertEquals "hunter2" "$JDBC_DATABASE_PASSWORD"
  )
}

testCustomDatabaseUrlWithoutPath() {
  (
    export DATABASE_URL="postgres://AzureDiamond:hunter2@db.example.com:5432"

    # shellcheck disable=SC1090
    source "$JDBC_SCRIPT_LOCATION"

    assertEquals "jdbc:postgresql://db.example.com:5432?user=AzureDiamond&password=hunter2&sslmode=require" "$JDBC_DATABASE_URL"
    assertEquals "AzureDiamond" "$JDBC_DATABASE_USERNAME"
    assertEquals "hunter2" "$JDBC_DATABASE_PASSWORD"
  )
}

# shellcheck disable=SC1091
source test/vendor/shunit2

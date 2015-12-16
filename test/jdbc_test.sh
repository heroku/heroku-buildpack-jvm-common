#!/usr/bin/env bash

. ${BUILDPACK_TEST_RUNNER_HOME}/lib/test_utils.sh
. ${BUILDPACK_HOME}/opt/jdbc.sh

testDefaultEnvVar() {
    set_jdbc_url "postgres://foo:bar@ec2-0-0-0-0:5432/abc123"
    assertEquals "Wrong JDBC_DATABASE_URL" \
                 "jdbc:postgresql://ec2-0-0-0-0:5432/abc123?user=foo&password=bar&ssl=true&sslfactory=org.postgresql.ssl.NonValidatingFactory" \
                 "$JDBC_DATABASE_URL"
    unset JDBC_DATABASE_URL
}

testSecondaryEnvVar() {
    set_jdbc_url "postgres://foo:bar@ec2-0-0-0-0:5432/abc123" "HEROKU_POSTGRESQL_RED_JDBC"
    assertEquals "Wrong secondary DB URL" \
                 "jdbc:postgresql://ec2-0-0-0-0:5432/abc123?user=foo&password=bar&ssl=true&sslfactory=org.postgresql.ssl.NonValidatingFactory" \
                 "$HEROKU_POSTGRESQL_RED_JDBC_URL"
    unset HEROKU_POSTGRESQL_RED_JDBC_URL
}

testMySqlEnvVar() {
    set_jdbc_url "mysql://foo:bar@ec2-0-0-0-0:5432/abc123?reconnect=true"
    assertEquals "Wrong MySQL URL" \
                 "jdbc:mysql://ec2-0-0-0-0:5432/abc123?reconnect=true&user=foo&password=bar" \
                 "$JDBC_DATABASE_URL"
    unset JDBC_DATABASE_URL
}

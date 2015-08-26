#!/usr/bin/env bash

set_jdbc_url() {
  local db_url=${1}

  db_protocol=$(expr "$db_url" : "\(.\+\)://")
  if [ $db_protocol == "postgres" ]; then
    jdbc_protocol="jdbc:postgresql"
  elif [ $db_protocol == "mysql" ]; then
    jdbc_protocol="jdbc:mysql"
  fi

  db_user=$(expr "$db_url" : "${db_protocol}://\(.\+\):\(.\+\)@")
  db_prefix="${db_protocol}://${db_user}:"

  db_pass=$(expr "$db_url" : "${db_prefix}\(.\+\)@")
  db_prefix="${db_prefix}${db_pass}@"

  db_host_port=$(expr "$db_url" : "${db_prefix}\(.\+\)/")
  db_prefix="${db_prefix}${db_host_port}/"

  db_name=$(expr "$db_url" : "${db_prefix}\(.\+\)")

  export JDBC_DATABASE_URL="${jdbc_protocol}://${db_host_port}/${db_name}?user=${db_user}&password=${db_pass}"
  export JDBC_DATABASE_USERNAME="${db_user}"
  export JDBC_DATABASE_PASSWORD="${db_pass}"
}

if [ -n "$DATABASE_URL" ]; then
  set_jdbc_url "$DATABASE_URL"
elif [ -n "$JAWSDB_URL" ]; then
  set_jdbc_url "$JAWSDB_URL"
elif [ -n "$CLEARDB_DATABASE_URL" ]; then
  set_jdbc_url "$CLEARDB_DATABASE_URL"
fi

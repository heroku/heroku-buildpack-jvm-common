#!/usr/bin/env bash

if [ -n "$DATABASE_URL" ]; then
  db_protocol=$(expr "$DATABASE_URL" : "\(.\+\)://")
  if [ $db_protocol == "postgres" ]; then
    jdbc_protocol="jdbc:postgresql"
  elif [ $db_protocol == "mysql" ]; then
    jdbc_protocol="jdbc:mysql"
  fi

  db_user=$(expr "$DATABASE_URL" : "${db_protocol}://\(.\+\):\(.\+\)@")
  db_prefix="${db_protocol}://${db_user}:"

  db_pass=$(expr "$DATABASE_URL" : "${db_prefix}\(.\+\)@")
  db_prefix="${db_prefix}${db_pass}@"

  db_host_port=$(expr "$DATABASE_URL" : "${db_prefix}\(.\+\)/")
  db_prefix="${db_prefix}${db_host_port}/"

  db_name_args=$(expr "$DATABASE_URL" : "${db_prefix}\(.\+\)")

  export JDBC_DATABASE_URL="${jdbc_protocol}://${db_host_port}/${db_name_args}"
  export JDBC_DATABASE_USERNAME="${db_user}"
  export JDBC_DATABASE_PASSWORD="${db_pass}"
fi

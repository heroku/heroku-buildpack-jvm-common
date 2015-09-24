#!/usr/bin/env bash

set_jdbc_url() {
  local db_url=${1}

  if [ -z "$JDBC_DATABASE_URL" ]; then
      local db_protocol=$(expr "$db_url" : "\(.\+\)://")
      if [ "$db_protocol" == "postgres" ]; then
	  local jdbc_protocol="jdbc:postgresql"
      elif [ "$db_protocol" == "mysql" ]; then
	  local jdbc_protocol="jdbc:mysql"
      fi

      if [ -n "$jdbc_protocol" ]; then
	  local db_user=$(expr "$db_url" : "${db_protocol}://\(.\+\):\(.\+\)@")
	  local db_prefix="${db_protocol}://${db_user}:"

	  local db_pass=$(expr "$db_url" : "${db_prefix}\(.\+\)@")
	  db_prefix="${db_prefix}${db_pass}@"

	  local db_host_port=$(expr "$db_url" : "${db_prefix}\(.\+\)/")
	  db_prefix="${db_prefix}${db_host_port}/"

	  local db_suffix=$(expr "$db_url" : "${db_prefix}\(.\+\)")

          if [[ "$db_suffix" == *\?* ]]; then
            local db_args="&user=${db_user}&password=${db_pass}"
	  else
            local db_args="?user=${db_user}&password=${db_pass}"
	  fi

	  export JDBC_DATABASE_URL="${jdbc_protocol}://${db_host_port}/${db_suffix}${db_args}"
	  export JDBC_DATABASE_USERNAME="${db_user}"
	  export JDBC_DATABASE_PASSWORD="${db_pass}"
      fi
  fi
}

if [ -n "$DATABASE_URL" ]; then
  set_jdbc_url "$DATABASE_URL"
elif [ -n "$JAWSDB_URL" ]; then
  set_jdbc_url "$JAWSDB_URL"
elif [ -n "$CLEARDB_DATABASE_URL" ]; then
  set_jdbc_url "$CLEARDB_DATABASE_URL"
fi

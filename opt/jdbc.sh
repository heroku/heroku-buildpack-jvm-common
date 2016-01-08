#!/usr/bin/env bash

set_jdbc_url() {
  local db_url=${1}
  local env_prefix=${2:-"JDBC_DATABASE"}

  if [ -z "$(eval echo \$${env_prefix}_URL)" ]; then
      local db_protocol=$(expr "$db_url" : "\(.\+\)://")
      if [ "$db_protocol" = "postgres" ]; then
        local jdbc_protocol="jdbc:postgresql"
        local db_default_args="&sslmode=require"
      elif [ "$db_protocol" = "mysql" ]; then
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

        if echo "$db_suffix" | grep -qi "?"; then
          local db_args="&user=${db_user}&password=${db_pass}"
        else
          local db_args="?user=${db_user}&password=${db_pass}"
        fi

        eval "export ${env_prefix}_URL=\"${jdbc_protocol}://${db_host_port}/${db_suffix}${db_args}${db_default_args}\""
        eval "export ${env_prefix}_USERNAME=\"${db_user}\""
        eval "export ${env_prefix}_PASSWORD=\"${db_pass}\""
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

for dbUrlVar in $(env | awk -F "=" '{print $1}' | grep "HEROKU_POSTGRESQL_.*_URL"); do
  set_jdbc_url "$(eval echo \$${dbUrlVar})" "$(echo $dbUrlVar | sed -e s/_URL//g)_JDBC"
done

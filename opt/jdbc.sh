#!/usr/bin/env bash

set_jdbc_url() {
  local database_url=${1}
  local environment_variables_prefix=${2}

  local pattern="^([a-zA-Z][a-zA-Z0-9\+\.\-]*)://(.*?@)?([^/:]+)(:[0-9]+)?([^#\?]+)?(\?[^#]+)?(#.+)?$"

  if [[ ! $database_url =~ $pattern ]]; then
    # We dont consider a non matching string an error and silently exit
    return 0
  else
    # NOTE: These variables also contain delimiters for easier re-concatentation later.
    # (i.e. :1234 instead of 1234 for port or user:pass@ instead of user:pass for user info.)
    local original_schema="${BASH_REMATCH[1]}"
    local original_user_info="${BASH_REMATCH[2]}"
    local original_host="${BASH_REMATCH[3]}"
    local original_port="${BASH_REMATCH[4]}"
    local original_path="${BASH_REMATCH[5]}"
    local original_query="${BASH_REMATCH[6]}"
    local original_fragment="${BASH_REMATCH[7]}"

    # Split the original query string into an associative array. We use this array to keep track of all query
    # parameters for the final JDBC URL. It will be modified by later parts of this function.
    declare -A query_parameters
    local current_key=""
    for value in ${original_query//[?&=]/ }; do
      if [[ -z $current_key ]]; then
        current_key=$value
      else
        query_parameters[$current_key]=$value
        current_key=""
      fi
    done

    # Populate username and password variables for later use. We also add those to the array of query parameters.
    local username
    local password
    if [[ $original_user_info =~ ^(.+?):(.+?)@$ ]]; then
      username="${BASH_REMATCH[1]}"
      password="${BASH_REMATCH[2]}"

      query_parameters["user"]=$username
      query_parameters["password"]=$password

    elif [[ $original_user_info =~ ^(.+?)@$ ]]; then
      username="${BASH_REMATCH[1]}"

      query_parameters["user"]=$username
    fi

    # Database specific transformations based on the URL schema.
    local modified_schema
    case $original_schema in
    "postgres")
      modified_schema="jdbc:postgresql"

      if [[ "${CI:-}" != "true" ]]; then
        query_parameters["sslmode"]="require"
      fi
      ;;
    "mysql")
      modified_schema="jdbc:mysql"
      ;;
    *)
      # We don't handle database URLs that aren't mysql or postgres.
      # But we also don't consider this an error and silently exit.
      return 0
      ;;
    esac

    # Fold all query parameters from the associative array into a query string.
    local modified_query

    local -r sorted_query_parameter_keys=$(echo -n "${!query_parameters[@]}" | tr " " "\n" | sort | tr "\n" " ")
    for query_parameter_key in $sorted_query_parameter_keys; do
      local key_value_pair="${query_parameter_key}=${query_parameters[$query_parameter_key]}"

      if [[ -z "${modified_query:-}" ]]; then
        modified_query="?${key_value_pair}"
      else
        modified_query="${modified_query}&${key_value_pair}"
      fi
    done

    # Previous versions of this script only set the environment variables when a username and password was present.
    # We keep this logic to ensure backwards compatability.
    if [[ -n $username && -n $password ]]; then
      eval "export ${environment_variables_prefix}_URL=\"${modified_schema}://${original_host}${original_port}${original_path}${modified_query}${original_fragment}\""
      eval "export ${environment_variables_prefix}_USERNAME=\"${username}\""
      eval "export ${environment_variables_prefix}_PASSWORD=\"${password}\""
    fi
  fi
}

if [[ -n "${DATABASE_URL:-}" ]]; then
  set_jdbc_url "$DATABASE_URL" "JDBC_DATABASE"
  if [[ -n "${DATABASE_CONNECTION_POOL_URL:-}" ]]; then
    set_jdbc_url "$DATABASE_CONNECTION_POOL_URL" "JDBC_DATABASE"
    set_jdbc_url "$DATABASE_CONNECTION_POOL_URL" "DATABASE_CONNECTION_POOL_JDBC"
  fi
elif [[ -n "${JAWSDB_URL:-}" ]]; then
  set_jdbc_url "$JAWSDB_URL" "JDBC_DATABASE"
elif [[ -n "${JAWSDB_MARIA_URL:-}" ]]; then
  set_jdbc_url "$JAWSDB_MARIA_URL" "JDBC_DATABASE"
elif [[ -n "${CLEARDB_DATABASE_URL:-}" ]]; then
  set_jdbc_url "$CLEARDB_DATABASE_URL" "JDBC_DATABASE"
fi

if [[ "${DISABLE_SPRING_DATASOURCE_URL:-}" != "true" ]] &&
  [[ -n "${JDBC_DATABASE_URL:-}" ]] &&
  [[ -z "${SPRING_DATASOURCE_URL:-}" ]] &&
  [[ -z "${SPRING_DATASOURCE_USERNAME:-}" ]] &&
  [[ -z "${SPRING_DATASOURCE_PASSWORD:-}" ]]; then

  export SPRING_DATASOURCE_URL="$JDBC_DATABASE_URL"
  export SPRING_DATASOURCE_USERNAME="${JDBC_DATABASE_USERNAME:-}"
  export SPRING_DATASOURCE_PASSWORD="${JDBC_DATABASE_PASSWORD:-}"
fi

for database_url_variable in $(env | awk -F "=" '{print $1}' | grep "HEROKU_POSTGRESQL_.*_URL"); do
  set_jdbc_url "$(eval echo "\$${database_url_variable}")" "${database_url_variable//_URL/}_JDBC"
done

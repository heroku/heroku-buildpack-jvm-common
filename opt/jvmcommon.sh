#!/usr/bin/env bash

calculate_java_memory_opts() {
  local opts=${1:-""}
  local memory_limit_file='/sys/fs/cgroup/memory/memory.limit_in_bytes'

  if [[ -f "${memory_limit_file}" ]]; then
    case $(cat "${memory_limit_file}") in
    536870912) # Eco, Basic, 1X
      echo "$opts -Xmx300m -Xss512k -XX:CICompilerCount=2"
      return 0
      ;;
    1073741824) # 2X, private-s
      echo "$opts -Xmx671m -XX:CICompilerCount=2"
      return 0
      ;;
    2684354560) # perf-m, private-m
      echo "$opts -Xmx2g"
      return 0
      ;;
    15032385536) # perf-l, private-l
      echo "$opts -Xmx12g"
      return 0
      ;;
    esac
  fi

  # Rely on JVM ergonomics for other dyno types, but increase the maximum RAM percentage from 25% to 80%.
  # This is more consistent with the Heroku defaults for other dyno types. For example, a 32GB dyno would only use
  # 8GB of heap with the 25% default, but performance-l with 14GB of memory would get 12GB max heap size as
  # explicitly configured.
  echo "$opts -XX:MaxRAMPercentage=80.0"
}

if [[ -d $HOME/.jdk ]]; then
  export JAVA_HOME="$HOME/.jdk"
  export PATH="$HOME/.heroku/bin:$JAVA_HOME/bin:$PATH"
else
  JAVA_HOME="$(realpath "$(dirname "$(command -v java)")/..")"
  export JAVA_HOME
fi

if [[ -d "$JAVA_HOME/jre/lib/amd64/server" ]]; then
  export LD_LIBRARY_PATH="$JAVA_HOME/jre/lib/amd64/server:$LD_LIBRARY_PATH"
elif [[ -d "$JAVA_HOME/lib/server" ]]; then
  export LD_LIBRARY_PATH="$JAVA_HOME/lib/server:$LD_LIBRARY_PATH"
fi

if [ -f "$JAVA_HOME/release" ] && grep -q '^JAVA_VERSION="1[0-9]' "$JAVA_HOME/release"; then
  default_java_mem_opts="$(calculate_java_memory_opts "-XX:+UseContainerSupport")"
else
  default_java_mem_opts="$(calculate_java_memory_opts | sed 's/^ //')"
fi

if echo "${JAVA_OPTS:-}" | grep -q "\-Xmx"; then
  export JAVA_TOOL_OPTIONS=${JAVA_TOOL_OPTIONS:-"-Dfile.encoding=UTF-8"}
else
  default_java_opts="${default_java_mem_opts} -Dfile.encoding=UTF-8"
  export JAVA_OPTS="${default_java_opts} ${JAVA_OPTS:-}"
  if echo "${DYNO}" | grep -vq '^run\..*$'; then
    export JAVA_TOOL_OPTIONS="${default_java_opts} ${JAVA_TOOL_OPTIONS:-}"
  fi
  if echo "${DYNO}" | grep -q '^web\..*$'; then
    echo "Setting JAVA_TOOL_OPTIONS defaults based on dyno size. Custom settings will override them."
  fi
fi

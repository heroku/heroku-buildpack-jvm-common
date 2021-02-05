#!/usr/bin/env bash

calculate_java_memory_opts() {
  local opts=${1:-""}

  container_size=$(echo $CONTAINER_SIZE)
  case $container_size in
  S)
    # XX:XICompilerCount=2 is the minimum value
    echo "$opts -Xmx160m -Xss512k -XX:CICompilerCount=2"
    ;;
  L)
    echo "$opts -Xmx671m -XX:CICompilerCount=2"
    ;;
  XL)
    echo "$opts -Xmx1536m -XX:CICompilerCount=2"
    ;;
  2XL)
    echo "$opts -Xmx3g -XX:CICompilerCount=3"
    ;;
  3XL)
    echo "$opts -Xmx6g -XX:CICompilerCount=3"
    ;;
  4XL)
    echo "$opts -Xmx12g -XX:CICompilerCount=4"
    ;;
  *) # M Container and default if buildpack is used elsewhere
    echo "$opts -Xmx300m -Xss512k -XX:CICompilerCount=2"
    ;;
  esac
}

if [[ -d $HOME/.jdk ]]; then
  export JAVA_HOME="$HOME/.jdk"
  export PATH="$HOME/.scalingo/bin:$JAVA_HOME/bin:$PATH"
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
  if echo "${DYNO}" | grep -vq '^one-off-.*$'; then
    export JAVA_TOOL_OPTIONS="${default_java_opts} ${JAVA_TOOL_OPTIONS:-}"
  fi
  if echo "${DYNO}" | grep -q '^web-.*$'; then
    echo "Setting JAVA_TOOL_OPTIONS defaults based on dyno size. Custom settings will override them."
  fi
fi

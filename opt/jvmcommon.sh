#!/usr/bin/env bash

export JAVA_HOME="$HOME/.jdk"
export LD_LIBRARY_PATH="$JAVA_HOME/jre/lib/amd64/server:$LD_LIBRARY_PATH"
export PATH="$HOME/.heroku/bin:$JAVA_HOME/bin:$PATH"
limit=$(ulimit -u)
case $limit in
256)   # 1X Dyno
  default_java_mem_opts="-Xmx300m -Xss512k"
  ;;
512)   # 2X Dyno
  default_java_mem_opts="-Xmx686m"
  ;;
16384) # IX Dyno
  default_java_mem_opts="-Xmx2g"
  ;;
32768) # PX Dyno
  default_java_mem_opts="-Xmx12g"
  ;;
*)
  default_java_mem_opts="-Xmx300m -Xss512k"
  ;;
esac

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

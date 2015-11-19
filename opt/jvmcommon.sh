#!/usr/bin/env bash

export JAVA_HOME="$HOME/.jdk"
export PATH="$HOME/.heroku/bin:$JAVA_HOME/bin:$PATH"
limit=$(ulimit -u)
case $limit in
256)   # 1X Dyno
  default_java_mem_opts="-Xmx350m -Xss512k"
  ;;
512)   # 2X Dyno
  default_java_mem_opts="-Xmx768m"
  ;;
16384) # IX Dyno
  default_java_mem_opts="-Xmx2g"
  ;;
32768) # PX Dyno
  default_java_mem_opts="-Xmx12g"
  ;;
*)
  default_java_mem_opts="-Xmx350m -Xss512k"
  ;;
esac

if [[ "${JAVA_OPTS}" == *-Xmx* ]]; then
  export JAVA_TOOL_OPTIONS=${JAVA_TOOL_OPTIONS:-"-Dfile.encoding=UTF-8"}
else
  default_java_opts="${default_java_mem_opts} -Dfile.encoding=UTF-8"
  export JAVA_OPTS="${default_java_opts} $JAVA_OPTS"
  if [[ "${DYNO}" != *run.* ]]; then
    export JAVA_TOOL_OPTIONS=${JAVA_TOOL_OPTIONS:-${default_java_opts}}
  fi
  if [[ "${DYNO}" == *web.* ]]; then
    echo "Setting JAVA_TOOL_OPTIONS defaults based on dyno size. Custom settings will override them."
  fi
fi

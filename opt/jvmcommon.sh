#!/usr/bin/env bash

export JAVA_HOME="$HOME/.jdk"
export PATH="$HOME/.heroku/bin:$JAVA_HOME/bin:$PATH"
limit=$(ulimit -u)
case $limit in
256)   # 1X Dyno
  default_java_opts="-Xmx384m -Xss512k"
  ;;
512)   # 2X Dyno
  default_java_opts="-Xmx768m"
  ;;
16384) # IX Dyno
  default_java_opts="-Xmx2g"
  ;;
32768) # PX Dyno
  default_java_opts="-Xmx12g"
  ;;
*)
  default_java_opts="-Xmx384m -Xss512k"
  ;;
esac

export JAVA_TOOL_OPTIONS=${JAVA_TOOL_OPTIONS:-"${default_java_opts} -Dfile.encoding=UTF-8"}

if [[ "${JAVA_OPTS}" == *-Xmx* ]]; then
  export JAVA_OPTS="$JAVA_OPTS"
else
  export JAVA_OPTS="${default_java_opts} $JAVA_OPTS"
fi

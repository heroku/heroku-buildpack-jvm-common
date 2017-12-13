#!/bin/bash

# don't do anything if we don't have a metrics url.
if [[ -z "${HEROKU_METRICS_URL:-}" ]] || [[ "${DYNO}" = run\.* ]]; then
    return 0
fi

# heroku-metrics-agent.jar is added in bin/compile
if [[ -f ${HOME}/.heroku/bin/heroku-metrics-agent.jar ]] && [[ -z "${DISABLE_HEROKU_METRICS_AGENT:-}" ]]; then
  if [[ -f build.sbt ]] || # Scala
     [[ -d target/resolution-cache ]]; then # Scala (sbt-heroku)
    export JAVA_OPTS="-javaagent:${HOME}/.heroku/bin/heroku-metrics-agent.jar ${JAVA_OPTS:-}"
  else
    export JAVA_TOOL_OPTIONS="-javaagent:${HOME}/.heroku/bin/heroku-metrics-agent.jar ${JAVA_TOOL_OPTIONS:-}"
  fi
fi

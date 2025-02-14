#!/bin/bash

if [ ! -f /app/Procfile ] && [ "${DYNO}" = "web.1" ]; then
	echo "Create a Procfile to customize the command used to run this process: https://devcenter.heroku.com/articles/procfile"
fi

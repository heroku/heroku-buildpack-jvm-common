unit:
	@echo "Running unit tests in docker (heroku-18)..."
	@docker run -v $(shell pwd):/buildpack:ro --rm -it -e "STACK=heroku-18" -e "BUILDPACK_HOME=/buildpack" heroku/heroku:18 bash -c 'cp -r /buildpack /buildpack_test; cd /buildpack_test/; test/unit;'
	@echo ""

it:
	@echo "Running integration tests in docker (heroku-18)..."
	@docker run -v $(shell pwd):/buildpack:ro --rm -it -e "STACK=heroku-18" -e "BUILDPACK_HOME=/buildpack" heroku/heroku:18 bash -c 'cp -r /buildpack /buildpack_test; cd /buildpack_test/; test/it;'
	@echo ""
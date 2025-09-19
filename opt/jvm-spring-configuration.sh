#!/usr/bin/env bash

# Automatically configures Spring Framework environment variables by mapping
# from standard Heroku add-on variables to their Spring equivalents.
# Only sets environment variables if they are not already defined or explicitly disabled.
# https://docs.spring.io/spring-boot/reference/features/external-config.html
#
# Note: Spring datasource configuration is handled separately in jdbc.sh since
# profile.d script execution order is not guaranteed.

ENV_MAPPINGS=(
	# Heroku Key-Value Store
	"REDIS_URL:SPRING_REDIS_URL:DISABLE_SPRING_REDIS_URL"
	# Heroku Managed Inference and Agents (MIA)
	"SPRING_AI_OPENAI_APIKEY:INFERENCE_KEY:DISABLE_SPRING_AI_CONFIG"
	"SPRING_AI_OPENAI_BASEURL:INFERENCE_URL:DISABLE_SPRING_AI_CONFIG"
	"SPRING_AI_OPENAI_CHAT_OPTIONS_MODEL:INFERENCE_MODEL_ID:DISABLE_SPRING_AI_CONFIG"
)

for env_mapping in "${ENV_MAPPINGS[@]}"; do
	IFS=':' read -r env_mapping_source env_mapping_target env_mapping_disable_var <<<"${env_mapping}"

	if [[ "${!env_mapping_disable_var:-}" != "true" && -z "${!env_mapping_target:-}" && -n "${!env_mapping_source:-}" ]]; then
		export "${env_mapping_target}"="${!env_mapping_source}"
	fi
done

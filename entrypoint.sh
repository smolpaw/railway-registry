#!/bin/sh
set -e

REQUIRED_VARS="
  RAILWAY_SERVICE_NAME
  RAILWAY_ENVIRONMENT_NAME
  AWS_ACCESS_KEY_ID
  AWS_SECRET_ACCESS_KEY
  AWS_DEFAULT_REGION
  AWS_ENDPOINT_URL
  AWS_S3_BUCKET_NAME
  REGISTRY_SECRET
  REGISTRY_USERNAME
  REGISTRY_PASSWORD
"

missing=0
for var in $REQUIRED_VARS; do
  eval val=\$$var
  if [ -z "$val" ]; then
    echo "ERROR: Required environment variable $var is not set" >&2
    missing=1
  fi
done

if [ "$missing" -eq 1 ]; then
  exit 1
fi

# Generate registry config from template
envsubst < /railway/config.yml.tmpl > /etc/distribution/config.yml

# Regenerate htpasswd only if credentials changed or file doesn't exist
HTPASSWD_PATH="/etc/registry/htpasswd"
mkdir -p "$(dirname "$HTPASSWD_PATH")"
if [ -f "$HTPASSWD_PATH" ] && htpasswd -vb "$HTPASSWD_PATH" "$REGISTRY_USERNAME" "$REGISTRY_PASSWORD" > /dev/null 2>&1; then
  echo "Registry credentials unchanged"
else
  htpasswd -Bbc "$HTPASSWD_PATH" "$REGISTRY_USERNAME" "$REGISTRY_PASSWORD"
  echo "Registry credentials updated"
fi

# Hand off to the original entrypoint: ENTRYPOINT ["registry"] CMD ["serve", "/etc/distribution/config.yml"]
exec registry serve /etc/distribution/config.yml

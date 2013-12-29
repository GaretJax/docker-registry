#!/bin/bash

WORKER_SECRET_KEY="${WORKER_SECRET_KEY:-$(< /dev/urandom tr -dc A-Za-z0-9 | head -c 32)}"
sed -i "s/ secret_key: REPLACEME/ secret_key: ${WORKER_SECRET_KEY}/" config/config.yml

if [[ -z "$GUNICORN_WORKERS" ]] ; then
    GUNICORN_WORKERS=4
fi

if [[ -z "$STORAGE_ENGINE" ]] ; then
    STORAGE_ENGINE="s3"
fi

if [ "$SETTINGS_FLAVOR" = "prod" ] ; then
    config=$(<config/config.yml);
    config=${config//boto_bucket: REPLACEME/boto_bucket: $S3_BUCKET};
    config=${config//storage: REPLACEME/storage: $STORAGE_ENGINE};
    
    if [ "$STORAGE_ENGINE" = "s3" ] ; then
        config=${config//s3_access_key: REPLACEME/s3_access_key: $AWS_ACCESS_KEY_ID};
        config=${config//s3_secret_key: REPLACEME/s3_secret_key: $AWS_SECRET_KEY};
        config=${config//s3_bucket: REPLACEME/s3_bucket: $S3_BUCKET};
        config=${config//s3_encrypt: REPLACEME/s3_encrypt: ${S3_ENCRYPT:-False}};
        config=${config//s3_secure: REPLACEME/s3_secure: ${S3_SECURE:-False}};
    else if [ "$STORAGE_ENGINE" = "gs" ] ; then
        config=${config//gs_access_key: REPLACEME/gs_access_key: $GS_ACCESS_KEY_ID};
        config=${config//gs_secret_key: REPLACEME/gs_secret_key: $GS_SECRET_KEY};
        config=${config//gs_secure: REPLACEME/gs_secure: ${GS_SECURE:-False}};
    fi
    printf '%s\n' "$config" >config/config.yml
fi

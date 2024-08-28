#!/bin/sh

while ! curl -s http://127.0.0.1:9001 > /dev/null; do echo "Waiting for MinIO to start..."; sleep 2; done
mc alias set local http://127.0.0.1:9000 $MINIO_ROOT_USER $MINIO_ROOT_PASSWORD
mc admin info local
mc mb local/production
mc anonymous set public local/production
mc admin user svcacct add local $MINIO_ROOT_USER --access-key $S3_ACCESS_KEY_ID --secret-key $S3_SECRET_ACCESS_KEY

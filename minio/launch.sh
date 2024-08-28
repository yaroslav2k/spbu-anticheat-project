#!/bin/sh

./add_user.sh &
mkdir ~/minio
minio server /data --console-address ":9001"

copy .\local_deployment\.env .\.env
copy .\local_deployment\.postgresql.env .\.postgresql.env
copy .\local_deployment\.s3.env .\.s3.env
copy .\local_deployment\ca.crt .\nginx\certificates\ca.crt
copy .\local_deployment\ca.key .\nginx\certificates\ca.key

docker compose build --pull
cmd /k
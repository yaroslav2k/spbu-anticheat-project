@REM @echo off
setlocal enabledelayedexpansion
docker compose up -d
docker compose exec frontier-web bundle exec rails db:seed

:check_container
call :wait_for_container "clone-detector"
call :wait_for_container "nginx"
@REM call :wait_for_container "frontier-web"
@REM call :wait_for_container "frontier-worker"
call :wait_for_container "frontier-redis"
call :wait_for_container "s3"
call :wait_for_container "frontier-postgresql"

goto :eof

:wait_for_container
set "container_name=%~1"
echo "%container_name%"
set "res="

for /f "usebackq" %%i in (`docker inspect -f {{.State.Health.Status}} %container_name%`) do set "res=%%i"
echo "%res%"
if "%res%" == "starting" (
    timeout /t 1 >nul
    echo "not started"
    goto wait_for_container
)
goto :eof
docker compose up -d
docker compose exec frontier-web bundle exec rails db:seed
start https://localhost/admin

# frozen_string_literal: true

namespace :reverseproxy do
  desc "Setup reverse proxy to 443/tcp"
  task setup: :environment do
    system "ngrok http https://localhost:443"
  end
end

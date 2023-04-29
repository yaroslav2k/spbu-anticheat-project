# frozen_string_literal: true

namespace :reverseproxy do
  desc "Setup reverse proxy to 3000/tcp"
  task setup: :environment do
    system "ngrok http 3000"
  end
end

# frozen_string_literal: true
host = ENV.fetch('REDIS_PORT_6379_TCP_ADDR') { 'localhost' }
port = ENV.fetch('REDIS_PORT_6379_TCP_PORT') { 6379 }

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://#{host}:#{port}/12", namespace: "RwWidget_#{Rails.env}" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://#{host}:#{port}/12", namespace: "RwWidget_#{Rails.env}" }
end

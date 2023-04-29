1) уставновить ngrok (либо его аналог)
2) ngrok http 80
3) curl -XPOST "https://api.telegram.org/bot#{api_token}/setWebhook?url=#{url}/gateway/telegram/webhooks/notify"

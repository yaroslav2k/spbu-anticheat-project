1) Install and start ngrok:

```bash
ngrok http https://localhost:443
```

2) Configure telegram bot:

```bash
curl -F "url=<host>/gateway/telegram/webhooks/notify" -F "certificate=@ca.pem" "https://api.telegram.org/bot<bot-api-token>/setWebhook"
```

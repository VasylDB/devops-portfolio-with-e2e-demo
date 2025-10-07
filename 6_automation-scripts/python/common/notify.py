import os
import json
import requests

def slack_notify(text: str) -> None:
    """Send a Slack webhook notification if SLACK_WEBHOOK_URL is set.
    Fails silently if not configured (so scripts can run without Slack).
    """
    url = os.getenv("SLACK_WEBHOOK_URL")
    if not url:
        return
    payload = {"text": text}
    try:
        requests.post(url, data=json.dumps(payload), timeout=5)
    except Exception:
        # Avoid breaking main flows on notification errors
        pass

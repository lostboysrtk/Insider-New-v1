import urllib.request
import json
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

API_KEY = ""
URL = "https://api.groq.com/openai/v1/chat/completions"

# Exact payload from DevKnowsViewController
payload = {
    "model": "llama-3.1-8b-instant",
    "messages": [
        {"role": "system", "content": "You are DevKnows, a helpful coding assistant. Use the provided article context to answer concisely."},
        {"role": "user", "content": "Hello World"}
    ],
    "temperature": 0.3,
    "max_tokens": 500
}

req = urllib.request.Request(URL, method='POST', headers={
    'Authorization': f'Bearer {API_KEY}',
    'Content-Type': 'application/json',
    'User-Agent': 'Insider/1.0 (com.yourdomain.Insider; build:1; iOS 16.0.0) Alamofire/5.6.1' # Mock iOS
}, data=json.dumps(payload).encode('utf-8'))

try:
    with urllib.request.urlopen(req, context=ctx) as res:
        print("Success:", json.loads(res.read().decode('utf-8')))
except Exception as e:
    print("Error:", e)
    if hasattr(e, 'read'):
        print(e.read().decode('utf-8'))

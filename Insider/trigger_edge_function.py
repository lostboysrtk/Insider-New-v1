import urllib.request
import json
import ssl
import re

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

with open("/Users/user1/Downloads/try 24/Insider/DB/SupabaseConfig.swift", "r") as f:
    config = f.read()

projectURL = re.search(r'static let projectURL = "(.*?)"', config).group(1)
anonKey = re.search(r'static let anonKey = "(.*?)"', config).group(1)

edge_url = f"{projectURL}/functions/v1/fetch-news"
print(f"Triggering Edge Function at: {edge_url}")

req = urllib.request.Request(edge_url, method='POST', headers={
    'Authorization': f'Bearer {anonKey}',
    'Content-Type': 'application/json'
})

try:
    with urllib.request.urlopen(req, context=ctx) as res:
        response_body = res.read().decode('utf-8')
        print("Success! Edge Function Response:")
        try:
            parsed = json.loads(response_body)
            print(json.dumps(parsed, indent=2))
        except json.JSONDecodeError:
            print(response_body)
except Exception as e:
    print(f"Error triggering Edge function: {e}")
    if hasattr(e, 'read'):
        print(e.read().decode('utf-8'))

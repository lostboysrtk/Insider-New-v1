import urllib.request
import json
import ssl

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

SUPABASE_URL = "https://edoumdymwuxndqtmcroz.supabase.co"
SUPABASE_KEY = ""

url = f"{SUPABASE_URL}/rest/v1/news_cards?select=category"
req = urllib.request.Request(url, headers={
    'apikey': SUPABASE_KEY,
    'Authorization': f'Bearer {SUPABASE_KEY}'
})

try:
    with urllib.request.urlopen(req, context=ctx) as res:
        data = json.loads(res.read().decode())
        categories = set()
        for item in data:
            for cat in item.get('category') or []:
                categories.add(cat)
        print("Unique categories:", sorted(list(categories)))
except Exception as e:
    print("Error:", e)
    if hasattr(e, 'read'):
        print(e.read().decode())

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

def check_counts():
    url = f"{projectURL}/rest/v1/news_cards?select=category"
    req = urllib.request.Request(url, headers={'apikey': anonKey, 'Authorization': f'Bearer {anonKey}'})
    try:
        with urllib.request.urlopen(req, context=ctx) as res:
            data = json.loads(res.read().decode())
            counts = {}
            for item in data:
                cat = item.get('category')
                if cat is None:
                    cat_str = "NULL"
                else:
                    cat_str = str(cat)
                counts[cat_str] = counts.get(cat_str, 0) + 1
            
            # Sort by count desc
            sorted_counts = sorted(counts.items(), key=lambda x: x[1], reverse=True)
            for k, v in sorted_counts[:15]:
                print(f"{v} rows: {k}")
            print(f"Total rows fetched: {len(data)}")
    except Exception as e:
        print("Error:", e)

check_counts()

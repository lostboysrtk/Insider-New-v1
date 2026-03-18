import urllib.request
import json
import ssl
import re
import time

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

with open("/Users/user1/Downloads/try 24/Insider/DB/SupabaseConfig.swift", "r") as f:
    config = f.read()

projectURL = re.search(r'static let projectURL = "(.*?)"', config).group(1)
anonKey = re.search(r'static let anonKey = "(.*?)"', config).group(1)

# Function to check database stats
def check_stats():
    # Check for rows that still need backfilling
    url_unprocessed = f"{projectURL}/rest/v1/news_cards?select=id&or=%28category.is.null%2Ccategory.cs.%7Bopen%20source%7D%2Ccategory.cs.%7BOpen%20Source%7D%2Ccategory.cs.%7BMisc%7D%2Cai_summary.is.null%29"
    req_unprocessed = urllib.request.Request(url_unprocessed, headers={'apikey': anonKey, 'Authorization': f'Bearer {anonKey}'})
    
    # Check for rows that have been successfully backfilled with a new category
    url_processed = f"{projectURL}/rest/v1/news_cards?select=category&category=cs.%7BTechnology%7D"
    req_processed = urllib.request.Request(url_processed, headers={'apikey': anonKey, 'Authorization': f'Bearer {anonKey}', 'Range-Unit': 'items', 'Range': '0-0', 'Prefer': 'count=exact'})

    try:
        with urllib.request.urlopen(req_unprocessed, context=ctx) as res_unproc:
            unprocessed = json.loads(res_unproc.read().decode())
            print(f"Rows waiting to be backfilled: {len(unprocessed)}")
            
        with urllib.request.urlopen(req_processed, context=ctx) as res_proc:
            # We just need the count from the headers
            count = res_proc.headers.get('Content-Range', '').split('/')[-1]
            print(f"Total rows correctly given a category: {count}")
    except Exception as e:
        print("Error checking database:", e)

print("Current Database Status:")
check_stats()

import urllib.request
import json
import ssl
import time

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

# --- CONFIGURATION ---
SUPABASE_URL = ""
SUPABASE_SERVICE_ROLE_KEY = ""

GROQ_API_KEY = ""
GROQ_API_URL = ""

 

def fetch_uncategorized_news():
    # Fetch 20 rows that have no category, newest first, or are tagged Technology/Open Source
    url = f"{SUPABASE_URL}/rest/v1/news_cards?select=id,title,description&limit=20&order=published_date.desc&or=%28category.is.null%2Ccategory.cs.%7Bopen%20source%7D%2Ccategory.cs.%7BOpen%20Source%7D%2Ccategory.cs.%7BMisc%7D%2Ccategory.cs.%7B%22Technology%22%7D%29"
    req = urllib.request.Request(url, headers={
        'apikey': SUPABASE_SERVICE_ROLE_KEY,
        'Authorization': f'Bearer {SUPABASE_SERVICE_ROLE_KEY}'
    })
    
    try:
        with urllib.request.urlopen(req, context=ctx) as res:
            return json.loads(res.read().decode())
    except Exception as e:
        print("Error fetching news:", e)
        if hasattr(e, 'read'):
            print(e.read().decode())
        return []

def get_categories_from_grok(title, description):
    payload = {
        "model": "llama-3.1-8b-instant",
        "messages": [
            {
                "role": "system",
                "content": "You are a specialized Tech & Software News classifier.\n1. Assign 1-3 specific, dynamic categories based on the article's actual topic. IMPORTANT: The categories MUST be strictly related to Technology, Software Engineering, IT, or Computer Science.\n2. Do NOT use non-tech categories like Politics, Entertainment, or Sports.\n3. Do NOT use generic terms like 'Technology' or 'News'. Be extremely specific (e.g. 'Cloud Computing', 'Hardware', 'Robotics', 'Startups', 'Cybersecurity').\n4. Return ONLY JSON: {\"categories\": [\"CategoryName\"]}"
            },
            {
                "role": "user",
                "content": f"Title: {title}\nDescription: {description}"
            }
        ],
        "response_format": {"type": "json_object"}
    }
    
    req = urllib.request.Request(GROQ_API_URL, method='POST', headers={
        'Content-Type': 'application/json',
        'Authorization': f'Bearer {GROQ_API_KEY}',
        'User-Agent': 'Insider/1.0 (com.yourdomain.Insider; build:1; iOS 16.0.0) Alamofire/5.6.1'
    }, data=json.dumps(payload).encode('utf-8'))
    
    try:
        with urllib.request.urlopen(req, context=ctx) as res:
            data = json.loads(res.read().decode())
            content = data['choices'][0]['message']['content']
            result_json = json.loads(content)
            
            # Accept dynamic categories directly
            dynamic_categories = result_json.get('categories', [])
            return dynamic_categories if dynamic_categories else None
    except Exception as e:
        err_msg = str(e)
        if hasattr(e, 'code') and e.code == 429:
            print(f"Rate limited by Groq API (429)! Skipping '{title[:20]}...' to avoid polluting data.")
            return None
        print(f"Error calling Grok for '{title}':", e)
        return None

def update_category_in_supabase(item_id, categories):
    url = f"{SUPABASE_URL}/rest/v1/news_cards?id=eq.{item_id}"
    payload = {"category": categories}
    
    req = urllib.request.Request(url, method='PATCH', headers={
        'apikey': SUPABASE_SERVICE_ROLE_KEY,
        'Authorization': f'Bearer {SUPABASE_SERVICE_ROLE_KEY}',
        'Content-Type': 'application/json',
        'Prefer': 'return=minimal'
    }, data=json.dumps(payload).encode('utf-8'))
    
    try:
        with urllib.request.urlopen(req, context=ctx) as res:
            return True
    except Exception as e:
        print(f"Error updating item {item_id}:", e)
        if hasattr(e, 'read'):
            print(e.read().decode())
        return False

def main():
    print("Starting Category Backfiller...")
    
    if SUPABASE_SERVICE_ROLE_KEY == "YOUR_SUPABASE_SERVICE_ROLE_KEY_HERE":
        print("\nERROR: You must paste your service_role_key at the top of this script first!")
        return

    while True:
        items = fetch_uncategorized_news()
        if not items:
            print("No more uncategorized news found! Backfill complete. 🎉")
            break
            
        print(f"Processing batch of {len(items)} items...")
        
        for item in items:
            title = item.get('title', '')
            desc = item.get('description', '')
            item_id = item.get('id')
            
            categories = get_categories_from_grok(title, desc)
            if categories is None:
                # Rate limit hit, pause longer and skip so we don't save ["Technology"] over and over
                time.sleep(5)
                continue

            print(f" -> Categorized as {categories}: {title[:40]}...")
            
            success = update_category_in_supabase(item_id, categories)
            if not success:
                print(f"    Failed to update {item_id}")
                
            time.sleep(2.5) # Stronger delay so Groq API doesn't ratelimit and database breathes
            
        print("Batch complete. Waiting 2 seconds before next batch...")
        time.sleep(2)

if __name__ == "__main__":
    main()

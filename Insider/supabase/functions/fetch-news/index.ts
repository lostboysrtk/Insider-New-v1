






import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const GROK_API_KEY = ''
const GROK_API_URL = ''
const NEWSDATA_API_KEY = ''

 

async function processArticleAI(title: string, description: string): Promise<{summary: string, categories: string[]}> {
  try {
    const response = await fetch(GROK_API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${GROK_API_KEY}`
      },
      body: JSON.stringify({
        model: 'llama-3.1-8b-instant',
        messages: [
          {
            role: 'system',
            content: `You are a specialized Tech & Software News classifier. 
            1. Summarize in 2 sentences.
            2. Assign 1-3 specific, dynamic categories based on the content. IMPORTANT: Categories MUST be strictly related to Technology, Software Engineering, IT, or Computer Science (e.g., 'Cloud Computing', 'Hardware', 'Robotics', 'Startups', 'Programming', 'Cybersecurity').
            3. Do NOT use non-tech categories like Politics, Entertainment, or Sports.
            4. Return ONLY JSON: {"summary": "...", "categories": ["CategoryName"]}`
          },
          { role: 'user', content: `Title: ${title}\nDescription: ${description}` }
        ],
        response_format: { type: "json_object" }
      })
    })
    const data = await response.json();
    const result = JSON.parse(data.choices[0]?.message?.content);
    const validCategories = result.categories;
    return { summary: result.summary || description, categories: validCategories && validCategories.length > 0 ? validCategories : ['Technology'] };
  } catch (error) {
    return { summary: description, categories: ['Technology'] };
  }
}

async function updateExistingData(supabase: any) {
  // Catch null arrays, arrays with just "Open Source" or "open source", and null ai_summary
  const { data: items } = await supabase.from('news_cards').select('id, title, description')
    .or('category.is.null,category.cs.{"open source"},category.cs.{"Open Source"},category.cs.{"Misc"},ai_summary.is.null')
    .limit(20);
  if (!items) return;
  for (const item of items) {
    const aiData = await processArticleAI(item.title, item.description);
    await supabase.from('news_cards').update({ ai_summary: aiData.summary, category: aiData.categories }).eq('id', item.id);
    await new Promise(r => setTimeout(r, 400));
  }
}

async function fetchAndSaveNewNews(supabase: any) {
  const response = await fetch(`https://newsdata.io/api/1/latest?apikey=${NEWSDATA_API_KEY}&language=en&category=technology&image=1&video=0&removeduplicate=1`);
  const data = await response.json();
  if (!data.results) return { saved: 0 };
  const newsItems = [];
  for (const item of data.results) {
    if (!item.image_url) continue;
    const aiData = await processArticleAI(item.title, item.description || "");
    newsItems.push({
      title: item.title, description: item.description || "", ai_summary: aiData.summary,
      category: aiData.categories, image_url: item.image_url, article_url: item.link,
      source: item.source_id || "Unknown", tags: aiData.categories,
      published_date: item.pubDate ? new Date(item.pubDate).toISOString() : new Date().toISOString()
    });
  }
  const { data: saved } = await supabase.from('news_cards').upsert(newsItems, { onConflict: 'article_url' }).select();
  return { saved: saved?.length || 0 };
}

Deno.serve(async (req) => {
  const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
  await updateExistingData(supabase);
  const result = await fetchAndSaveNewNews(supabase);
  return new Response(JSON.stringify(result), { headers: { "Content-Type": "application/json" } });
})

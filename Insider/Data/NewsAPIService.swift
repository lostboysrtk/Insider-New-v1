import Foundation

// 1. Define Categories
enum NewsCategory: String {
    case daily = "daily"
    case feed = "feed"
    case swift = "swift"
    case web = "web"
}

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The API request URL was malformed."
        case .noData: return "No readable data was received from the server."
        case .decodingError(let error): return "Failed to process data: \(error.localizedDescription)"
        case .apiError(let message): return message
        }
    }
}

class NewsAPIService {
    
    static let shared = NewsAPIService()
    private init() {}
    
    private let apiKey = ""
    private let baseURL = "https://newsdata.io/api/1/news"
    private let cacheDuration: TimeInterval = 1800
    
    // Auto-save toggle - ensures data goes to Supabase automatically
    var autoSaveToDatabase: Bool = true
    
    func fetchNews(for category: NewsCategory, completion: @escaping (Result<[NewsItem], NetworkError>) -> Void) {
        let dataKey = "newsCache_data_\(category.rawValue)"
        let timeKey = "newsCache_time_\(category.rawValue)"
        
        // 1. CHECK CACHE
        if let cachedData = UserDefaults.standard.data(forKey: dataKey),
           let lastFetch = UserDefaults.standard.object(forKey: timeKey) as? Date {
            let timeDiff = Date().timeIntervalSince(lastFetch)
            if timeDiff < cacheDuration {
                self.processData(cachedData, category: category, isDaily: (category == .daily), completion: completion)
                return
            }
        }
        
        // 2. API REQUEST
        var searchKeywords: [String] = []
        switch category {
        case .daily: searchKeywords = ["technology", "ai", "apple", "google", "startup"]
        case .feed: searchKeywords = ["coding", "developer", "software", "engineering", "tech"]
        case .swift: searchKeywords = ["swift", "ios", "xcode", "apple", "iphone"]
        case .web: searchKeywords = ["javascript", "react", "web", "frontend", "backend"]
        }
        
        let query = searchKeywords.joined(separator: " OR ")
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let urlString = "\(baseURL)?apikey=\(apiKey)&language=en&category=technology&q=\(encodedQuery)&image=1"
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(.apiError(error.localizedDescription)))
                return
            }
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            UserDefaults.standard.set(data, forKey: dataKey)
            UserDefaults.standard.set(Date(), forKey: timeKey)
            self?.processData(data, category: category, isDaily: (category == .daily), completion: completion)
        }.resume()
    }
    
    private func processData(_ data: Data, category: NewsCategory, isDaily: Bool, completion: @escaping (Result<[NewsItem], NetworkError>) -> Void) {
        do {
            let apiResponse = try JSONDecoder().decode(NewsAPIResponse.self, from: data)
            let filteredItems = apiResponse.results
                .compactMap { $0 }
                .filter { $0.image_url != nil } // Filter items with images
                .map { NewsItem(from: $0) }
            
            let finalItems = isDaily ? Array(filteredItems.prefix(10)) : filteredItems
            
            if finalItems.isEmpty {
                completion(.failure(.apiError("No relevant news found.")))
            } else {
                // AUTOMATICALLY SAVE TO DATABASE
                if self.autoSaveToDatabase {
                    self.categorizeAndSaveToDatabase(newsItems: finalItems, category: category)
                }
                completion(.success(finalItems))
            }
        } catch {
            completion(.failure(.decodingError(error)))
        }
    }
    
    private func categorizeAndSaveToDatabase(newsItems: [NewsItem], category: NewsCategory) {
        let group = DispatchGroup()
        var categorizedItems = newsItems
        
        for i in 0..<categorizedItems.count {
            group.enter()
            fetchCategoriesFromGrok(for: categorizedItems[i]) { categories in
                if let categories = categories {
                    categorizedItems[i].category = categories
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            NewsPersistenceManager.shared.saveNewsCards(categorizedItems) { result in
                switch result {
                case .success(let savedCards):
                    print("✅ [AUTO-SAVE SUCCESS] Saved \(savedCards.count) categorized items.")
                case .failure(let error):
                    print("⚠️ [AUTO-SAVE FAILED] \(error.localizedDescription)")
                }
            }
        }
    }
    
    private let grokAPIKey = ""
    
    private func fetchCategoriesFromGrok(for item: NewsItem, completion: @escaping ([String]?) -> Void) {
        let prompt = """
        Analyze this news article and categorize it. Provide ONLY a comma-separated list of the 1 to 3 most relevant categories (e.g., Swift, AI, ML, Python, Data Science, Web, Cybersecurity, DevOps).
        Title: \(item.title)
        Description: \(item.description)
        """
        
        guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else {
            completion(nil); return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(grokAPIKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonBody: [String: Any] = [
            "model": "llama-3.1-8b-instant",
            "messages": [
                ["role": "system", "content": "You are a news classifier. Output only a comma-separated list of technology categories. No other text."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.1,
            "max_tokens": 15
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: jsonBody)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if error != nil {
                completion(nil)
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let content = choices.first?["message"] as? [String: Any],
                  let text = content["content"] as? String else {
                completion(nil)
                return
            }
            
            let categories = text.components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            
            completion(categories.isEmpty ? nil : categories)
        }.resume()
    }
}

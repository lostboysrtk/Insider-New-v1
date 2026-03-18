//
//  AudioNewsAPIService.swift
//  Insider
//
//  Fixed to match actual NewsData.io API response structure
//

import Foundation
import UIKit

// MARK: - API Response Models (Matching Actual API Structure)
struct AudioNewsAPIResponse: Codable {
    let status: String
    let totalResults: Int?
    let results: [AudioNewsResult]?
}

struct AudioNewsResult: Codable {
    let article_id: String?
    let title: String?
    let link: String?
    let keywords: [String]?
    let creator: [String]?
    let video_url: String?
    let description: String?
    let content: String?
    let pubDate: String?
    let pubDateTZ: String?
    let image_url: String?
    let source_id: String?
    let source_priority: Int?
    let source_name: String?
    let source_url: String?
    let source_icon: String?
    let language: String?
    let country: [String]?
    let category: [String]?
    let ai_tag: String?
    let sentiment: String?
    let sentiment_stats: String?
    let ai_region: String?
    let ai_org: String?
    let duplicate: Bool?
}

// MARK: - Audio News Service
class AudioNewsAPIService {
    
    static let shared = AudioNewsAPIService()
    private init() {}
    
    private let apiKey = "pub_31bd30d00c0e4867b23f2fe29d79e55d"
    private let baseURL = "https://newsdata.io/api/1/news"
    
    // Cache Settings (30 minutes)
    private let cacheDuration: TimeInterval = 1800
    
    // MARK: - Article Content Cache
    private var articleContentCache: [String: String] = [:]
    
    enum AudioCategory {
        case breakingNews
        case swiftUI
        case pythonDS
        case nodeJS
        case docker
        case awsCloud
        case kubernetes
        
        var searchQuery: String {
            switch self {
            case .breakingNews:
                return "artificial intelligence OR machine learning OR tech breakthrough"
            case .swiftUI:
                return "swift OR swiftui OR ios development"
            case .pythonDS:
                return "python data science OR pandas OR machine learning"
            case .nodeJS:
                return "nodejs OR javascript backend"
            case .docker:
                return "docker OR container"
            case .awsCloud:
                return "aws OR amazon web services OR cloud"
            case .kubernetes:
                return "kubernetes OR k8s"
            }
        }
        
        var cacheKey: String {
            switch self {
            case .breakingNews: return "audio_breaking"
            case .swiftUI: return "audio_swift"
            case .pythonDS: return "audio_python"
            case .nodeJS: return "audio_node"
            case .docker: return "audio_docker"
            case .awsCloud: return "audio_aws"
            case .kubernetes: return "audio_k8s"
            }
        }
    }
    
    // MARK: - Fetch Breaking News
    func fetchBreakingNews(completion: @escaping (Result<[BreakingNewsItem], Error>) -> Void) {
        fetchNews(for: .breakingNews) { result in
            switch result {
            case .success(let items):
                // Cache article content
                for item in items {
                    if let title = item.title {
                        let fullContent = self.buildFullContent(from: item)
                        self.cacheArticleContent(fullContent, forTitle: title)
                    }
                }
                
                let breaking = items.prefix(4).map { item in
                    BreakingNewsItem(
                        category: self.categorizeContent(item.title ?? "", keywords: item.keywords),
                        headline: item.title ?? "Tech News",
                        source: item.source_name ?? "Tech Source",
                        imageUrl: item.image_url
                    )
                }
                completion(.success(Array(breaking)))
                
            case .failure(let error):
                print("❌ Breaking News Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Fetch Technical Briefs (All Categories)
    func fetchAllTechnicalBriefs(completion: @escaping (Result<[TopChoiceItem], Error>) -> Void) {
        let group = DispatchGroup()
        var allBriefs: [TopChoiceItem] = []
        var fetchError: Error?
        
        let categories: [AudioCategory] = [.swiftUI, .pythonDS, .nodeJS, .docker, .awsCloud, .kubernetes]
        
        for category in categories {
            group.enter()
            fetchNews(for: category) { result in
                switch result {
                case .success(let items):
                    // Cache full content
                    for item in items {
                        if let title = item.title {
                            let fullContent = self.buildFullContent(from: item)
                            self.cacheArticleContent(fullContent, forTitle: title)
                        }
                    }
                    
                    let briefs = items.prefix(3).map { item in
                        TopChoiceItem(
                            title: item.title ?? "Technical Update",
                            date: self.formatDate(item.pubDate),
                            summary: item.description ?? "Latest developments in technology.",
                            category: self.getCategoryName(category),
                            imageUrl: item.image_url,
                            publishedDate: self.parseDate(item.pubDate)
                        )
                    }
                    allBriefs.append(contentsOf: briefs)
                    
                case .failure(let error):
                    print("❌ Category \(category.cacheKey) Error: \(error.localizedDescription)")
                    fetchError = error
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if let error = fetchError, allBriefs.isEmpty {
                completion(.failure(error))
            } else {
                let sorted = allBriefs.sorted { brief1, brief2 in
                    self.compareDates(brief1.date, brief2.date)
                }
                print("✅ Loaded \(sorted.count) technical briefs")
                completion(.success(sorted))
            }
        }
    }
    
    // MARK: - Fetch Filtered Briefs for Toolkit
    func fetchFilteredBriefs(for toolkitName: String, completion: @escaping (Result<[TopChoiceItem], Error>) -> Void) {
        let category = mapToolkitToCategory(toolkitName)
        
        fetchNews(for: category) { result in
            switch result {
            case .success(let items):
                // Cache full content
                for item in items {
                    if let title = item.title {
                        let fullContent = self.buildFullContent(from: item)
                        self.cacheArticleContent(fullContent, forTitle: title)
                    }
                }
                
                let briefs = items.map { item in
                    TopChoiceItem(
                        title: item.title ?? "Technical Update",
                        date: self.formatDate(item.pubDate),
                        summary: item.description ?? "Latest developments.",
                        category: toolkitName,
                        imageUrl: item.image_url,
                        publishedDate: self.parseDate(item.pubDate)
                    )
                }
                completion(.success(briefs))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Core Fetch Method
    private func fetchNews(for category: AudioCategory, completion: @escaping (Result<[AudioNewsResult], Error>) -> Void) {
        
        let dataKey = "newsCache_data_\(category.cacheKey)"
        let timeKey = "newsCache_time_\(category.cacheKey)"
        
        // Check Cache
        if let cachedData = UserDefaults.standard.data(forKey: dataKey),
           let lastFetch = UserDefaults.standard.object(forKey: timeKey) as? Date {
            
            let timeDiff = Date().timeIntervalSince(lastFetch)
            
            if timeDiff < cacheDuration {
                print("📦 [CACHE HIT] \(category.cacheKey)")
                self.processData(cachedData, category: category, completion: completion)
                return
            }
        }
        
        // Build API URL
        guard let encodedQuery = category.searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let urlString = "\(baseURL)?apikey=\(apiKey)&language=en&category=technology&q=\(encodedQuery)&image=1"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        print("🔄 [API CALL] \(category.cacheKey)...")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("❌ Network Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                completion(.failure(NetworkError.noData))
                return
            }
            
            // Save to Cache
            UserDefaults.standard.set(data, forKey: dataKey)
            UserDefaults.standard.set(Date(), forKey: timeKey)
            
            self?.processData(data, category: category, completion: completion)
            
        }.resume()
    }
    
    private func processData(_ data: Data, category: AudioCategory, completion: @escaping (Result<[AudioNewsResult], Error>) -> Void) {
        do {
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(AudioNewsAPIResponse.self, from: data)
            
            print("📊 Status: \(apiResponse.status), Total: \(apiResponse.totalResults ?? 0)")
            
            guard let results = apiResponse.results, !results.isEmpty else {
                print("⚠️ No results in response")
                completion(.failure(NetworkError.noData))
                return
            }
            
            // Filter for quality content
            let filtered = results.filter { result in
                guard let title = result.title,
                      let description = result.description else {
                    return false
                }
                return description.count > 50 && title.count > 10
            }
            
            print("✅ \(category.cacheKey): \(filtered.count)/\(results.count) articles")
            
            if filtered.isEmpty {
                completion(.failure(NetworkError.apiError("No quality articles found")))
            } else {
                completion(.success(filtered))
            }
            
        } catch let DecodingError.keyNotFound(key, context) {
            print("❌ Missing key: \(key.stringValue)")
            print("   Context: \(context.debugDescription)")
            completion(.failure(NetworkError.decodingError(DecodingError.keyNotFound(key, context))))
            
        } catch let DecodingError.typeMismatch(type, context) {
            print("❌ Type mismatch: \(type)")
            print("   Context: \(context.debugDescription)")
            completion(.failure(NetworkError.decodingError(DecodingError.typeMismatch(type, context))))
            
        } catch {
            print("❌ Decoding Error: \(error)")
            completion(.failure(NetworkError.decodingError(error)))
        }
    }
    
    // MARK: - Build Full Content from API Result
    private func buildFullContent(from item: AudioNewsResult) -> String {
        var content = ""
        
        // Title
        if let title = item.title {
            content += "\(title)\n\n"
        }
        
        // Metadata - REMOVED (User request: remove Published date and source)
        /*
        if let source = item.source_name, let date = item.pubDate {
            content += "Published by \(source) on \(formatDate(date))\n\n"
        }
        */
        
        // Main Content (from API 'content' field)
        if let apiContent = item.content, !apiContent.isEmpty && apiContent.count > 100 {
            content += apiContent
        } else if let description = item.description, !description.isEmpty {
            // Fallback to description if content is missing
            content += description
            
            // Add some context
            content += "\n\nThis article discusses recent developments in technology. "
            
            if let keywords = item.keywords, !keywords.isEmpty {
                content += "Key topics include: \(keywords.prefix(5).joined(separator: ", "))."
            }
        } else {
            content += "Article content is being retrieved from the source.\n"
        }
        
        // Add link - REMOVED (User request: remove source link)
        /*
        if let link = item.link {
            content += "\n\nRead the full article at: \(link)"
        }
        */
        
        return content
    }
    
    // MARK: - Article Content Management
    
    func cacheArticleContent(_ content: String, forTitle title: String) {
        articleContentCache[title] = content
        print("💾 Cached: \(title) (\(content.count) chars)")
    }
    
    func getArticleContent(forTitle title: String, withDescription description: String?, andSource source: String?) -> String {
        // Check cache first
        if let cached = articleContentCache[title], cached.count > 200 {
            print("📖 Using cached content for: \(title)")
            return cached
        }
        
        // Build from description
        if let description = description, !description.isEmpty {
            return formatArticleFromDescription(title: title, description: description, source: source)
        }
        
        // Last resort
        return generateBasicContent(title: title, source: source)
    }
    
    private func formatArticleFromDescription(title: String, description: String, source: String?) -> String {
        let sourceName = source ?? "Tech News"
        let date = DateFormatter.audioDateFormatter.string(from: Date())
        
        return """
        \(title)
        
        \(description)
        
        This update represents the latest developments in technology. The article provides insights into current trends and innovations shaping the industry.
        
        For more detailed information and analysis, this story continues to develop as new information becomes available.
        """
    }
    
    private func generateBasicContent(title: String, source: String?) -> String {
        let sourceName = source ?? "Tech News"
        
        return """
        \(title)
        
        This is a developing story with more details expected soon. The article is being updated as new information becomes available.
        
        Stay tuned for the complete coverage of this important development in technology.
        """
    }
    
    // MARK: - Helper Methods
    
    private func categorizeContent(_ title: String, keywords: [String]?) -> String {
        let content = title.lowercased()
        
        if content.contains("ai") || content.contains("artificial intelligence") {
            return "Artificial Intelligence"
        } else if content.contains("web") || content.contains("javascript") {
            return "Web Development"
        } else if content.contains("mobile") || content.contains("ios") {
            return "Mobile Engineering"
        } else if content.contains("security") || content.contains("cyber") {
            return "Cybersecurity"
        } else if content.contains("cloud") || content.contains("aws") {
            return "Cloud Computing"
        }
        
        return "Technology"
    }
    
    private func formatDate(_ dateString: String?) -> String {
        guard let dateString = dateString else {
            return DateFormatter.audioDateFormatter.string(from: Date())
        }
        
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: dateString) {
            return DateFormatter.audioDateFormatter.string(from: date)
        }
        
        return DateFormatter.audioDateFormatter.string(from: Date())
    }
    
    private func compareDates(_ date1: String, _ date2: String) -> Bool {
        let formatter = DateFormatter.audioDateFormatter
        if let d1 = formatter.date(from: date1),
           let d2 = formatter.date(from: date2) {
            return d1 > d2
        }
        return false
    }
    
    private func getCategoryName(_ category: AudioCategory) -> String {
        switch category {
        case .breakingNews: return "Breaking"
        case .swiftUI: return "SwiftUI"
        case .pythonDS: return "Python DS"
        case .nodeJS: return "Node.js"
        case .docker: return "Docker"
        case .awsCloud: return "AWS Cloud"
        case .kubernetes: return "Kubernetes"
        }
    }
    
    private func mapToolkitToCategory(_ toolkitName: String) -> AudioCategory {
        switch toolkitName.lowercased() {
        case "swiftui": return .swiftUI
        case "python ds": return .pythonDS
        case "node.js": return .nodeJS
        case "docker": return .docker
        case "aws cloud": return .awsCloud
        case "kubernetes": return .kubernetes
        default: return .breakingNews
        }
    }
    
    // Added helper method parseDate(_:)
    private func parseDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString else {
            return nil
        }
        
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: dateString) {
            return date
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yy"
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        return nil
    }
}

// MARK: - Date Formatter Extension
extension DateFormatter {
    static let audioDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yy"
        return formatter
    }()
}

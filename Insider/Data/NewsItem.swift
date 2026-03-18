import UIKit
import Foundation

// MARK: - 1. API Response Models
struct APINewsResult: Decodable {
    let title: String?
    let description: String?
    let link: String?
    let image_url: String?
    let source_id: String?
    let pubDate: String?
    let category: [String]?
}

struct NewsAPIResponse: Decodable {
    let status: String
    let totalResults: Int?
    let results: [APINewsResult]
}

// MARK: - 2. Discussion & Interaction Models
enum VoteStatus {
    case none, upvoted, downvoted
}

/*struct Comment {
    var userName: String
    var text: String
    var timeAgo: String
    var likes: Int
    var profileColor: UIColor
    var isReply: Bool
    var commentId: UUID = UUID()
    
    // Threading Logic
    var replies: [Comment] = []
    var parentCommentId: UUID?
    var level: Int = 0
    var isExpanded: Bool = false
    var isLoadMoreButton: Bool = false

    // Interactive States
    var isLiked: Bool = false
    var isDisliked: Bool = false
    var voteStatus: VoteStatus = .none
}*/

struct ReplyData {
    let articleTitle: String
    let myOriginalComment: String
    var repliesToMe: [Comment] = []
    var isExpanded: Bool = false
    
    var replyAuthor: String = ""
    var replyText: String = ""
    var timeAgo: String = ""
    var color: UIColor = .systemBlue
}

// MARK: - 3. Main NewsItem Model
struct NewsItem {
    var id: String? // Added to track backend IDs natively
    let title: String
    let description: String
    let imageURL: String?
    let source: String
    let likes: String
    let dislikes: String
    let comments: String
    let userName: String
    let timeAgo: String
    let profileColor: UIColor
    let tags: [String]
    let discussions: String
    let bookmarks: String
    
    let codeSnippet: String?
    let snippetLanguage: String?
    
    // NEW: Expose the article URL used by CardTableViewCell/WebViewController
    let articleURL: String?
    
    // NEW: Grok AI assigned category
    var category: [String]?
    
    // Mutable properties for filtering
    var isStartedByCurrentUser: Bool
    var isJoinedByCurrentUser: Bool

    var discussionQuestion: String {
        switch self.title {
        case "18 New Enhancements Powering AI, Security, and Performance With 8-Year Long Term Support":
            return "Will the new AI capabilities shift how Java is used in the ML/AI space, or does Python still dominate?"
        case "Apple Announces New M5 Pro and M5 Max Chips":
            return "Will this reshape the laptop market, or is it just incremental progress?"
        default:
            return "How will this development impact the current industry standards and developer workflows?"
        }
    }

    init(from apiResult: APINewsResult) {
        self.title = apiResult.title ?? "Untitled News"
        self.description = (apiResult.description ?? "No summary available.")
            .replacingOccurrences(of: ">", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        self.imageURL = apiResult.image_url
        self.source = apiResult.source_id ?? "Source"
        self.likes = "0"
        self.dislikes = "0"
        self.comments = "0"
        self.discussions = "3"
        self.bookmarks = "0"
        self.userName = apiResult.source_id?.capitalized ?? "Insider User"
        self.timeAgo = "Just now"
        self.tags = apiResult.category ?? ["Technology"]
        self.codeSnippet = nil
        self.snippetLanguage = nil
        
        // Map link from API to articleURL
        self.articleURL = apiResult.link
        self.category = nil
        
        // Default values
        self.isStartedByCurrentUser = false
        self.isJoinedByCurrentUser = false
        
        let colorHash = abs((apiResult.source_id ?? "").hashValue) % 5
        self.profileColor = [.systemBlue, .systemRed, .systemGreen, .systemPurple, .systemOrange][colorHash]
    }
}

// MARK: - 4. Networking Service
/*class NewsAPIService {
    static let shared = NewsAPIService()
    private let apiKey = "pub_c8121a77a29d4343aa0ecc905c922886"
    private let baseURL = "https://newsdata.io/api/1/news"
    
    private init() {}

    func fetchNews(for domains: [String], completion: @escaping (Result<[NewsItem], Error>) -> Void) {
        let urlString = "\(baseURL)?apikey=\(apiKey)&language=en&category=technology&image=1"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }
            
            do {
                let response = try JSONDecoder().decode(NewsAPIResponse.self, from: data)
                let items = response.results.map { NewsItem(from: $0) }
                completion(.success(items))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}*/

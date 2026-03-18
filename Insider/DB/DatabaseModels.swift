// DatabaseModels.swift
// Database models for Supabase integration

import Foundation
import UIKit

// MARK: - News Card Database Model

/// Represents a news card stored in Supabase
struct NewsCardDB: Codable {
    let id: String?
    let title: String
    let description: String
    let imageURL: String?
    let articleURL: String?
    let source: String
    let userName: String
    let profileColor: String // Store as hex string
    let tags: [String]
    let codeSnippet: String?
    let snippetLanguage: String?
    let publishedDate: Date?
    let category: [String]?
    let createdAt: Date?
    let updatedAt: Date?
    
    // Interaction counters (managed by triggers/functions in Supabase)
    let likesCount: Int?
    let dislikesCount: Int?
    let commentsCount: Int?
    let discussionsCount: Int?
    let bookmarksCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case imageURL = "image_url"
        case articleURL = "article_url"
        case source
        case userName = "user_name"
        case profileColor = "profile_color"
        case tags
        case codeSnippet = "code_snippet"
        case snippetLanguage = "snippet_language"
        case publishedDate = "published_date"
        case category
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case likesCount = "likes_count"
        case dislikesCount = "dislikes_count"
        case commentsCount = "comments_count"
        case discussionsCount = "discussions_count"
        case bookmarksCount = "bookmarks_count"
    }
    
    /// Convert from NewsItem to database model
    init(from newsItem: NewsItem) {
        self.id = nil
        self.title = newsItem.title
        self.description = newsItem.description
        self.imageURL = newsItem.imageURL
        self.articleURL = newsItem.articleURL
        self.source = newsItem.source
        self.userName = newsItem.userName
        self.profileColor = newsItem.profileColor.toHex() ?? "#007AFF"
        self.tags = newsItem.tags
        self.codeSnippet = newsItem.codeSnippet
        self.snippetLanguage = newsItem.snippetLanguage
        
        // Set a valid date object that the .iso8601 strategy can now encode
        self.publishedDate = Date()
        self.category = newsItem.category
        
        self.createdAt = nil
        self.updatedAt = nil
        
        self.likesCount = Int(newsItem.likes) ?? 0
        self.dislikesCount = Int(newsItem.dislikes) ?? 0
        self.commentsCount = Int(newsItem.comments) ?? 0
        self.discussionsCount = Int(newsItem.discussions) ?? 0
        self.bookmarksCount = Int(newsItem.bookmarks) ?? 0
    }
    
    /// Convert from database model to NewsItem
    func toNewsItem() -> NewsItem {
        let displayDescription = self.description
        
        var item = NewsItem(
            title: self.title,
            description: displayDescription,
            imageURL: self.imageURL,
            source: self.source,
            likes: "\(self.likesCount ?? 0)",
            dislikes: "\(self.dislikesCount ?? 0)",
            comments: "\(self.commentsCount ?? 0)",
            userName: self.userName,
            timeAgo: self.publishedDate?.timeAgoDisplay() ?? "Just now",
            profileColor: UIColor(hex: self.profileColor) ?? .systemBlue,
            tags: self.tags,
            discussions: "\(self.discussionsCount ?? 0)",
            bookmarks: "\(self.bookmarksCount ?? 0)",
            codeSnippet: self.codeSnippet,
            snippetLanguage: self.snippetLanguage,
            articleURL: self.articleURL,
            category: self.category,
            isStartedByCurrentUser: false,
            isJoinedByCurrentUser: false
        )
        item.id = self.id
        return item
    }
}

// MARK: - User Interaction Model

/// Represents user interactions with news cards
struct UserInteractionDB: Codable {
    let id: String?
    let userId: String // Device ID or user ID
    let newsCardId: String
    let interactionType: String // "like", "dislike", "bookmark", "comment", "discussion"
    let isActive: Bool
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case newsCardId = "news_card_id"
        case interactionType = "interaction_type"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Dedicated Saved Post Model

/// Represents a record in the dedicated saved_posts table
struct SavedPostDB: Codable {
    let id: String?
    let userId: String
    let newsCardId: String
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case newsCardId = "news_card_id"
        case createdAt = "created_at"
    }
}

// MARK: - Discussion Model

/// Represents a discussion thread
struct DiscussionDB: Codable {
    let id: String?
    let newsCardId: String
    let userId: String
    let userName: String
    let userProfileColor: String
    let question: String
    let participantsCount: Int?
    let messagesCount: Int?
    let isActive: Bool
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case newsCardId = "news_card_id"
        case userId = "user_id"
        case userName = "user_name"
        case userProfileColor = "user_profile_color"
        case question
        case participantsCount = "participants_count"
        case messagesCount = "messages_count"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Comment Model

/// Represents a comment on a news card
struct CommentDB: Codable {
    let id: String?
    let newsCardId: String
    let userId: String
    let userName: String
    let userProfileColor: String
    let text: String
    let parentCommentId: String? // For replies
    let level: Int
    let likesCount: Int?
    let isEdited: Bool
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case newsCardId = "news_card_id"
        case userId = "user_id"
        case userName = "user_name"
        case userProfileColor = "user_profile_color"
        case text
        case parentCommentId = "parent_comment_id"
        case level
        case likesCount = "likes_count"
        case isEdited = "is_edited"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Helper Extensions

extension UIColor {
    /// Convert UIColor to hex string
    func toHex() -> String? {
        guard let components = self.cgColor.components else { return nil }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
    
    /// Create UIColor from hex string
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}

extension Date {
    /// Convert date to "time ago" display string
    func timeAgoDisplay() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute], from: self, to: now)
        
        if let year = components.year, year >= 1 {
            return year == 1 ? "1 year ago" : "\(year) years ago"
        }
        
        if let month = components.month, month >= 1 {
            return month == 1 ? "1 month ago" : "\(month) months ago"
        }
        
        if let week = components.weekOfYear, week >= 1 {
            return week == 1 ? "1 week ago" : "\(week) weeks ago"
        }
        
        if let day = components.day, day >= 1 {
            return day == 1 ? "1 day ago" : "\(day) days ago"
        }
        
        if let hour = components.hour, hour >= 1 {
            return hour == 1 ? "1 hour ago" : "\(hour) hours ago"
        }
        
        if let minute = components.minute, minute >= 1 {
            return minute == 1 ? "1 minute ago" : "\(minute) minutes ago"
        }
        
        return "Just now"
    }
}

// MARK: - NewsItem Extension for Database

extension NewsItem {
    /// Initialize NewsItem with all parameters (for database conversion)
    init(
        title: String,
        description: String,
        imageURL: String?,
        source: String,
        likes: String,
        dislikes: String,
        comments: String,
        userName: String,
        timeAgo: String,
        profileColor: UIColor,
        tags: [String],
        discussions: String,
        bookmarks: String,
        codeSnippet: String?,
        snippetLanguage: String?,
        articleURL: String?,
        category: [String]?,
        isStartedByCurrentUser: Bool,
        isJoinedByCurrentUser: Bool
    ) {
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.source = source
        self.likes = likes
        self.dislikes = dislikes
        self.comments = comments
        self.userName = userName
        self.timeAgo = timeAgo
        self.profileColor = profileColor
        self.tags = tags
        self.discussions = discussions
        self.bookmarks = bookmarks
        self.codeSnippet = codeSnippet
        self.snippetLanguage = snippetLanguage
        self.articleURL = articleURL
        self.category = category
        self.isStartedByCurrentUser = isStartedByCurrentUser
        self.isJoinedByCurrentUser = isJoinedByCurrentUser
    }
}


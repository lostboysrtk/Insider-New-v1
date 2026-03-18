//
//  Audiodatabasemodels.swift
//  Insider
//
//  Created by Sarthak Sharma on 04/02/26.
//

// AudioDatabaseModels.swift
// Database models for Audio Briefs stored in Supabase

import Foundation
import UIKit

// MARK: - Audio Brief Database Model

/// Represents an audio brief stored in Supabase
struct AudioBriefDB: Codable {
    let id: String?
    let title: String
    let description: String
    let fullContent: String?
    let imageURL: String?
    let articleURL: String?
    let audioURL: String?
    let source: String
    let category: String
    let toolkitName: String?
    let tags: [String]
    let contentType: String // "breaking_news" or "technical_brief"
    let publishedDate: Date?
    let createdAt: Date?
    let updatedAt: Date?
    let playCount: Int?
    let likesCount: Int?
    let bookmarksCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case fullContent = "full_content"
        case imageURL = "image_url"
        case articleURL = "article_url"
        case audioURL = "audio_url"
        case source
        case category
        case toolkitName = "toolkit_name"
        case tags
        case contentType = "content_type"
        case publishedDate = "published_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case playCount = "play_count"
        case likesCount = "likes_count"
        case bookmarksCount = "bookmarks_count"
    }
    
    /// Initialize from API result
    init(from result: AudioNewsResult, category: String, contentType: String, fullContent: String? = nil) {
        self.id = nil
        self.title = result.title ?? "Untitled"
        self.description = result.description ?? ""
        self.fullContent = fullContent
        self.imageURL = result.image_url
        self.articleURL = result.link
        self.audioURL = nil
        self.source = result.source_name ?? result.source_id ?? "Unknown"
        self.category = category
        self.toolkitName = AudioBriefDB.mapCategoryToToolkit(category)
        self.tags = result.category ?? []
        self.contentType = contentType
        self.publishedDate = Self.parseDate(result.pubDate)
        self.createdAt = nil
        self.updatedAt = nil
        self.playCount = 0
        self.likesCount = 0
        self.bookmarksCount = 0
    }
    
    /// Convert from TopChoiceItem
    init(from item: TopChoiceItem, contentType: String, fullContent: String? = nil) {
        self.id = nil
        self.title = item.title
        self.description = item.summary
        self.fullContent = fullContent
        self.imageURL = item.imageUrl
        self.articleURL = nil
        self.audioURL = nil
        self.source = "Internal"
        self.category = item.category
        self.toolkitName = item.category
        self.tags = [item.category]
        self.contentType = contentType
        self.publishedDate = Self.parseDate(item.date)
        self.createdAt = nil
        self.updatedAt = nil
        self.playCount = 0
        self.likesCount = 0
        self.bookmarksCount = 0
    }
    
    /// Convert from BreakingNewsItem
    init(from item: BreakingNewsItem, fullContent: String? = nil) {
        self.id = nil
        self.title = item.headline
        self.description = item.headline // Breaking news uses headline as description
        self.fullContent = fullContent
        self.imageURL = item.imageUrl
        self.articleURL = nil
        self.audioURL = nil
        self.source = item.source
        self.category = item.category
        self.toolkitName = nil
        self.tags = [item.category]
        self.contentType = "breaking_news"
        self.publishedDate = Date()
        self.createdAt = nil
        self.updatedAt = nil
        self.playCount = 0
        self.likesCount = 0
        self.bookmarksCount = 0
    }
    
    /// Convert to TopChoiceItem for UI display
    func toTopChoiceItem() -> TopChoiceItem {
        return TopChoiceItem(
            title: self.title,
            date: formatDate(self.publishedDate ?? self.createdAt ?? Date()),
            summary: self.description,
            category: self.category,
            imageUrl: self.imageURL, publishedDate: self.publishedDate
        )
    }
    
    /// Convert to BreakingNewsItem for UI display
    func toBreakingNewsItem() -> BreakingNewsItem {
        return BreakingNewsItem(
            category: self.category,
            headline: self.title,
            source: self.source,
            imageUrl: self.imageURL
        )
    }
    
    // MARK: - Helper Methods
    
    private static func parseDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return Date() }
        
        // Try ISO8601 first
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: dateString) {
            return date
        }
        
        // Try custom format "dd MMM yy"
        let customFormatter = DateFormatter()
        customFormatter.dateFormat = "dd MMM yy"
        if let date = customFormatter.date(from: dateString) {
            return date
        }
        
        return Date()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yy"
        return formatter.string(from: date)
    }
    
    private static func mapCategoryToToolkit(_ category: String) -> String? {
        let categoryLower = category.lowercased()
        
        if categoryLower.contains("swift") || categoryLower.contains("ios") {
            return "SwiftUI"
        } else if categoryLower.contains("python") || categoryLower.contains("data") {
            return "Python DS"
        } else if categoryLower.contains("node") || categoryLower.contains("javascript") {
            return "Node.js"
        } else if categoryLower.contains("docker") || categoryLower.contains("container") {
            return "Docker"
        } else if categoryLower.contains("aws") || categoryLower.contains("cloud") {
            return "AWS Cloud"
        } else if categoryLower.contains("kubernetes") || categoryLower.contains("k8s") {
            return "Kubernetes"
        }
        
        return nil
    }
}

// MARK: - Helper Extensions

extension AudioBriefDB {
    /// Check if this brief was created today
    var isToday: Bool {
        guard let createdAt = self.createdAt else { return false }
        return Calendar.current.isDateInToday(createdAt)
    }
    
    /// Get a user-friendly time description
    var timeDescription: String {
        guard let date = self.publishedDate ?? self.createdAt else {
            return "Just now"
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            let components = calendar.dateComponents([.hour], from: date, to: now)
            if let hours = components.hour {
                if hours == 0 {
                    return "Just now"
                } else if hours == 1 {
                    return "1 hour ago"
                } else {
                    return "\(hours) hours ago"
                }
            }
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yy"
            return formatter.string(from: date)
        }
        
        return "Recently"
    }
}

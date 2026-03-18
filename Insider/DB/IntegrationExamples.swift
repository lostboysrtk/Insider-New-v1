// IntegrationExamples.swift
// Example usage of Supabase integration in your iOS app

import Foundation
import UIKit

// MARK: - Example 1: Save News Cards to Database

class ExampleSaveNewsCards {
    
    /// Example: Save news items fetched from API to Supabase
    func saveNewsItemsToDatabase(newsItems: [NewsItem]) {
        // Option 1: Save individually
        for newsItem in newsItems {
            NewsPersistenceManager.shared.saveNewsCard(newsItem) { result in
                switch result {
                case .success(let savedCard):
                    print("✅ Saved card: \(savedCard.title)")
                case .failure(let error):
                    print("❌ Error saving card: \(error.localizedDescription)")
                }
            }
        }
        
        // Option 2: Bulk save (more efficient)
        NewsPersistenceManager.shared.saveNewsCards(newsItems) { result in
            switch result {
            case .success(let savedCards):
                print("✅ Saved \(savedCards.count) cards to database")
            case .failure(let error):
                print("❌ Error saving cards: \(error.localizedDescription)")
            }
        }
    }
    
    /// Example: Integrate with your existing NewsAPIService
    func fetchAndSaveNews(for category: NewsCategory) {
        NewsAPIService.shared.fetchNews(for: category) { result in
            switch result {
            case .success(let newsItems):
                // Save to Supabase using the new Persistence Manager
                NewsPersistenceManager.shared.saveNewsCards(newsItems) { dbResult in
                    switch dbResult {
                    case .success(let savedCards):
                        print("✅ Fetched and saved \(savedCards.count) news items")
                    case .failure(let error):
                        print("⚠️ Saved to cache but DB save failed: \(error)")
                    }
                }
            case .failure(let error):
                print("❌ Error fetching news: \(error)")
            }
        }
    }
}

// MARK: - Example 2: Fetch News from Database

class ExampleFetchNews {
    
    func fetchAllNews() {
        NewsPersistenceManager.shared.fetchNewsCards(limit: 50, offset: 0) { result in
            switch result {
            case .success(let newsCardsDB):
                let newsItems = newsCardsDB.map { $0.toNewsItem() }
                print("📰 Fetched \(newsItems.count) news items")
                DispatchQueue.main.async { /* self.tableView.reloadData() */ }
            case .failure(let error):
                print("❌ Error fetching news: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchNewsByCategory(tag: String) {
        NewsPersistenceManager.shared.fetchNewsCards(byTag: tag, limit: 50) { result in
            if case .success(let newsCardsDB) = result {
                let newsItems = newsCardsDB.map { $0.toNewsItem() }
                print("📰 Fetched \(newsItems.count) items for tag: \(tag)")
            }
        }
    }
    
    func searchNews(query: String) {
        NewsPersistenceManager.shared.searchNewsCards(query: query, limit: 50) { result in
            if case .success(let newsCardsDB) = result {
                let newsItems = newsCardsDB.map { $0.toNewsItem() }
                print("🔍 Found \(newsItems.count) results for: \(query)")
            }
        }
    }
}

// MARK: - Example 3: Handle User Interactions

class ExampleUserInteractions {
    
    func handleLikeTap(newsCardId: String) {
        NewsPersistenceManager.shared.getUserInteraction(newsCardId: newsCardId, type: "like") { result in
            switch result {
            case .success(let existingInteraction):
                if let interaction = existingInteraction, interaction.isActive {
                    NewsPersistenceManager.shared.updateInteraction(newsCardId: newsCardId, type: "like", isActive: false) { _ in print("👎 Like removed") }
                } else if existingInteraction != nil {
                    NewsPersistenceManager.shared.updateInteraction(newsCardId: newsCardId, type: "like", isActive: true) { _ in print("👍 Like added") }
                } else {
                    NewsPersistenceManager.shared.recordInteraction(newsCardId: newsCardId, type: "like", isActive: true) { _ in print("👍 Like added") }
                }
            case .failure(let error):
                print("❌ Error: \(error.localizedDescription)")
            }
        }
    }
    
    func toggleBookmark(newsCardId: String) {
        NewsPersistenceManager.shared.getUserInteraction(newsCardId: newsCardId, type: "bookmark") { result in
            if case .success(let existing) = result {
                let newStatus = !(existing?.isActive ?? false)
                if existing != nil {
                    NewsPersistenceManager.shared.updateInteraction(newsCardId: newsCardId, type: "bookmark", isActive: newStatus) { _ in print(newStatus ? "🔖 Bookmarked" : "📑 Removed") }
                } else {
                    NewsPersistenceManager.shared.recordInteraction(newsCardId: newsCardId, type: "bookmark", isActive: true) { _ in print("🔖 Bookmarked") }
                }
            }
        }
    }
}

// MARK: - Example 4: Discussion Management

class ExampleDiscussions {
    func createDiscussion(newsCardId: String, question: String) {
        NewsPersistenceManager.shared.createDiscussion(newsCardId: newsCardId, question: question, userName: "User", userProfileColor: .systemBlue) { result in
            if case .success(let discussion) = result { print("💬 Discussion created: \(discussion.question)") }
        }
    }
}

// MARK: - Example 6: Complete Workflow Integration

class ExampleCompleteWorkflow {
    func loadNewsFromDatabase() {
        NewsPersistenceManager.shared.fetchNewsCards(limit: 50) { result in
            switch result {
            case .success(let newsCardsDB) where !newsCardsDB.isEmpty:
                let newsItems = newsCardsDB.map { $0.toNewsItem() }
                print("📱 Loaded \(newsItems.count) items from database")
            default:
                self.fetchFromAPI()
            }
        }
    }
    
    private func fetchFromAPI() {
        NewsAPIService.shared.fetchNews(for: .daily) { result in
            if case .success(let newsItems) = result {
                NewsPersistenceManager.shared.saveNewsCards(newsItems) { _ in }
            }
        }
    }
}

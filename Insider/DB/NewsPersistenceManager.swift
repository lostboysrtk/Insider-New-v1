// NewsPersistenceManager.swift
// Enhanced Persistence Manager with duplicate prevention and smart saving

import Foundation
import UIKit

struct CommentUpdate: Encodable {
    let text: String
    let is_edited: Bool
}

struct NewsCardCountersUpdate: Encodable {
    let likes_count: Int?
    let dislikes_count: Int?
    let comments_count: Int?
    let discussions_count: Int?
    let bookmarks_count: Int?
}

class NewsPersistenceManager {
    
    static let shared = NewsPersistenceManager()
    private init() {}
    
    // MARK: - Device ID Management
    
    /// Resolves the current user ID asynchronously (prefers Supabase session)
    private func resolveUserId(completion: @escaping (String) -> Void) {
        Task {
            // ALWAYS try the live session first to ensure current status and casing
            if let supabaseUID = await SupabaseManager.shared.currentUserID {
                let lowercasedUID = supabaseUID.lowercased()
                print("🆔 Resolved Supabase UID (Lower): \(lowercasedUID)")
                
                // Keep cache updated but don't rely only on it
                UserDefaults.standard.set(lowercasedUID, forKey: "currentUserId")
                await MainActor.run { completion(lowercasedUID) }
                return
            }
            
            // Fallback to device ID if not logged in
            let deviceId = (UserDefaults.standard.string(forKey: "deviceId") ?? {
                let newId = UUID().uuidString.lowercased()
                UserDefaults.standard.set(newId, forKey: "deviceId")
                return newId
            }()).lowercased()
            
            print("🆔 Resolved Device ID (Guest/Lower): \(deviceId)")
            await MainActor.run { completion(deviceId) }
        }
    }
    
    // MARK: - Current User ID (Legacy Sync Accessor)
    private var currentUserId: String {
        return UserDefaults.standard.string(forKey: "currentUserId") ?? UserDefaults.standard.string(forKey: "deviceId") ?? "GUEST"
    }
    
    // MARK: - News Card Operations with Duplicate Prevention
    
    /// Save a news card to Supabase (checks for duplicates first)
    func saveNewsCard(_ newsItem: NewsItem, completion: @escaping (Result<NewsCardDB, SupabaseError>) -> Void) {
        if let articleURL = newsItem.articleURL {
            checkForDuplicate(articleURL: articleURL, title: newsItem.title) { [weak self] isDuplicate in
                if isDuplicate {
                    print("⏭️ [SKIP] Article already exists in database")
                    completion(.failure(.serverError("Duplicate article")))
                } else {
                    self?.performSaveNewsCard(newsItem, completion: completion)
                }
            }
        } else {
            performSaveNewsCard(newsItem, completion: completion)
        }
    }
    
    private func performSaveNewsCard(_ newsItem: NewsItem, completion: @escaping (Result<NewsCardDB, SupabaseError>) -> Void) {
        let newsCardDB = NewsCardDB(from: newsItem)
        
        SupabaseService.shared.post(
            endpoint: SupabaseConfig.Tables.newsCards,
            body: newsCardDB
        ) { (result: Result<[NewsCardDB], SupabaseError>) in
            switch result {
            case .success(let cards):
                if let card = cards.first {
                    completion(.success(card))
                } else {
                    completion(.failure(.noData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func saveNewsCards(_ newsItems: [NewsItem], completion: @escaping (Result<[NewsCardDB], SupabaseError>) -> Void) {
        filterDuplicates(from: newsItems) { [weak self] uniqueItems in
            guard !uniqueItems.isEmpty else {
                print("ℹ️ [SKIP] All items already exist in database")
                completion(.success([]))
                return
            }
            
            print("💾 [SAVE] Saving \(uniqueItems.count) unique items (filtered from \(newsItems.count))")
            
            let newsCardsDB = uniqueItems.map { NewsCardDB(from: $0) }
            
            SupabaseService.shared.post(
                endpoint: SupabaseConfig.Tables.newsCards,
                body: newsCardsDB,
                completion: completion
            )
        }
    }
    
    private func checkForDuplicate(articleURL: String, title: String, completion: @escaping (Bool) -> Void) {
        let queryParams = [
            "article_url": "eq.\(articleURL)",
            "limit": "1"
        ]
        
        SupabaseService.shared.get(
            endpoint: SupabaseConfig.Tables.newsCards,
            queryParams: queryParams
        ) { (result: Result<[NewsCardDB], SupabaseError>) in
            switch result {
            case .success(let cards):
                completion(!cards.isEmpty)
            case .failure:
                completion(false)
            }
        }
    }
    
    private func filterDuplicates(from newsItems: [NewsItem], completion: @escaping ([NewsItem]) -> Void) {
        let articleURLs = newsItems.compactMap { $0.articleURL }
        
        guard !articleURLs.isEmpty else {
            completion(newsItems)
            return
        }
        
        let urlList = articleURLs.joined(separator: ",")
        let queryParams = [
            "article_url": "in.(\(urlList))",
            "select": "article_url"
        ]
        
        SupabaseService.shared.get(
            endpoint: SupabaseConfig.Tables.newsCards,
            queryParams: queryParams
        ) { (result: Result<[NewsCardDB], SupabaseError>) in
            switch result {
            case .success(let existingCards):
                let existingURLs = Set(existingCards.compactMap { $0.articleURL })
                let uniqueItems = newsItems.filter { item in
                    guard let url = item.articleURL else { return true }
                    return !existingURLs.contains(url)
                }
                print("🔍 [FILTER] Found \(existingCards.count) duplicates, keeping \(uniqueItems.count) unique items")
                completion(uniqueItems)
                
            case .failure:
                print("⚠️ [FILTER] Duplicate check failed, saving all items")
                completion(newsItems)
            }
        }
    }
    
    func fetchNewsCards(limit: Int = 50, offset: Int = 0, completion: @escaping (Result<[NewsCardDB], SupabaseError>) -> Void) {
        let queryParams = [
            "limit": "\(limit)",
            "offset": "\(offset)",
            "order": "created_at.desc"
        ]
        
        SupabaseService.shared.get(
            endpoint: SupabaseConfig.Tables.newsCards,
            queryParams: queryParams,
            completion: completion
        )
    }
    
    func fetchNewsCards(byTag tag: String, limit: Int = 50, completion: @escaping (Result<[NewsCardDB], SupabaseError>) -> Void) {
        let queryParams = [
            "tags": "cs.{\(tag)}",
            "limit": "\(limit)",
            "order": "created_at.desc"
        ]
        
        SupabaseService.shared.get(
            endpoint: SupabaseConfig.Tables.newsCards,
            queryParams: queryParams,
            completion: completion
        )
    }
    
    // NEW: Fetch by category array
    func fetchNewsCards(byCategory category: String, limit: Int = 50, offset: Int = 0, completion: @escaping (Result<[NewsCardDB], SupabaseError>) -> Void) {
        let queryParams = [
            "category": "cs.{\(category)}",
            "limit": "\(limit)",
            "offset": "\(offset)",
            "order": "created_at.desc"
        ]
        
        SupabaseService.shared.get(
            endpoint: SupabaseConfig.Tables.newsCards,
            queryParams: queryParams,
            completion: completion
        )
    }
    
    // NEW: Fetch all distinct available categories dynamically
    func fetchAllUniqueCategories(completion: @escaping (Result<[String], SupabaseError>) -> Void) {
        let queryParams = [
            "select": "category",
            "limit": "1000" // Fetch up to 1000 items to extract all unique tags
        ]
        
        // We do a raw dictionary fetch to just pluck the strings without decoding full NewsCards
        SupabaseService.shared.get(
            endpoint: SupabaseConfig.Tables.newsCards,
            queryParams: queryParams
        ) { (result: Result<[[String: [String]?]], SupabaseError>) in
            switch result {
            case .success(let rows):
                var uniqueCategories = Set<String>()
                for row in rows {
                    if let categoryArray = row["category"], let resolvedArray = categoryArray {
                        for cat in resolvedArray {
                            uniqueCategories.insert(cat)
                        }
                    }
                }
                completion(.success(Array(uniqueCategories).sorted()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func searchNewsCards(query: String, limit: Int = 50, completion: @escaping (Result<[NewsCardDB], SupabaseError>) -> Void) {
        let queryParams = [
            "or": "(title.ilike.*\(query)*,description.ilike.*\(query)*)",
            "limit": "\(limit)",
            "order": "created_at.desc"
        ]
        
        SupabaseService.shared.get(
            endpoint: SupabaseConfig.Tables.newsCards,
            queryParams: queryParams,
            completion: completion
        )
    }
    
    func getNewsCard(id: String, completion: @escaping (Result<NewsCardDB, SupabaseError>) -> Void) {
        let queryParams = ["id": "eq.\(id)"]
        
        SupabaseService.shared.get(
            endpoint: SupabaseConfig.Tables.newsCards,
            queryParams: queryParams
        ) { (result: Result<[NewsCardDB], SupabaseError>) in
            switch result {
            case .success(let cards):
                if let card = cards.first {
                    completion(.success(card))
                } else {
                    completion(.failure(.notFound))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateNewsCardCounters(id: String, likes: Int? = nil, dislikes: Int? = nil, comments: Int? = nil, discussions: Int? = nil, bookmarks: Int? = nil, completion: @escaping (Result<NewsCardDB, SupabaseError>) -> Void) {
        let updates = NewsCardCountersUpdate(likes_count: likes, dislikes_count: dislikes, comments_count: comments, discussions_count: discussions, bookmarks_count: bookmarks)
        let queryParams = ["id": "eq.\(id)"]
        
        SupabaseService.shared.update(endpoint: SupabaseConfig.Tables.newsCards, body: updates, queryParams: queryParams) { (result: Result<[NewsCardDB], SupabaseError>) in
            if case .success(let cards) = result, let card = cards.first {
                completion(.success(card))
            } else if case .failure(let error) = result {
                completion(.failure(error))
            } else {
                completion(.failure(.notFound))
            }
        }
    }
    
    // MARK: - User Interaction Operations
    
    func recordInteraction(newsCardId: String, type: String, isActive: Bool = true, completion: @escaping (Result<UserInteractionDB, SupabaseError>) -> Void) {
        resolveUserId { userId in
            let interaction = UserInteractionDB(id: nil, userId: userId, newsCardId: newsCardId, interactionType: type, isActive: isActive, createdAt: nil, updatedAt: nil)
            
            SupabaseService.shared.post(endpoint: SupabaseConfig.Tables.userInteractions, body: interaction) { (result: Result<[UserInteractionDB], SupabaseError>) in
                if case .success(let interactions) = result, let interaction = interactions.first {
                    completion(.success(interaction))
                } else if case .failure(let error) = result {
                    completion(.failure(error))
                } else {
                    completion(.failure(.noData))
                }
            }
        }
    }
    
    func getUserInteraction(newsCardId: String, type: String, completion: @escaping (Result<UserInteractionDB?, SupabaseError>) -> Void) {
        resolveUserId { userId in
            let queryParams = ["user_id": "eq.\(userId)", "news_card_id": "eq.\(newsCardId)", "interaction_type": "eq.\(type)"]
            
            SupabaseService.shared.get(endpoint: SupabaseConfig.Tables.userInteractions, queryParams: queryParams) { (result: Result<[UserInteractionDB], SupabaseError>) in
                switch result {
                case .success(let interactions):
                    completion(.success(interactions.first))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func updateInteraction(newsCardId: String, type: String, isActive: Bool, completion: @escaping (Result<UserInteractionDB, SupabaseError>) -> Void) {
        resolveUserId { userId in
            let updates = ["is_active": isActive]
            let queryParams = ["user_id": "eq.\(userId)", "news_card_id": "eq.\(newsCardId)", "interaction_type": "eq.\(type)"]
            
            SupabaseService.shared.update(endpoint: SupabaseConfig.Tables.userInteractions, body: updates, queryParams: queryParams) { (result: Result<[UserInteractionDB], SupabaseError>) in
                if case .success(let interactions) = result, let interaction = interactions.first {
                    completion(.success(interaction))
                } else if case .failure(let error) = result {
                    completion(.failure(error))
                } else {
                    completion(.failure(.notFound))
                }
            }
        }
    }
    
    func savePostDedicated(newsCardId: String, completion: @escaping (Result<SavedPostDB, SupabaseError>) -> Void) {
        resolveUserId { userId in
            print("🚀 Attempting to save post with userId: \(userId)")
            let savedPost = SavedPostDB(id: nil, userId: userId, newsCardId: newsCardId, createdAt: nil)
            
            SupabaseService.shared.post(endpoint: SupabaseConfig.Tables.savedPosts, body: savedPost) { (result: Result<[SavedPostDB], SupabaseError>) in
                if case .success(let posts) = result, let post = posts.first {
                    completion(.success(post))
                } else if case .failure(let error) = result {
                    completion(.failure(error))
                } else {
                    completion(.failure(.noData))
                }
            }
        }
    }
    
    func removePostDedicated(newsCardId: String, completion: @escaping (Result<[SavedPostDB], SupabaseError>) -> Void) {
        resolveUserId { userId in
            let queryParams = ["user_id": "eq.\(userId)", "news_card_id": "eq.\(newsCardId)"]
            SupabaseService.shared.delete(endpoint: SupabaseConfig.Tables.savedPosts, queryParams: queryParams, completion: completion)
        }
    }
    
    func getSavedPostsDedicated(completion: @escaping (Result<[NewsCardDB], SupabaseError>) -> Void) {
        resolveUserId { userId in
            let queryParams = ["user_id": "eq.\(userId)"]
            
            SupabaseService.shared.get(endpoint: SupabaseConfig.Tables.savedPosts, queryParams: queryParams) { (result: Result<[SavedPostDB], SupabaseError>) in
                switch result {
                case .success(let savedItems):
                    let cardIds = savedItems.map { $0.newsCardId }
                    if cardIds.isEmpty { completion(.success([])); return }
                    
                    let cardQueryParams = ["id": "in.(\(cardIds.joined(separator: ",")))", "order": "created_at.desc"]
                    SupabaseService.shared.get(endpoint: SupabaseConfig.Tables.newsCards, queryParams: cardQueryParams, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func getBookmarkedCards(completion: @escaping (Result<[NewsCardDB], SupabaseError>) -> Void) {
        getSavedPostsDedicated(completion: completion)
    }
    
    // MARK: - Discussion Operations
    
    func createDiscussion(newsCardId: String, question: String, userName: String, userProfileColor: UIColor, completion: @escaping (Result<DiscussionDB, SupabaseError>) -> Void) {
        resolveUserId { userId in
            let discussion = DiscussionDB(id: nil, newsCardId: newsCardId, userId: userId, userName: userName, userProfileColor: userProfileColor.toHex() ?? "#007AFF", question: question, participantsCount: 1, messagesCount: 0, isActive: true, createdAt: nil, updatedAt: nil)
            
            SupabaseService.shared.post(endpoint: SupabaseConfig.Tables.discussions, body: discussion) { (result: Result<[DiscussionDB], SupabaseError>) in
                if case .success(let discussions) = result, let discussion = discussions.first {
                    completion(.success(discussion))
                } else if case .failure(let error) = result {
                    completion(.failure(error))
                } else {
                    completion(.failure(.noData))
                }
            }
        }
    }
    
    func getDiscussions(forNewsCardId newsCardId: String, completion: @escaping (Result<[DiscussionDB], SupabaseError>) -> Void) {
        let queryParams = ["news_card_id": "eq.\(newsCardId)", "is_active": "eq.true", "order": "created_at.desc"]
        SupabaseService.shared.get(endpoint: SupabaseConfig.Tables.discussions, queryParams: queryParams, completion: completion)
    }
    
    // MARK: - Comment Operations
    
    func createComment(newsCardId: String, text: String, userName: String, userProfileColor: UIColor, parentCommentId: String? = nil, level: Int = 0, completion: @escaping (Result<CommentDB, SupabaseError>) -> Void) {
        resolveUserId { userId in
            let comment = CommentDB(id: nil, newsCardId: newsCardId, userId: userId, userName: userName, userProfileColor: userProfileColor.toHex() ?? "#007AFF", text: text, parentCommentId: parentCommentId, level: level, likesCount: 0, isEdited: false, createdAt: nil, updatedAt: nil)
            
            SupabaseService.shared.post(endpoint: SupabaseConfig.Tables.comments, body: comment) { (result: Result<[CommentDB], SupabaseError>) in
                if case .success(let comments) = result, let comment = comments.first {
                    completion(.success(comment))
                } else if case .failure(let error) = result {
                    completion(.failure(error))
                } else {
                    completion(.failure(.noData))
                }
            }
        }
    }
    
    func getComments(forNewsCardId newsCardId: String, completion: @escaping (Result<[CommentDB], SupabaseError>) -> Void) {
        let queryParams = ["news_card_id": "eq.\(newsCardId)", "order": "created_at.asc"]
        SupabaseService.shared.get(endpoint: SupabaseConfig.Tables.comments, queryParams: queryParams, completion: completion)
    }
    
    func updateComment(id: String, text: String, completion: @escaping (Result<CommentDB, SupabaseError>) -> Void) {
        let updates = CommentUpdate(text: text, is_edited: true)
        let queryParams = ["id": "eq.\(id)"]
        
        SupabaseService.shared.update(endpoint: SupabaseConfig.Tables.comments, body: updates, queryParams: queryParams) { (result: Result<[CommentDB], SupabaseError>) in
            if case .success(let comments) = result, let comment = comments.first {
                completion(.success(comment))
            } else if case .failure(let error) = result {
                completion(.failure(error))
            } else {
                completion(.failure(.notFound))
            }
        }
    }
    
    // MARK: - Main Discussions Dynamic Queries
    
    /// Fetches all comments made by the current user DEVICE ID
    func getUserCommentActivity(completion: @escaping (Result<[CommentDB], SupabaseError>) -> Void) {
        resolveUserId { userId in
            let queryParams = ["user_id": "eq.\(userId)", "order": "created_at.desc"]
            SupabaseService.shared.get(endpoint: SupabaseConfig.Tables.comments, queryParams: queryParams, completion: completion)
        }
    }
    
    /// Fetches all news cards where the user has commented, along with their comments
    func getUserCommentedNewsCards(completion: @escaping (Result<([NewsCardDB], [CommentDB]), SupabaseError>) -> Void) {
        getUserCommentActivity { [weak self] result in
            switch result {
            case .success(let comments):
                // Get unique news card IDs
                let cardIds = Array(Set(comments.map { $0.newsCardId }))
                if cardIds.isEmpty {
                    completion(.success(([], [])))
                    return
                }
                
                // Fetch the news cards
                let cardQueryParams = ["id": "in.(\(cardIds.joined(separator: ",")))", "order": "created_at.desc"]
                SupabaseService.shared.get(endpoint: SupabaseConfig.Tables.newsCards, queryParams: cardQueryParams) { (cardResult: Result<[NewsCardDB], SupabaseError>) in
                    switch cardResult {
                    case .success(let cards):
                        
                        // We must fetch ALL comments for these cards to calculate correct reply counts
                        let allCommentsQuery = ["news_card_id": "in.(\(cardIds.joined(separator: ",")))", "order": "created_at.asc"]
                        SupabaseService.shared.get(endpoint: SupabaseConfig.Tables.comments, queryParams: allCommentsQuery) { (allCommentsResult: Result<[CommentDB], SupabaseError>) in
                             switch allCommentsResult {
                             case .success(let allComments):
                                 completion(.success((cards, allComments)))
                             case .failure(let err):
                                 completion(.failure(err)) // Could fall back to user comments if this fails, but strict failure is safer
                             }
                        }
                        
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

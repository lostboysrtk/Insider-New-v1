//// AudioPersistenceManager.swift
//// Manages audio briefs in Supabase - saving from API and fetching for playback
//
//import Foundation
//import UIKit
//
//class AudioPersistenceManager {
//    
//    static let shared = AudioPersistenceManager()
//    private init() {}
//    
//    // MARK: - Save Audio Briefs to Database
//    
//    /// Save breaking news items to Supabase
//    func saveBreakingNews(_ items: [BreakingNewsItem], fullContents: [String] = [], completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
//        // Convert to AudioBriefDB
//        let audioBriefs = items.enumerated().map { index, item in
//            let fullContent = index < fullContents.count ? fullContents[index] : nil
//            return AudioBriefDB(from: item, fullContent: fullContent)
//        }
//        
//        // Filter out duplicates before saving
//        filterDuplicateAudioBriefs(from: audioBriefs) { [weak self] uniqueBriefs in
//            guard !uniqueBriefs.isEmpty else {
//                print("ℹ️ [AUDIO] All breaking news items already exist in database")
//                completion(.success([]))
//                return
//            }
//            
//            print("💾 [AUDIO] Saving \(uniqueBriefs.count) breaking news items")
//            self?.performSaveAudioBriefs(uniqueBriefs, completion: completion)
//        }
//    }
//    
//    /// Save technical briefs to Supabase
//    func saveTechnicalBriefs(_ items: [TopChoiceItem], fullContents: [String] = [], completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
//        // Convert to AudioBriefDB
//        let audioBriefs = items.enumerated().map { index, item in
//            let fullContent = index < fullContents.count ? fullContents[index] : nil
//            return AudioBriefDB(from: item, contentType: "technical_brief", fullContent: fullContent)
//        }
//        
//        // Filter out duplicates before saving
//        filterDuplicateAudioBriefs(from: audioBriefs) { [weak self] uniqueBriefs in
//            guard !uniqueBriefs.isEmpty else {
//                print("ℹ️ [AUDIO] All technical briefs already exist in database")
//                completion(.success([]))
//                return
//            }
//            
//            print("💾 [AUDIO] Saving \(uniqueBriefs.count) technical briefs")
//            self?.performSaveAudioBriefs(uniqueBriefs, completion: completion)
//        }
//    }
//    
//    /// Save audio briefs from API results
//    func saveFromAPIResults(_ results: [AudioNewsResult], category: String, contentType: String, fullContents: [String] = [], completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
//        let audioBriefs = results.enumerated().map { index, result in
//            let fullContent = index < fullContents.count ? fullContents[index] : nil
//            return AudioBriefDB(from: result, category: category, contentType: contentType, fullContent: fullContent)
//        }
//        
//        filterDuplicateAudioBriefs(from: audioBriefs) { [weak self] uniqueBriefs in
//            guard !uniqueBriefs.isEmpty else {
//                print("ℹ️ [AUDIO] All API results already exist in database")
//                completion(.success([]))
//                return
//            }
//            
//            print("💾 [AUDIO] Saving \(uniqueBriefs.count) items from API")
//            self?.performSaveAudioBriefs(uniqueBriefs, completion: completion)
//        }
//    }
//    
//    private func performSaveAudioBriefs(_ briefs: [AudioBriefDB], completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
//        SupabaseService.shared.post(
//            endpoint: "audio_briefs",
//            body: briefs,
//            completion: completion
//        )
//    }
//    
//    // MARK: - Fetch Audio Briefs from Database
//    
//    /// Fetch today's audio briefs (breaking news + recent technical briefs)
//    func fetchTodaysAudio(completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
//        let queryParams = [
//            "created_at": "gte.\(getTodayStartISO8601())",
//            "order": "created_at.desc",
//            "limit": "50"
//        ]
//        
//        SupabaseService.shared.get(
//            endpoint: "audio_briefs",
//            queryParams: queryParams,
//            completion: completion
//        )
//    }
//    
//    /// Fetch all audio briefs (for "View All" - shows today's first, then older content)
//    func fetchAllAudio(limit: Int = 100, offset: Int = 0, completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
//        let queryParams = [
//            "order": "created_at.desc",
//            "limit": "\(limit)",
//            "offset": "\(offset)"
//        ]
//        
//        SupabaseService.shared.get(
//            endpoint: "audio_briefs",
//            queryParams: queryParams,
//            completion: completion
//        )
//    }
//    
//    /// Fetch breaking news only
//    func fetchBreakingNews(limit: Int = 10, completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
//        let queryParams = [
//            "content_type": "eq.breaking_news",
//            "order": "created_at.desc",
//            "limit": "\(limit)"
//        ]
//        
//        SupabaseService.shared.get(
//            endpoint: "audio_briefs",
//            queryParams: queryParams,
//            completion: completion
//        )
//    }
//    
//    /// Fetch technical briefs for a specific toolkit
//    func fetchBriefsByToolkit(_ toolkitName: String, limit: Int = 50, completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
//        let queryParams = [
//            "toolkit_name": "eq.\(toolkitName)",
//            "order": "created_at.desc",
//            "limit": "\(limit)"
//        ]
//        
//        SupabaseService.shared.get(
//            endpoint: "audio_briefs",
//            queryParams: queryParams,
//            completion: completion
//        )
//    }
//    
//    /// Fetch technical briefs by category
//    func fetchBriefsByCategory(_ category: String, limit: Int = 50, completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
//        let queryParams = [
//            "category": "ilike.*\(category)*",
//            "order": "created_at.desc",
//            "limit": "\(limit)"
//        ]
//        
//        SupabaseService.shared.get(
//            endpoint: "audio_briefs",
//            queryParams: queryParams,
//            completion: completion
//        )
//    }
//    
//    /// Search audio briefs
//    func searchAudioBriefs(query: String, limit: Int = 50, completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
//        let queryParams = [
//            "or": "(title.ilike.*\(query)*,description.ilike.*\(query)*)",
//            "order": "created_at.desc",
//            "limit": "\(limit)"
//        ]
//        
//        SupabaseService.shared.get(
//            endpoint: "audio_briefs",
//            queryParams: queryParams,
//            completion: completion
//        )
//    }
//    
//    // MARK: - Get Full Content for Audio Brief
//    
//    /// Get the full article content for an audio brief by its ID
//    func getFullContent(for briefId: String, completion: @escaping (Result<String, SupabaseError>) -> Void) {
//        let queryParams = [
//            "id": "eq.\(briefId)",
//            "select": "full_content"
//        ]
//        
//        SupabaseService.shared.get(
//            endpoint: "audio_briefs",
//            queryParams: queryParams
//        ) { (result: Result<[AudioBriefDB], SupabaseError>) in
//            switch result {
//            case .success(let briefs):
//                if let brief = briefs.first, let content = brief.fullContent {
//                    completion(.success(content))
//                } else {
//                    completion(.failure(.notFound))
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//    
//    /// Get full content by title (fallback if no ID)
//    func getFullContent(forTitle title: String, completion: @escaping (Result<String, SupabaseError>) -> Void) {
//        let queryParams = [
//            "title": "eq.\(title)",
//            "select": "full_content",
//            "order": "created_at.desc",
//            "limit": "1"
//        ]
//        
//        SupabaseService.shared.get(
//            endpoint: "audio_briefs",
//            queryParams: queryParams
//        ) { (result: Result<[AudioBriefDB], SupabaseError>) in
//            switch result {
//            case .success(let briefs):
//                if let brief = briefs.first, let content = brief.fullContent {
//                    completion(.success(content))
//                } else {
//                    completion(.failure(.notFound))
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//    
//    // MARK: - Engagement Tracking
//    
//    /// Increment play count for an audio brief
//    func incrementPlayCount(for briefId: String, completion: @escaping (Result<AudioBriefDB, SupabaseError>) -> Void) {
//        // First get current play count
//        let queryParams = ["id": "eq.\(briefId)"]
//        
//        SupabaseService.shared.get(
//            endpoint: "audio_briefs",
//            queryParams: queryParams
//        ) { (result: Result<[AudioBriefDB], SupabaseError>) in
//            switch result {
//            case .success(let briefs):
//                guard let brief = briefs.first else {
//                    completion(.failure(.notFound))
//                    return
//                }
//                
//                let newCount = (brief.playCount ?? 0) + 1
//                let update = ["play_count": newCount]
//                
//                SupabaseService.shared.update(
//                    endpoint: "audio_briefs",
//                    body: update,
//                    queryParams: queryParams
//                ) { (updateResult: Result<[AudioBriefDB], SupabaseError>) in
//                    if case .success(let updated) = updateResult, let first = updated.first {
//                        completion(.success(first))
//                    } else if case .failure(let error) = updateResult {
//                        completion(.failure(error))
//                    } else {
//                        completion(.failure(.notFound))
//                    }
//                }
//                
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//    
//    // MARK: - Helper Methods
//    
//    private func filterDuplicateAudioBriefs(from briefs: [AudioBriefDB], completion: @escaping ([AudioBriefDB]) -> Void) {
//        // Get article URLs that are not nil
//        let articleURLs = briefs.compactMap { $0.articleURL }
//        
//        guard !articleURLs.isEmpty else {
//            // If no article URLs, can't check for duplicates, return all
//            completion(briefs)
//            return
//        }
//        
//        let urlList = articleURLs.joined(separator: ",")
//        let queryParams = [
//            "article_url": "in.(\(urlList))",
//            "select": "article_url"
//        ]
//        
//        SupabaseService.shared.get(
//            endpoint: "audio_briefs",
//            queryParams: queryParams
//        ) { (result: Result<[AudioBriefDB], SupabaseError>) in
//            switch result {
//            case .success(let existingBriefs):
//                let existingURLs = Set(existingBriefs.compactMap { $0.articleURL })
//                let uniqueBriefs = briefs.filter { brief in
//                    guard let url = brief.articleURL else { return true }
//                    return !existingURLs.contains(url)
//                }
//                print("🔍 [AUDIO FILTER] Found \(existingBriefs.count) duplicates, keeping \(uniqueBriefs.count) unique items")
//                completion(uniqueBriefs)
//                
//            case .failure:
//                print("⚠️ [AUDIO FILTER] Duplicate check failed, saving all items")
//                completion(briefs)
//            }
//        }
//    }
//    
//    private func getTodayStartISO8601() -> String {
//        let calendar = Calendar.current
//        let today = calendar.startOfDay(for: Date())
//        let isoFormatter = ISO8601DateFormatter()
//        return isoFormatter.string(from: today)
//    }
//}












//
//// AudioPersistenceManager.swift
//// Manages audio briefs in Supabase - saving from API and fetching for playback
//
//import Foundation
//import UIKit
//
//class AudioPersistenceManager {
//    
//    static let shared = AudioPersistenceManager()
//    private init() {}
//    
//    // MARK: - Save Audio Briefs to Database
//    
//    /// Save breaking news items to Supabase
//    func saveBreakingNews(_ items: [BreakingNewsItem], fullContents: [String] = [], completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
//        // Convert to AudioBriefDB
//        let audioBriefs = items.enumerated().map { index, item in
//            let fullContent = index < fullContents.count ? fullContents[index] : nil
//            return AudioBriefDB(from: item, fullContent: fullContent)
//        }
//        
//        // Filter out duplicates before saving
//        filterDuplicateAudioBriefs(from: audioBriefs) { [weak self] uniqueBriefs in
//            guard !uniqueBriefs.isEmpty else {
//                print("ℹ️ [AUDIO] All breaking news items already exist in database")
//                completion(.success([]))
//                return
//            }
//            
//            print("💾 [AUDIO] Saving \(uniqueBriefs.count) breaking news items")
//            self?.performSaveAudioBriefs(uniqueBriefs, completion: completion)
//        }
//    }
//    
//    /// Save technical briefs to Supabase
//    func saveTechnicalBriefs(_ items: [TopChoiceItem], fullContents: [String] = [], completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
//        // Convert to AudioBriefDB
//        let audioBriefs = items.enumerated().map { index, item in
//            let fullContent = index < fullContents.count ? fullContents[index] : nil
//            return AudioBriefDB(from: item, contentType: "technical_brief", fullContent: fullContent)
//        }
//        
//        // Filter out duplicates before saving
//        filterDuplicateAudioBriefs(from: audioBriefs) { [weak self] uniqueBriefs in
//            guard !uniqueBriefs.isEmpty else {
//                print("ℹ️ [AUDIO] All technical briefs already exist in database")
//                completion(.success([]))
//                return
//            }
//            
//            print("💾 [AUDIO] Saving \(uniqueBriefs.count) technical briefs")
//            self?.performSaveAudioBriefs(uniqueBriefs, completion: completion)
//        }
//    }
//    
//    /// Save audio briefs from API results
//    func saveFromAPIResults(_ results: [AudioNewsResult], category: String, contentType: String, fullContents: [String] = [], completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
//        let audioBriefs = results.enumerated().map { index, result in
//            let fullContent = index < fullContents.count ? fullContents[index] : nil
//            return AudioBriefDB(from: result, category: category, contentType: contentType, fullContent: fullContent)
//        }
//        
//        filterDuplicateAudioBriefs(from: audioBriefs) { [weak self] uniqueBriefs in
//            guard !uniqueBriefs.isEmpty else {
//                print("ℹ️ [AUDIO] All API results already exist in database")
//                completion(.success([]))
//                return
//            }
//            
//            print("💾 [AUDIO] Saving \(uniqueBriefs.count) items from API")
//            self?.performSaveAudioBriefs(uniqueBriefs, completion: completion)
//        }
//    }
//    
//    private func performSaveAudioBriefs(_ briefs: [AudioBriefDB], completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
//        SupabaseService.shared.post(
//            endpoint: "audio_briefs",
//            body: briefs,
//            completion: completion
//        )
//    }
//    
//    // MARK: - Fetch Audio Briefs from Database
//    
//    /// Fetch today's audio briefs (breaking news + recent technical briefs)
//    func fetchTodaysAudio(completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
//        let queryParams = [
//            "created_at": "gte.\(getTodayStartISO8601())",
//            "order": "created_at.desc",
//            "limit": "50"
//        ]
//        
//        SupabaseService.shared.get(
//            endpoint: "audio_briefs",
//            queryParams: queryParams,
//            completion: completion
//        )
//    }
//    
//    /// Fetch all audio briefs (for "View All" - shows today's first, then older content)
//    func fetchAllAudio(limit: Int = 100, offset: Int = 0, completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
//        let queryParams = [
//            "order": "created_at.desc",
//            "limit": "\(limit)",
//            "offset": "\(offset)"
//        ]
//        
//        SupabaseService.shared.get(
//            endpoint: "audio_briefs",
//            queryParams: queryParams,
//            completion: completion
//        )
//    }
//    
//    /// Fetch breaking news only
//    func fetchBreakingNews(limit: Int = 10, completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
//        let queryParams = [
//            "content_type": "eq.breaking_news",
//            "order": "created_at.desc",
//            "limit": "\(limit)"
//        ]
//        
//        SupabaseService.shared.get(
//            endpoint: "audio_briefs",
//            queryParams: queryParams,
//            completion: completion
//        )
//    }
//    
//    /// Fetch technical briefs for a specific toolkit
//    func fetchBriefsByToolkit(_ toolkitName: String, limit: Int = 50, completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
//        let queryParams = [
//            "toolkit_name": "eq.\(toolkitName)",
//            "order": "created_at.desc",
//            "limit": "\(limit)"
//        ]
//        
//        SupabaseService.shared.get(
//            endpoint: "audio_briefs",
//            queryParams: queryParams,
//            completion: completion
//        )
//    }
//    
//    /// Fetch technical briefs by category
//    func fetchBriefsByCategory(_ category: String, limit: Int = 50, completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
//        let queryParams = [
//            "category": "ilike.*\(category)*",
//            "order": "created_at.desc",
//            "limit": "\(limit)"
//        ]
//        
//        SupabaseService.shared.get(
//            endpoint: "audio_briefs",
//            queryParams: queryParams,
//            completion: completion
//        )
//    }
//    
//    /// Search audio briefs
//    func searchAudioBriefs(query: String, limit: Int = 50, completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
//        let queryParams = [
//            "or": "(title.ilike.*\(query)*,description.ilike.*\(query)*)",
//            "order": "created_at.desc",
//            "limit": "\(limit)"
//        ]
//        
//        SupabaseService.shared.get(
//            endpoint: "audio_briefs",
//            queryParams: queryParams,
//            completion: completion
//        )
//    }
//    
//    // MARK: - Get Full Content for Audio Brief
//    
//    /// Get the full article content for an audio brief by its ID
//    func getFullContent(for briefId: String, completion: @escaping (Result<String, SupabaseError>) -> Void) {
//        let queryParams = [
//            "id": "eq.\(briefId)",
//            "select": "full_content"
//        ]
//        
//        SupabaseService.shared.get(
//            endpoint: "audio_briefs",
//            queryParams: queryParams
//        ) { (result: Result<[AudioBriefDB], SupabaseError>) in
//            switch result {
//            case .success(let briefs):
//                if let brief = briefs.first, let content = brief.fullContent {
//                    completion(.success(content))
//                } else {
//                    completion(.failure(.notFound))
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//    
//    /// Get full content by title (fallback if no ID)
//    func getFullContent(forTitle title: String, completion: @escaping (Result<String, SupabaseError>) -> Void) {
//        let queryParams = [
//            "title": "eq.\(title)",
//            "select": "full_content",
//            "order": "created_at.desc",
//            "limit": "1"
//        ]
//        
//        SupabaseService.shared.get(
//            endpoint: "audio_briefs",
//            queryParams: queryParams
//        ) { (result: Result<[AudioBriefDB], SupabaseError>) in
//            switch result {
//            case .success(let briefs):
//                if let brief = briefs.first, let content = brief.fullContent {
//                    completion(.success(content))
//                } else {
//                    completion(.failure(.notFound))
//                }
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//    
//    // MARK: - Engagement Tracking
//    
//    /// Increment play count for an audio brief
//    func incrementPlayCount(for briefId: String, completion: @escaping (Result<AudioBriefDB, SupabaseError>) -> Void) {
//        // First get current play count
//        let queryParams = ["id": "eq.\(briefId)"]
//        
//        SupabaseService.shared.get(
//            endpoint: "audio_briefs",
//            queryParams: queryParams
//        ) { (result: Result<[AudioBriefDB], SupabaseError>) in
//            switch result {
//            case .success(let briefs):
//                guard let brief = briefs.first else {
//                    completion(.failure(.notFound))
//                    return
//                }
//                
//                let newCount = (brief.playCount ?? 0) + 1
//                let update = ["play_count": newCount]
//                
//                SupabaseService.shared.update(
//                    endpoint: "audio_briefs",
//                    body: update,
//                    queryParams: queryParams
//                ) { (updateResult: Result<[AudioBriefDB], SupabaseError>) in
//                    if case .success(let updated) = updateResult, let first = updated.first {
//                        completion(.success(first))
//                    } else if case .failure(let error) = updateResult {
//                        completion(.failure(error))
//                    } else {
//                        completion(.failure(.notFound))
//                    }
//                }
//                
//            case .failure(let error):
//                completion(.failure(error))
//            }
//        }
//    }
//    
//    // MARK: - Helper Methods
//    
//    /// Delete all existing breaking news rows from Supabase.
//    /// Called before saving fresh daily breaking news so old items don't persist.
//    func deleteAllBreakingNews(completion: @escaping (Bool) -> Void) {
//        let queryParams = ["content_type": "eq.breaking_news"]
//        SupabaseService.shared.delete(
//            endpoint: "audio_briefs",
//            queryParams: queryParams
//        ) { result in
//            switch result {
//            case .success:
//                print("🗑️ [AUDIO] Deleted old breaking news rows")
//                completion(true)
//            case .failure(let error):
//                print("⚠️ [AUDIO] Failed to delete old breaking news: \(error.localizedDescription)")
//                completion(false)
//            }
//        }
//    }
//    
//    /// Replace all breaking news with fresh items — delete old, insert new.
//    /// This is the correct daily refresh strategy so stale news never lingers.
//    func replaceBreakingNews(_ items: [BreakingNewsItem], fullContents: [String] = [], completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
//        let freshBriefs = items.prefix(5).enumerated().map { index, item -> AudioBriefDB in
//            let fullContent = index < fullContents.count ? fullContents[index] : nil
//            return AudioBriefDB(from: item, fullContent: fullContent)
//        }
//        
//        // Step 1: Delete all existing breaking news
//        deleteAllBreakingNews { [weak self] deleted in
//            guard deleted else {
//                // If delete failed, still try to save (duplicates will be rejected by DB constraints)
//                self?.performSaveAudioBriefs(Array(freshBriefs), completion: completion)
//                return
//            }
//            
//            // Step 2: Insert the fresh 5 items (skip duplicate filter — we just cleared the table)
//            print("💾 [AUDIO] Saving \(freshBriefs.count) fresh breaking news items")
//            self?.performSaveAudioBriefs(Array(freshBriefs), completion: completion)
//        }
//    }
//    
//    private func filterDuplicateAudioBriefs(from briefs: [AudioBriefDB], completion: @escaping ([AudioBriefDB]) -> Void) {
//        // Get article URLs that are not nil
//        let articleURLs = briefs.compactMap { $0.articleURL }
//        
//        guard !articleURLs.isEmpty else {
//            // If no article URLs, can't check for duplicates, return all
//            completion(briefs)
//            return
//        }
//        
//        let urlList = articleURLs.joined(separator: ",")
//        let queryParams = [
//            "article_url": "in.(\(urlList))",
//            "select": "article_url"
//        ]
//        
//        SupabaseService.shared.get(
//            endpoint: "audio_briefs",
//            queryParams: queryParams
//        ) { (result: Result<[AudioBriefDB], SupabaseError>) in
//            switch result {
//            case .success(let existingBriefs):
//                let existingURLs = Set(existingBriefs.compactMap { $0.articleURL })
//                let uniqueBriefs = briefs.filter { brief in
//                    guard let url = brief.articleURL else { return true }
//                    return !existingURLs.contains(url)
//                }
//                print("🔍 [AUDIO FILTER] Found \(existingBriefs.count) duplicates, keeping \(uniqueBriefs.count) unique items")
//                completion(uniqueBriefs)
//                
//            case .failure:
//                print("⚠️ [AUDIO FILTER] Duplicate check failed, saving all items")
//                completion(briefs)
//            }
//        }
//    }
//    
//    private func getTodayStartISO8601() -> String {
//        let calendar = Calendar.current
//        let today = calendar.startOfDay(for: Date())
//        let isoFormatter = ISO8601DateFormatter()
//        return isoFormatter.string(from: today)
//    }
//}





// AudioPersistenceManager.swift
// Manages audio briefs in Supabase - saving from API and fetching for playback

import Foundation
import UIKit

class AudioPersistenceManager {
    
    static let shared = AudioPersistenceManager()
    private init() {}
    
    // MARK: - Save Audio Briefs to Database
    
    /// Save breaking news items to Supabase
    func saveBreakingNews(_ items: [BreakingNewsItem], fullContents: [String] = [], completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
        // Convert to AudioBriefDB
        let audioBriefs = items.enumerated().map { index, item in
            let fullContent = index < fullContents.count ? fullContents[index] : nil
            return AudioBriefDB(from: item, fullContent: fullContent)
        }
        
        // Filter out duplicates before saving
        filterDuplicateAudioBriefs(from: audioBriefs) { [weak self] uniqueBriefs in
            guard !uniqueBriefs.isEmpty else {
                print("ℹ️ [AUDIO] All breaking news items already exist in database")
                completion(.success([]))
                return
            }
            
            print("💾 [AUDIO] Saving \(uniqueBriefs.count) breaking news items")
            self?.performSaveAudioBriefs(uniqueBriefs, completion: completion)
        }
    }
    
    /// Save technical briefs to Supabase
    func saveTechnicalBriefs(_ items: [TopChoiceItem], fullContents: [String] = [], completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
        // Convert to AudioBriefDB
        let audioBriefs = items.enumerated().map { index, item in
            let fullContent = index < fullContents.count ? fullContents[index] : nil
            return AudioBriefDB(from: item, contentType: "technical_brief", fullContent: fullContent)
        }
        
        // Filter out duplicates before saving
        filterDuplicateAudioBriefs(from: audioBriefs) { [weak self] uniqueBriefs in
            guard !uniqueBriefs.isEmpty else {
                print("ℹ️ [AUDIO] All technical briefs already exist in database")
                completion(.success([]))
                return
            }
            
            print("💾 [AUDIO] Saving \(uniqueBriefs.count) technical briefs")
            self?.performSaveAudioBriefs(uniqueBriefs, completion: completion)
        }
    }
    
    /// Save audio briefs from API results
    func saveFromAPIResults(_ results: [AudioNewsResult], category: String, contentType: String, fullContents: [String] = [], completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
        let audioBriefs = results.enumerated().map { index, result in
            let fullContent = index < fullContents.count ? fullContents[index] : nil
            return AudioBriefDB(from: result, category: category, contentType: contentType, fullContent: fullContent)
        }
        
        filterDuplicateAudioBriefs(from: audioBriefs) { [weak self] uniqueBriefs in
            guard !uniqueBriefs.isEmpty else {
                print("ℹ️ [AUDIO] All API results already exist in database")
                completion(.success([]))
                return
            }
            
            print("💾 [AUDIO] Saving \(uniqueBriefs.count) items from API")
            self?.performSaveAudioBriefs(uniqueBriefs, completion: completion)
        }
    }
    
    private func performSaveAudioBriefs(_ briefs: [AudioBriefDB], completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
        SupabaseService.shared.post(
            endpoint: "audio_briefs",
            body: briefs,
            completion: completion
        )
    }
    
    // MARK: - Fetch Audio Briefs from Database
    
    /// Fetch today's audio briefs (breaking news + recent technical briefs)
    func fetchTodaysAudio(completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
        let queryParams = [
            "created_at": "gte.\(getTodayStartISO8601())",
            "order": "created_at.desc",
            "limit": "50"
        ]
        
        SupabaseService.shared.get(
            endpoint: "audio_briefs",
            queryParams: queryParams,
            completion: completion
        )
    }
    
    /// Fetch all audio briefs (for "View All" - shows today's first, then older content)
    func fetchAllAudio(limit: Int = 100, offset: Int = 0, completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
        let queryParams = [
            "order": "created_at.desc",
            "limit": "\(limit)",
            "offset": "\(offset)"
        ]
        
        SupabaseService.shared.get(
            endpoint: "audio_briefs",
            queryParams: queryParams,
            completion: completion
        )
    }
    
    /// Fetch the 5 most recent breaking news items (newest first).
    /// Since we insert fresh items on each daily refresh, created_at.desc always returns today's news.
    func fetchBreakingNews(limit: Int = 5, completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
        let queryParams = [
            "content_type": "eq.breaking_news",
            "order": "created_at.desc",
            "limit": "\(limit)"
        ]
        
        SupabaseService.shared.get(
            endpoint: "audio_briefs",
            queryParams: queryParams,
            completion: completion
        )
    }
    
    /// Fetch technical briefs for a specific toolkit
    func fetchBriefsByToolkit(_ toolkitName: String, limit: Int = 50, completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
        let queryParams = [
            "toolkit_name": "eq.\(toolkitName)",
            "order": "created_at.desc",
            "limit": "\(limit)"
        ]
        
        SupabaseService.shared.get(
            endpoint: "audio_briefs",
            queryParams: queryParams,
            completion: completion
        )
    }
    
    /// Fetch technical briefs by category
    func fetchBriefsByCategory(_ category: String, limit: Int = 50, completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
        let queryParams = [
            "category": "ilike.*\(category)*",
            "order": "created_at.desc",
            "limit": "\(limit)"
        ]
        
        SupabaseService.shared.get(
            endpoint: "audio_briefs",
            queryParams: queryParams,
            completion: completion
        )
    }
    
    /// Search audio briefs
    func searchAudioBriefs(query: String, limit: Int = 50, completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
        let queryParams = [
            "or": "(title.ilike.*\(query)*,description.ilike.*\(query)*)",
            "order": "created_at.desc",
            "limit": "\(limit)"
        ]
        
        SupabaseService.shared.get(
            endpoint: "audio_briefs",
            queryParams: queryParams,
            completion: completion
        )
    }
    
    // MARK: - Get Full Content for Audio Brief
    
    /// Get the full article content for an audio brief by its ID
    func getFullContent(for briefId: String, completion: @escaping (Result<String, SupabaseError>) -> Void) {
        let queryParams = [
            "id": "eq.\(briefId)",
            "select": "full_content"
        ]
        
        SupabaseService.shared.get(
            endpoint: "audio_briefs",
            queryParams: queryParams
        ) { (result: Result<[AudioBriefDB], SupabaseError>) in
            switch result {
            case .success(let briefs):
                if let brief = briefs.first, let content = brief.fullContent {
                    completion(.success(content))
                } else {
                    completion(.failure(.notFound))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Get full content by title (fallback if no ID)
    func getFullContent(forTitle title: String, completion: @escaping (Result<String, SupabaseError>) -> Void) {
        let queryParams = [
            "title": "eq.\(title)",
            "select": "full_content",
            "order": "created_at.desc",
            "limit": "1"
        ]
        
        SupabaseService.shared.get(
            endpoint: "audio_briefs",
            queryParams: queryParams
        ) { (result: Result<[AudioBriefDB], SupabaseError>) in
            switch result {
            case .success(let briefs):
                if let brief = briefs.first, let content = brief.fullContent {
                    completion(.success(content))
                } else {
                    completion(.failure(.notFound))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Engagement Tracking
    
    /// Increment play count for an audio brief
    func incrementPlayCount(for briefId: String, completion: @escaping (Result<AudioBriefDB, SupabaseError>) -> Void) {
        // First get current play count
        let queryParams = ["id": "eq.\(briefId)"]
        
        SupabaseService.shared.get(
            endpoint: "audio_briefs",
            queryParams: queryParams
        ) { (result: Result<[AudioBriefDB], SupabaseError>) in
            switch result {
            case .success(let briefs):
                guard let brief = briefs.first else {
                    completion(.failure(.notFound))
                    return
                }
                
                let newCount = (brief.playCount ?? 0) + 1
                let update = ["play_count": newCount]
                
                SupabaseService.shared.update(
                    endpoint: "audio_briefs",
                    body: update,
                    queryParams: queryParams
                ) { (updateResult: Result<[AudioBriefDB], SupabaseError>) in
                    if case .success(let updated) = updateResult, let first = updated.first {
                        completion(.success(first))
                    } else if case .failure(let error) = updateResult {
                        completion(.failure(error))
                    } else {
                        completion(.failure(.notFound))
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Marks all existing breaking news rows as inactive (is_active = false).
    /// Uses UPDATE since SupabaseService has no DELETE method.
    /// Fresh items are then inserted with is_active = true and fetched by date order.
    private func deactivateOldBreakingNews(completion: @escaping (Bool) -> Void) {
        let queryParams = ["content_type": "eq.breaking_news"]
        let body = ["is_active": false]
        
        SupabaseService.shared.update(
            endpoint: "audio_briefs",
            body: body,
            queryParams: queryParams
        ) { (result: Result<[AudioBriefDB], SupabaseError>) in
            switch result {
            case .success:
                print("✅ [AUDIO] Marked old breaking news as inactive")
                completion(true)
            case .failure(let error):
                print("⚠️ [AUDIO] Could not deactivate old breaking news: \(error.localizedDescription)")
                // Non-fatal — still proceed with saving new items
                completion(true)
            }
        }
    }
    
    /// Replace all breaking news with fresh items.
    /// Deactivates old rows first, then saves the new top-5.
    /// On fetch, items are ordered by created_at desc so newest always win.
    func replaceBreakingNews(_ items: [BreakingNewsItem], fullContents: [String] = [], completion: @escaping (Result<[AudioBriefDB], SupabaseError>) -> Void) {
        let freshBriefs = items.prefix(5).enumerated().map { index, item -> AudioBriefDB in
            let fullContent = index < fullContents.count ? fullContents[index] : nil
            return AudioBriefDB(from: item, fullContent: fullContent)
        }
        
        // Step 1: Deactivate old breaking news rows
        deactivateOldBreakingNews { [weak self] _ in
            // Step 2: Insert the fresh 5 — skip duplicate filter since these are today's new items
            print("💾 [AUDIO] Saving \(freshBriefs.count) fresh breaking news items")
            self?.performSaveAudioBriefs(Array(freshBriefs), completion: completion)
        }
    }
    
    private func filterDuplicateAudioBriefs(from briefs: [AudioBriefDB], completion: @escaping ([AudioBriefDB]) -> Void) {
        // Get article URLs that are not nil
        let articleURLs = briefs.compactMap { $0.articleURL }
        
        guard !articleURLs.isEmpty else {
            // If no article URLs, can't check for duplicates, return all
            completion(briefs)
            return
        }
        
        let urlList = articleURLs.joined(separator: ",")
        let queryParams = [
            "article_url": "in.(\(urlList))",
            "select": "article_url"
        ]
        
        SupabaseService.shared.get(
            endpoint: "audio_briefs",
            queryParams: queryParams
        ) { (result: Result<[AudioBriefDB], SupabaseError>) in
            switch result {
            case .success(let existingBriefs):
                let existingURLs = Set(existingBriefs.compactMap { $0.articleURL })
                let uniqueBriefs = briefs.filter { brief in
                    guard let url = brief.articleURL else { return true }
                    return !existingURLs.contains(url)
                }
                print("🔍 [AUDIO FILTER] Found \(existingBriefs.count) duplicates, keeping \(uniqueBriefs.count) unique items")
                completion(uniqueBriefs)
                
            case .failure:
                print("⚠️ [AUDIO FILTER] Duplicate check failed, saving all items")
                completion(briefs)
            }
        }
    }
    
    private func getTodayStartISO8601() -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let isoFormatter = ISO8601DateFormatter()
        return isoFormatter.string(from: today)
    }
}

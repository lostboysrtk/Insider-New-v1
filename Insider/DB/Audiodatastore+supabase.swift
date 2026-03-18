//// AudioDataStore+Supabase.swift
//// Updated AudioDataStore to fetch audio content from Supabase instead of directly from API
//
//import UIKit
//
//// MARK: - Extended Audio Data Store with Supabase Integration
//extension AudioDataStore {
//    
//    // MARK: - Load Breaking News (from Supabase)
//    
//    /// Load breaking news from Supabase database
//    /// Falls back to API if database is empty or fails
//    func loadBreakingNewsFromDatabase(completion: @escaping ([BreakingNewsItem]) -> Void) {
//        AudioPersistenceManager.shared.fetchBreakingNews(limit: 10) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let audioBriefs):
//                    if !audioBriefs.isEmpty {
//                        let breakingNews = audioBriefs.map { $0.toBreakingNewsItem() }
//                        print("✅ Loaded \(breakingNews.count) breaking news items from database")
//                        completion(breakingNews)
//                    } else {
//                        // Database is empty, fetch from API and save
//                        print("📡 Database empty, fetching breaking news from API...")
//                        self?.fetchAndSaveBreakingNews(completion: completion)
//                    }
//                    
//                case .failure(let error):
//                    print("⚠️ Database fetch failed: \(error.localizedDescription), using API")
//                    self?.fetchAndSaveBreakingNews(completion: completion)
//                }
//            }
//        }
//    }
//    
//    private func fetchAndSaveBreakingNews(completion: @escaping ([BreakingNewsItem]) -> Void) {
//        AudioNewsAPIService.shared.fetchBreakingNews { [weak self] result in
//            switch result {
//            case .success(let items):
//                // Get full contents from API service cache
//                let fullContents = items.map { item in
//                    AudioNewsAPIService.shared.getArticleContent(
//                        forTitle: item.headline,
//                        withDescription: nil,
//                        andSource: item.source
//                    )
//                }
//                
//                // Save to database in background
//                AudioPersistenceManager.shared.saveBreakingNews(items, fullContents: fullContents) { result in
//                    if case .success(let saved) = result {
//                        print("💾 Saved \(saved.count) breaking news items to database")
//                    }
//                }
//                
//                completion(items)
//                
//            case .failure(let error):
//                print("❌ API Error: \(error.localizedDescription). Using static data.")
//                completion(self?.breakingNews ?? [])
//            }
//        }
//    }
//    
//    // MARK: - Load All Technical Briefs (from Supabase)
//    
//    /// Load all technical briefs from Supabase
//    /// Shows today's briefs first, then older content
//    func loadAllTechnicalBriefsFromDatabase(completion: @escaping ([TopChoiceItem]) -> Void) {
//        AudioPersistenceManager.shared.fetchAllAudio(limit: 100) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let audioBriefs):
//                    if !audioBriefs.isEmpty {
//                        let briefs = audioBriefs.map { $0.toTopChoiceItem() }
//                        print("✅ Loaded \(briefs.count) technical briefs from database")
//                        completion(briefs)
//                    } else {
//                        // Database is empty, fetch from API and save
//                        print("📡 Database empty, fetching technical briefs from API...")
//                        self?.fetchAndSaveTechnicalBriefs(completion: completion)
//                    }
//                    
//                case .failure(let error):
//                    print("⚠️ Database fetch failed: \(error.localizedDescription), using API")
//                    self?.fetchAndSaveTechnicalBriefs(completion: completion)
//                }
//            }
//        }
//    }
//    
//    /// Load today's audio only (for the main screen)
//    func loadTodaysAudioFromDatabase(completion: @escaping ([TopChoiceItem]) -> Void) {
//        AudioPersistenceManager.shared.fetchTodaysAudio { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let audioBriefs):
//                    if !audioBriefs.isEmpty {
//                        let briefs = audioBriefs.map { $0.toTopChoiceItem() }
//                        print("✅ Loaded \(briefs.count) today's audio items from database")
//                        completion(briefs)
//                    } else {
//                        // No today's content, fetch from API
//                        print("📡 No today's content, fetching from API...")
//                        self?.fetchAndSaveTechnicalBriefs(completion: completion)
//                    }
//                    
//                case .failure(let error):
//                    print("⚠️ Database fetch failed: \(error.localizedDescription), using API")
//                    self?.fetchAndSaveTechnicalBriefs(completion: completion)
//                }
//            }
//        }
//    }
//    
//    private func fetchAndSaveTechnicalBriefs(completion: @escaping ([TopChoiceItem]) -> Void) {
//        AudioNewsAPIService.shared.fetchAllTechnicalBriefs { [weak self] result in
//            switch result {
//            case .success(let items):
//                // Get full contents from API service cache
//                let fullContents = items.map { item in
//                    AudioNewsAPIService.shared.getArticleContent(
//                        forTitle: item.title,
//                        withDescription: item.summary,
//                        andSource: nil
//                    )
//                }
//                
//                // Save to database in background
//                AudioPersistenceManager.shared.saveTechnicalBriefs(items, fullContents: fullContents) { result in
//                    if case .success(let saved) = result {
//                        print("💾 Saved \(saved.count) technical briefs to database")
//                    }
//                }
//                
//                completion(items)
//                
//            case .failure(let error):
//                print("❌ API Error: \(error.localizedDescription). Using static data.")
//                completion(self?.topChoices ?? [])
//            }
//        }
//    }
//    
//    // MARK: - Load Filtered Briefs for Toolkit (from Supabase)
//    
//    /// Load filtered briefs for a specific toolkit from Supabase
//    func loadFilteredBriefsFromDatabase(for toolkitName: String, completion: @escaping ([TopChoiceItem]) -> Void) {
//        AudioPersistenceManager.shared.fetchBriefsByToolkit(toolkitName, limit: 50) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let audioBriefs):
//                    if !audioBriefs.isEmpty {
//                        let briefs = audioBriefs.map { $0.toTopChoiceItem() }
//                        print("✅ Loaded \(briefs.count) briefs for \(toolkitName) from database")
//                        completion(briefs)
//                    } else {
//                        // Database has no content for this toolkit, fetch from API
//                        print("📡 No content for \(toolkitName), fetching from API...")
//                        self?.fetchAndSaveFilteredBriefs(for: toolkitName, completion: completion)
//                    }
//                    
//                case .failure(let error):
//                    print("⚠️ Database fetch failed: \(error.localizedDescription), using API")
//                    self?.fetchAndSaveFilteredBriefs(for: toolkitName, completion: completion)
//                }
//            }
//        }
//    }
//    
//    private func fetchAndSaveFilteredBriefs(for toolkitName: String, completion: @escaping ([TopChoiceItem]) -> Void) {
//        AudioNewsAPIService.shared.fetchFilteredBriefs(for: toolkitName) { [weak self] result in
//            switch result {
//            case .success(let items):
//                // Get full contents
//                let fullContents = items.map { item in
//                    AudioNewsAPIService.shared.getArticleContent(
//                        forTitle: item.title,
//                        withDescription: item.summary,
//                        andSource: nil
//                    )
//                }
//                
//                // Save to database
//                AudioPersistenceManager.shared.saveTechnicalBriefs(items, fullContents: fullContents) { result in
//                    if case .success(let saved) = result {
//                        print("💾 Saved \(saved.count) filtered briefs for \(toolkitName)")
//                    }
//                }
//                
//                completion(items)
//                
//            case .failure(let error):
//                print("❌ API Error: \(error.localizedDescription)")
//                let staticFiltered = self?.getFilteredBriefs(for: toolkitName) ?? []
//                completion(staticFiltered)
//            }
//        }
//    }
//    
//    // MARK: - Get Full Article Content (from Supabase)
//    
//    /// Gets the full article content for a TopChoiceItem from Supabase
//    /// First tries database, then falls back to API cache, then static transcripts
//    func getArticleContentFromDatabase(for item: TopChoiceItem, fallbackIndex: Int, completion: @escaping (String) -> Void) {
//        // Try to get from database first
//        AudioPersistenceManager.shared.getFullContent(forTitle: item.title) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let content):
//                    print("✅ Retrieved full content from database for: \(item.title)")
//                    completion(content)
//                    
//                case .failure:
//                    print("⚠️ Content not in database, trying API cache...")
//                    // Fall back to API cache
//                    let apiContent = AudioNewsAPIService.shared.getArticleContent(
//                        forTitle: item.title,
//                        withDescription: item.summary,
//                        andSource: nil
//                    )
//                    
//                    // Check if we got real content from API
//                    if apiContent.contains(item.title) && apiContent.count > 200 {
//                        completion(apiContent)
//                    } else {
//                        // Last resort: static transcripts
//                        print("⚠️ Using static transcript as final fallback")
//                        let staticContent = self?.getFullTranscript(for: fallbackIndex) ?? "Content not available."
//                        completion(staticContent)
//                    }
//                }
//            }
//        }
//    }
//    
//    /// Synchronous version that tries API cache and static fallback immediately
//    /// Use this when you need content right away without async callback
//    func getArticleContentSync(for item: TopChoiceItem, fallbackIndex: Int) -> String {
//        // Try API cache first
//        let apiContent = AudioNewsAPIService.shared.getArticleContent(
//            forTitle: item.title,
//            withDescription: item.summary,
//            andSource: nil
//        )
//        
//        // Check if we got real content
//        if apiContent.contains(item.title) && apiContent.count > 200 {
//            return apiContent
//        }
//        
//        // Fall back to static transcripts
//        return getFullTranscript(for: fallbackIndex)
//    }
//    
//    // MARK: - Refresh All Data (API to Database)
//    
//    /// Refresh all data from API and save to database
//    func refreshAllAudioData(completion: @escaping (Bool) -> Void) {
//        let group = DispatchGroup()
//        var hasErrors = false
//        
//        // Refresh breaking news
//        group.enter()
//        fetchAndSaveBreakingNews { _ in
//            group.leave()
//        }
//        
//        // Refresh technical briefs
//        group.enter()
//        fetchAndSaveTechnicalBriefs { _ in
//            group.leave()
//        }
//        
//        group.notify(queue: .main) {
//            print(hasErrors ? "⚠️ Some errors during refresh" : "✅ All audio data refreshed")
//            completion(!hasErrors)
//        }
//    }
//}






//
//// AudioDataStore+Supabase.swift
//// Updated AudioDataStore to fetch audio content from Supabase instead of directly from API
//
//import UIKit
//
//// MARK: - Extended Audio Data Store with Supabase Integration
//extension AudioDataStore {
//    
//    // MARK: - Load Breaking News (from Supabase)
//    
//    /// Load breaking news from Supabase database
//    /// Falls back to API if database is empty or fails
//    func loadBreakingNewsFromDatabase(completion: @escaping ([BreakingNewsItem]) -> Void) {
//        AudioPersistenceManager.shared.fetchBreakingNews(limit: 10) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let audioBriefs):
//                    if !audioBriefs.isEmpty {
//                        let breakingNews = audioBriefs.map { $0.toBreakingNewsItem() }
//                        print("✅ Loaded \(breakingNews.count) breaking news items from database")
//                        completion(breakingNews)
//                    } else {
//                        // Database is empty, fetch from API and save
//                        print("📡 Database empty, fetching breaking news from API...")
//                        self?.fetchAndSaveBreakingNews(completion: completion)
//                    }
//                    
//                case .failure(let error):
//                    print("⚠️ Database fetch failed: \(error.localizedDescription), using API")
//                    self?.fetchAndSaveBreakingNews(completion: completion)
//                }
//            }
//        }
//    }
//    
//    private func fetchAndSaveBreakingNews(completion: @escaping ([BreakingNewsItem]) -> Void) {
//        AudioNewsAPIService.shared.fetchBreakingNews { [weak self] result in
//            switch result {
//            case .success(let items):
//                // Get full contents from API service cache
//                let fullContents = items.map { item in
//                    AudioNewsAPIService.shared.getArticleContent(
//                        forTitle: item.headline,
//                        withDescription: nil,
//                        andSource: item.source
//                    )
//                }
//                
//                // Save to database in background
//                AudioPersistenceManager.shared.saveBreakingNews(items, fullContents: fullContents) { result in
//                    if case .success(let saved) = result {
//                        print("💾 Saved \(saved.count) breaking news items to database")
//                    }
//                }
//                
//                completion(items)
//                
//            case .failure(let error):
//                print("❌ API Error: \(error.localizedDescription). Using static data.")
//                completion(self?.breakingNews ?? [])
//            }
//        }
//    }
//    
//    // MARK: - Load All Technical Briefs (from Supabase)
//    
//    /// Load all technical briefs from Supabase
//    /// Shows today's briefs first, then older content
//    func loadAllTechnicalBriefsFromDatabase(completion: @escaping ([TopChoiceItem]) -> Void) {
//        AudioPersistenceManager.shared.fetchAllAudio(limit: 100) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let audioBriefs):
//                    if !audioBriefs.isEmpty {
//                        let briefs = audioBriefs.map { $0.toTopChoiceItem() }
//                        print("✅ Loaded \(briefs.count) technical briefs from database")
//                        completion(briefs)
//                    } else {
//                        // Database is empty, fetch from API and save
//                        print("📡 Database empty, fetching technical briefs from API...")
//                        self?.fetchAndSaveTechnicalBriefs(completion: completion)
//                    }
//                    
//                case .failure(let error):
//                    print("⚠️ Database fetch failed: \(error.localizedDescription), using API")
//                    self?.fetchAndSaveTechnicalBriefs(completion: completion)
//                }
//            }
//        }
//    }
//    
//    /// Load today's audio only (for the main screen)
//    func loadTodaysAudioFromDatabase(completion: @escaping ([TopChoiceItem]) -> Void) {
//        AudioPersistenceManager.shared.fetchTodaysAudio { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let audioBriefs):
//                    if !audioBriefs.isEmpty {
//                        let briefs = audioBriefs.map { $0.toTopChoiceItem() }
//                        print("✅ Loaded \(briefs.count) today's audio items from database")
//                        completion(briefs)
//                    } else {
//                        // No today's content, fetch from API
//                        print("📡 No today's content, fetching from API...")
//                        self?.fetchAndSaveTechnicalBriefs(completion: completion)
//                    }
//                    
//                case .failure(let error):
//                    print("⚠️ Database fetch failed: \(error.localizedDescription), using API")
//                    self?.fetchAndSaveTechnicalBriefs(completion: completion)
//                }
//            }
//        }
//    }
//    
//    private func fetchAndSaveTechnicalBriefs(completion: @escaping ([TopChoiceItem]) -> Void) {
//        AudioNewsAPIService.shared.fetchAllTechnicalBriefs { [weak self] result in
//            switch result {
//            case .success(let items):
//                // Get full contents from API service cache
//                let fullContents = items.map { item in
//                    AudioNewsAPIService.shared.getArticleContent(
//                        forTitle: item.title,
//                        withDescription: item.summary,
//                        andSource: nil
//                    )
//                }
//                
//                // Save to database in background
//                AudioPersistenceManager.shared.saveTechnicalBriefs(items, fullContents: fullContents) { result in
//                    if case .success(let saved) = result {
//                        print("💾 Saved \(saved.count) technical briefs to database")
//                    }
//                }
//                
//                completion(items)
//                
//            case .failure(let error):
//                print("❌ API Error: \(error.localizedDescription). Using static data.")
//                completion(self?.topChoices ?? [])
//            }
//        }
//    }
//    
//    // MARK: - Load Filtered Briefs for Toolkit (from Supabase)
//    
//    /// Load filtered briefs for a specific toolkit from Supabase
//    func loadFilteredBriefsFromDatabase(for toolkitName: String, completion: @escaping ([TopChoiceItem]) -> Void) {
//        AudioPersistenceManager.shared.fetchBriefsByToolkit(toolkitName, limit: 50) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let audioBriefs):
//                    if !audioBriefs.isEmpty {
//                        let briefs = audioBriefs.map { $0.toTopChoiceItem() }
//                        print("✅ Loaded \(briefs.count) briefs for \(toolkitName) from database")
//                        completion(briefs)
//                    } else {
//                        // Database has no content for this toolkit, fetch from API
//                        print("📡 No content for \(toolkitName), fetching from API...")
//                        self?.fetchAndSaveFilteredBriefs(for: toolkitName, completion: completion)
//                    }
//                    
//                case .failure(let error):
//                    print("⚠️ Database fetch failed: \(error.localizedDescription), using API")
//                    self?.fetchAndSaveFilteredBriefs(for: toolkitName, completion: completion)
//                }
//            }
//        }
//    }
//    
//    private func fetchAndSaveFilteredBriefs(for toolkitName: String, completion: @escaping ([TopChoiceItem]) -> Void) {
//        AudioNewsAPIService.shared.fetchFilteredBriefs(for: toolkitName) { [weak self] result in
//            switch result {
//            case .success(let items):
//                // Get full contents
//                let fullContents = items.map { item in
//                    AudioNewsAPIService.shared.getArticleContent(
//                        forTitle: item.title,
//                        withDescription: item.summary,
//                        andSource: nil
//                    )
//                }
//                
//                // Save to database
//                AudioPersistenceManager.shared.saveTechnicalBriefs(items, fullContents: fullContents) { result in
//                    if case .success(let saved) = result {
//                        print("💾 Saved \(saved.count) filtered briefs for \(toolkitName)")
//                    }
//                }
//                
//                completion(items)
//                
//            case .failure(let error):
//                print("❌ API Error: \(error.localizedDescription)")
//                let staticFiltered = self?.getFilteredBriefs(for: toolkitName) ?? []
//                completion(staticFiltered)
//            }
//        }
//    }
//    
//    // MARK: - Get Full Article Content (from Supabase)
//    
//    /// Gets the full article content for a TopChoiceItem from Supabase
//    /// First tries database, then falls back to API cache, then static transcripts
//    func getArticleContentFromDatabase(for item: TopChoiceItem, fallbackIndex: Int, completion: @escaping (String) -> Void) {
//        // Try to get from database first
//        AudioPersistenceManager.shared.getFullContent(forTitle: item.title) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let content):
//                    print("✅ Retrieved full content from database for: \(item.title)")
//                    completion(content)
//                    
//                case .failure:
//                    print("⚠️ Content not in database, trying API cache...")
//                    // Fall back to API cache
//                    let apiContent = AudioNewsAPIService.shared.getArticleContent(
//                        forTitle: item.title,
//                        withDescription: item.summary,
//                        andSource: nil
//                    )
//                    
//                    // Check if we got real content from API
//                    if apiContent.contains(item.title) && apiContent.count > 200 {
//                        completion(apiContent)
//                    } else {
//                        // Last resort: static transcripts
//                        print("⚠️ Using static transcript as final fallback")
//                        let staticContent = self?.getFullTranscript(for: fallbackIndex) ?? "Content not available."
//                        completion(staticContent)
//                    }
//                }
//            }
//        }
//    }
//    
//    /// Synchronous version that tries API cache and static fallback immediately
//    /// Use this when you need content right away without async callback
//    func getArticleContentSync(for item: TopChoiceItem, fallbackIndex: Int) -> String {
//        // Try API cache first
//        let apiContent = AudioNewsAPIService.shared.getArticleContent(
//            forTitle: item.title,
//            withDescription: item.summary,
//            andSource: nil
//        )
//        
//        // Check if we got real content
//        if apiContent.contains(item.title) && apiContent.count > 200 {
//            return apiContent
//        }
//        
//        // Fall back to static transcripts
//        return getFullTranscript(for: fallbackIndex)
//    }
//    
//    // MARK: - Refresh All Data (API to Database)
//    
//    /// Refresh only breaking news from API and save to database
//    /// Used for the daily auto-refresh on the breaking news carousel
//    func refreshBreakingNewsOnly(completion: @escaping (Bool) -> Void) {
//        fetchAndSaveBreakingNews { items in
//            completion(!items.isEmpty)
//        }
//    }
//    
//    /// Refresh all data from API and save to database
//    func refreshAllAudioData(completion: @escaping (Bool) -> Void) {
//        let group = DispatchGroup()
//        var hasErrors = false
//        
//        // Refresh breaking news
//        group.enter()
//        fetchAndSaveBreakingNews { _ in
//            group.leave()
//        }
//        
//        // Refresh technical briefs
//        group.enter()
//        fetchAndSaveTechnicalBriefs { _ in
//            group.leave()
//        }
//        
//        group.notify(queue: .main) {
//            print(hasErrors ? "⚠️ Some errors during refresh" : "✅ All audio data refreshed")
//            completion(!hasErrors)
//        }
//    }
//}





// AudioDataStore+Supabase.swift
// Updated AudioDataStore to fetch audio content from Supabase instead of directly from API

import UIKit

// MARK: - Extended Audio Data Store with Supabase Integration
extension AudioDataStore {
    
    // MARK: - Load Breaking News (from Supabase)
    
    /// Load breaking news from Supabase database
    /// Falls back to API if database is empty or fails
    func loadBreakingNewsFromDatabase(completion: @escaping ([BreakingNewsItem]) -> Void) {
        AudioPersistenceManager.shared.fetchBreakingNews(limit: 5) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let audioBriefs):
                    if !audioBriefs.isEmpty {
                        let breakingNews = audioBriefs.map { $0.toBreakingNewsItem() }
                        print("✅ Loaded \(breakingNews.count) breaking news items from database")
                        completion(breakingNews)
                    } else {
                        // Database is empty, fetch from API and save
                        print("📡 Database empty, fetching breaking news from API...")
                        self?.fetchAndSaveBreakingNews(completion: completion)
                    }
                    
                case .failure(let error):
                    print("⚠️ Database fetch failed: \(error.localizedDescription), using API")
                    self?.fetchAndSaveBreakingNews(completion: completion)
                }
            }
        }
    }
    
    private func fetchAndSaveBreakingNews(completion: @escaping ([BreakingNewsItem]) -> Void) {
        AudioNewsAPIService.shared.fetchBreakingNews { [weak self] result in
            switch result {
            case .success(let items):
                // Take only the top 5 freshest items
                let top5 = Array(items.prefix(5))
                
                let fullContents = top5.map { item in
                    AudioNewsAPIService.shared.getArticleContent(
                        forTitle: item.headline,
                        withDescription: nil,
                        andSource: item.source
                    )
                }
                
                // REPLACE (delete old + insert new) so stale breaking news never lingers
                AudioPersistenceManager.shared.replaceBreakingNews(top5, fullContents: fullContents) { result in
                    if case .success(let saved) = result {
                        print("💾 Replaced breaking news with \(saved.count) fresh items")
                    }
                }
                
                completion(top5)
                
            case .failure(let error):
                print("❌ API Error: \(error.localizedDescription). Using static data.")
                completion(self?.breakingNews ?? [])
            }
        }
    }
    
    // MARK: - Load All Technical Briefs (from Supabase)
    
    /// Load all technical briefs from Supabase
    /// Shows today's briefs first, then older content
    func loadAllTechnicalBriefsFromDatabase(completion: @escaping ([TopChoiceItem]) -> Void) {
        AudioPersistenceManager.shared.fetchAllAudio(limit: 100) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let audioBriefs):
                    if !audioBriefs.isEmpty {
                        let briefs = audioBriefs.map { $0.toTopChoiceItem() }
                        print("✅ Loaded \(briefs.count) technical briefs from database")
                        completion(briefs)
                    } else {
                        // Database is empty, fetch from API and save
                        print("📡 Database empty, fetching technical briefs from API...")
                        self?.fetchAndSaveTechnicalBriefs(completion: completion)
                    }
                    
                case .failure(let error):
                    print("⚠️ Database fetch failed: \(error.localizedDescription), using API")
                    self?.fetchAndSaveTechnicalBriefs(completion: completion)
                }
            }
        }
    }
    
    /// Load today's audio only (for the main screen)
    func loadTodaysAudioFromDatabase(completion: @escaping ([TopChoiceItem]) -> Void) {
        AudioPersistenceManager.shared.fetchTodaysAudio { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let audioBriefs):
                    if !audioBriefs.isEmpty {
                        let briefs = audioBriefs.map { $0.toTopChoiceItem() }
                        print("✅ Loaded \(briefs.count) today's audio items from database")
                        completion(briefs)
                    } else {
                        // No today's content, fetch from API
                        print("📡 No today's content, fetching from API...")
                        self?.fetchAndSaveTechnicalBriefs(completion: completion)
                    }
                    
                case .failure(let error):
                    print("⚠️ Database fetch failed: \(error.localizedDescription), using API")
                    self?.fetchAndSaveTechnicalBriefs(completion: completion)
                }
            }
        }
    }
    
    private func fetchAndSaveTechnicalBriefs(completion: @escaping ([TopChoiceItem]) -> Void) {
        AudioNewsAPIService.shared.fetchAllTechnicalBriefs { [weak self] result in
            switch result {
            case .success(let items):
                // Get full contents from API service cache
                let fullContents = items.map { item in
                    AudioNewsAPIService.shared.getArticleContent(
                        forTitle: item.title,
                        withDescription: item.summary,
                        andSource: nil
                    )
                }
                
                // Save to database in background
                AudioPersistenceManager.shared.saveTechnicalBriefs(items, fullContents: fullContents) { result in
                    if case .success(let saved) = result {
                        print("💾 Saved \(saved.count) technical briefs to database")
                    }
                }
                
                completion(items)
                
            case .failure(let error):
                print("❌ API Error: \(error.localizedDescription). Using static data.")
                completion(self?.topChoices ?? [])
            }
        }
    }
    
    // MARK: - Load Filtered Briefs for Toolkit (from Supabase)
    
    /// Load filtered briefs for a specific toolkit from Supabase
    func loadFilteredBriefsFromDatabase(for toolkitName: String, completion: @escaping ([TopChoiceItem]) -> Void) {
        AudioPersistenceManager.shared.fetchBriefsByToolkit(toolkitName, limit: 50) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let audioBriefs):
                    if !audioBriefs.isEmpty {
                        let briefs = audioBriefs.map { $0.toTopChoiceItem() }
                        print("✅ Loaded \(briefs.count) briefs for \(toolkitName) from database")
                        completion(briefs)
                    } else {
                        // Database has no content for this toolkit, fetch from API
                        print("📡 No content for \(toolkitName), fetching from API...")
                        self?.fetchAndSaveFilteredBriefs(for: toolkitName, completion: completion)
                    }
                    
                case .failure(let error):
                    print("⚠️ Database fetch failed: \(error.localizedDescription), using API")
                    self?.fetchAndSaveFilteredBriefs(for: toolkitName, completion: completion)
                }
            }
        }
    }
    
    private func fetchAndSaveFilteredBriefs(for toolkitName: String, completion: @escaping ([TopChoiceItem]) -> Void) {
        AudioNewsAPIService.shared.fetchFilteredBriefs(for: toolkitName) { [weak self] result in
            switch result {
            case .success(let items):
                // Get full contents
                let fullContents = items.map { item in
                    AudioNewsAPIService.shared.getArticleContent(
                        forTitle: item.title,
                        withDescription: item.summary,
                        andSource: nil
                    )
                }
                
                // Save to database
                AudioPersistenceManager.shared.saveTechnicalBriefs(items, fullContents: fullContents) { result in
                    if case .success(let saved) = result {
                        print("💾 Saved \(saved.count) filtered briefs for \(toolkitName)")
                    }
                }
                
                completion(items)
                
            case .failure(let error):
                print("❌ API Error: \(error.localizedDescription)")
                let staticFiltered = self?.getFilteredBriefs(for: toolkitName) ?? []
                completion(staticFiltered)
            }
        }
    }
    
    // MARK: - Get Full Article Content (from Supabase)
    
    /// Gets the full article content for a TopChoiceItem from Supabase
    /// First tries database, then falls back to API cache, then static transcripts
    func getArticleContentFromDatabase(for item: TopChoiceItem, fallbackIndex: Int, completion: @escaping (String) -> Void) {
        // Try to get from database first
        AudioPersistenceManager.shared.getFullContent(forTitle: item.title) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let content):
                    print("✅ Retrieved full content from database for: \(item.title)")
                    completion(content)
                    
                case .failure:
                    print("⚠️ Content not in database, trying API cache...")
                    // Fall back to API cache
                    let apiContent = AudioNewsAPIService.shared.getArticleContent(
                        forTitle: item.title,
                        withDescription: item.summary,
                        andSource: nil
                    )
                    
                    // Check if we got real content from API
                    if apiContent.contains(item.title) && apiContent.count > 200 {
                        completion(apiContent)
                    } else {
                        // Last resort: static transcripts
                        print("⚠️ Using static transcript as final fallback")
                        let staticContent = self?.getFullTranscript(for: fallbackIndex) ?? "Content not available."
                        completion(staticContent)
                    }
                }
            }
        }
    }
    
    /// Synchronous version that tries API cache and static fallback immediately
    /// Use this when you need content right away without async callback
    func getArticleContentSync(for item: TopChoiceItem, fallbackIndex: Int) -> String {
        // Try API cache first
        let apiContent = AudioNewsAPIService.shared.getArticleContent(
            forTitle: item.title,
            withDescription: item.summary,
            andSource: nil
        )
        
        // Check if we got real content
        if apiContent.contains(item.title) && apiContent.count > 200 {
            return apiContent
        }
        
        // Fall back to static transcripts
        return getFullTranscript(for: fallbackIndex)
    }
    
    // MARK: - Refresh All Data (API to Database)
    
    /// Refresh only breaking news — delete old rows and insert fresh top 5.
    /// Called automatically every new calendar day from NewAudioViewController.
    func refreshBreakingNewsOnly(completion: @escaping (Bool) -> Void) {
        fetchAndSaveBreakingNews { items in
            completion(!items.isEmpty)
        }
    }
    
    /// Refresh all data from API and save to database
    func refreshAllAudioData(completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var hasErrors = false
        
        // Refresh breaking news
        group.enter()
        fetchAndSaveBreakingNews { _ in
            group.leave()
        }
        
        // Refresh technical briefs
        group.enter()
        fetchAndSaveTechnicalBriefs { _ in
            group.leave()
        }
        
        group.notify(queue: .main) {
            print(hasErrors ? "⚠️ Some errors during refresh" : "✅ All audio data refreshed")
            completion(!hasErrors)
        }
    }
}

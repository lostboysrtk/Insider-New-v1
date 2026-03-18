//
//  AudioDataStore+API.swift
//  Insider
//
//  Hybrid approach: API data with full article content
//

import UIKit

// MARK: - Extended Audio Data Store with API Integration
extension AudioDataStore {
    
    // MARK: - Load Breaking News (API)
    func loadBreakingNews(completion: @escaping ([BreakingNewsItem]) -> Void) {
        AudioNewsAPIService.shared.fetchBreakingNews { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    completion(items)
                    
                case .failure(let error):
                    print("⚠️ API Error: \(error.localizedDescription). Using static data.")
                    completion(self?.breakingNews ?? [])
                }
            }
        }
    }
    
    // MARK: - Load All Technical Briefs (API)
    func loadAllTechnicalBriefs(completion: @escaping ([TopChoiceItem]) -> Void) {
        AudioNewsAPIService.shared.fetchAllTechnicalBriefs { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    completion(items)
                    
                case .failure(let error):
                    print("⚠️ API Error: \(error.localizedDescription). Using static data.")
                    completion(self?.topChoices ?? [])
                }
            }
        }
    }
    
    // MARK: - Load Filtered Briefs for Toolkit (API)
    func loadFilteredBriefs(for toolkitName: String, completion: @escaping ([TopChoiceItem]) -> Void) {
        AudioNewsAPIService.shared.fetchFilteredBriefs(for: toolkitName) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let items):
                    completion(items)
                    
                case .failure(let error):
                    print("⚠️ API Error: \(error.localizedDescription). Using static filtered data.")
                    let staticFiltered = self?.getFilteredBriefs(for: toolkitName) ?? []
                    completion(staticFiltered)
                }
            }
        }
    }
    
    // MARK: - Get Full Article Content for Item
    /// Gets the full article content for a TopChoiceItem
    /// First tries to get cached API content, then falls back to static transcripts
    func getArticleContent(for item: TopChoiceItem, fallbackIndex: Int) -> String {
        // Try to get full article content from API cache
        let apiContent = AudioNewsAPIService.shared.getArticleContent(
            forTitle: item.title,
            withDescription: item.summary,
            andSource: nil
        )
        
        // Check if we got real content (not just a fallback message)
        if apiContent.contains(item.title) && apiContent.count > 200 {
            return apiContent
        }
        
        // Fall back to static transcripts if available
        return getFullTranscript(for: fallbackIndex)
    }
    
    // MARK: - Refresh All Data
    func refreshAllData(completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var hasErrors = false
        
        group.enter()
        loadBreakingNews { _ in
            group.leave()
        }
        
        group.enter()
        loadAllTechnicalBriefs { _ in
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(!hasErrors)
        }
    }
}

// MARK: - Usage in Audio Player
/*
 
 In NewAudioPlayerViewController.swift:
 
 private func setupData() {
     allBriefs = AudioDataStore.shared.topChoices
     
     if let item = newsItem {
         if let index = allBriefs.firstIndex(where: { $0.title == item.title }) {
             currentBriefIndex = index
             transcriptIndex = index
         }
     }
     
     // Load the full article content
     loadArticleContent()
     calculateDuration()
 }
 
 private func loadArticleContent() {
     guard let item = newsItem else { return }
     
     let content = AudioDataStore.shared.getArticleContent(for: item, fallbackIndex: transcriptIndex)
     transcriptTextView.text = content
     
     // Update the attributed text for transcript highlighting
     transcriptTextView.attributedText = NSAttributedString(
         string: content,
         attributes: [
             .foregroundColor: UIColor.label.withAlphaComponent(0.3),
             .font: UIFont.systemFont(ofSize: 28, weight: .semibold)
         ]
     )
 }
 
 */

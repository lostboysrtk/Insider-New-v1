//
//  Notificationmanager+ui.swift
//  Insider
//
//  Created by Sarthak Sharma on 04/02/26.
//

//
//  NotificationManager+UI.swift
//  Insider
//
//  Extension to convert NotificationManager events to NotificationItems for UI
//

import Foundation

extension NotificationManager {
    
    // Helper to create notification items for the UI
    func createNotificationItem(
        from userInfo: [AnyHashable: Any],
        id: String,
        timestamp: Date = Date()
    ) -> NotificationItem? {
        
        guard let type = userInfo["type"] as? String else { return nil }
        
        let timeAgo = timestamp.timeAgoString()
        
        switch type {
        case "reply":
            guard let discussionId = userInfo["discussion_id"] as? String,
                  let topic = userInfo["topic"] as? String else { return nil }
            
            // Extract username from notification title or body
            let username = userInfo["username"] as? String ?? "Someone"
            let comment = userInfo["comment"] as? String ?? "replied to your discussion"
            
            return NotificationItem(
                id: id,
                type: .reply(
                    discussion: topic,
                    username: username,
                    comment: comment,
                    discussionId: discussionId,
                    time: timeAgo
                ),
                isRead: false,
                timestamp: timestamp,
                category: .discussions
            )
            
        case "like":
            guard let discussionId = userInfo["discussion_id"] as? String,
                  let topic = userInfo["topic"] as? String else { return nil }
            
            let username = userInfo["username"] as? String ?? "Someone"
            
            return NotificationItem(
                id: id,
                type: .like(
                    username: username,
                    discussionTitle: topic,
                    discussionId: discussionId,
                    time: timeAgo
                ),
                isRead: false,
                timestamp: timestamp,
                category: .activity
            )
            
        case "deep_dive":
            guard let topic = userInfo["topic"] as? String else { return nil }
            let summary = userInfo["summary"] as? String ?? "New update available"
            
            return NotificationItem(
                id: id,
                type: .deepDive(topic: topic, summary: summary, time: timeAgo),
                isRead: false,
                timestamp: timestamp,
                category: .forYou
            )
            
        case "streak":
            let days = userInfo["days"] as? Int ?? currentStreak
            
            return NotificationItem(
                id: id,
                type: .streak(days: days, time: timeAgo),
                isRead: false,
                timestamp: timestamp,
                category: .activity
            )
            
        case "milestone":
            let badge = userInfo["badge"] as? String ?? "Achievement"
            let description = userInfo["description"] as? String ?? "New milestone reached"
            
            return NotificationItem(
                id: id,
                type: .milestone(badge: badge, description: description, time: timeAgo),
                isRead: false,
                timestamp: timestamp,
                category: .activity
            )
            
        case "recap":
            let category = userInfo["category"] as? String ?? "Technology"
            let story = userInfo["story"] as? String ?? "Check out what you missed"
            
            return NotificationItem(
                id: id,
                type: .weeklyRecap(topCategory: category, missedStory: story, time: timeAgo),
                isRead: false,
                timestamp: timestamp,
                category: .forYou
            )
            
        case "sentiment":
            guard let topic = userInfo["topic"] as? String else { return nil }
            let from = userInfo["from"] as? String ?? "Neutral"
            let to = userInfo["to"] as? String ?? "Mixed"
            
            return NotificationItem(
                id: id,
                type: .sentiment(topic: topic, from: from, to: to, time: timeAgo),
                isRead: false,
                timestamp: timestamp,
                category: .forYou
            )
            
        case "expert":
            guard let niche = userInfo["niche"] as? String else { return nil }
            let title = userInfo["title"] as? String ?? "New update"
            
            return NotificationItem(
                id: id,
                type: .expert(niche: niche, title: title, time: timeAgo),
                isRead: false,
                timestamp: timestamp,
                category: .forYou
            )
            
        case "correction":
            guard let topic = userInfo["topic"] as? String else { return nil }
            let changes = userInfo["changes"] as? String ?? "Story has been updated"
            
            return NotificationItem(
                id: id,
                type: .correction(topic: topic, changes: changes, time: timeAgo),
                isRead: false,
                timestamp: timestamp,
                category: .forYou
            )
            
        case "trending":
            guard let topic = userInfo["topic"] as? String else { return nil }
            let count = userInfo["count"] as? Int ?? 0
            
            return NotificationItem(
                id: id,
                type: .trending(topic: topic, count: count, time: timeAgo),
                isRead: false,
                timestamp: timestamp,
                category: .forYou
            )
            
        case "morning_brief":
            return NotificationItem(
                id: id,
                type: .morningBrief(time: timeAgo),
                isRead: false,
                timestamp: timestamp,
                category: .forYou
            )
            
        case "evening_brief":
            return NotificationItem(
                id: id,
                type: .eveningBrief(time: timeAgo),
                isRead: false,
                timestamp: timestamp,
                category: .forYou
            )
            
        case "weekly_digest":
            return NotificationItem(
                id: id,
                type: .weeklyDigest(time: timeAgo),
                isRead: false,
                timestamp: timestamp,
                category: .forYou
            )
            
        default:
            return nil
        }
    }
}

// MARK: - Date Extension for Time Ago
extension Date {
    func timeAgoString() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.second, .minute, .hour, .day, .weekOfYear], from: self, to: now)
        
        if let weeks = components.weekOfYear, weeks > 0 {
            return "\(weeks)w"
        } else if let days = components.day, days > 0 {
            return "\(days)d"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)h"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m"
        } else {
            return "now"
        }
    }
}

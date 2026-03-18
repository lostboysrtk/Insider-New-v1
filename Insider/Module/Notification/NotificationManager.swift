////
////  NotificationManager.swift
////  Insider
////
////  Created by Sarthak Sharma on 04/02/26.
////
//
////
////  NotificationManager.swift
////  Insider
////
////  Complete notification system in a single file
////
//
//import UIKit
//import UserNotifications
//
//// MARK: - Notification Manager (All-in-One)
//class NotificationManager: NSObject {
//    
//    static let shared = NotificationManager()
//    private let center = UNUserNotificationCenter.current()
//    
//    // MARK: - User Preferences
//    var enableMorningBrief: Bool = true
//    var enableEveningBrief: Bool = true
//    var enableWeeklyDigest: Bool = true
//    var enableStreakSaver: Bool = true
//    
//    var morningBriefTime: DateComponents = DateComponents(hour: 7, minute: 0)
//    var eveningBriefTime: DateComponents = DateComponents(hour: 18, minute: 0)
//    
//    // User tracking
//    var currentStreak: Int = 0
//    var lastAppOpen: Date = Date()
//    private var readArticles: Set<String> = []
//    private var followedTopics: Set<String> = []
//    
//    private override init() {
//        super.init()
//    }
//    
//    // MARK: - Setup
//    func setup() {
//        center.delegate = self
//        setupNotificationCategories()
//        loadPreferences()
//    }
//    
//    func requestPermission(completion: @escaping (Bool) -> Void) {
//        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
//            DispatchQueue.main.async {
//                if granted {
//                    self.scheduleRecurringNotifications()
//                }
//                completion(granted)
//            }
//        }
//    }
//    
//    private func setupNotificationCategories() {
//        let replyAction = UNNotificationAction(identifier: "REPLY", title: "Reply", options: [.foreground])
//        let viewAction = UNNotificationAction(identifier: "VIEW", title: "View", options: [.foreground])
//        
//        let replyCategory = UNNotificationCategory(identifier: "REPLY_CATEGORY", actions: [replyAction], intentIdentifiers: [])
//        let contentCategory = UNNotificationCategory(identifier: "CONTENT_CATEGORY", actions: [viewAction], intentIdentifiers: [])
//        
//        center.setNotificationCategories([replyCategory, contentCategory])
//    }
//    
//    // MARK: - Schedule Recurring Notifications
//    private func scheduleRecurringNotifications() {
//        if enableMorningBrief {
//            scheduleNotification(
//                id: "morning_brief",
//                title: "☕️ Your Morning Brief is Ready",
//                body: "Get up to speed while you grab your coffee",
//                trigger: UNCalendarNotificationTrigger(dateMatching: morningBriefTime, repeats: true)
//            )
//        }
//        
//        if enableEveningBrief {
//            scheduleNotification(
//                id: "evening_brief",
//                title: "🌙 Your Evening Brief is Ready",
//                body: "Catch up on today's most important stories",
//                trigger: UNCalendarNotificationTrigger(dateMatching: eveningBriefTime, repeats: true)
//            )
//        }
//        
//        if enableWeeklyDigest {
//            var friday = DateComponents()
//            friday.weekday = 6  // Friday
//            friday.hour = 18
//            scheduleNotification(
//                id: "weekly_digest",
//                title: "📰 While You Were Away",
//                body: "This week's most discussed topics are ready",
//                trigger: UNCalendarNotificationTrigger(dateMatching: friday, repeats: true)
//            )
//        }
//    }
//    
//    // MARK: - Send Specific Notifications
//    
//    func sendReply(username: String, comment: String, topic: String, discussionId: String) {
//        scheduleNotification(
//            id: "reply_\(discussionId)",
//            title: "\(username) replied to you",
//            body: comment,
//            category: "REPLY_CATEGORY",
//            userInfo: ["type": "reply", "discussion_id": discussionId, "topic": topic]
//        )
//    }
//    
//    func sendDeepDiveUpdate(topic: String, summary: String) {
//        if followedTopics.contains(topic) {
//            scheduleNotification(
//                id: "deepdive_\(topic)",
//                title: "📍 Update: \(topic)",
//                body: summary,
//                category: "CONTENT_CATEGORY",
//                userInfo: ["type": "deep_dive", "topic": topic]
//            )
//        }
//    }
//    
//    func sendStreakReminder() {
//        if enableStreakSaver && currentStreak > 0 {
//            scheduleNotification(
//                id: "streak_saver",
//                title: "🔥 Don't Lose Your \(currentStreak)-Day Streak!",
//                body: "Read one summary to keep it alive",
//                userInfo: ["type": "streak"]
//            )
//        }
//    }
//    
//    func sendMilestone(badge: String, description: String) {
//        scheduleNotification(
//            id: "milestone_\(badge)",
//            title: "🏆 New Badge Unlocked: \(badge)",
//            body: description,
//            userInfo: ["type": "milestone", "badge": badge]
//        )
//    }
//    
//    func sendWeeklyRecap(topCategory: String, missedStory: String) {
//        scheduleNotification(
//            id: "weekly_recap",
//            title: "📊 Your Weekly Recap",
//            body: "You were most interested in \(topCategory). Here's one you missed.",
//            category: "CONTENT_CATEGORY",
//            userInfo: ["type": "recap", "category": topCategory]
//        )
//    }
//    
//    func sendSentimentShift(topic: String, from: String, to: String) {
//        scheduleNotification(
//            id: "sentiment_\(topic)",
//            title: "💭 Community Mood Shift",
//            body: "Sentiment on \(topic) shifted from '\(from)' to '\(to)'",
//            category: "CONTENT_CATEGORY",
//            userInfo: ["type": "sentiment", "topic": topic]
//        )
//    }
//    
//    func sendExpertUpdate(niche: String, title: String) {
//        scheduleNotification(
//            id: "expert_\(niche)",
//            title: "🎯 Major Update in \(niche)",
//            body: title,
//            category: "CONTENT_CATEGORY",
//            userInfo: ["type": "expert", "niche": niche]
//        )
//    }
//    
//    func sendCorrectionAlert(topic: String, changes: String) {
//        if readArticles.contains(topic) {
//            scheduleNotification(
//                id: "correction_\(topic)",
//                title: "✏️ Story Updated: \(topic)",
//                body: changes,
//                category: "CONTENT_CATEGORY",
//                userInfo: ["type": "correction", "topic": topic]
//            )
//        }
//    }
//    
//    func sendTrending(topic: String, count: Int) {
//        scheduleNotification(
//            id: "trending_\(topic)",
//            title: "🔥 Trending Now: \(topic)",
//            body: "\(count) people are discussing this right now",
//            category: "CONTENT_CATEGORY",
//            userInfo: ["type": "trending", "topic": topic]
//        )
//    }
//    
//    // MARK: - User Activity Tracking
//    
//    func trackAppOpen() {
//        lastAppOpen = Date()
//        clearBadge()
//    }
//    
//    func trackArticleRead(articleId: String, topic: String) {
//        readArticles.insert(articleId)
//        followedTopics.insert(topic)
//    }
//    
//    func trackChatbotUsage(topic: String) {
//        followedTopics.insert(topic)
//    }
//    
//    func updateStreak(_ streak: Int) {
//        currentStreak = streak
//        
//        // Check milestones
//        if [7, 14, 30, 60, 100].contains(streak) {
//            sendMilestone(badge: "\(streak)-Day Streak", description: "Amazing consistency!")
//        }
//    }
//    
//    // MARK: - Core Notification Methods
//    
//    private func scheduleNotification(
//        id: String,
//        title: String,
//        body: String,
//        category: String? = nil,
//        userInfo: [String: Any] = [:],
//        trigger: UNNotificationTrigger? = nil,
//        delay: TimeInterval = 0
//    ) {
//        let content = UNMutableNotificationContent()
//        content.title = title
//        content.body = body
//        content.sound = .default
//        content.badge = 1
//        content.userInfo = userInfo
//        
//        if let category = category {
//            content.categoryIdentifier = category
//        }
//        
//        let finalTrigger = trigger ?? (delay > 0 ? UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false) : nil)
//        
//        let request = UNNotificationRequest(identifier: id, content: content, trigger: finalTrigger)
//        
//        center.add(request) { error in
//            if let error = error {
//                print("❌ Notification error: \(error)")
//            } else {
//                print("✅ Notification scheduled: \(title)")
//            }
//        }
//    }
//    
//    // MARK: - Utility
//    
//    func clearBadge() {
//        UIApplication.shared.applicationIconBadgeNumber = 0
//    }
//    
//    func cancelAllNotifications() {
//        center.removeAllPendingNotificationRequests()
//    }
//    
//    func cancelNotification(id: String) {
//        center.removePendingNotificationRequests(withIdentifiers: [id])
//    }
//    
//    // MARK: - Preferences
//    
//    func savePreferences() {
//        let defaults = UserDefaults.standard
//        defaults.set(enableMorningBrief, forKey: "notif_morning")
//        defaults.set(enableEveningBrief, forKey: "notif_evening")
//        defaults.set(enableWeeklyDigest, forKey: "notif_digest")
//        defaults.set(enableStreakSaver, forKey: "notif_streak")
//    }
//    
//    func loadPreferences() {
//        let defaults = UserDefaults.standard
//        enableMorningBrief = defaults.bool(forKey: "notif_morning")
//        enableEveningBrief = defaults.bool(forKey: "notif_evening")
//        enableWeeklyDigest = defaults.bool(forKey: "notif_digest")
//        enableStreakSaver = defaults.bool(forKey: "notif_streak")
//    }
//}
//
//// MARK: - Notification Delegate
//extension NotificationManager: UNUserNotificationCenterDelegate {
//    
//    // When notification is received while app is open
//    func userNotificationCenter(
//        _ center: UNUserNotificationCenter,
//        willPresent notification: UNNotification,
//        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
//    ) {
//        if #available(iOS 14.0, *) {
//            completionHandler([.banner, .sound, .badge])
//        } else {
//            completionHandler([.alert, .sound, .badge])
//        }
//    }
//    
//    // When user taps notification
//    func userNotificationCenter(
//        _ center: UNUserNotificationCenter,
//        didReceive response: UNNotificationResponse,
//        withCompletionHandler completionHandler: @escaping () -> Void
//    ) {
//        let userInfo = response.notification.request.content.userInfo
//        
//        // Handle navigation based on notification type
//        if let type = userInfo["type"] as? String {
//            handleNotificationTap(type: type, userInfo: userInfo)
//        }
//        
//        completionHandler()
//    }
//    
//    private func handleNotificationTap(type: String, userInfo: [AnyHashable: Any]) {
//        // Post notification for app to handle navigation
//        NotificationCenter.default.post(
//            name: NSNotification.Name("HandleNotificationTap"),
//            object: nil,
//            userInfo: ["type": type, "data": userInfo]
//        )
//    }
//}





//
//  NotificationManager.swift
//  Insider
//
//  Complete notification system - FIXED to show in notification center
//

import UIKit
import UserNotifications

// MARK: - Notification Manager (All-in-One)
class NotificationManager: NSObject {
    
    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()
    
    // MARK: - User Preferences
    var enableMorningBrief: Bool = true
    var enableEveningBrief: Bool = true
    var enableWeeklyDigest: Bool = true
    var enableStreakSaver: Bool = true
    
    var morningBriefTime: DateComponents = DateComponents(hour: 7, minute: 0)
    var eveningBriefTime: DateComponents = DateComponents(hour: 18, minute: 0)
    
    // User tracking
    var currentStreak: Int = 0
    var lastAppOpen: Date = Date()
    private var readArticles: Set<String> = []
    private var followedTopics: Set<String> = []
    
    private override init() {
        super.init()
    }
    
    // MARK: - Setup
    func setup() {
        center.delegate = self
        setupNotificationCategories()
        loadPreferences()
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    print("✅ Notification permission granted")
                    self.scheduleRecurringNotifications()
                }
                completion(granted)
            }
        }
    }
    
    private func setupNotificationCategories() {
        let replyAction = UNNotificationAction(identifier: "REPLY", title: "Reply", options: [.foreground])
        let viewAction = UNNotificationAction(identifier: "VIEW", title: "View", options: [.foreground])
        
        let replyCategory = UNNotificationCategory(identifier: "REPLY_CATEGORY", actions: [replyAction], intentIdentifiers: [])
        let contentCategory = UNNotificationCategory(identifier: "CONTENT_CATEGORY", actions: [viewAction], intentIdentifiers: [])
        
        center.setNotificationCategories([replyCategory, contentCategory])
    }
    
    // MARK: - Schedule Recurring Notifications
    private func scheduleRecurringNotifications() {
        if enableMorningBrief {
            scheduleNotification(
                id: "morning_brief",
                title: "☕️ Your Morning Brief is Ready",
                body: "new news came for today, go and check",
                userInfo: ["type": "morning_brief"], trigger: UNCalendarNotificationTrigger(dateMatching: morningBriefTime, repeats: true)
            )
        }
        
        if enableEveningBrief {
            scheduleNotification(
                id: "evening_brief",
                title: "🌙 Your Evening Brief is Ready",
                body: "Catch up on today's most important stories",
                userInfo: ["type": "evening_brief"], trigger: UNCalendarNotificationTrigger(dateMatching: eveningBriefTime, repeats: true)
            )
        }
        
        if enableWeeklyDigest {
            var friday = DateComponents()
            friday.weekday = 6  // Friday
            friday.hour = 18
            scheduleNotification(
                id: "weekly_digest",
                title: "📰 While You Were Away",
                body: "This week's most discussed topics are ready",
                userInfo: ["type": "weekly_digest"], trigger: UNCalendarNotificationTrigger(dateMatching: friday, repeats: true)
            )
        }
    }
    
    // MARK: - Send Specific Notifications (FIXED - with proper triggers)
    
    func sendReply(username: String, comment: String, topic: String, discussionId: String) {
        // Schedule notification to appear in 1 second (so it shows in notification center)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        scheduleNotification(
            id: "reply_\(discussionId)_\(UUID().uuidString)",
            title: "\(username) replied to you",
            body: comment,
            category: "REPLY_CATEGORY",
            userInfo: [
                "type": "reply",
                "discussion_id": discussionId,
                "topic": topic,
                "username": username,
                "comment": comment
            ],
            trigger: trigger
        )
    }
    
    func sendLike(username: String, discussionTitle: String, discussionId: String) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        scheduleNotification(
            id: "like_\(discussionId)_\(UUID().uuidString)",
            title: "👍 \(username) liked your discussion",
            body: "Someone found your thoughts on \(discussionTitle) helpful.",
            category: "CONTENT_CATEGORY",
            userInfo: [
                "type": "like",
                "discussion_id": discussionId,
                "topic": discussionTitle,
                "username": username
            ],
            trigger: trigger
        )
    }

    
    func sendDeepDiveUpdate(topic: String, summary: String) {
        if followedTopics.contains(topic) {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            scheduleNotification(
                id: "deepdive_\(topic)_\(UUID().uuidString)",
                title: "🔍 Update: \(topic)",
                body: summary,
                category: "CONTENT_CATEGORY",
                userInfo: [
                    "type": "deep_dive",
                    "topic": topic,
                    "summary": summary
                ],
                trigger: trigger
            )
        }
    }
    
    func sendStreakReminder() {
        if enableStreakSaver && currentStreak > 0 {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            scheduleNotification(
                id: "streak_saver_\(UUID().uuidString)",
                title: "🔥 Don't Lose Your \(currentStreak)-Day Streak!",
                body: "Read one summary to keep it alive",
                userInfo: [
                    "type": "streak",
                    "days": currentStreak
                ],
                trigger: trigger
            )
        }
    }
    
    func sendMilestone(badge: String, description: String) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        scheduleNotification(
            id: "milestone_\(badge)_\(UUID().uuidString)",
            title: "🏆 New Badge Unlocked: \(badge)",
            body: description,
            userInfo: [
                "type": "milestone",
                "badge": badge,
                "description": description
            ],
            trigger: trigger
        )
    }
    
    func sendWeeklyRecap(topCategory: String, missedStory: String) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        scheduleNotification(
            id: "weekly_recap_\(UUID().uuidString)",
            title: "📊 Your Weekly Recap",
            body: "You were most interested in \(topCategory). Here's one you missed.",
            category: "CONTENT_CATEGORY",
            userInfo: [
                "type": "recap",
                "category": topCategory,
                "story": missedStory
            ],
            trigger: trigger
        )
    }
    
    func sendSentimentShift(topic: String, from: String, to: String) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        scheduleNotification(
            id: "sentiment_\(topic)_\(UUID().uuidString)",
            title: "💭 Community Mood Shift",
            body: "Sentiment on \(topic) shifted from '\(from)' to '\(to)'",
            category: "CONTENT_CATEGORY",
            userInfo: [
                "type": "sentiment",
                "topic": topic,
                "from": from,
                "to": to
            ],
            trigger: trigger
        )
    }
    
    func sendExpertUpdate(niche: String, title: String) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        scheduleNotification(
            id: "expert_\(niche)_\(UUID().uuidString)",
            title: "🎯 Major Update in \(niche)",
            body: title,
            category: "CONTENT_CATEGORY",
            userInfo: [
                "type": "expert",
                "niche": niche,
                "title": title
            ],
            trigger: trigger
        )
    }
    
    func sendCorrectionAlert(topic: String, changes: String) {
        if readArticles.contains(topic) {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            scheduleNotification(
                id: "correction_\(topic)_\(UUID().uuidString)",
                title: "✏️ Story Updated: \(topic)",
                body: changes,
                category: "CONTENT_CATEGORY",
                userInfo: [
                    "type": "correction",
                    "topic": topic,
                    "changes": changes
                ],
                trigger: trigger
            )
        }
    }
    
    func sendTrending(topic: String, count: Int) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        scheduleNotification(
            id: "trending_\(topic)_\(UUID().uuidString)",
            title: "🔥 Trending Now: \(topic)",
            body: "\(count) people are discussing this right now",
            category: "CONTENT_CATEGORY",
            userInfo: [
                "type": "trending",
                "topic": topic,
                "count": count
            ],
            trigger: trigger
        )
    }
    
    // MARK: - User Activity Tracking
    
    func trackAppOpen() {
        lastAppOpen = Date()
        clearBadge()
    }
    
    func trackArticleRead(articleId: String, topic: String) {
        readArticles.insert(articleId)
        followedTopics.insert(topic)
    }
    
    func trackChatbotUsage(topic: String) {
        followedTopics.insert(topic)
    }
    
    func updateStreak(_ streak: Int) {
        currentStreak = streak
        
        // Check milestones
        if [7, 14, 30, 60, 100].contains(streak) {
            sendMilestone(badge: "\(streak)-Day Streak", description: "Amazing consistency!")
        }
    }
    
    // MARK: - Core Notification Methods
    
    private func scheduleNotification(
        id: String,
        title: String,
        body: String,
        category: String? = nil,
        userInfo: [String: Any] = [:],
        trigger: UNNotificationTrigger?
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        content.userInfo = userInfo
        
        if let category = category {
            content.categoryIdentifier = category
        }
        
        // CRITICAL: trigger must not be nil for notifications to appear in notification center
        guard let trigger = trigger else {
            print("⚠️ Warning: No trigger provided for notification '\(title)'. Using 1 second delay.")
            let defaultTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: id, content: content, trigger: defaultTrigger)
            
            center.add(request) { error in
                if let error = error {
                    print("❌ Notification error: \(error)")
                } else {
                    print("✅ Notification scheduled: \(title)")
                }
            }
            return
        }
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("❌ Notification error: \(error)")
            } else {
                print("✅ Notification scheduled: \(title)")
            }
        }
    }
    
    // MARK: - Utility
    
    func clearBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
    
    func cancelNotification(id: String) {
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    // MARK: - Preferences
    
    func savePreferences() {
        let defaults = UserDefaults.standard
        defaults.set(enableMorningBrief, forKey: "notif_morning")
        defaults.set(enableEveningBrief, forKey: "notif_evening")
        defaults.set(enableWeeklyDigest, forKey: "notif_digest")
        defaults.set(enableStreakSaver, forKey: "notif_streak")
    }
    
    func loadPreferences() {
        let defaults = UserDefaults.standard
        enableMorningBrief = defaults.bool(forKey: "notif_morning")
        enableEveningBrief = defaults.bool(forKey: "notif_evening")
        enableWeeklyDigest = defaults.bool(forKey: "notif_digest")
        enableStreakSaver = defaults.bool(forKey: "notif_streak")
    }
}

// MARK: - Notification Delegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    
    // IMPORTANT: This makes notifications appear even when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification banner even when app is open
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    // When user taps notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle navigation based on notification type
        if let type = userInfo["type"] as? String {
            handleNotificationTap(type: type, userInfo: userInfo)
        }
        
        completionHandler()
    }
    
    private func handleNotificationTap(type: String, userInfo: [AnyHashable: Any]) {
        // Post notification for app to handle navigation
        NotificationCenter.default.post(
            name: NSNotification.Name("HandleNotificationTap"),
            object: nil,
            userInfo: ["type": type, "data": userInfo]
        )
    }
}

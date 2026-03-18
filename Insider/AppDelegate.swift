//
//  AppDelegate.swift
//  Insider
//
//  Created by krishna lodha on 07/11/25.
//

import UIKit
import UserNotifications
import GoogleSignIn
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Setup notifications
        setupNotifications()
        
        // Ensure background audio session is ready early
        setupBackgroundAudio()
        
        return true
    }

    private func setupBackgroundAudio() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // Optimized for media playback and Dynamic Island persistence
            try audioSession.setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowBluetoothA2DP])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up global audio session: \(error)")
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Track app open
        handleAppOpen()
    }
    
    // MARK: - Google Sign-In URL Handler
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

// MARK: - Notification Setup & Handling
extension AppDelegate {
    
    func setupNotifications() {
        // Initialize notification manager
        NotificationManager.shared.setup()
        
        // Check current authorization status
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    // First time - request permission
                    self.requestNotificationPermission()
                    
                case .authorized, .provisional:
                    print("✅ Notifications already authorized")
                    // Optionally schedule recurring notifications
                    
                case .denied:
                    print("❌ Notifications denied by user")
                    
                case .ephemeral:
                    print("📱 Ephemeral authorization")
                    
                @unknown default:
                    print("⚠️ Unknown authorization status")
                }
            }
        }
        
        // Listen for notification taps
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNotificationTap(_:)),
            name: NSNotification.Name("HandleNotificationTap"),
            object: nil
        )
    }
    
    private func requestNotificationPermission() {
        NotificationManager.shared.requestPermission { [weak self] granted in
            if granted {
                print("✅ Notification permissions granted")
            } else {
                print("❌ Notification permissions denied")
                // Optionally show alert to user
                DispatchQueue.main.async {
                    self?.showPermissionDeniedAlert()
                }
            }
        }
    }
    
    private func handleAppOpen() {
        // Track app open
        NotificationManager.shared.trackAppOpen()
        
        // Update streak (you should get this from your data model)
        // Example: let currentStreak = UserDefaults.standard.integer(forKey: "reading_streak")
        // NotificationManager.shared.updateStreak(currentStreak)
    }
    
    // MARK: - Handle Permission Denied
    private func showPermissionDeniedAlert() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController else { return }
        
        let alert = UIAlertController(
            title: "Enable Notifications",
            message: "To receive updates about replies, trending topics, and your reading streak, please enable notifications in Settings.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Later", style: .cancel))
        
        rootVC.present(alert, animated: true)
    }
    
    // MARK: - Handle notification navigation
    @objc private func handleNotificationTap(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let type = userInfo["type"] as? String,
              let data = userInfo["data"] as? [AnyHashable: Any] else { return }
        
        print("📱 Notification tapped - Type: \(type)")
        
        // Get the window from scene
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        // Navigate based on notification type
        switch type {
        case "reply":
            if let discussionId = data["discussion_id"] as? String {
                navigateToDiscussion(discussionId, window: window)
            }
            
        case "deep_dive", "sentiment", "expert", "correction", "trending":
            if let topic = data["topic"] as? String {
                navigateToTopic(topic, window: window)
            }
            
        case "streak":
            navigateToFeed(window: window)
            
        case "milestone":
            navigateToBadges(window: window)
            
        case "recap":
            navigateToProfile(window: window)
            
        default:
            navigateToFeed(window: window)
        }
    }
    
    // MARK: - Navigation Helpers
    
    private func navigateToFeed(window: UIWindow) {
        print("📱 Navigate to feed")
        if let tabBar = window.rootViewController as? UITabBarController {
            tabBar.selectedIndex = 0
        }
    }
    
    private func navigateToDiscussion(_ discussionId: String, window: UIWindow) {
        print("📱 Navigate to discussion: \(discussionId)")
        
        // Navigate to discussions tab
        if let tabBar = window.rootViewController as? UITabBarController {
            // Find discussions tab (adjust index as needed)
            tabBar.selectedIndex = 2 // Assuming discussions is at index 2
        }
        
        // TODO: Push to specific discussion view controller
        // Example:
        // if let tabBar = window.rootViewController as? UITabBarController,
        //    let navController = tabBar.selectedViewController as? UINavigationController {
        //     let discussionVC = DiscussionViewController(discussionId: discussionId)
        //     navController.pushViewController(discussionVC, animated: true)
        // }
    }
    
    private func navigateToTopic(_ topic: String, window: UIWindow) {
        print("📱 Navigate to topic: \(topic)")
        navigateToFeed(window: window)
        
        // TODO: Implement topic-specific navigation
        // Example: Show a topic detail view or filter by topic
    }
    
    private func navigateToBadges(window: UIWindow) {
        print("📱 Navigate to badges")
        if let tabBar = window.rootViewController as? UITabBarController {
            tabBar.selectedIndex = 3 // Adjust to your profile/badges tab
        }
    }
    
    private func navigateToProfile(window: UIWindow) {
        print("📱 Navigate to profile")
        if let tabBar = window.rootViewController as? UITabBarController {
            tabBar.selectedIndex = 3 // Adjust to your profile tab
        }
    }
}

// MARK: - Public Test Methods (for testing from other view controllers)
extension AppDelegate {
    
    /// Call this from anywhere to test notifications
    /// Usage: AppDelegate.testNotifications()
    static func testNotifications() {
        print("🧪 Testing all notification types...")
        
        // Test 1: Reply notification (immediate)
        NotificationManager.shared.sendReply(
            username: "mohan_sh9",
            comment: "Great point about Swift Concurrency! 👍",
            topic: "Swift",
            discussionId: "disc_123"
        )
        
        // Test 2: Streak reminder (after 3 seconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            NotificationManager.shared.currentStreak = 25
            NotificationManager.shared.sendStreakReminder()
        }
        
        // Test 3: Milestone badge (after 6 seconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            NotificationManager.shared.sendMilestone(
                badge: "The Fact Checker",
                description: "You've used the chatbot 10 times this week!"
            )
        }
        
        // Test 4: Trending topic (after 9 seconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + 9) {
            NotificationManager.shared.sendTrending(
                topic: "AI Development",
                count: 1247
            )
        }
        
        print("✅ Test notifications scheduled! They will arrive in 0, 3, 6, and 9 seconds.")
    }
    
    /// Test a single notification immediately
    static func testSingleNotification() {
        NotificationManager.shared.sendReply(
            username: "test_user",
            comment: "This is a test notification! If you see this, everything is working! 🎉",
            topic: "Testing",
            discussionId: "test_123"
        )
    }
}

// MARK: - User Activity Tracking Helpers
extension AppDelegate {
    
    /// Call this when user reads an article
    func trackArticleRead(articleId: String, topic: String) {
        NotificationManager.shared.trackArticleRead(
            articleId: articleId,
            topic: topic
        )
    }
    
    /// Call this when user uses the chatbot
    func trackChatbotUsage(topic: String) {
        NotificationManager.shared.trackChatbotUsage(topic: topic)
    }
    
    /// Call this to update the user's reading streak
    func updateReadingStreak(_ streak: Int) {
        NotificationManager.shared.updateStreak(streak)
    }
}

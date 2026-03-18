//
//  Notificationtestviewcontroller.swift
//  Insider
//
//  Created by Sarthak Sharma on 04/02/26.
//

//
//  NotificationTestViewController.swift
//  Insider
//
//  Quick test screen for notifications
//

import UIKit

class NotificationTestViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Test Notifications"
        view.backgroundColor = .systemBackground
        
        setupUI()
    }
    
    private func setupUI() {
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Setup stack view
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        
        // Add header
        let header = UILabel()
        header.text = "Tap any button to test notifications"
        header.font = .systemFont(ofSize: 16, weight: .medium)
        header.textAlignment = .center
        header.numberOfLines = 0
        stackView.addArrangedSubview(header)
        
        // Add test buttons
        addButton(title: "💬 Reply Notification", color: .systemBlue) {
            self.testReply()
        }
        
        addButton(title: "🔥 Streak Reminder", color: .systemOrange) {
            self.testStreak()
        }
        
        addButton(title: "🏆 Milestone Badge", color: .systemYellow) {
            self.testMilestone()
        }
        
        addButton(title: "📊 Weekly Recap", color: .systemPurple) {
            self.testRecap()
        }
        
        addButton(title: "💭 Sentiment Shift", color: .systemPink) {
            self.testSentiment()
        }
        
        addButton(title: "🎯 Expert Update", color: .systemIndigo) {
            self.testExpert()
        }
        
        addButton(title: "✏️ Correction Alert", color: .systemTeal) {
            self.testCorrection()
        }
        
        addButton(title: "🔥 Trending Topic", color: .systemRed) {
            self.testTrending()
        }
        
        // Add separator
        let separator = UIView()
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        separator.backgroundColor = .separator
        stackView.addArrangedSubview(separator)
        
        // Add test all button
        addButton(title: "🧪 TEST ALL (4 notifications)", color: .systemGreen) {
            self.testAll()
        }
        
        // Add check permission button
        addButton(title: "⚙️ Check Permission Status", color: .systemGray) {
            self.checkPermission()
        }
    }
    
    private func addButton(title: String, color: UIColor, action: @escaping () -> Void) {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let tapAction = UIAction { _ in action() }
        button.addAction(tapAction, for: .touchUpInside)
        
        stackView.addArrangedSubview(button)
    }
    
    // MARK: - Test Methods
    
    private func testReply() {
        NotificationManager.shared.sendReply(
            username: "mohan_sh9",
            comment: "I completely agree with your point about Swift's async/await! 👍",
            topic: "Swift",
            discussionId: "disc_swift_123"
        )
        showToast("💬 Reply notification sent!")
    }
    
    private func testStreak() {
        NotificationManager.shared.currentStreak = 25
        NotificationManager.shared.sendStreakReminder()
        showToast("🔥 Streak reminder sent!")
    }
    
    private func testMilestone() {
        NotificationManager.shared.sendMilestone(
            badge: "The Fact Checker",
            description: "You've used the chatbot 10 times this week!"
        )
        showToast("🏆 Milestone badge sent!")
    }
    
    private func testRecap() {
        NotificationManager.shared.sendWeeklyRecap(
            topCategory: "Technology",
            missedStory: "Swift 6.0 Released with Major Improvements"
        )
        showToast("📊 Weekly recap sent!")
    }
    
    private func testSentiment() {
        NotificationManager.shared.sendSentimentShift(
            topic: "Climate Policy",
            from: "Optimistic",
            to: "Concerned"
        )
        showToast("💭 Sentiment shift sent!")
    }
    
    private func testExpert() {
        NotificationManager.shared.sendExpertUpdate(
            niche: "Swift Development",
            title: "Major concurrency improvements announced in Swift 6.0"
        )
        showToast("🎯 Expert update sent!")
    }
    
    private func testCorrection() {
        // First mark as read
        NotificationManager.shared.trackArticleRead(articleId: "article_123", topic: "Tech Merger")
        
        // Then send correction
        NotificationManager.shared.sendCorrectionAlert(
            topic: "Tech Merger",
            changes: "Initial valuation revised upward by 15%"
        )
        showToast("✏️ Correction alert sent!")
    }
    
    private func testTrending() {
        NotificationManager.shared.sendTrending(
            topic: "AI Development",
            count: 1247
        )
        showToast("🔥 Trending notification sent!")
    }
    
    private func testAll() {
        AppDelegate.testNotifications()
        showToast("🧪 Sending 4 test notifications!\nThey will arrive at 0, 3, 6, and 9 seconds.")
    }
    
    private func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                var message = ""
                
                switch settings.authorizationStatus {
                case .authorized:
                    message = "✅ Authorized\nNotifications are enabled!"
                case .denied:
                    message = "❌ Denied\nPlease enable in Settings > Notifications > Insider"
                case .notDetermined:
                    message = "⏳ Not Determined\nPermission hasn't been requested yet"
                case .provisional:
                    message = "⚠️ Provisional\nQuiet notifications only"
                case .ephemeral:
                    message = "📱 Ephemeral\nTemporary authorization"
                @unknown default:
                    message = "❓ Unknown status"
                }
                
                let alert = UIAlertController(
                    title: "Notification Permission",
                    message: message,
                    preferredStyle: .alert
                )
                
                if settings.authorizationStatus == .denied {
                    alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    })
                }
                
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    // MARK: - Toast
    
    private func showToast(_ message: String) {
        let toast = UILabel()
        toast.text = message
        toast.font = .systemFont(ofSize: 14, weight: .medium)
        toast.textColor = .white
        toast.backgroundColor = .black.withAlphaComponent(0.8)
        toast.textAlignment = .center
        toast.numberOfLines = 0
        toast.layer.cornerRadius = 10
        toast.clipsToBounds = true
        toast.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(toast)
        
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            toast.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            toast.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40),
            toast.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
        
        toast.alpha = 0
        UIView.animate(withDuration: 0.3) {
            toast.alpha = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            UIView.animate(withDuration: 0.3) {
                toast.alpha = 0
            } completion: { _ in
                toast.removeFromSuperview()
            }
        }
    }
}

// MARK: - Add to your app
/*
 
 To use this test screen, add a button in your NotificationsViewController:
 
 let testButton = UIButton(type: .system)
 testButton.setTitle("🧪 Test Notifications", for: .normal)
 testButton.addTarget(self, action: #selector(openTestScreen), for: .touchUpInside)
 
 @objc private func openTestScreen() {
     let testVC = NotificationTestViewController()
     navigationController?.pushViewController(testVC, animated: true)
 }
 
 */

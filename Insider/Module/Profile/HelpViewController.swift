
//
//  HelpViewController.swift
//  Insider
//
//  Created by user@1 on 01/02/26.
//

import UIKit
import WebKit

class HelpViewController: UIViewController {
    
    private var webView: WKWebView!
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadHelpContent()
    }
    
    private func setupUI() {
        title = "Help & Support"
        view.backgroundColor = .systemBackground
        
        // Setup navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        // Configure WebView
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        // Set webview background to match system
        webView.scrollView.backgroundColor = .systemBackground
        webView.backgroundColor = .systemBackground
        webView.isOpaque = false
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup loading indicator
        loadingIndicator.color = .systemBlue
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func loadHelpContent() {
        loadingIndicator.startAnimating()
        
        let htmlContent = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Help & Support</title>
            <style>
                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                    -webkit-tap-highlight-color: transparent;
                }
                
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
                    background-color: #ffffff; /* System Background White */
                    color: #000000; /* Text Color Black */
                    padding: 20px;
                    line-height: 1.6;
                }
                
                .container {
                    max-width: 800px;
                    margin: 0 auto;
                }
                
                h1 {
                    font-size: 28px;
                    font-weight: 700;
                    margin-bottom: 10px;
                    color: #000000;
                }
                
                .subtitle {
                    font-size: 13px; /* Changed from 15px to match Account Settings info label */
                    font-weight: 400; /* Regular weight */
                    color: #8e8e93;
                    margin-bottom: 30px;
                }
                
                .search-box {
                    background: #f2f2f7; /* Light Grayish */
                    border-radius: 12px;
                    padding: 12px 16px;
                    margin-bottom: 30px;
                    display: flex;
                    align-items: center;
                    gap: 10px;
                }
                
                .search-box input {
                    background: none;
                    border: none;
                    color: #000000;
                    font-size: 15px; /* Changed from 16px to match Account Settings */
                    font-weight: 400; /* Regular weight */
                    flex: 1;
                    outline: none;
                }
                
                .search-box input::placeholder {
                    color: #8e8e93;
                }
                
                .section {
                    margin-bottom: 30px;
                }
                
                .section-title {
                    font-size: 11px; /* Changed from 13px to match Account Settings section labels */
                    font-weight: 700; /* Bold */
                    color: #8e8e93;
                    margin-bottom: 12px;
                    letter-spacing: 0.5px;
                }
                
                .card {
                    background: #f2f2f7; /* Light Grayish */
                    border-radius: 16px;
                    overflow: hidden;
                    margin-bottom: 12px;
                }
                
                .faq-item {
                    padding: 18px;
                    cursor: pointer;
                    border-bottom: 0.5px solid #d1d1d6;
                }
                
                .faq-item:last-child {
                    border-bottom: none;
                }
                
                .faq-question {
                    font-size: 15px; /* Changed from 16px to match Account Settings */
                    font-weight: 400; /* Changed from 600 to regular */
                    color: #000000;
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                }
                
                .faq-question::after {
                    content: '›';
                    font-size: 24px;
                    color: #8e8e93;
                    font-weight: 300;
                }
                
                .faq-answer {
                    font-size: 15px; /* Consistent 15px */
                    font-weight: 400; /* Regular weight */
                    color: #3a3a3c;
                    margin-top: 10px;
                    display: none;
                    line-height: 1.5;
                }
                
                .faq-item.active .faq-answer {
                    display: block;
                }
                
                .contact-card {
                    background: #f2f2f7; /* Light Grayish */
                    border-radius: 16px;
                    padding: 24px;
                    text-align: center;
                    margin-top: 30px;
                }
                
                .contact-card h2 {
                    font-size: 17px; /* Changed to match navigation title */
                    font-weight: 600; /* Semibold */
                    color: #000000;
                    margin-bottom: 8px;
                }
                
                .contact-card p {
                    font-size: 13px; /* Match subtitle/info text */
                    font-weight: 400; /* Regular */
                    color: #8e8e93;
                    margin-bottom: 16px;
                    line-height: 1.4;
                }
                
                .contact-button {
                    background: #0d74f2; /* Accent Blue */
                    color: white;
                    border: none;
                    border-radius: 12px;
                    padding: 14px 32px;
                    font-size: 15px; /* Consistent 15px */
                    font-weight: 600; /* Semibold for button */
                    cursor: pointer;
                }
                
                .emoji {
                    margin-right: 8px;
                    font-size: 18px;
                }
                
                @media (prefers-color-scheme: dark) {
                    body {
                        background-color: #000000;
                        color: #ffffff;
                    }
                    h1, .contact-card h2, .faq-question {
                        color: #ffffff;
                    }
                    .search-box input {
                        color: #ffffff;
                    }
                    .faq-item {
                        border-bottom: 0.5px solid #38383a;
                    }
                    .card, .contact-card, .search-box {
                        background: #1c1c1e; /* secondarySystemGroupedBackground equivalent */
                    }
                    .faq-answer, .subtitle, .contact-card p, .section-title {
                        color: #ebebf5;
                    }
                }
            </style>
        </head>
        <body>
            <div class="container">
                <h1>Help & Support</h1>
                <p class="subtitle">Find answers to common questions and learn how to make the most of Insider.</p>
                
                <div class="search-box">
                    <span style="color: #8e8e93;">🔍</span>
                    <input type="text" id="searchInput" placeholder="Search for help...">
                </div>
                
                <div class="section">
                    <div class="section-title">GETTING STARTED</div>
                    <div class="card">
                        <div class="faq-item" onclick="toggleFAQ(this)">
                            <div class="faq-question">
                                <span><span class="emoji">🚀</span>What is Insider?</span>
                            </div>
                            <div class="faq-answer">
                                Insider is your personal tech news curator. We aggregate news from top sources, summarize it with AI, and deliver it in bite-sized, personalized posts called DeckDrop. Stay informed without the overwhelm.
                            </div>
                        </div>
                        
                        <div class="faq-item" onclick="toggleFAQ(this)">
                            <div class="faq-question">
                                <span><span class="emoji">📱</span>How do I personalize my feed?</span>
                            </div>
                            <div class="faq-answer">
                                Navigate to Profile > Personalize Feed. Select your interests from categories like AI, Cloud Computing, Cybersecurity, and more. Your daily DeckDrop posts will be tailored to your selections.
                            </div>
                        </div>
                        
                        <div class="faq-item" onclick="toggleFAQ(this)">
                            <div class="faq-question">
                                <span><span class="emoji">⏰</span>When do I get new content?</span>
                            </div>
                            <div class="faq-answer">
                                Your personalized DeckDrop posts arrive daily at a time you can customize in settings. Enable notifications to never miss your daily tech briefing.
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="section">
                    <div class="section-title">DECKDROP POSTS</div>
                    <div class="card">
                        <div class="faq-item" onclick="toggleFAQ(this)">
                            <div class="faq-question">
                                <span><span class="emoji">📰</span>What are DeckDrop posts?</span>
                            </div>
                            <div class="faq-answer">
                                DeckDrop posts are AI-curated summaries of the latest tech news, personalized to your interests. Each post includes key points, source links, and additional context to keep you informed efficiently.
                            </div>
                        </div>
                        
                        <div class="faq-item" onclick="toggleFAQ(this)">
                            <div class="faq-question">
                                <span><span class="emoji">💾</span>How do I save posts for later?</span>
                            </div>
                            <div class="faq-answer">
                                Tap the bookmark icon on any post to save it to your library. Access all saved content from Profile > Saved Library. Save unlimited posts across all categories.
                            </div>
                        </div>
                        
                        <div class="faq-item" onclick="toggleFAQ(this)">
                            <div class="faq-question">
                                <span><span class="emoji">🔗</span>Can I share posts with others?</span>
                            </div>
                            <div class="faq-answer">
                                Yes! Tap the share icon on any post to share via messaging, email, or social media. Recipients can view the summary even without an Insider account.
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="section">
                    <div class="section-title">AUDIO NEWS</div>
                    <div class="card">
                        <div class="faq-item" onclick="toggleFAQ(this)">
                            <div class="faq-question">
                                <span><span class="emoji">🎧</span>How does audio news work?</span>
                            </div>
                            <div class="faq-answer">
                                Insider converts your DeckDrop posts into audio format using natural-sounding AI voices. Perfect for commutes, workouts, or multitasking. Access audio from the Audio tab or within individual posts.
                            </div>
                        </div>
                        
                        <div class="faq-item" onclick="toggleFAQ(this)">
                            <div class="faq-question">
                                <span><span class="emoji">⏯️</span>Can I control playback speed?</span>
                            </div>
                            <div class="faq-answer">
                                Yes! Adjust playback speed from 0.5x to 2x in the audio player controls. Your preference is saved for future sessions.
                            </div>
                        </div>
                        
                        <div class="faq-item" onclick="toggleFAQ(this)">
                            <div class="faq-question">
                                <span><span class="emoji">📲</span>Does audio work in the background?</span>
                            </div>
                            <div class="faq-answer">
                                Absolutely. Audio continues playing when you switch apps or lock your screen. Control playback from your device's lock screen or control center.
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="section">
                    <div class="section-title">AI CHATBOT</div>
                    <div class="card">
                        <div class="faq-item" onclick="toggleFAQ(this)">
                            <div class="faq-question">
                                <span><span class="emoji">🤖</span>What can the chatbot do?</span>
                            </div>
                            <div class="faq-answer">
                                Ask the chatbot questions about any tech topic, request deeper explanations of news stories, or get clarification on technical concepts. It's trained on the latest tech news and trends.
                            </div>
                        </div>
                        
                        <div class="faq-item" onclick="toggleFAQ(this)">
                            <div class="faq-question">
                                <span><span class="emoji">💬</span>Are my conversations private?</span>
                            </div>
                            <div class="faq-answer">
                                Yes. All chatbot conversations are encrypted and private to your account. We don't share conversation data with third parties.
                            </div>
                        </div>
                        
                        <div class="faq-item" onclick="toggleFAQ(this)">
                            <div class="faq-question">
                                <span><span class="emoji">🔄</span>Can I start new conversations?</span>
                            </div>
                            <div class="faq-answer">
                                Yes. Tap the new chat icon to start a fresh conversation. Previous chats are automatically saved in your history for easy reference.
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="section">
                    <div class="section-title">FEATURES & FILTERS</div>
                    <div class="card">
                        <div class="faq-item" onclick="toggleFAQ(this)">
                            <div class="faq-question">
                                <span><span class="emoji">🔍</span>What are ultra filters?</span>
                            </div>
                            <div class="faq-answer">
                                Ultra filters let you categorize content as "Need to Know" (critical updates, breaking changes) or "Nice to Know" (interesting but not urgent). This helps you prioritize what to read first.
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="section">
                    <div class="section-title">STREAK SYSTEM</div>
                    <div class="card">
                        <div class="faq-item" onclick="toggleFAQ(this)">
                            <div class="faq-question">
                                <span><span class="emoji">🔥</span>How do streaks work?</span>
                            </div>
                            <div class="faq-answer">
                                Build your streak by checking in daily and engaging with your DeckDrop posts. Your current streak and record appear on both your profile and home feed, motivating consistent learning.
                            </div>
                        </div>
                        
                        <div class="faq-item" onclick="toggleFAQ(this)">
                            <div class="faq-question">
                                <span><span class="emoji">📅</span>When does my streak reset?</span>
                            </div>
                            <div class="faq-answer">
                                Your streak continues as long as you engage with content daily. Miss a day, and your streak resets to zero, but your record (longest streak) is preserved.
                            </div>
                        </div>
                        
                        <div class="faq-item" onclick="toggleFAQ(this)">
                            <div class="faq-question">
                                <span><span class="emoji">✅</span>What counts as activity for streaks?</span>
                            </div>
                            <div class="faq-answer">
                                Reading through your daily posts, engaging with discussions, listening to audio news, or using the chatbot all count toward maintaining your streak. Just stay active daily!
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="section">
                    <div class="section-title">ACCOUNT & SETTINGS</div>
                    <div class="card">
                        <div class="faq-item" onclick="toggleFAQ(this)">
                            <div class="faq-question">
                                <span><span class="emoji">⚙️</span>How do I change my preferences?</span>
                            </div>
                            <div class="faq-answer">
                                Go to Profile > Personalize Feed to adjust your technology interests, content filters, and notification settings. Changes take effect immediately.
                            </div>
                        </div>
                        
                        <div class="faq-item" onclick="toggleFAQ(this)">
                            <div class="faq-question">
                                <span><span class="emoji">📁</span>Where can I find saved content?</span>
                            </div>
                            <div class="faq-answer">
                                Access all your saved posts, articles, and audio content from Profile > Saved Library. Content stays saved until you remove it.
                            </div>
                        </div>
                        
                        <div class="faq-item" onclick="toggleFAQ(this)">
                            <div class="faq-question">
                                <span><span class="emoji">🔔</span>How do notifications work?</span>
                            </div>
                            <div class="faq-answer">
                                Enable Daily Drop Alerts in your Profile to get notified when new content is available. You can also receive notifications when someone shares content with you.
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="section">
                    <div class="section-title">TROUBLESHOOTING</div>
                    <div class="card">
                        <div class="faq-item" onclick="toggleFAQ(this)">
                            <div class="faq-question">
                                <span><span class="emoji">⚠️</span>App not loading content?</span>
                            </div>
                            <div class="faq-answer">
                                Check your internet connection, then try refreshing by pulling down on the feed. If issues persist, try logging out and back in, or reinstalling the app.
                            </div>
                        </div>
                        
                        <div class="faq-item" onclick="toggleFAQ(this)">
                            <div class="faq-question">
                                <span><span class="emoji">🎵</span>Audio not playing?</span>
                            </div>
                            <div class="faq-answer">
                                Ensure your device isn't on silent mode and volume is up. Check that the app has audio permissions in Settings. Try closing and reopening the app.
                            </div>
                        </div>
                        
                        <div class="faq-item" onclick="toggleFAQ(this)">
                            <div class="faq-question">
                                <span><span class="emoji">💔</span>Lost my streak?</span>
                            </div>
                            <div class="faq-answer">
                                Streaks require daily engagement. If you believe your streak was lost due to a technical issue, contact support with details about when you last used the app.
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="contact-card">
                    <h2>Still need help?</h2>
                    <p>Can't find what you're looking for? Our support team is here to help.</p>
                    <button class="contact-button" onclick="contactSupport()">Contact Support</button>
                </div>
            </div>
            
            <script>
                function toggleFAQ(element) {
                    element.classList.toggle('active');
                }
                
                function contactSupport() {
                    window.webkit.messageHandlers.contactSupport.postMessage('contact');
                }
                
                // Search functionality
                document.getElementById('searchInput').addEventListener('input', function(e) {
                    const searchTerm = e.target.value.toLowerCase();
                    const faqItems = document.querySelectorAll('.faq-item');
                    
                    faqItems.forEach(item => {
                        const question = item.querySelector('.faq-question').textContent.toLowerCase();
                        const answer = item.querySelector('.faq-answer').textContent.toLowerCase();
                        
                        if (question.includes(searchTerm) || answer.includes(searchTerm)) {
                            item.style.display = 'block';
                        } else {
                            item.style.display = 'none';
                        }
                    });
                });
            </script>
        </body>
        </html>
        """
        
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
}

// MARK: - WKNavigationDelegate
extension HelpViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
        showErrorAlert()
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to load help content. Please try again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.loadHelpContent()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - WKScriptMessageHandler
extension HelpViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "contactSupport" {
            let alert = UIAlertController(
                title: "Contact Support",
                message: "Send us an email at support@insider.app or reach out through the app.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var newsItems: [NewsItem] = []
    private let refreshControl = UIRefreshControl()
    private let headerContainer = UIView()
    
    // Dynamic categories based on user selection
    private var categories: [String] = ["For You", "Daily"]
    private var activePreferenceName: String = "For You"
    private var currentFilterTag: String = "technology"
    
    // MARK: - Pagination
    private let pageSize = 10
    private var currentPage = 0
    private var isLoadingMore = false
    private var hasMorePages = true
    /// Full pool of filtered items for "For You" (local pagination)
    private var forYouPool: [NewsItem] = []
    /// User's selected reading-time cap for the For You feed
    private var forYouLimit: Int {
        let pref = UserDefaults.standard.string(forKey: "ReadingTime") ?? "15 news"
        return Int(pref.components(separatedBy: " ").first ?? "15") ?? 15
    }
    /// Cache of all items loaded so far (keyed by tab name)
    private var itemCache: [String: [NewsItem]] = [:]
    
    // Notification Badge
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = .white
        label.backgroundColor = .systemRed
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    // MARK: - Tech-Only Variety Keywords
    private let domainKeywords: [String: [String]] = [
        "Swift": ["swiftui", "uikit", "xcode", "apple developer", "ios development", "combine"],
        "Python": ["django", "flask", "pandas", "numpy", "pytorch", "fastapi"],
        "AI/ML": ["neural networks", "llm", "gpt", "deep learning", "inference", "openai"],
        "React": ["reactjs", "next.js", "virtual dom", "typescript", "frontend"],
        "Data Science": ["machine learning model", "data engineering", "big data", "pandas"],
        "Blockchain": ["smart contracts", "solidity", "web3", "ethereum", "distributed ledger"],
        "Cybersecurity": ["penetration testing", "encryption", "malware", "zero trust", "firewall"],
        "Web Dev": ["backend", "frontend", "fullstack", "v8 engine", "rest api", "graphql"],
        "DevOps": ["kubernetes", "docker", "ci/cd pipeline", "terraform", "ansible"]
    ]
    
    private let tagMapping: [String: String] = [
        "AI/ML": "technology", "Python": "technology", "Swift": "technology",
        "React": "web", "DevOps": "technology", "Data Science": "science",
        "Cybersecurity": "technology", "Web Dev": "web", "Blockchain": "technology"
    ]
    
    private let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["For You", "Daily"])
        sc.selectedSegmentIndex = 0
        sc.backgroundColor = .secondarySystemBackground
        sc.selectedSegmentTintColor = .white
        sc.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.label], for: .normal)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomHeaderView()
        setupTableView()
        setupRefreshControl()
        
        segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        refreshUserPreferences()
        
        loadNews(forTag: "technology", preference: "For You")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        // Refresh preferences every time the view appears to catch deletions from the Personalize screen
        refreshUserPreferences()
        updateNotificationBadge()
    }
    
    private func updateNotificationBadge() {
        UNUserNotificationCenter.current().getDeliveredNotifications { [weak self] notifications in
            DispatchQueue.main.async {
                let unreadCount = notifications.count
                self?.badgeLabel.text = "\(unreadCount)"
                self?.badgeLabel.isHidden = unreadCount == 0
                
                // Also update app icon badge
                if #available(iOS 16.0, *) {
                    UNUserNotificationCenter.current().setBadgeCount(unreadCount)
                } else {
                    UIApplication.shared.applicationIconBadgeNumber = unreadCount
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Logic Implementation
    
    /// Rebuilds the segmented control based on saved UserSelectedDomains
    private func refreshUserPreferences() {
        // Retrieve valid domains (filtered in PersonalizeViewController)
        let savedDomains = UserDefaults.standard.stringArray(forKey: "UserSelectedDomains") ?? []
        
        // Always include the defaults
        self.categories = ["For You", "Daily"] + savedDomains
        
        // Clear and rebuild the segments
        segmentedControl.removeAllSegments()
        for (index, title) in categories.enumerated() {
            segmentedControl.insertSegment(withTitle: title, at: index, animated: false)
        }
        
        // Maintain selection or fallback to "For You" if the previously active tab was deleted
        if let index = categories.firstIndex(of: activePreferenceName) {
            segmentedControl.selectedSegmentIndex = index
        } else {
            segmentedControl.selectedSegmentIndex = 0
            activePreferenceName = "For You"
            loadNews(forTag: "technology", preference: "For You")
        }
    }
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        let selectedTitle = categories[sender.selectedSegmentIndex]
        self.activePreferenceName = selectedTitle
        loadNews(forTag: selectedTitle, preference: selectedTitle)
    }
    
    func loadNews(forTag tag: String, preference: String) {
        self.currentFilterTag = tag
        
        // Reset pagination state for a fresh load
        currentPage = 0
        hasMorePages = true
        isLoadingMore = false
        forYouPool = []
        
        if preference == "For You" {
            loadForYouPage(isInitial: true)
        } else if preference == "Daily" {
            loadDBPage(preference: preference, category: nil, isInitial: true)
        } else {
            loadDBPage(preference: preference, category: preference, isInitial: true)
        }
    }
    
    // MARK: - "For You" Pagination (local pool)
    
    /// Fetches a large pool once, filters/sorts locally, then pages through it in chunks of 10.
    private func loadForYouPage(isInitial: Bool) {
        guard !isLoadingMore else { return }
        isLoadingMore = true
        
        if isInitial {
            // Fetch a big pool from DB (100 items), filter & sort once, then paginate locally
            NewsPersistenceManager.shared.fetchNewsCards(limit: 100, offset: 0) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self, case .success(let dbCards) = result else {
                        self?.isLoadingMore = false
                        self?.refreshControl.endRefreshing()
                        return
                    }
                    
                    let allItemsFromDB = dbCards.map { $0.toNewsItem() }
                    let blockedTopics = UserDefaults.standard.stringArray(forKey: "BlockedTopics") ?? []
                    let followingItems = UserDefaults.standard.stringArray(forKey: "FollowingItems") ?? []
                    let goal = UserDefaults.standard.string(forKey: "ProfessionalGoal") ?? "General Knowledge"

                    var finalFilteredItems: [NewsItem] = []
                    var seenImageUrls = Set<String>()
                    
                    for item in allItemsFromDB {
                        if let url = item.imageURL, !url.isEmpty {
                            if seenImageUrls.contains(url) { continue }
                            seenImageUrls.insert(url)
                        }
                        
                        let content = (item.title + " " + item.description).lowercased()
                        let isBlocked = blockedTopics.contains { content.contains($0.lowercased()) }
                        if isBlocked { continue }
                        
                        if content.contains("tariff") || content.contains("politics") || content.contains("diplomacy") {
                            continue
                        }
                        finalFilteredItems.append(item)
                    }

                    finalFilteredItems.shuffle()

                    // Sorting based on Following and Goals
                    finalFilteredItems.sort { a, b in
                        let aContent = (a.title + " " + a.description).lowercased()
                        let bContent = (b.title + " " + b.description).lowercased()
                        
                        let aFollowing = followingItems.contains { aContent.contains($0.lowercased()) }
                        let bFollowing = followingItems.contains { bContent.contains($0.lowercased()) }
                        if aFollowing != bFollowing { return aFollowing }
                        
                        if goal == "Mastering Swift" {
                            let aGoal = aContent.contains("swift") || aContent.contains("apple") || aContent.contains("xcode")
                            let bGoal = bContent.contains("swift") || bContent.contains("apple") || bContent.contains("xcode")
                            if aGoal != bGoal { return aGoal }
                        }
                        return false
                    }

                    // Cap the pool to the user's reading time setting (10 / 15 / 20)
                    let limit = self.forYouLimit
                    self.forYouPool = Array(finalFilteredItems.prefix(limit))
                    self.currentPage = 0
                    
                    // Take the first page
                    let end = min(self.pageSize, self.forYouPool.count)
                    self.newsItems = Array(self.forYouPool.prefix(end))
                    self.itemCache["For You"] = self.newsItems
                    self.hasMorePages = end < self.forYouPool.count
                    self.currentPage = 1
                    
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                    self.isLoadingMore = false
                }
            }
        } else {
            // Paginate locally from the pool
            let startIndex = currentPage * pageSize
            guard startIndex < forYouPool.count else {
                hasMorePages = false
                isLoadingMore = false
                return
            }
            let endIndex = min(startIndex + pageSize, forYouPool.count)
            let nextPage = Array(forYouPool[startIndex..<endIndex])
            
            newsItems.append(contentsOf: nextPage)
            itemCache["For You"] = newsItems
            hasMorePages = endIndex < forYouPool.count
            currentPage += 1
            
            tableView.reloadData()
            isLoadingMore = false
        }
    }
    
    // MARK: - DB-Backed Pagination (Daily / Category tabs)
    
    /// Fetches `pageSize` items from DB with offset, appends to the list.
    private func loadDBPage(preference: String, category: String?, isInitial: Bool) {
        guard !isLoadingMore else { return }
        isLoadingMore = true
        
        let offset = isInitial ? 0 : currentPage * pageSize
        
        let handleResult: (Result<[NewsCardDB], SupabaseError>) -> Void = { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.refreshControl.endRefreshing()
                self.isLoadingMore = false
                
                guard case .success(let dbCards) = result else { return }
                
                var newItems = dbCards.map { $0.toNewsItem() }
                
                // Filter out non-tech content for "Daily"
                if preference == "Daily" {
                    newItems = newItems.filter { item in
                        let content = (item.title + " " + item.description).lowercased()
                        return !content.contains("tariff") && !content.contains("politics") && !content.contains("diplomacy")
                    }
                }
                
                if isInitial {
                    self.newsItems = newItems
                    self.currentPage = 1
                } else {
                    self.newsItems.append(contentsOf: newItems)
                    self.currentPage += 1
                }
                
                self.hasMorePages = dbCards.count >= self.pageSize
                self.itemCache[preference] = self.newsItems
                self.tableView.reloadData()
            }
        }
        
        if let category = category {
            NewsPersistenceManager.shared.fetchNewsCards(byCategory: category, limit: pageSize, completion: handleResult)
        } else {
            NewsPersistenceManager.shared.fetchNewsCards(limit: pageSize, offset: offset, completion: handleResult)
        }
    }
    
    // MARK: - Load More (called from willDisplay)
    
    private func loadMoreIfNeeded() {
        guard hasMorePages, !isLoadingMore else { return }
        
        if activePreferenceName == "For You" {
            loadForYouPage(isInitial: false)
        } else {
            let category = (activePreferenceName == "Daily") ? nil : activePreferenceName
            loadDBPage(preference: activePreferenceName, category: category, isInitial: false)
        }
    }
    
    private func applyVarietyFilter(to items: [NewsItem], for preference: String) -> [NewsItem] {
        let keywords = domainKeywords[preference] ?? [preference.lowercased()]
        return items.filter { item in
            let content = (item.title + " " + item.description).lowercased()
            return keywords.contains { keyword in content.contains(keyword.lowercased()) }
        }
    }
    
    // MARK: - UI Setup
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 90, right: 0)
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(handlePullToRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc private func handlePullToRefresh() {
        loadNews(forTag: currentFilterTag, preference: activePreferenceName)
    }

    private func setupCustomHeaderView() {
        headerContainer.backgroundColor = .systemBackground
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerContainer)
        
        let topRow = UIView(); topRow.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.addSubview(topRow)
        
        let titleLabel = UILabel(); titleLabel.text = "Insider"; titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        topRow.addSubview(titleLabel)
        
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
        
        let profileButton = UIButton(type: .system)
        profileButton.setImage(UIImage(systemName: "person.crop.circle", withConfiguration: config), for: .normal)
        profileButton.tintColor = .label
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        profileButton.addTarget(self, action: #selector(profileTapped), for: .touchUpInside)
        topRow.addSubview(profileButton)

        let notificationButton = UIButton(type: .system)
        notificationButton.setImage(UIImage(systemName: "bell", withConfiguration: config), for: .normal)
        notificationButton.tintColor = .label
        notificationButton.translatesAutoresizingMaskIntoConstraints = false
        notificationButton.addTarget(self, action: #selector(notificationTapped), for: .touchUpInside)
        topRow.addSubview(notificationButton)
        
        notificationButton.addSubview(badgeLabel)
        
        headerContainer.addSubview(segmentedControl)
        
        NSLayoutConstraint.activate([
            badgeLabel.topAnchor.constraint(equalTo: notificationButton.topAnchor, constant: -4),
            badgeLabel.trailingAnchor.constraint(equalTo: notificationButton.trailingAnchor, constant: 4),
            badgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 16),
            badgeLabel.heightAnchor.constraint(equalToConstant: 16),
            headerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerContainer.heightAnchor.constraint(equalToConstant: 105),
            topRow.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            topRow.heightAnchor.constraint(equalToConstant: 60),
            topRow.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            topRow.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: topRow.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: topRow.leadingAnchor, constant: 20),
            profileButton.centerYAnchor.constraint(equalTo: topRow.centerYAnchor),
            profileButton.trailingAnchor.constraint(equalTo: topRow.trailingAnchor, constant: -20),
            notificationButton.centerYAnchor.constraint(equalTo: topRow.centerYAnchor),
            notificationButton.trailingAnchor.constraint(equalTo: profileButton.leadingAnchor, constant: -16),
            segmentedControl.topAnchor.constraint(equalTo: topRow.bottomAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -16)
        ])
    }

    @objc func notificationTapped() {
        let notificationVC = NotificationsViewController()
        self.navigationController?.pushViewController(notificationVC, animated: true)
    }

    @objc func profileTapped() {
        let profileVC = ProfileViewController()
        self.navigationController?.pushViewController(profileVC, animated: true)
    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardTableViewCell", for: indexPath) as? CardTableViewCell else {
            return UITableViewCell()
        }
        let item = newsItems[indexPath.row]
        cell.configure(with: item)
        
        cell.onSourceLinkTap = { [weak self] urlString in
            let webVC = WebViewController()
            webVC.urlString = urlString
            self?.navigationController?.pushViewController(webVC, animated: true)
        }
        
        cell.onBookmarkTap = { [weak self] isSaved in
            guard let cardId = item.id else { return }
            
            // Persist locally for instant feedback
            UserDefaults.standard.set(isSaved, forKey: "bookmarked_\(cardId)")
            
            // Persist to dedicated database table
            if isSaved {
                NewsPersistenceManager.shared.savePostDedicated(newsCardId: cardId) { result in
                    if case .failure(let error) = result {
                        print("⚠️ Failed to save post: \(error)")
                    }
                }
            } else {
                NewsPersistenceManager.shared.removePostDedicated(newsCardId: cardId) { result in
                    if case .failure(let error) = result {
                        print("⚠️ Failed to remove post: \(error)")
                    }
                }
            }
        }
        
        cell.discussion.tag = indexPath.row
        cell.devknows.tag = indexPath.row
        cell.discussion.addTarget(self, action: #selector(discussionButtonTapped(sender:)), for: .touchUpInside)
        cell.devknows.addTarget(self, action: #selector(devKnowsButtonTapped(sender:)), for: .touchUpInside)
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // When the user reaches the last cell on the "For You" tab, mark the day as read
        if activePreferenceName == "For You" && indexPath.row == newsItems.count - 1 && newsItems.count > 0 {
            StreakManager.shared.markTodayAsRead()
        }
        
        // Infinite scroll: load next page when within 3 items of the bottom
        if indexPath.row >= newsItems.count - 3 {
            loadMoreIfNeeded()
        }
    }

    @objc func discussionButtonTapped(sender: UIButton) {
        let item = newsItems[sender.tag]
        let discussionVC = PostDiscussionViewController()
        discussionVC.newsItem = item
        self.navigationController?.pushViewController(discussionVC, animated: true)
    }
    
    @objc func devKnowsButtonTapped(sender: UIButton) {
        let item = newsItems[sender.tag]
        let devVC = DevKnowsViewController()
        devVC.newsItemContext = item
        present(devVC, animated: true)
    }
}

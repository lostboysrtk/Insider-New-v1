import UIKit

class MainDiscussionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DiscussionsHeaderDelegate {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    var allItems: [NewsItem] = []
    var displayedItems: [NewsItem] = []
    var currentFilterIndex: Int = 0
    var currentSortIndex: Int = 0
    let sortOptions = ["Recent Activity", "Most Liked", "Top Replies"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchTechNews()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Discussions"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Remove the default extra space at the top of the first section
        tableView.sectionHeaderTopPadding = 0
        
        // Registering programmatic cells
        tableView.register(DiscussionsHeaderCell.self, forCellReuseIdentifier: "DiscussionsHeaderCell")
        tableView.register(FilterRowCell.self, forCellReuseIdentifier: "FilterRowCell")
        tableView.register(DropdownSortRowCell.self, forCellReuseIdentifier: "DropdownSortRowCell")
        tableView.register(DiscussionRowCell.self, forCellReuseIdentifier: "DiscussionRowCell")
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // Gap management between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? 4 : 0.1
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }

    private var rawComments: [CommentDB] = []
    
    // MARK: - Logic
    private func fetchTechNews() {
        NewsPersistenceManager.shared.getUserCommentedNewsCards { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let (cards, comments)):
                    self.rawComments = comments
                    
                    let myId = UserDefaults.standard.string(forKey: "deviceId") ?? ""
                    
                    self.allItems = cards.map { card in
                        var item = card.toNewsItem()
                        item.id = card.id // Store the DB ID for matching comments later!
                        // Check user's comments on this specific card
                        let myCardComments = comments.filter { $0.newsCardId == card.id && $0.userId == myId }
                        // Started if ANY comment is a top-level comment (no parent)
                        item.isStartedByCurrentUser = myCardComments.contains { $0.parentCommentId == nil }
                        // Joined if ANY comment is a reply (has parent)
                        item.isJoinedByCurrentUser = myCardComments.contains { $0.parentCommentId != nil }
                        return item
                    }
                    self.applyFilterAndSort()
                case .failure(let error):
                    print("Failed to fetch user discussions: \(error)")
                }
            }
        }
    }

    func applyFilterAndSort() {
        var filtered = (currentFilterIndex == 0) ? allItems.filter { $0.isStartedByCurrentUser } : allItems.filter { $0.isJoinedByCurrentUser }
        
        if currentSortIndex == 1 {
            filtered.sort { Int($0.likes) ?? 0 > Int($1.likes) ?? 0 }
        } else if currentSortIndex == 2 {
            filtered.sort { Int($0.comments) ?? 0 > Int($1.comments) ?? 0 }
        }
        
        self.displayedItems = filtered
        UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.tableView.reloadData()
        })
    }

    // MARK: - DiscussionsHeaderDelegate
    func didTapGraphDay(dayIndex: Int) {
        let vc = ReplyCountViewController()
        vc.selectedDay = dayIndex
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didChangeFilter(to index: Int) {
        self.currentFilterIndex = index
        self.applyFilterAndSort()
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int { return 2 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : displayedItems.count + 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DiscussionsHeaderCell", for: indexPath) as! DiscussionsHeaderCell
            cell.delegate = self
            
            // Calculate activity for the last 15 days
            var recentActivityCounts = Array(repeating: CGFloat(0), count: 15)
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            
            for comment in rawComments {
                if let date = comment.createdAt {
                    let commentStartOfDay = calendar.startOfDay(for: date)
                    let components = calendar.dateComponents([.day], from: commentStartOfDay, to: today)
                    if let daysAgo = components.day, daysAgo >= 0 && daysAgo < 15 {
                        // Reverse the index so index 14 is today, 0 is 14 days ago
                        let index = 14 - daysAgo
                        recentActivityCounts[index] += 1
                    }
                }
            }
            
            cell.configure(with: recentActivityCounts)
            return cell
        } else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FilterRowCell", for: indexPath) as! FilterRowCell
                cell.startedJoinedButton.selectedSegmentIndex = currentFilterIndex
                cell.onFilterChanged = { [weak self] index in
                    self?.currentFilterIndex = index
                    self?.applyFilterAndSort()
                }
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DropdownSortRowCell", for: indexPath) as! DropdownSortRowCell
                cell.configure(selectedTitle: sortOptions[currentSortIndex]) { [weak self] index in
                    self?.currentSortIndex = index
                    self?.applyFilterAndSort()
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DiscussionRowCell", for: indexPath) as! DiscussionRowCell
                let item = displayedItems[indexPath.row - 2]
                
                // Find user's relevant comment for this item
                var commentText = "No comment found"
                var replyCount = 0
                
                if let cardId = item.id {
                    let cardComments = rawComments.filter { $0.newsCardId == cardId }
                    
                    if currentFilterIndex == 0 {
                        // Started by me: look for a top-level comment
                        if let topLevel = cardComments.first(where: { $0.parentCommentId == nil }) {
                            commentText = topLevel.text
                            replyCount = rawComments.filter { $0.parentCommentId == topLevel.id }.count // In a full app this might query all DB replies, but we'll use local list for now
                        }
                    } else {
                        // Joined by me: look for a reply
                        if let reply = cardComments.first(where: { $0.parentCommentId != nil }) {
                            commentText = reply.text
                            replyCount = rawComments.filter { $0.parentCommentId == reply.id }.count
                        }
                    }
                }
                
                cell.configure(
                    with: item,
                    commentText: commentText,
                    replyCount: replyCount,
                    isLast: indexPath.row == displayedItems.count + 1
                )
                return cell
            }
        }
    }

    // MARK: - Navigation Logic
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 1. Navigation for the Discussion Activity Header (Section 0)
        if indexPath.section == 0 {
            let activityVC = ReplyCountViewController()
            navigationController?.pushViewController(activityVC, animated: true)
        }
        
        // 2. Navigation for News Articles (Section 1)
        else if indexPath.row >= 2 {
            let selectedItem = displayedItems[indexPath.row - 2]
            
            // CHECK: Route based on the current filter index
            if currentFilterIndex == 0 {
                // Navigates to the "Started By Me" screen
                let startedVC = StartedByMeDiscussionViewController()
                startedVC.newsItem = selectedItem
                // Pass any custom data if needed, e.g.:
                // startedVC.userInitialComment = "My thoughts on this..."
                self.navigationController?.pushViewController(startedVC, animated: true)
                
            } else {
                // Navigates to the "Joined By Me" screen
                let joinedVC = JoinedByMeDiscussionViewController()
                joinedVC.newsItem = selectedItem
                // Optional: Provide context for the reply highlight
                joinedVC.repliedToUsername = "CommunityUser"
                joinedVC.userReplyText = "I contributed this specific insight to the thread."
                self.navigationController?.pushViewController(joinedVC, animated: true)
            }
        }
    }
}

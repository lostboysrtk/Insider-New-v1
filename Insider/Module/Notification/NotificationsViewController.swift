
import UIKit

// MARK: - Models
enum NotificationType {
    case reply(discussion: String, username: String, comment: String, discussionId: String, time: String)
    case like(username: String, discussionTitle: String, discussionId: String, time: String)
    case deepDive(topic: String, summary: String, time: String)
    case streak(days: Int, time: String)
    case milestone(badge: String, description: String, time: String)
    case weeklyRecap(topCategory: String, missedStory: String, time: String)
    case sentiment(topic: String, from: String, to: String, time: String)
    case expert(niche: String, title: String, time: String)
    case correction(topic: String, changes: String, time: String)
    case trending(topic: String, count: Int, time: String)
    case morningBrief(time: String)
    case eveningBrief(time: String)
    case weeklyDigest(time: String)
}

enum NotificationFilter: String, CaseIterable {
    case all = "All"
    case forYou = "For You"
    case discussions = "Discussions"
    case audio = "Audio"
    case activity = "Activity"
}

struct NotificationItem {
    let id: String
    let type: NotificationType
    var isRead: Bool
    let timestamp: Date
    let category: NotificationFilter
}

// MARK: - Main View Controller
class NotificationsViewController: UIViewController {
    
    private var tableView: UITableView!
    private var allNotifications: [NotificationItem] = []
    private var filteredNotifications: [NotificationItem] = []
    private var selectedFilter: NotificationFilter = .all
    
    private lazy var filterScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private lazy var filterStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupFilters()
        loadNotifications()

        // Listen for notification taps
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNotificationTap(_:)),
            name: NSNotification.Name("HandleNotificationTap"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        title = "Notifications"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // Add back button
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .label
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Setup filter scroll view
        view.addSubview(filterScrollView)
        filterScrollView.addSubview(filterStackView)
        
        // Setup table view
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 0)
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: "NotificationCell")
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            filterScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            filterScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterScrollView.heightAnchor.constraint(equalToConstant: 50),
            
            filterStackView.topAnchor.constraint(equalTo: filterScrollView.topAnchor, constant: 8),
            filterStackView.leadingAnchor.constraint(equalTo: filterScrollView.leadingAnchor, constant: 16),
            filterStackView.trailingAnchor.constraint(equalTo: filterScrollView.trailingAnchor, constant: -16),
            filterStackView.bottomAnchor.constraint(equalTo: filterScrollView.bottomAnchor, constant: -8),
            filterStackView.heightAnchor.constraint(equalToConstant: 34),
            
            tableView.topAnchor.constraint(equalTo: filterScrollView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupFilters() {
        for filter in NotificationFilter.allCases {
            let button = createFilterButton(title: filter.rawValue, filter: filter)
            filterStackView.addArrangedSubview(button)
        }
        
        // Select first button by default
        if let firstButton = filterStackView.arrangedSubviews.first as? UIButton {
            selectFilterButton(firstButton)
        }
    }
    
    private func createFilterButton(title: String, filter: NotificationFilter) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = .secondarySystemBackground
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.layer.cornerRadius = 17
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.tag = NotificationFilter.allCases.firstIndex(of: filter) ?? 0
        button.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private func filterButtonTapped(_ sender: UIButton) {
        selectFilterButton(sender)
        
        let filter = NotificationFilter.allCases[sender.tag]
        selectedFilter = filter
        
        if filter == .all {
            filteredNotifications = allNotifications
        } else {
            filteredNotifications = allNotifications.filter { $0.category == filter }
        }
        
        tableView.reloadData()
    }
    
    private func selectFilterButton(_ button: UIButton) {
        // Deselect all buttons
        for case let btn as UIButton in filterStackView.arrangedSubviews {
            btn.backgroundColor = .secondarySystemBackground
            btn.setTitleColor(.secondaryLabel, for: .normal)
        }
        
        // Select tapped button
        button.backgroundColor = AppColor.brand
        button.setTitleColor(.systemBackground, for: .normal)
    }
    
    private func loadNotifications() {
        UNUserNotificationCenter.current().getDeliveredNotifications { [weak self] notifications in
            DispatchQueue.main.async {
                var loaded: [NotificationItem] = []
                for notification in notifications {
                    let request = notification.request
                    let userInfo = request.content.userInfo
                    let date = notification.date
                    
                    if let item = NotificationManager.shared.createNotificationItem(
                        from: userInfo,
                        id: request.identifier,
                        timestamp: date
                    ) {
                        loaded.append(item)
                    }
                }
                
                // Sort by newest first
                loaded.sort { $0.timestamp > $1.timestamp }
                
                self?.allNotifications = loaded
                
                if self?.selectedFilter == .all {
                    self?.filteredNotifications = loaded
                } else {
                    self?.filteredNotifications = loaded.filter { $0.category == self?.selectedFilter }
                }
                
                self?.tableView.reloadData()
            }
        }
    }
    
    @objc private func handleNotificationTap(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let type = userInfo["type"] as? String,
              let data = userInfo["data"] as? [AnyHashable: Any] else {
            return
        }
        
        // Handle different notification types
        switch type {
        case "reply", "like":
            if let discussionId = data["discussion_id"] as? String {
                print("Navigate to discussion: \(discussionId)")
                // Navigate to discussion screen
            }
        case "deep_dive", "trending", "expert", "correction", "sentiment":
            if let topic = data["topic"] as? String {
                print("Navigate to topic: \(topic)")
                // Navigate to topic screen
            }
        case "streak", "milestone":
            print("Navigate to profile/achievements")
            // Navigate to profile screen
        case "recap":
            print("Navigate to recap")
            // Navigate to weekly recap screen
        default:
            break
        }
    }
    
    // Public method to add new notification
    func addNotification(_ item: NotificationItem) {
        allNotifications.insert(item, at: 0)
        
        if selectedFilter == .all || item.category == selectedFilter {
            filteredNotifications.insert(item, at: 0)
            tableView.reloadData()
        }
    }
    
    // Public method to mark notification as read
    func markAsRead(id: String) {
        if let index = allNotifications.firstIndex(where: { $0.id == id }) {
            allNotifications[index].isRead = true
        }
        
        if let index = filteredNotifications.firstIndex(where: { $0.id == id }) {
            filteredNotifications[index].isRead = true
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
        
        // Remove from system Notification Center so badge count updates
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
    }
    
    // Also handle deletion
    func deleteNotification(id: String) {
        allNotifications.removeAll { $0.id == id }
        filteredNotifications.removeAll { $0.id == id }
        tableView.reloadData()
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
    }
}

// MARK: - Table View Delegate & DataSource
extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNotifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        cell.configure(with: filteredNotifications[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = filteredNotifications[indexPath.row]
        markAsRead(id: item.id)
        
        // Handle tap based on notification type
        switch item.type {
        case .reply(_, _, _, let discussionId, _),
             .like(_, _, let discussionId, _):
            print("Opening discussion: \(discussionId)")
            // Navigate to discussion
            
        case .deepDive(let topic, _, _),
             .trending(let topic, _, _),
             .expert(_, let topic, _),
             .correction(let topic, _, _),
             .sentiment(let topic, _, _, _):
            print("Opening topic: \(topic)")
            // Navigate to topic
            
        case .streak, .milestone:
            print("Opening achievements")
            // Navigate to achievements
            
        case .weeklyRecap:
            print("Opening weekly recap")
            // Navigate to recap
            
        case .morningBrief, .eveningBrief, .weeklyDigest:
            print("Opening brief")
            // Navigate to brief
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = filteredNotifications[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.deleteNotification(id: item.id)
            completion(true)
        }
        
        let readAction = UIContextualAction(style: .normal, title: item.isRead ? "Unread" : "Read") { [weak self] _, _, completion in
            self?.markAsRead(id: item.id)
            completion(true)
        }
        readAction.backgroundColor = AppColor.brand
        
        return UISwipeActionsConfiguration(actions: [deleteAction, readAction])
    }
}

// MARK: - Notification Cell
class NotificationCell: UITableViewCell {
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 24
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let avatarLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dotView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.brand
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Thumbnail view removed - no longer needed
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupCell() {
        backgroundColor = .systemBackground
        selectionStyle = .default
        
        contentView.addSubview(dotView)
        contentView.addSubview(iconContainer)
        iconContainer.addSubview(iconView)
        iconContainer.addSubview(avatarLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(timeLabel)
        // Removed thumbnailView - not adding it to the view hierarchy
        
        NSLayoutConstraint.activate([
            dotView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            dotView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            dotView.widthAnchor.constraint(equalToConstant: 8),
            dotView.heightAnchor.constraint(equalToConstant: 8),
            
            iconContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            iconContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            iconContainer.widthAnchor.constraint(equalToConstant: 48),
            iconContainer.heightAnchor.constraint(equalToConstant: 48),
            
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            avatarLabel.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            
            messageLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            timeLabel.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor),
            timeLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 4),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with item: NotificationItem) {
        dotView.isHidden = item.isRead
        backgroundColor = item.isRead ? .systemBackground : .systemBackground.withAlphaComponent(0.98)
        
        // Reset visibility
        iconView.isHidden = false
        avatarLabel.isHidden = true
        
        switch item.type {
        case .reply(let discussion, let username, _, _, let time):
            let colors: [UIColor] = [.systemCyan, .systemPink, .systemOrange, AppColor.brand, .systemTeal, .systemIndigo]
            let colorIndex = abs(username.hashValue) % colors.count
            iconContainer.backgroundColor = colors[colorIndex]
            iconView.isHidden = true
            avatarLabel.isHidden = false
            avatarLabel.text = String(username.prefix(1).uppercased())
            
            let text = NSMutableAttributedString(string: username, attributes: [
                .font: UIFont.boldSystemFont(ofSize: 15),
                .foregroundColor: UIColor.label
            ])
            text.append(NSAttributedString(string: " replied to your discussion on ", attributes: [
                .font: UIFont.systemFont(ofSize: 15),
                .foregroundColor: UIColor.label
            ]))
            text.append(NSAttributedString(string: discussion, attributes: [
                .font: UIFont.boldSystemFont(ofSize: 15),
                .foregroundColor: UIColor.label
            ]))
            messageLabel.attributedText = text
            timeLabel.text = time
            
        case .like(let username, let discussionTitle, _, let time):
            iconView.image = UIImage(systemName: "hand.thumbsup.fill")
            iconView.tintColor = .white
            iconContainer.backgroundColor = .systemPink
            
            let text = NSMutableAttributedString(string: username, attributes: [
                .font: UIFont.boldSystemFont(ofSize: 15),
                .foregroundColor: UIColor.label
            ])
            text.append(NSAttributedString(string: " liked your discussion on ", attributes: [
                .font: UIFont.systemFont(ofSize: 15),
                .foregroundColor: UIColor.label
            ]))
            text.append(NSAttributedString(string: discussionTitle, attributes: [
                .font: UIFont.boldSystemFont(ofSize: 15),
                .foregroundColor: UIColor.label
            ]))
            messageLabel.attributedText = text
            timeLabel.text = time
            
            
        case .streak(let days, let time):
            iconView.image = UIImage(systemName: "flame.fill")
            iconView.tintColor = .white
            iconContainer.backgroundColor = .systemOrange
            messageLabel.text = "You are on a \(days) days reading streak! Keep it up."
            timeLabel.text = time
            
        case .milestone(let badge, let description, let time):
            iconView.image = UIImage(systemName: "star.fill")
            iconView.tintColor = .white
            iconContainer.backgroundColor = .systemYellow
            
            let text = NSMutableAttributedString(string: "You earned a badge: \(badge)\n", attributes: [
                .font: UIFont.boldSystemFont(ofSize: 15),
                .foregroundColor: UIColor.label
            ])
            text.append(NSAttributedString(string: description, attributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.secondaryLabel
            ]))
            messageLabel.attributedText = text
            timeLabel.text = time
            
        case .trending(let topic, let count, let time):
            iconView.image = UIImage(systemName: "chart.line.uptrend.xyaxis")
            iconView.tintColor = .white
            iconContainer.backgroundColor = .systemGreen
            messageLabel.text = "A new post is trending in your followed topic: \(topic)."
            timeLabel.text = time
            
        case .expert(let niche, let title, let time):
            iconView.image = UIImage(systemName: "newspaper.fill")
            iconView.tintColor = .white
            iconContainer.backgroundColor = .systemIndigo
            messageLabel.text = "New article in \(niche): \(title)"
            timeLabel.text = time
            
        case .deepDive(let topic, let summary, let time):
            iconView.image = UIImage(systemName: "magnifyingglass")
            iconView.tintColor = .white
            iconContainer.backgroundColor = .systemPurple
            messageLabel.text = "🔍 Update: \(topic) - \(summary)"
            timeLabel.text = time
            
        case .weeklyRecap(let topCategory, let missedStory, let time):
            iconView.image = UIImage(systemName: "chart.bar.fill")
            iconView.tintColor = .white
            iconContainer.backgroundColor = .systemPurple
            messageLabel.text = "📊 Your Weekly Recap: You were most interested in \(topCategory)"
            timeLabel.text = time
            
        case .sentiment(let topic, let from, let to, let time):
            iconView.image = UIImage(systemName: "arrow.up.arrow.down")
            iconView.tintColor = .white
            iconContainer.backgroundColor = .systemPink
            messageLabel.text = "💭 Community Mood Shift: \(topic) - from '\(from)' to '\(to)'"
            timeLabel.text = time
            
        case .correction(let topic, let changes, let time):
            iconView.image = UIImage(systemName: "pencil.circle.fill")
            iconView.tintColor = .white
            iconContainer.backgroundColor = .systemTeal
            messageLabel.text = "✏️ Story Updated: \(topic) - \(changes)"
            timeLabel.text = time
            
        case .morningBrief(let time):
            iconView.image = UIImage(systemName: "cup.and.saucer.fill")
            iconView.tintColor = .white
            iconContainer.backgroundColor = .systemOrange
            messageLabel.text = "☕️ Your Morning Brief is Ready"
            timeLabel.text = time
            
        case .eveningBrief(let time):
            iconView.image = UIImage(systemName: "moon.fill")
            iconView.tintColor = .white
            iconContainer.backgroundColor = .systemIndigo
            messageLabel.text = "🌙 Your Evening Brief is Ready"
            timeLabel.text = time
            
        case .weeklyDigest(let time):
            iconView.image = UIImage(systemName: "calendar")
            iconView.tintColor = .white
            iconContainer.backgroundColor = .systemPurple
            messageLabel.text = "📰 While You Were Away - This week's digest"
            timeLabel.text = time
        }
    }
}

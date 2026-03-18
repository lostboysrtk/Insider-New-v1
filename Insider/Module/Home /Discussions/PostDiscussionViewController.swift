import UIKit

// MARK: - Model
struct DiscussionPost {
    let id: String // Supabase UUID string
    let author: String
    var text: String
    var likes: Int = 0
    var replies: [DiscussionPost] = []
    var level: Int = 0
    var replyingTo: String?
}

class PostDiscussionViewController: UIViewController {
    
    var newsItem: NewsItem?
    private var discussionThreads: [DiscussionPost] = []
    private var activeReplyIndex: Int?
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - Interaction Bar Properties
    private let likeBtn = UIButton(type: .system)
    private let likeCountLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 13, weight: .semibold)
        lbl.textColor = .systemGray
        lbl.text = "0"
        return lbl
    }()
    private let dislikeBtn = UIButton(type: .system)
    private let dislikeCountLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 13, weight: .semibold)
        lbl.textColor = .systemGray
        lbl.text = "0"
        return lbl
    }()
    private let devKnowsBtn = UIButton(type: .system)
    private let bookmarkBtn = UIButton(type: .system)
    private let separatorLine = UIView()

    private var isLiked = false
    private var isDisliked = false
    private var isBookmarked = false
    private var likeCount: Int = 0
    private var dislikeCount: Int = 0
    
    // MARK: - UI Elements
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    private let inputBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -1)
        view.layer.shadowOpacity = 0.05
        view.layer.shadowRadius = 5
        return view
    }()
    
    private let replyField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Write a new thread..."
        tf.backgroundColor = .secondarySystemBackground
        tf.layer.cornerRadius = 18
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        tf.leftViewMode = .always
        return tf
    }()
    
    private let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        btn.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: config), for: .normal)
        btn.tintColor = .systemBlue
        return btn
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupKeyboardHandling()
        fetchComments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .label
        let titleLabel = UILabel()
        titleLabel.text = "Discussion"
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .label
        navigationItem.titleView = titleLabel
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(DiscussionCommentCell.self, forCellReuseIdentifier: "CommentCell")
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        view.addSubview(inputBar)
        inputBar.addSubview(replyField)
        inputBar.addSubview(sendButton)
        
        [tableView, inputBar, replyField, sendButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputBar.topAnchor),
            
            inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            inputBar.heightAnchor.constraint(equalToConstant: 60),
            
            replyField.leadingAnchor.constraint(equalTo: inputBar.leadingAnchor, constant: 16),
            replyField.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            replyField.heightAnchor.constraint(equalToConstant: 36),
            replyField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            
            sendButton.trailingAnchor.constraint(equalTo: inputBar.trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 44)
        ])
        
        setupHeader()
        updateHeaderUI()
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupHeader() {
        let headerWidth = view.frame.width
        let imageHeight: CGFloat = 350
        let spacing: CGFloat = 20
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: headerWidth, height: 500))
        headerView.backgroundColor = .systemBackground
        
        let postImage = UIImageView(frame: CGRect(x: 0, y: 0, width: headerWidth, height: imageHeight))
        postImage.contentMode = .scaleAspectFill
        postImage.clipsToBounds = true
        
        let headlineLabel = UILabel(frame: CGRect(x: spacing, y: imageHeight + 10, width: headerWidth - (spacing * 2), height: 60))
        headlineLabel.font = .systemFont(ofSize: 18, weight: .bold)
        headlineLabel.numberOfLines = 2
        
        if let item = newsItem {
            ImageLoader.shared.loadImage(from: item.imageURL, into: postImage)
            headlineLabel.text = item.title
            
            // Load counts from the item
            likeCount = Int(item.likes) ?? 0
            dislikeCount = Int(item.dislikes) ?? 0
            
            // Restore persisted state from UserDefaults
            if let cardId = item.id {
                isLiked = UserDefaults.standard.bool(forKey: "liked_\(cardId)")
                isDisliked = UserDefaults.standard.bool(forKey: "disliked_\(cardId)")
            }
        }
        
        let interactionStack = UIStackView()
        interactionStack.axis = .horizontal
        interactionStack.distribution = .fill
        interactionStack.spacing = 25
        interactionStack.translatesAutoresizingMaskIntoConstraints = false
        
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        func style(_ btn: UIButton, icon: String, color: UIColor = .systemGray) {
            btn.setImage(UIImage(systemName: icon, withConfiguration: config), for: .normal)
            btn.tintColor = color
        }
        
        style(likeBtn, icon: "hand.thumbsup")
        style(dislikeBtn, icon: "hand.thumbsdown")
        style(devKnowsBtn, icon: "sparkles", color: .systemIndigo)
        style(bookmarkBtn, icon: "bookmark")
        
        [likeBtn, dislikeBtn, bookmarkBtn, devKnowsBtn].forEach { $0.addTarget(self, action: #selector(btnTapped), for: .touchUpInside) }

        // Group like button + count
        let likeGroup = UIStackView(arrangedSubviews: [likeBtn, likeCountLabel])
        likeGroup.axis = .horizontal; likeGroup.spacing = 2; likeGroup.alignment = .center
        
        // Group dislike button + count
        let dislikeGroup = UIStackView(arrangedSubviews: [dislikeBtn, dislikeCountLabel])
        dislikeGroup.axis = .horizontal; dislikeGroup.spacing = 2; dislikeGroup.alignment = .center
        
        interactionStack.addArrangedSubview(likeGroup)
        interactionStack.addArrangedSubview(dislikeGroup)
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        interactionStack.addArrangedSubview(spacer)
        interactionStack.addArrangedSubview(devKnowsBtn)
        interactionStack.addArrangedSubview(bookmarkBtn)
        
        separatorLine.backgroundColor = .separator
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(postImage)
        headerView.addSubview(headlineLabel)
        headerView.addSubview(interactionStack)
        headerView.addSubview(separatorLine)
        
        NSLayoutConstraint.activate([
            interactionStack.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 10),
            interactionStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: spacing),
            interactionStack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -spacing),
            interactionStack.heightAnchor.constraint(equalToConstant: 44),
            
            separatorLine.topAnchor.constraint(equalTo: interactionStack.bottomAnchor, constant: 10),
            separatorLine.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: spacing),
            separatorLine.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -spacing),
            separatorLine.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        tableView.tableHeaderView = headerView
    }

    @objc private func btnTapped(sender: UIButton) {
        guard let item = newsItem, let cardId = item.id else {
            // Handle devknows without needing cardId
            if sender == devKnowsBtn {
                let devVC = DevKnowsViewController()
                devVC.newsItemContext = newsItem
                present(devVC, animated: true)
            }
            return
        }
        
        if sender == likeBtn {
            if isLiked {
                isLiked = false
                likeCount = max(0, likeCount - 1)
            } else {
                isLiked = true
                likeCount += 1
                if isDisliked { isDisliked = false; dislikeCount = max(0, dislikeCount - 1) }
            }
            UserDefaults.standard.set(isLiked, forKey: "liked_\(cardId)")
            UserDefaults.standard.set(isDisliked, forKey: "disliked_\(cardId)")
            NewsPersistenceManager.shared.updateNewsCardCounters(id: cardId, likes: likeCount, dislikes: dislikeCount) { _ in }
        }
        if sender == dislikeBtn {
            if isDisliked {
                isDisliked = false
                dislikeCount = max(0, dislikeCount - 1)
            } else {
                isDisliked = true
                dislikeCount += 1
                if isLiked { isLiked = false; likeCount = max(0, likeCount - 1) }
            }
            UserDefaults.standard.set(isLiked, forKey: "liked_\(cardId)")
            UserDefaults.standard.set(isDisliked, forKey: "disliked_\(cardId)")
            NewsPersistenceManager.shared.updateNewsCardCounters(id: cardId, likes: likeCount, dislikes: dislikeCount) { _ in }
        }
        if sender == bookmarkBtn { isBookmarked.toggle() }
        if sender == devKnowsBtn {
             let devVC = DevKnowsViewController()
             devVC.newsItemContext = newsItem
             present(devVC, animated: true)
        }
        updateHeaderUI()
    }

    private func updateHeaderUI() {
        likeBtn.tintColor = isLiked ? AppColor.brand : .systemGray
        likeBtn.setImage(UIImage(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup"), for: .normal)
        likeCountLabel.text = "\(likeCount)"
        likeCountLabel.textColor = isLiked ? AppColor.brand : .systemGray
        
        dislikeBtn.tintColor = isDisliked ? .systemRed : .systemGray
        dislikeBtn.setImage(UIImage(systemName: isDisliked ? "hand.thumbsdown.fill" : "hand.thumbsdown"), for: .normal)
        dislikeCountLabel.text = "\(dislikeCount)"
        dislikeCountLabel.textColor = isDisliked ? .systemRed : .systemGray
        
        bookmarkBtn.setImage(UIImage(systemName: isBookmarked ? "bookmark.fill" : "bookmark"), for: .normal)
    }

    @objc private func handleSend() {
        guard let text = replyField.text, !text.isEmpty, let newsItem = newsItem else { return }
        
        var parentId: String? = nil
        var level = 0
        var replyingTo: String? = nil
        
        if let threadIndex = activeReplyIndex {
            parentId = discussionThreads[threadIndex].id
            level = 1
            replyingTo = discussionThreads[threadIndex].author
        }
        
        sendButton.isEnabled = false
        activityIndicator.startAnimating()
        
        // Use the current user's name if available, otherwise fallback
        let authorName = UserDefaults.standard.string(forKey: "currentUserFullName") ?? "User"
        let authorColor = UIColor.systemBlue // Or fetch from user profile
        
        // Find the actual news DB ID. This is a bit tricky if newsItem doesn't store the Supabase ID.
        // Assuming NewsPersistenceManager takes the generated ID or article URL via newsCardId, 
        // we should find the DB ID first.
        
        // To handle this, we fetch the news card by its title/url to ensure we have the ID,
        // or we rely on newsCardDB creation.
        // Here, we try to fetch it first, or handle a new insert.
        saveAndPostComment(text: text, parentId: parentId, authorName: authorName, authorColor: authorColor, level: level, replyingTo: replyingTo)
    }
    
    private func saveAndPostComment(text: String, parentId: String?, authorName: String, authorColor: UIColor, level: Int, replyingTo: String?) {
        guard let item = newsItem else { return }
        
        // Save NewsCard first to ensure we have a valid newsCardId
        NewsPersistenceManager.shared.saveNewsCard(item) { [weak self] result in
            guard let self = self else { return }
            
            let newsCardId: String
            switch result {
            case .success(let card):
                guard let id = card.id else { self.finishPosting(success: false); return }
                newsCardId = id
            case .failure(let error):
                if case .serverError(let msg) = error, msg == "Duplicate article" {
                    self.fetchNewsCardId(for: item) { cachedId in
                        guard let cachedId = cachedId else { self.finishPosting(success: false); return }
                        self.postComment(newsCardId: cachedId, text: text, parentId: parentId, authorName: authorName, authorColor: authorColor, level: level, replyingTo: replyingTo)
                    }
                    return
                }
                self.finishPosting(success: false)
                return
            }
            
            self.postComment(newsCardId: newsCardId, text: text, parentId: parentId, authorName: authorName, authorColor: authorColor, level: level, replyingTo: replyingTo)
        }
    }
    
    private func fetchNewsCardId(for item: NewsItem, completion: @escaping (String?) -> Void) {
        guard let url = item.articleURL else { completion(nil); return }
        let queryParams = ["article_url": "eq.\(url)", "limit": "1"]
        SupabaseService.shared.get(endpoint: SupabaseConfig.Tables.newsCards, queryParams: queryParams) { (result: Result<[NewsCardDB], SupabaseError>) in
            switch result {
            case .success(let cards):
                completion(cards.first?.id)
            case .failure:
                completion(nil)
            }
        }
    }
    
    private func postComment(newsCardId: String, text: String, parentId: String?, authorName: String, authorColor: UIColor, level: Int, replyingTo: String?) {
        NewsPersistenceManager.shared.createComment(
            newsCardId: newsCardId,
            text: text,
            userName: authorName,
            userProfileColor: authorColor,
            parentCommentId: parentId,
            level: level
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let commentDB):
                    let newPost = DiscussionPost(
                        id: commentDB.id ?? UUID().uuidString,
                        author: commentDB.userName,
                        text: commentDB.text,
                        likes: commentDB.likesCount ?? 0,
                        replies: [],
                        level: commentDB.level,
                        replyingTo: replyingTo
                    )
                    
                    if let threadIndex = self.activeReplyIndex {
                        self.discussionThreads[threadIndex].replies.append(newPost)
                    } else {
                        self.discussionThreads.append(newPost)
                    }
                    self.finishPosting(success: true)
                    
                case .failure:
                    self.finishPosting(success: false)
                }
            }
        }
    }
    
    private func finishPosting(success: Bool) {
        DispatchQueue.main.async {
            self.sendButton.isEnabled = true
            self.activityIndicator.stopAnimating()
            
            if success {
                self.replyField.text = ""
                self.replyField.placeholder = "Write a new thread..."
                self.activeReplyIndex = nil
                self.view.endEditing(true)
                self.tableView.reloadData()
                
                // Trigger activity notification
                NotificationManager.shared.sendMilestone(badge: "Discussion Contributor", description: "You recently posted to a discussion!")
            } else {
                let alert = UIAlertController(title: "Error", message: "Failed to post comment. Please try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    private func fetchComments() {
        guard let item = newsItem else { return }
        activityIndicator.startAnimating()
        
        fetchNewsCardId(for: item) { [weak self] newsCardId in
            guard let self = self, let cardId = newsCardId else {
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                }
                return
            }
            
            NewsPersistenceManager.shared.getComments(forNewsCardId: cardId) { result in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    
                    switch result {
                    case .success(let fetchedComments):
                        self.organizeComments(fetchedComments)
                    case .failure(let error):
                        print("Failed to fetch comments: \(error)")
                    }
                }
            }
        }
    }
    
    private func organizeComments(_ comments: [CommentDB]) {
        var threadDict: [String: DiscussionPost] = [:]
        var orphans: [CommentDB] = [] // comments that are replies
        
        // 1. First pass: find all root comments
        for comment in comments {
            if comment.parentCommentId == nil, let id = comment.id {
                let post = DiscussionPost(
                    id: id,
                    author: comment.userName,
                    text: comment.text,
                    likes: comment.likesCount ?? 0,
                    replies: [],
                    level: comment.level,
                    replyingTo: nil
                )
                threadDict[id] = post
            } else if comment.parentCommentId != nil {
                orphans.append(comment)
            }
        }
        
        // 2. Second pass: attach replies to their parent threads
        for reply in orphans {
            if let parentId = reply.parentCommentId, let parentThread = threadDict[parentId] {
                let post = DiscussionPost(
                    id: reply.id ?? UUID().uuidString,
                    author: reply.userName,
                    text: reply.text,
                    likes: reply.likesCount ?? 0,
                    replies: [],
                    level: reply.level,
                    replyingTo: parentThread.author
                )
                // Mutate the struct in the dictionary
                threadDict[parentId]?.replies.append(post)
            }
        }
        
        // Convert to array and sort by oldest first (or adjust sorting if preferable)
        self.discussionThreads = Array(threadDict.values)
        self.tableView.reloadData()
    }

    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            if let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let height = value.cgRectValue.height
                self.inputBar.transform = CGAffineTransform(translationX: 0, y: -height + self.view.safeAreaInsets.bottom)
            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            self.inputBar.transform = .identity
        }
    }
}

// MARK: - TableView Extensions
extension PostDiscussionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return discussionThreads.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1 + discussionThreads[section].replies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! DiscussionCommentCell
        let thread = discussionThreads[indexPath.section]
        let post = indexPath.row == 0 ? thread : thread.replies[indexPath.row - 1]
        
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == thread.replies.count
        
        cell.configure(with: post, isFirstInBlock: isFirst, isLastInBlock: isLast)
        
        cell.onReply = { [weak self] in
            self?.activeReplyIndex = indexPath.section
            self?.replyField.placeholder = "Replying in thread..."
            self?.replyField.becomeFirstResponder()
        }
        cell.onLike = { [weak self] in
            let userName = UserDefaults.standard.string(forKey: "currentUserFullName") ?? "Someone"
            NotificationManager.shared.sendLike(
                username: userName,
                discussionTitle: self?.newsItem?.title ?? "a discussion",
                discussionId: post.id
            )
        }
        return cell
    }
}

// MARK: - Refined Card Discussion Cell
class DiscussionCommentCell: UITableViewCell {
    var onReply: (() -> Void)?
    var onLike: (() -> Void)?
    
    private let containerView = UIView()
    private let authorLabel = UILabel()
    private let messageLabel = UILabel()
    private let likeBtn = UIButton(type: .system)
    private let dislikeBtn = UIButton(type: .system)
    private let replyBtn = UIButton(type: .system)
    
    private var leftPaddingConstraint: NSLayoutConstraint?
    private var containerBottomConstraint: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        containerView.backgroundColor = .secondarySystemBackground
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        authorLabel.font = .systemFont(ofSize: 13, weight: .bold)
        authorLabel.textColor = .systemBlue
        
        messageLabel.font = .systemFont(ofSize: 15)
        messageLabel.numberOfLines = 0
        
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        likeBtn.setImage(UIImage(systemName: "arrow.up", withConfiguration: config), for: .normal)
        dislikeBtn.setImage(UIImage(systemName: "arrow.down", withConfiguration: config), for: .normal)
        [likeBtn, dislikeBtn].forEach { $0.tintColor = .systemGray }
        
        replyBtn.setTitle("Reply", for: .normal)
        replyBtn.titleLabel?.font = .systemFont(ofSize: 12, weight: .bold)
        replyBtn.addTarget(self, action: #selector(replyTapped), for: .touchUpInside)
        
        likeBtn.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        
        [authorLabel, messageLabel, likeBtn, dislikeBtn, replyBtn].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
        }
        
        leftPaddingConstraint = authorLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16)
        containerBottomConstraint = containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerBottomConstraint!,
            
            authorLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            leftPaddingConstraint!,
            
            messageLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 4),
            messageLabel.leadingAnchor.constraint(equalTo: authorLabel.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            likeBtn.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10),
            likeBtn.leadingAnchor.constraint(equalTo: authorLabel.leadingAnchor),
            likeBtn.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            dislikeBtn.centerYAnchor.constraint(equalTo: likeBtn.centerYAnchor),
            dislikeBtn.leadingAnchor.constraint(equalTo: likeBtn.trailingAnchor, constant: 15),
            
            replyBtn.centerYAnchor.constraint(equalTo: likeBtn.centerYAnchor),
            replyBtn.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
    }
    
    @objc private func replyTapped() { onReply?() }
    
    @objc private func likeTapped() {
        // Toggle UI (basic feedback)
        likeBtn.tintColor = likeBtn.tintColor == .systemBlue ? .systemGray : .systemBlue
        onLike?()
    }
    
    func configure(with post: DiscussionPost, isFirstInBlock: Bool, isLastInBlock: Bool) {
        authorLabel.text = post.author
        
        if let tag = post.replyingTo {
            let attrText = NSMutableAttributedString(string: "@\(tag) ", attributes: [.foregroundColor: UIColor.systemBlue, .font: UIFont.boldSystemFont(ofSize: 14)])
            attrText.append(NSAttributedString(string: post.text))
            messageLabel.attributedText = attrText
            leftPaddingConstraint?.constant = 40
        } else {
            messageLabel.text = post.text
            leftPaddingConstraint?.constant = 16
        }
        
        containerView.layer.cornerRadius = 12
        var maskedCorners: CACornerMask = []
        if isFirstInBlock { maskedCorners.insert([.layerMinXMinYCorner, .layerMaxXMinYCorner]) }
        if isLastInBlock { maskedCorners.insert([.layerMinXMaxYCorner, .layerMaxXMaxYCorner]) }
        containerView.layer.maskedCorners = maskedCorners
        
        // Gap logic
        if isLastInBlock {
            containerBottomConstraint?.constant = -16
        } else {
            containerBottomConstraint?.constant = 0
        }
    }
}

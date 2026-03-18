import UIKit

// MARK: - 1. Model
struct JBMComment {
    let id: String // Supabase UUID
    let userName: String
    let text: String
    let timeAgo: String
    var likes: Int
    var voteStatus: Int = 0 // -1: down, 0: none, 1: up
    var nestedReplies: [JBMComment] = []
    var isExpanded: Bool = false
    var level: Int = 0
}

// MARK: - 2. View Controller
class JoinedByMeDiscussionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let commentInputBar = UIView()
    private let inputField = UITextField()
    
    // MARK: - Connection Properties
    var newsItem: NewsItem?
    var repliedToUsername: String = ""
    var userReplyText: String = ""
    private var activeReplyToIndex: Int?
    private let sendButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private var comments: [JBMComment] = []

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavbar()
        setupUI()
        fetchComments()
    }

    private func setupNavbar() {
        self.title = "Joined by me"
        navigationItem.largeTitleDisplayMode = .never
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(JBMCardCommentCell.self, forCellReuseIdentifier: "JoinedCardCell")
        
        commentInputBar.backgroundColor = .systemBackground
        commentInputBar.translatesAutoresizingMaskIntoConstraints = false
        
        inputField.placeholder = "Write a reply..."
        inputField.backgroundColor = .systemGray6
        inputField.layer.cornerRadius = 20
        inputField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        inputField.leftViewMode = .always
        inputField.translatesAutoresizingMaskIntoConstraints = false
        
        // Add send button to input
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        sendButton.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: config), for: .normal)
        sendButton.tintColor = .systemBlue
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSendComment), for: .touchUpInside)
        
        view.addSubview(tableView)
        view.addSubview(commentInputBar)
        commentInputBar.addSubview(inputField)
        commentInputBar.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: commentInputBar.topAnchor),
            
            commentInputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            commentInputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            commentInputBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            commentInputBar.heightAnchor.constraint(equalToConstant: 100),
            
            inputField.topAnchor.constraint(equalTo: commentInputBar.topAnchor, constant: 12),
            inputField.leadingAnchor.constraint(equalTo: commentInputBar.leadingAnchor, constant: 16),
            inputField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            inputField.heightAnchor.constraint(equalToConstant: 40),
            
            sendButton.centerYAnchor.constraint(equalTo: inputField.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: commentInputBar.trailingAnchor, constant: -16)
        ])
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func handleSendComment() {
        guard let text = inputField.text, !text.isEmpty, let item = newsItem else { return }
        
        var parentId: String? = nil
        var level = 0
        
        if let replyIndex = activeReplyToIndex {
            parentId = comments[replyIndex].id
            level = 1
        }
        
        sendButton.isEnabled = false
        activityIndicator.startAnimating()
        
        let authorName = UserDefaults.standard.string(forKey: "currentUserFullName") ?? "User"
        let authorColor = UIColor.systemBlue
        
        saveAndPostComment(text: text, parentId: parentId, authorName: authorName, authorColor: authorColor, level: level, item: item)
    }
    
    private func saveAndPostComment(text: String, parentId: String?, authorName: String, authorColor: UIColor, level: Int, item: NewsItem) {
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
                        self.postComment(newsCardId: cachedId, text: text, parentId: parentId, authorName: authorName, authorColor: authorColor, level: level)
                    }
                    return
                }
                self.finishPosting(success: false)
                return
            }
            
            self.postComment(newsCardId: newsCardId, text: text, parentId: parentId, authorName: authorName, authorColor: authorColor, level: level)
        }
    }
    
    private func postComment(newsCardId: String, text: String, parentId: String?, authorName: String, authorColor: UIColor, level: Int) {
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
                    let newComment = JBMComment(
                        id: commentDB.id ?? UUID().uuidString,
                        userName: commentDB.userName,
                        text: commentDB.text,
                        timeAgo: "just now",
                        likes: commentDB.likesCount ?? 0,
                        level: commentDB.level
                    )
                    
                    if let replyIndex = self.activeReplyToIndex {
                        self.comments[replyIndex].nestedReplies.append(newComment)
                        self.comments[replyIndex].isExpanded = true
                    } else {
                        self.comments.insert(newComment, at: 0)
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
                self.inputField.text = ""
                self.inputField.placeholder = "Write a reply..."
                self.activeReplyToIndex = nil
                self.inputField.resignFirstResponder()
                self.tableView.reloadData()
            } else {
                let alert = UIAlertController(title: "Error", message: "Failed to post comment. Please try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
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
    
    private func organizeComments(_ fetchedComments: [CommentDB]) {
        var rootComments: [String: JBMComment] = [:]
        var replies: [CommentDB] = []
        
        for comment in fetchedComments {
            if comment.parentCommentId == nil, let id = comment.id {
                let jbm = JBMComment(
                    id: id,
                    userName: comment.userName,
                    text: comment.text,
                    timeAgo: comment.createdAt?.timeAgoDisplay() ?? "recent",
                    likes: comment.likesCount ?? 0,
                    level: comment.level
                )
                rootComments[id] = jbm
            } else if comment.parentCommentId != nil {
                replies.append(comment)
            }
        }
        
        for reply in replies {
            if let parentId = reply.parentCommentId, let _ = rootComments[parentId], let id = reply.id {
                let jbmReply = JBMComment(
                    id: id,
                    userName: reply.userName,
                    text: reply.text,
                    timeAgo: reply.createdAt?.timeAgoDisplay() ?? "recent",
                    likes: reply.likesCount ?? 0,
                    level: reply.level
                )
                rootComments[parentId]?.nestedReplies.append(jbmReply)
            }
        }
        
        self.comments = Array(rootComments.values).sorted { c1, c2 in
            return true 
        }
        self.tableView.reloadData()
    }

    // MARK: - Header (No Bold Highlight Box)
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground

        let articleImageView = UIImageView()
        articleImageView.contentMode = .scaleAspectFill
        articleImageView.clipsToBounds = true
        articleImageView.backgroundColor = .darkGray
        articleImageView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(articleImageView)
        
        if let urlStr = newsItem?.imageURL, let url = URL(string: urlStr) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data { DispatchQueue.main.async { articleImageView.image = UIImage(data: data) } }
            }.resume()
        }
        
        let headlineLabel = UILabel()
        headlineLabel.text = newsItem?.title.uppercased() ?? "ARTICLE HEADLINE"
        headlineLabel.font = .systemFont(ofSize: 11, weight: .black); headlineLabel.textColor = .systemGray3
        headlineLabel.numberOfLines = 2
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(headlineLabel)

        NSLayoutConstraint.activate([
            articleImageView.topAnchor.constraint(equalTo: headerView.topAnchor),
            articleImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            articleImageView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            articleImageView.heightAnchor.constraint(equalToConstant: 320),

            headlineLabel.topAnchor.constraint(equalTo: articleImageView.bottomAnchor, constant: 24),
            headlineLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            headlineLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            headlineLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20)
        ])
        return headerView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return comments.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JoinedCardCell", for: indexPath) as! JBMCardCommentCell
        cell.configure(with: comments[indexPath.row])
        cell.onToggleExpansion = { [weak self] in
            self?.comments[indexPath.row].isExpanded.toggle()
            self?.tableView.reloadData()
        }
        cell.onReplyTriggered = { [weak self] username in
            self?.activeReplyToIndex = indexPath.row
            self?.inputField.placeholder = "Replying to \(username)..."
            self?.inputField.becomeFirstResponder()
        }
        return cell
    }
}

// MARK: - 3. Card Cell (White Card + Grey Bubbles)
class JBMCardCommentCell: UITableViewCell {
    private let mainCard = UIView()
    private let profileImage = UIImageView(image: UIImage(systemName: "person.crop.circle.fill"))
    private let nameLabel = UILabel()
    private let bodyLabel = UILabel()
    private let actionsStack = UIStackView()
    private let upBtn = UIButton()
    private let scoreLabel = UILabel()
    private let downBtn = UIButton()
    private let replyBtn = UIButton()
    private let replyStack = UIStackView()
    private let viewMoreBtn = UIButton(type: .system)

    var onToggleExpansion: (() -> Void)?
    var onReplyTriggered: ((String) -> Void)?
    
    private var currentVote: Int = 0
    private var baseLikes: Int = 0

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }

    private func setupLayout() {
        selectionStyle = .none; backgroundColor = .clear
        
        mainCard.backgroundColor = .systemBackground
        mainCard.layer.cornerRadius = 16
        mainCard.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainCard)
        
        profileImage.tintColor = .systemGray4
        nameLabel.font = .systemFont(ofSize: 14, weight: .bold)
        bodyLabel.font = .systemFont(ofSize: 15); bodyLabel.numberOfLines = 0
        
        upBtn.addTarget(self, action: #selector(handleParentUp), for: .touchUpInside)
        downBtn.addTarget(self, action: #selector(handleParentDown), for: .touchUpInside)
        replyBtn.setImage(UIImage(systemName: "arrowshape.turn.up.left.fill"), for: .normal)
        replyBtn.addTarget(self, action: #selector(handleParentReply), for: .touchUpInside)
        
        scoreLabel.font = .systemFont(ofSize: 13, weight: .bold)
        
        [upBtn, scoreLabel, downBtn, replyBtn].forEach {
            $0.tintColor = .systemGray3
            actionsStack.addArrangedSubview($0)
        }
        actionsStack.spacing = 15; actionsStack.alignment = .center
        
        replyStack.axis = .vertical; replyStack.spacing = 10
        viewMoreBtn.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        viewMoreBtn.setTitleColor(.systemGray3, for: .normal)
        viewMoreBtn.addTarget(self, action: #selector(handleExpand), for: .touchUpInside)

        [profileImage, nameLabel, bodyLabel, actionsStack, replyStack, viewMoreBtn].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            mainCard.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            mainCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            profileImage.topAnchor.constraint(equalTo: mainCard.topAnchor, constant: 15),
            profileImage.leadingAnchor.constraint(equalTo: mainCard.leadingAnchor, constant: 15),
            profileImage.widthAnchor.constraint(equalToConstant: 32),
            profileImage.heightAnchor.constraint(equalToConstant: 32),
            
            nameLabel.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 10),
            
            bodyLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 10),
            bodyLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: mainCard.trailingAnchor, constant: -15),
            
            actionsStack.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 12),
            actionsStack.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            replyStack.topAnchor.constraint(equalTo: actionsStack.bottomAnchor, constant: 15),
            replyStack.leadingAnchor.constraint(equalTo: mainCard.leadingAnchor, constant: 15),
            replyStack.trailingAnchor.constraint(equalTo: mainCard.trailingAnchor, constant: -15),
            
            viewMoreBtn.topAnchor.constraint(equalTo: replyStack.bottomAnchor, constant: 5),
            viewMoreBtn.leadingAnchor.constraint(equalTo: replyStack.leadingAnchor),
            viewMoreBtn.bottomAnchor.constraint(equalTo: mainCard.bottomAnchor, constant: -15)
        ])
    }

    func configure(with comment: JBMComment) {
        nameLabel.text = comment.userName
        bodyLabel.text = comment.text
        baseLikes = comment.likes
        currentVote = comment.voteStatus
        updateVoteUI()
        
        replyStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let repliesToShow = comment.isExpanded ? comment.nestedReplies : Array(comment.nestedReplies.prefix(2))
        repliesToShow.forEach { replyStack.addArrangedSubview(createReplyBubble(for: $0)) }
        viewMoreBtn.isHidden = comment.nestedReplies.count <= 2
    }

    @objc private func handleParentUp() { currentVote = (currentVote == 1) ? 0 : 1; updateVoteUI() }
    @objc private func handleParentDown() { currentVote = (currentVote == -1) ? 0 : -1; updateVoteUI() }
    @objc private func handleParentReply() { onReplyTriggered?(nameLabel.text ?? "") }

    private func updateVoteUI() {
        upBtn.setImage(UIImage(systemName: currentVote == 1 ? "hand.thumbsup.fill" : "hand.thumbsup"), for: .normal)
        downBtn.setImage(UIImage(systemName: currentVote == -1 ? "hand.thumbsdown.fill" : "hand.thumbsdown"), for: .normal)
        upBtn.tintColor = currentVote == 1 ? .systemBlue : .systemGray3
        downBtn.tintColor = currentVote == -1 ? .systemRed : .systemGray3
        scoreLabel.text = "\(baseLikes + currentVote)"
    }

    private func createReplyBubble(for reply: JBMComment) -> UIView {
        let container = UIView(); container.backgroundColor = .systemGray6; container.layer.cornerRadius = 12
        
        let user = UILabel()
        let authorName = UserDefaults.standard.string(forKey: "currentUserFullName") ?? "User"
        user.text = reply.userName == authorName ? "You" : reply.userName
        user.font = .systemFont(ofSize: 13, weight: .bold)
        
        let body = UILabel(); body.text = reply.text; body.font = .systemFont(ofSize: 14); body.numberOfLines = 0
        
        let rUp = UIButton(); rUp.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal); rUp.tintColor = .systemGray2
        let rDown = UIButton(); rDown.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal); rDown.tintColor = .systemGray2
        let rScore = UILabel(); rScore.text = "\(reply.likes)"; rScore.font = .systemFont(ofSize: 11, weight: .bold); rScore.textColor = .systemGray2
        let rReply = UIButton(); rReply.setImage(UIImage(systemName: "arrowshape.turn.up.left.fill"), for: .normal); rReply.tintColor = .systemGray2
        
        var bubbleVote = 0; let base = reply.likes
        rUp.addAction(UIAction(handler: { _ in
            bubbleVote = (bubbleVote == 1) ? 0 : 1
            rUp.setImage(UIImage(systemName: bubbleVote == 1 ? "hand.thumbsup.fill" : "hand.thumbsup"), for: .normal)
            rDown.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal)
            rUp.tintColor = bubbleVote == 1 ? .systemBlue : .systemGray2
            rScore.text = "\(base + bubbleVote)"
        }), for: .touchUpInside)

        rDown.addAction(UIAction(handler: { _ in
            bubbleVote = (bubbleVote == -1) ? 0 : -1
            rDown.setImage(UIImage(systemName: bubbleVote == -1 ? "hand.thumbsdown.fill" : "hand.thumbsdown"), for: .normal)
            rUp.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            rDown.tintColor = bubbleVote == -1 ? .systemRed : .systemGray2
            rScore.text = "\(base + bubbleVote)"
        }), for: .touchUpInside)
        
        rReply.addAction(UIAction(handler: { [weak self] _ in self?.onReplyTriggered?(reply.userName) }), for: .touchUpInside)

        let rStack = UIStackView(arrangedSubviews: [rUp, rScore, rDown, rReply]); rStack.spacing = 12
        [user, body, rStack].forEach { $0.translatesAutoresizingMaskIntoConstraints = false; container.addSubview($0) }
        
        NSLayoutConstraint.activate([
            user.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            user.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            body.topAnchor.constraint(equalTo: user.bottomAnchor, constant: 4),
            body.leadingAnchor.constraint(equalTo: user.leadingAnchor),
            body.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            rStack.topAnchor.constraint(equalTo: body.bottomAnchor, constant: 8),
            rStack.leadingAnchor.constraint(equalTo: user.leadingAnchor),
            rStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10)
        ])
        return container
    }

    @objc private func handleExpand() { onToggleExpansion?() }
}

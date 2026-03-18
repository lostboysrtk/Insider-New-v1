import UIKit

// MARK: - 1. Models

struct Comment {
    let id = UUID()
    let userName: String
    let text: String
    let timeAgo: String
    var likes: Int
    var voteStatus: VoteStatus = .none
    var nestedReplies: [Comment] = []
    var isExpanded: Bool = false
}

// MARK: - 2. View Controller
class DiscussionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let commentInputBar = UIView()
    private let inputField = UITextField()
    private let sendButton = UIButton(type: .system)
    
    var newsItem: NewsItem?
    var userComment: String?
    var explicitNewsCardId: String?
    
    // TRACKING STATE: Remembers which comment we are replying to
    private var activeReplyToIndex: Int?

    private var comments: [Comment] = []
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.hidesBottomBarWhenPushed = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavbar()
        setupUI()
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        fetchComments()
    }
    
    private func fetchComments() {
        activityIndicator.startAnimating()
        
        if let explicitId = explicitNewsCardId {
            fetchCommentsById(explicitId)
            return
        }
        
        guard let item = newsItem else { return }
        
        // Find newsCardId first
        fetchNewsCardId(for: item) { [weak self] newsCardId in
            guard let self = self, let cardId = newsCardId else {
                DispatchQueue.main.async { self?.activityIndicator.stopAnimating() }
                return
            }
            self.fetchCommentsById(cardId)
        }
    }
    
    private func fetchCommentsById(_ cardId: String) {
        NewsPersistenceManager.shared.getComments(forNewsCardId: cardId) { result in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                switch result {
                case .success(let fetchedComments):
                    self.organizeComments(fetchedComments)
                case .failure(let error):
                    print("Failed to fetch comments: \\(error)")
                }
            }
        }
    }
    
    private func fetchNewsCardId(for item: NewsItem, completion: @escaping (String?) -> Void) {
        guard let url = item.articleURL else { completion(nil); return }
        let queryParams = ["article_url": "eq.\\(url)", "limit": "1"]
        SupabaseService.shared.get(endpoint: SupabaseConfig.Tables.newsCards, queryParams: queryParams) { (result: Result<[NewsCardDB], SupabaseError>) in
            switch result {
            case .success(let cards): completion(cards.first?.id)
            case .failure: completion(nil)
            }
        }
    }
    
    private func organizeComments(_ fetchedComments: [CommentDB]) {
        var rootComments: [String: Comment] = [:]
        var replies: [CommentDB] = []
        
        for comment in fetchedComments {
            if comment.parentCommentId == nil, let id = comment.id {
                let sbm = Comment(
                    userName: comment.userName,
                    text: comment.text,
                    timeAgo: comment.createdAt?.timeAgoDisplay() ?? "recent",
                    likes: comment.likesCount ?? 0,
                    voteStatus: .none,
                    nestedReplies: [],
                    isExpanded: false
                )
                // Need to use id to link replies, but Comment struct uses UUID without ID mapping.
                // We map by ID for now just to build the hierarchy
                rootComments[id] = sbm
            } else if comment.parentCommentId != nil {
                replies.append(comment)
            }
        }
        
        for reply in replies {
            if let parentId = reply.parentCommentId, let _ = rootComments[parentId] {
                let sbmReply = Comment(
                    userName: reply.userName,
                    text: reply.text,
                    timeAgo: reply.createdAt?.timeAgoDisplay() ?? "recent",
                    likes: reply.likesCount ?? 0
                )
                rootComments[parentId]?.nestedReplies.append(sbmReply)
            }
        }
        
        self.comments = Array(rootComments.values)
        self.tableView.reloadData()
    }

    private func setupNavbar() {
        self.title = "Discussion"
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
        tableView.register(DiscussionCardCell.self, forCellReuseIdentifier: "DiscussionCardCell")
        
        commentInputBar.backgroundColor = .systemBackground
        commentInputBar.translatesAutoresizingMaskIntoConstraints = false
        
        inputField.placeholder = "Write a comment..."
        inputField.backgroundColor = .systemGray6
        inputField.layer.cornerRadius = 20
        inputField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        inputField.leftViewMode = .always
        inputField.translatesAutoresizingMaskIntoConstraints = false
        
        sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton.tintColor = .systemBlue
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSendAction), for: .touchUpInside)
        
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
            inputField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -12),
            inputField.heightAnchor.constraint(equalToConstant: 40),
            
            sendButton.centerYAnchor.constraint(equalTo: inputField.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: commentInputBar.trailingAnchor, constant: -16),
            sendButton.widthAnchor.constraint(equalToConstant: 44)
        ])
    }

    // MARK: - Posting Logic
    @objc private func handleSendAction() {
        guard let text = inputField.text, !text.isEmpty else { return }
        
        let authorName = UserDefaults.standard.string(forKey: "currentUserFullName") ?? "User"
        let newReply = Comment(userName: authorName, text: text, timeAgo: "now", likes: 0)
        
        if let index = activeReplyToIndex {
            // Add as a nested reply to existing comment
            comments[index].nestedReplies.append(newReply)
            comments[index].isExpanded = true
        } else {
            // Post as a brand new main comment
            comments.insert(newReply, at: 0)
        }
        
        // UI Reset
        inputField.text = ""
        inputField.placeholder = "Write a comment..."
        activeReplyToIndex = nil
        inputField.resignFirstResponder()
        tableView.reloadData()
        
        // Scroll to the updated section if needed
    }

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
        headlineLabel.text = newsItem?.title.uppercased() ?? "DISCUSSION TOPIC"
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscussionCardCell", for: indexPath) as! DiscussionCardCell
        cell.configure(with: comments[indexPath.row])
        
        cell.onToggleExpansion = { [weak self] in
            self?.comments[indexPath.row].isExpanded.toggle()
            self?.tableView.reloadData()
        }
        
        cell.onReplyTriggered = { [weak self] username in
            self?.activeReplyToIndex = indexPath.row // Store the index to append reply later
            self?.inputField.placeholder = "Replying to \(username)..."
            self?.inputField.becomeFirstResponder()
        }
        return cell
    }
}

// MARK: - 3. Card Cell
class DiscussionCardCell: UITableViewCell {
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
    
    private var currentVote: VoteStatus = .none
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
        
        // STYLING: Reply Button with Grey Text
        replyBtn.setTitle("Reply", for: .normal)
        replyBtn.setTitleColor(.systemGray, for: .normal)
        replyBtn.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
        replyBtn.addTarget(self, action: #selector(handleParentReply), for: .touchUpInside)
        
        scoreLabel.font = .systemFont(ofSize: 13, weight: .bold)
        
        [upBtn, scoreLabel, downBtn, replyBtn].forEach {
            if $0 != replyBtn { $0.tintColor = .systemGray3 }
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

    func configure(with comment: Comment) {
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

    @objc private func handleParentUp() { currentVote = (currentVote == .upvoted) ? .none : .upvoted; updateVoteUI() }
    @objc private func handleParentDown() { currentVote = (currentVote == .downvoted) ? .none : .downvoted; updateVoteUI() }
    @objc private func handleParentReply() { onReplyTriggered?(nameLabel.text ?? "") }

    private func updateVoteUI() {
        upBtn.setImage(UIImage(systemName: currentVote == .upvoted ? "hand.thumbsup.fill" : "hand.thumbsup"), for: .normal)
        downBtn.setImage(UIImage(systemName: currentVote == .downvoted ? "hand.thumbsdown.fill" : "hand.thumbsdown"), for: .normal)
        upBtn.tintColor = currentVote == .upvoted ? .systemBlue : .systemGray3
        downBtn.tintColor = currentVote == .downvoted ? .systemRed : .systemGray3
        var total = baseLikes
        if currentVote == .upvoted { total += 1 } else if currentVote == .downvoted { total -= 1 }
        scoreLabel.text = "\(total)"
    }

    private func createReplyBubble(for reply: Comment) -> UIView {
        let container = UIView(); container.backgroundColor = .systemGray6; container.layer.cornerRadius = 12
        let user = UILabel()
        let authorName = UserDefaults.standard.string(forKey: "currentUserFullName") ?? "User"
        user.text = reply.userName == authorName ? "You" : reply.userName
        user.font = .systemFont(ofSize: 13, weight: .bold)
        let body = UILabel(); body.text = reply.text; body.font = .systemFont(ofSize: 14); body.numberOfLines = 0
        
        let rUp = UIButton(); rUp.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal); rUp.tintColor = .systemGray2
        let rDown = UIButton(); rDown.setImage(UIImage(systemName: "hand.thumbsdown"), for: .normal); rDown.tintColor = .systemGray2
        let rScore = UILabel(); rScore.text = "\(reply.likes)"; rScore.font = .systemFont(ofSize: 11, weight: .bold); rScore.textColor = .systemGray2
        
        // STYLING: Reply Button with Grey Text in Bubble
        let rReply = UIButton(); rReply.setTitle("Reply", for: .normal)
        rReply.setTitleColor(.systemGray, for: .normal)
        rReply.titleLabel?.font = .systemFont(ofSize: 11, weight: .bold)
        
        var bubbleVote: VoteStatus = .none
        let base = reply.likes
        
        rUp.addAction(UIAction(handler: { _ in
            bubbleVote = (bubbleVote == .upvoted) ? .none : .upvoted
            rUp.setImage(UIImage(systemName: bubbleVote == .upvoted ? "hand.thumbsup.fill" : "hand.thumbsup"), for: .normal)
            rUp.tintColor = bubbleVote == .upvoted ? .systemBlue : .systemGray2
            var score = base; if bubbleVote == .upvoted { score += 1 }; rScore.text = "\(score)"
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

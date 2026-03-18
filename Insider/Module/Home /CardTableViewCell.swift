import UIKit

class CardTableViewCell: UITableViewCell, UITextViewDelegate {
    
    // MARK: - Properties
    // Callback to handle opening links in WebKit inside the ViewController
    var onContentTap: (() -> Void)?
    var onSourceLinkTap: ((String) -> Void)?  // Callback for source link taps
    var onBookmarkTap: ((Bool) -> Void)?     // Callback for bookmark taps
    
    private var isLiked = false
    private var isDisliked = false
    private var isBookmarked = false
    private var newsItem: NewsItem?
    
    // Tracked counts (mutable copies from the NewsItem)
    private var likeCount: Int = 0
    private var dislikeCount: Int = 0
    
    // MARK: - UI Components
    private let cardContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 24
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.separator.cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let newsImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray5
        iv.layer.cornerRadius = 24
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.heightAnchor.constraint(equalToConstant: 180).isActive = true
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        lbl.numberOfLines = 3
        lbl.textColor = .label
        return lbl
    }()
    
    private let bodyLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.preferredFont(forTextStyle: .body)
        lbl.numberOfLines = 6
        lbl.lineBreakMode = .byTruncatingTail
        lbl.textColor = .secondaryLabel
        return lbl
    }()
    
    private let sourceStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()
    
    private lazy var sourceTextView: UITextView = {
        let tv = UITextView()
        tv.isScrollEnabled = false
        tv.isEditable = false
        tv.isSelectable = true
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.backgroundColor = .clear
        tv.delegate = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let devknows: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        btn.setImage(UIImage(systemName: "sparkles", withConfiguration: config), for: .normal)
        btn.tintColor = .systemIndigo
        btn.backgroundColor = .clear
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let actionStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let like = UIButton(type: .system)
    private let likeCountLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 13, weight: .semibold)
        lbl.textColor = .systemGray
        lbl.text = "0"
        return lbl
    }()
    
    let dislike = UIButton(type: .system)
    private let dislikeCountLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 13, weight: .semibold)
        lbl.textColor = .systemGray
        lbl.text = "0"
        return lbl
    }()
    
    let bookmark = UIButton(type: .system)
    let discussion = UIButton(type: .system)
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()

    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Configuration
    func configure(with item: NewsItem) {
        self.newsItem = item
        titleLabel.text = item.title
        bodyLabel.text = item.description
        
        // Load image
        ImageLoader.shared.loadImage(from: item.imageURL, into: newsImageView)
        
        // Setup Link in Source TextView
        if let articleURLString = item.articleURL, let url = URL(string: articleURLString) {
            let linkText = "🔗 \(item.source)"
            let attributed = NSMutableAttributedString(string: linkText)
            attributed.addAttribute(.link, value: url, range: NSRange(location: 0, length: attributed.length))
            attributed.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .medium), range: NSRange(location: 0, length: attributed.length))
            attributed.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: NSRange(location: 0, length: attributed.length))
            sourceTextView.attributedText = attributed
        }
        
        // Initialize counts from the item
        likeCount = Int(item.likes) ?? 0
        dislikeCount = Int(item.dislikes) ?? 0
        
        // Restore persisted like/dislike state
        if let cardId = item.id {
            isLiked = UserDefaults.standard.bool(forKey: "liked_\(cardId)")
            isDisliked = UserDefaults.standard.bool(forKey: "disliked_\(cardId)")
        } else {
            isLiked = false
            isDisliked = false
        }
        // Restore persisted bookmark state
        if let cardId = item.id {
            isBookmarked = UserDefaults.standard.bool(forKey: "bookmarked_\(cardId)")
        } else {
            isBookmarked = false
        }
        
        // Update UI
        updateSocialUI()
        
        // WEBVIEW TRIGGER
        cardContainer.gestureRecognizers?.forEach { cardContainer.removeGestureRecognizer($0) }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(contentTapped))
        cardContainer.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        onSourceLinkTap?(URL.absoluteString)
        return false
    }
    
    // MARK: - Actions
    @objc private func contentTapped() {
        onContentTap?()
    }
    
    @objc private func likeTapped() {
        guard let item = newsItem, let cardId = item.id else { return }
        
        if isLiked {
            // Un-like
            isLiked = false
            likeCount = max(0, likeCount - 1)
        } else {
            // Like (and remove dislike if active)
            isLiked = true
            likeCount += 1
            if isDisliked {
                isDisliked = false
                dislikeCount = max(0, dislikeCount - 1)
            }
        }
        
        // Persist state
        UserDefaults.standard.set(isLiked, forKey: "liked_\(cardId)")
        UserDefaults.standard.set(isDisliked, forKey: "disliked_\(cardId)")
        
        updateSocialUI()
        
        // Persist counts to database
        NewsPersistenceManager.shared.updateNewsCardCounters(
            id: cardId,
            likes: likeCount,
            dislikes: dislikeCount
        ) { result in
            if case .failure(let error) = result {
                print("⚠️ Failed to update like count: \(error)")
            }
        }
    }
    
    @objc private func dislikeTapped() {
        guard let item = newsItem, let cardId = item.id else { return }
        
        if isDisliked {
            // Un-dislike
            isDisliked = false
            dislikeCount = max(0, dislikeCount - 1)
        } else {
            // Dislike (and remove like if active)
            isDisliked = true
            dislikeCount += 1
            if isLiked {
                isLiked = false
                likeCount = max(0, likeCount - 1)
            }
        }
        
        // Persist state
        UserDefaults.standard.set(isLiked, forKey: "liked_\(cardId)")
        UserDefaults.standard.set(isDisliked, forKey: "disliked_\(cardId)")
        
        updateSocialUI()
        
        // Persist counts to database
        NewsPersistenceManager.shared.updateNewsCardCounters(
            id: cardId,
            likes: likeCount,
            dislikes: dislikeCount
        ) { result in
            if case .failure(let error) = result {
                print("⚠️ Failed to update dislike count: \(error)")
            }
        }
    }
    
    @objc private func bookmarkTapped() {
        isBookmarked.toggle()
        updateSocialUI()
        onBookmarkTap?(isBookmarked)
    }
    
    private func updateSocialUI() {
        // Like button
        like.tintColor = isLiked ? AppColor.brand : .systemGray
        like.setImage(UIImage(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup"), for: .normal)
        likeCountLabel.text = "\(likeCount)"
        likeCountLabel.textColor = isLiked ? AppColor.brand : .systemGray
        
        // Dislike button
        dislike.tintColor = isDisliked ? .systemRed : .systemGray
        dislike.setImage(UIImage(systemName: isDisliked ? "hand.thumbsdown.fill" : "hand.thumbsdown"), for: .normal)
        dislikeCountLabel.text = "\(dislikeCount)"
        dislikeCountLabel.textColor = isDisliked ? .systemRed : .systemGray
        
        // Bookmark button
        bookmark.tintColor = isBookmarked ? AppColor.brand : .systemGray
        bookmark.setImage(UIImage(systemName: isBookmarked ? "bookmark.fill" : "bookmark"), for: .normal)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        contentView.addSubview(cardContainer)
        cardContainer.addSubview(mainStack)
        mainStack.addArrangedSubview(newsImageView)
        
        let contentWrapper = UIStackView()
        contentWrapper.axis = .vertical
        contentWrapper.spacing = 8
        contentWrapper.isLayoutMarginsRelativeArrangement = true
        contentWrapper.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        contentWrapper.addArrangedSubview(titleLabel)
        contentWrapper.addArrangedSubview(bodyLabel)
        
        sourceStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        sourceStack.addArrangedSubview(sourceTextView)
        let sourceSpacer = UIView()
        sourceSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        sourceStack.addArrangedSubview(sourceSpacer)
        
        contentWrapper.addArrangedSubview(sourceStack)
        mainStack.addArrangedSubview(contentWrapper)
        mainStack.addArrangedSubview(separatorLine)
        
        let actionWrapper = UIView()
        actionWrapper.addSubview(actionStack)
        setupActionButtons()
        
        // Like button + count label group
        let likeGroup = UIStackView(arrangedSubviews: [like, likeCountLabel])
        likeGroup.axis = .horizontal
        likeGroup.spacing = 2
        likeGroup.alignment = .center
        
        // Dislike button + count label group
        let dislikeGroup = UIStackView(arrangedSubviews: [dislike, dislikeCountLabel])
        dislikeGroup.axis = .horizontal
        dislikeGroup.spacing = 2
        dislikeGroup.alignment = .center
        
        actionStack.addArrangedSubview(likeGroup)
        actionStack.addArrangedSubview(dislikeGroup)
        
        let midSpacer = UIView()
        midSpacer.translatesAutoresizingMaskIntoConstraints = false
        midSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        actionStack.addArrangedSubview(midSpacer)
        
        actionStack.addArrangedSubview(devknows)
        actionStack.addArrangedSubview(discussion)
        actionStack.addArrangedSubview(bookmark)
        
        mainStack.addArrangedSubview(actionWrapper)
        
        NSLayoutConstraint.activate([
            cardContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            cardContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            cardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            mainStack.topAnchor.constraint(equalTo: cardContainer.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor, constant: -12),
            mainStack.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
            
            sourceTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 24),
            
            actionStack.topAnchor.constraint(equalTo: actionWrapper.topAnchor),
            actionStack.bottomAnchor.constraint(equalTo: actionWrapper.bottomAnchor),
            actionStack.leadingAnchor.constraint(equalTo: actionWrapper.leadingAnchor, constant: 16),
            actionStack.trailingAnchor.constraint(equalTo: actionWrapper.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupActionButtons() {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        func style(_ btn: UIButton, icon: String) {
            btn.setImage(UIImage(systemName: icon, withConfiguration: config), for: .normal)
            btn.tintColor = .systemGray
        }
        style(like, icon: "hand.thumbsup")
        style(dislike, icon: "hand.thumbsdown")
        style(discussion, icon: "bubble.left")
        style(bookmark, icon: "bookmark")
        
        like.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        dislike.addTarget(self, action: #selector(dislikeTapped), for: .touchUpInside)
        bookmark.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
    }
}

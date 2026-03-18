import UIKit
import SafariServices

class ArticleDetailViewController: UIViewController {
    
    private let article: NewsItem
    private let libraryTitle: String
    
    // MARK: - State
    private var likeCount: Int
    private var dislikeCount: Int
    private var isLiked: Bool = false
    private var isDisliked: Bool = false
    private var isBookmarked: Bool = false
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.backgroundColor = .systemGroupedBackground
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let cardView: UIView = {
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
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 24
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        iv.backgroundColor = .systemGray5
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.numberOfLines = 0
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.numberOfLines = 6 // STRICT 6 LINE LIMIT
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let sourceStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.isUserInteractionEnabled = true
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let interactionStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let likeBtn = UIButton(type: .system)
    private let dislikeBtn = UIButton(type: .system)
    private let sparkleBtn = UIButton(type: .system)
    private let commentBtn = UIButton(type: .system)
    private let bookmarkBtn = UIButton(type: .system)

    // MARK: - Init
    init(article: NewsItem, libraryTitle: String) {
        self.article = article
        self.libraryTitle = libraryTitle
        self.likeCount = Int(article.likes) ?? 0
        self.dislikeCount = Int(article.dislikes) ?? 0
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupButtonStyles()
        configureData()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    private func setupNavigationBar() {
        self.title = libraryTitle
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = .label
    }
    
    private func setupButtonStyles() {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        
        func style(_ btn: UIButton, icon: String, title: String? = nil) {
            btn.setImage(UIImage(systemName: icon, withConfiguration: config), for: .normal)
            btn.tintColor = .systemGray
            if let title = title {
                btn.setTitle(" \(title)", for: .normal)
                btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            }
        }
        
        style(likeBtn, icon: "hand.thumbsup", title: "\(likeCount)")
        style(dislikeBtn, icon: "hand.thumbsdown", title: "\(dislikeCount)")
        style(commentBtn, icon: "bubble.left", title: article.comments)
        style(bookmarkBtn, icon: "bookmark")
        
        sparkleBtn.setImage(UIImage(systemName: "sparkles", withConfiguration: config), for: .normal)
        sparkleBtn.tintColor = .systemIndigo
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(cardView)
        
        [imageView, headlineLabel, bodyLabel, sourceStack, separatorLine, interactionStack].forEach {
            cardView.addSubview($0)
        }
        
        let linkIcon = UIImageView(image: UIImage(systemName: "link"))
        linkIcon.tintColor = .systemBlue
        linkIcon.contentMode = .scaleAspectFit
        linkIcon.widthAnchor.constraint(equalToConstant: 14).isActive = true
        linkIcon.heightAnchor.constraint(equalToConstant: 14).isActive = true
        
        sourceStack.addArrangedSubview(linkIcon)
        sourceStack.addArrangedSubview(sourceLabel)
        
        [likeBtn, dislikeBtn, sparkleBtn, commentBtn, bookmarkBtn].forEach { interactionStack.addArrangedSubview($0) }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            imageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 250),
            
            headlineLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            headlineLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            headlineLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            bodyLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 12),
            bodyLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            bodyLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            sourceStack.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 16),
            sourceStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            
            separatorLine.topAnchor.constraint(equalTo: sourceStack.bottomAnchor, constant: 16),
            separatorLine.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            separatorLine.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5),
            
            interactionStack.topAnchor.constraint(equalTo: separatorLine.bottomAnchor, constant: 8),
            interactionStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            interactionStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            interactionStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            interactionStack.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func configureData() {
        headlineLabel.text = article.title
        bodyLabel.text = article.description
        sourceLabel.text = article.source.lowercased()
        
        // Using the extension provided in your code snippet
        imageView.loadImage(from: article.imageURL ?? "")
        updateSocialUI()
    }
    
    private func setupActions() {
        likeBtn.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        dislikeBtn.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
        sparkleBtn.addTarget(self, action: #selector(openDevKnows), for: .touchUpInside)
        commentBtn.addTarget(self, action: #selector(openDiscussion), for: .touchUpInside)
        bookmarkBtn.addTarget(self, action: #selector(bookmarkTapped), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openSourceLink))
        sourceStack.addGestureRecognizer(tap)
    }

    // MARK: - Handlers
    
    @objc private func handleLike() {
        isLiked.toggle()
        if isLiked {
            likeCount += 1
            if isDisliked { isDisliked = false; dislikeCount -= 1 }
        } else {
            likeCount -= 1
        }
        updateSocialUI()
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    @objc private func handleDislike() {
        isDisliked.toggle()
        if isDisliked {
            dislikeCount += 1
            if isLiked { isLiked = false; likeCount -= 1 }
        } else {
            dislikeCount -= 1
        }
        updateSocialUI()
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    @objc private func bookmarkTapped() {
        isBookmarked.toggle()
        updateSocialUI()
    }

    private func updateSocialUI() {
        likeBtn.tintColor = isLiked ? AppColor.brand : .systemGray
        likeBtn.setImage(UIImage(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup"), for: .normal)
        likeBtn.setTitle(" \(likeCount)", for: .normal)
        
        dislikeBtn.tintColor = isDisliked ? AppColor.Status.error : .systemGray
        dislikeBtn.setImage(UIImage(systemName: isDisliked ? "hand.thumbsdown.fill" : "hand.thumbsdown"), for: .normal)
        dislikeBtn.setTitle(" \(dislikeCount)", for: .normal)
        
        bookmarkBtn.tintColor = isBookmarked ? AppColor.brand : .systemGray
        bookmarkBtn.setImage(UIImage(systemName: isBookmarked ? "bookmark.fill" : "bookmark"), for: .normal)
    }

    @objc func openDiscussion() {
        let vc = PostDiscussionViewController()
        vc.newsItem = self.article
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func openDevKnows() {
        let vc = DevKnowsViewController()
        vc.newsItemContext = self.article
        present(vc, animated: true)
    }
    
    @objc private func openSourceLink() {
        guard let urlString = article.articleURL, let url = URL(string: urlString) else { return }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
}
// MARK: - UIImageView Extension
extension UIImageView {
    func loadImage(from urlString: String) {
        guard !urlString.isEmpty, let url = URL(string: urlString) else {
            self.image = nil // Optional: Set a placeholder image here
            return
        }
        
        // Basic async image loading
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
        }.resume()
    }
}

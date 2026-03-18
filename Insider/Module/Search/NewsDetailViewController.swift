import UIKit

class NewsDetailViewController: UIViewController, UITextViewDelegate {
    
    var newsItem: NewsItem?
    
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
    
    private let newsImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray5
        iv.layer.cornerRadius = 24
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        lbl.numberOfLines = 0
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
    
    private lazy var devknows: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        btn.setImage(UIImage(systemName: "sparkles", withConfiguration: config), for: .normal)
        btn.tintColor = .systemIndigo
        btn.backgroundColor = .clear
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(openDevKnows), for: .touchUpInside)
        return btn
    }()
    
    private let actionStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let like = UIButton(type: .system)
    private let dislike = UIButton(type: .system)
    private let bookmark = UIButton(type: .system)
    private let discussion = UIButton(type: .system)
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        btn.layer.cornerRadius = 20
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        return btn
    }()
    
    // MARK: - Properties
    private var isLiked = false
    private var isDisliked = false
    private var isBookmarked = false
    private var currentLikes = 0
    private var currentDislikes = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        setupUI()
        configureContent()
        
        print("📱 NewsDetailVC loaded")
        print("Navigation controller: \(navigationController != nil ? "✅ EXISTS" : "❌ NIL")")
        print("View controllers in stack: \(navigationController?.viewControllers.count ?? 0)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
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
        
        actionStack.addArrangedSubview(like)
        actionStack.addArrangedSubview(dislike)
        
        let midSpacer = UIView()
        midSpacer.translatesAutoresizingMaskIntoConstraints = false
        midSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        actionStack.addArrangedSubview(midSpacer)
        
        actionStack.addArrangedSubview(devknows)
        actionStack.addArrangedSubview(discussion)
        actionStack.addArrangedSubview(bookmark)
        
        mainStack.addArrangedSubview(actionWrapper)
        
        view.addSubview(backButton)
        
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
            
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            cardContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 80),
            cardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            mainStack.topAnchor.constraint(equalTo: cardContainer.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor, constant: -12),
            mainStack.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
            
            newsImageView.heightAnchor.constraint(equalToConstant: 250),
            
            sourceTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 24),
            
            separatorLine.heightAnchor.constraint(equalToConstant: 1),
            
            actionStack.topAnchor.constraint(equalTo: actionWrapper.topAnchor),
            actionStack.bottomAnchor.constraint(equalTo: actionWrapper.bottomAnchor),
            actionStack.leadingAnchor.constraint(equalTo: actionWrapper.leadingAnchor, constant: 16),
            actionStack.trailingAnchor.constraint(equalTo: actionWrapper.trailingAnchor, constant: -16)
        ])
        
        view.bringSubviewToFront(backButton)
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
        discussion.addTarget(self, action: #selector(openDiscussion), for: .touchUpInside)
    }

    private func configureContent() {
        guard let item = newsItem else { return }
        titleLabel.text = item.title
        bodyLabel.text = item.description
        ImageLoader.shared.loadImage(from: item.imageURL, into: newsImageView)
        
        if let articleURLString = item.articleURL, let url = URL(string: articleURLString) {
            let linkText = "🔗 \(item.source)"
            let attributed = NSMutableAttributedString(string: linkText)
            attributed.addAttribute(.link, value: url, range: NSRange(location: 0, length: attributed.length))
            attributed.addAttribute(.font, value: UIFont.systemFont(ofSize: 13), range: NSRange(location: 0, length: attributed.length))
            attributed.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: NSRange(location: 0, length: attributed.length))
            sourceTextView.attributedText = attributed
        } else {
            sourceTextView.text = "🔗 \(item.source)"
            sourceTextView.textColor = .secondaryLabel
            sourceTextView.font = UIFont.systemFont(ofSize: 13)
        }
        
        currentLikes = 0
        currentDislikes = 0
        isLiked = false
        isDisliked = false
        isBookmarked = false
        
        discussion.setTitle(" 0", for: .normal)
        updateSocialUI()
    }

    @objc func didTapBack() {
        print("🔙 Back button TAPPED!")
        print("Navigation controller exists: \(navigationController != nil)")
        print("View controllers count: \(navigationController?.viewControllers.count ?? 0)")
        
        if let nav = navigationController {
            print("✅ Using navigation controller to pop")
            nav.popViewController(animated: true)
            return
        }
        
        print("⚠️ No nav controller - dismissing")
        dismiss(animated: true)
    }
    
    @objc private func likeTapped() {
        isLiked.toggle()
        
        if isLiked {
            currentLikes = 1
            if isDisliked {
                isDisliked = false
                currentDislikes = 0
            }
        } else {
            currentLikes = 0
        }
        
        updateSocialUI()
    }
    
    @objc private func dislikeTapped() {
        isDisliked.toggle()
        
        if isDisliked {
            currentDislikes = 1
            if isLiked {
                isLiked = false
                currentLikes = 0
            }
        } else {
            currentDislikes = 0
        }
        
        updateSocialUI()
    }
    
    @objc private func bookmarkTapped() {
        isBookmarked.toggle()
        updateSocialUI()
    }
    
    private func updateSocialUI() {
        like.tintColor = isLiked ? AppColor.brand : .systemGray
        like.setImage(UIImage(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup"), for: .normal)
        like.setTitle(" \(currentLikes)", for: .normal)
        
        dislike.tintColor = isDisliked ? AppColor.Status.error : .systemGray
        dislike.setImage(UIImage(systemName: isDisliked ? "hand.thumbsdown.fill" : "hand.thumbsdown"), for: .normal)
        dislike.setTitle(" \(currentDislikes)", for: .normal)
        
        bookmark.tintColor = isBookmarked ? AppColor.brand : .systemGray
        bookmark.setImage(UIImage(systemName: isBookmarked ? "bookmark.fill" : "bookmark"), for: .normal)
    }
    
    @objc func openDiscussion() {
        let vc = PostDiscussionViewController()
        vc.newsItem = self.newsItem
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func openDevKnows() {
        let vc = DevKnowsViewController()
        vc.newsItemContext = self.newsItem
        present(vc, animated: true)
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let webVC = WebViewController()
        webVC.urlString = URL.absoluteString
        webVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(webVC, animated: true)
        return false
    }
}



import UIKit

class TechnicalTranscriptViewController: UIViewController {
    var newsItem: TopChoiceItem?
    var transcriptIndex: Int = 0
    var fullArticleContent: String = "" // ADD THIS PROPERTY
    private var isBookmarked = false
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let bodyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        let bookmarkImage = isBookmarked ? "bookmark.fill" : "bookmark"
        let bookmarkBtn = UIBarButtonItem(image: UIImage(systemName: bookmarkImage), style: .plain, target: self, action: #selector(toggleBookmark))
        navigationItem.rightBarButtonItem = bookmarkBtn
    }
    
    @objc private func toggleBookmark() {
        isBookmarked.toggle()
        setupNavigationBar()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = newsItem?.title
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        bodyLabel.numberOfLines = 0
        bodyLabel.font = .systemFont(ofSize: 18, weight: .regular)
        bodyLabel.lineBreakMode = .byWordWrapping
        
        // UPDATED: Use fullArticleContent if available, otherwise get from store
        if !fullArticleContent.isEmpty {
            bodyLabel.text = fullArticleContent
        } else if let item = newsItem {
            bodyLabel.text = AudioDataStore.shared.getArticleContent(for: item, fallbackIndex: transcriptIndex)
        } else {
            bodyLabel.text = AudioDataStore.shared.getFullTranscript(for: transcriptIndex)
        }
        
        contentStack.addArrangedSubview(bodyLabel)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
}

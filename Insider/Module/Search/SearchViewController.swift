import UIKit

// MARK: - Search View Controller
class SearchViewController: UIViewController {

    // MARK: - Properties
    var newsItems: [NewsItem] = []
    var filteredItems: [NewsItem] = []
    
    private let allPossibleCategories = [
        ("AI & Future", "cpu", ["ai", "intelligence", "gpt", "robot", "t-mobile"]),
        ("Startups", "rocket", ["startup", "vc", "founder", "funding", "elon", "musk"]),
        ("Open Source", "terminal", ["source", "github", "linux", "repo", "verizon"]),
        ("Mobile App", "iphone", ["app", "android", "mobile", "store", "verizon"]),
        ("Cloud Computing", "cloud.fill", ["cloud", "aws", "azure", "server", "elon"]),
        ("Big Data", "database.fill", ["data", "analytics", "sql", "db", "verizon"]),
        ("SwiftUI", "swift", ["swift", "ios", "apple", "xcode"]),
        ("Web Dev", "safari", ["web", "javascript", "css", "react"]),
        ("Cybersecurity", "shield.lefthalf.filled", ["security", "hack", "cyber", "privacy"]),
        ("Fintech", "dollarsign.circle", ["finance", "crypto", "bank", "pay"]),
        ("Gaming", "gamecontroller", ["game", "playstation", "xbox", "steam"])
    ]
    
    var activeCategories: [(title: String, icon: String, keywords: [String], imageUrl: String?)] = []

    // MARK: - UI Components
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Search"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search news and categories..."
        sb.searchBarStyle = .minimal
        sb.delegate = self
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(CategoryGridCell.self, forCellWithReuseIdentifier: "CategoryCell")
        cv.register(SearchResultListCell.self, forCellWithReuseIdentifier: "ResultCell")
        cv.delegate = self
        cv.dataSource = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        fetchSearchData()
        
        // Debug
        print("🔍 SearchVC loaded")
        print("Navigation controller: \(navigationController != nil ? "✅ EXISTS" : "❌ NIL")")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Show navigation bar on this screen (hidden, since we use custom title)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // Debug
        print("🔍 SearchVC will appear")
        print("View controllers in stack: \(navigationController?.viewControllers.count ?? 0)")
    }

    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func fetchSearchData() {
        NewsAPIService.shared.fetchNews(for: .feed) { [weak self] result in
            if case .success(let items) = result {
                DispatchQueue.main.async {
                    self?.newsItems = items
                    self?.filterEmptyCategories()
                }
            }
        }
    }

    private func filterEmptyCategories() {
        activeCategories = allPossibleCategories.compactMap { cat -> (String, String, [String], String?)? in
            let keywords = cat.2
            let matchingItem = newsItems.first { item in
                let content = (item.title + " " + item.description).lowercased()
                return keywords.contains { content.contains($0) }
            }
            if let item = matchingItem { return (cat.0, cat.1, cat.2, item.imageURL) }
            return nil
        }
        collectionView.reloadData()
    }
}

// MARK: - Delegates
extension SearchViewController: UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let isSearching = !(searchBar.text?.isEmpty ?? true)
        
        if isSearching {
            // User tapped a search result - go to detail
            let selectedItem = filteredItems[indexPath.row]
            pushToDetail(with: selectedItem)
        } else {
            // User tapped a category - filter results
            let category = activeCategories[indexPath.row]
            searchBar.text = category.title
            filteredItems = newsItems.filter { item in
                let content = (item.title + " " + item.description).lowercased()
                return category.keywords.contains { content.contains($0) }
            }
            collectionView.reloadData()
            searchBar.resignFirstResponder()
        }
    }
    
    // CRITICAL FIX: Separate method for pushing to detail
    private func pushToDetail(with item: NewsItem) {
        print("🚀 Pushing to detail view")
        print("Navigation controller exists: \(navigationController != nil)")
        
        let detailVC = NewsDetailViewController()
        detailVC.newsItem = item
        detailVC.hidesBottomBarWhenPushed = true
        
        // CRITICAL: Verify navigation controller exists
        guard let nav = navigationController else {
            print("❌ ERROR: No navigation controller found!")
            // Fallback: present modally
            let navController = UINavigationController(rootViewController: detailVC)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
            return
        }
        
        print("✅ Navigation controller found - pushing")
        print("Current stack count: \(nav.viewControllers.count)")
        nav.pushViewController(detailVC, animated: true)
        print("New stack count: \(nav.viewControllers.count)")
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredItems = searchText.isEmpty ? [] : newsItems.filter {
            $0.title.lowercased().contains(searchText.lowercased())
        }
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return !(searchBar.text?.isEmpty ?? true) ? filteredItems.count : activeCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if !(searchBar.text?.isEmpty ?? true) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResultCell", for: indexPath) as! SearchResultListCell
            cell.configure(with: filteredItems[indexPath.row])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryGridCell
            let data = activeCategories[indexPath.row]
            cell.configure(title: data.title, imageUrl: data.imageUrl, iconName: data.icon)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return !(searchBar.text?.isEmpty ?? true)
            ? CGSize(width: view.frame.width - 40, height: 80)
            : CGSize(width: (view.frame.width - 50) / 2, height: 120)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 20, bottom: 100, right: 20)
    }
}

// MARK: - Internal Cell Classes
class CategoryGridCell: UICollectionViewCell {
    private let backgroundImageView = UIImageView()
    private let overlayView = UIView()
    private let titleLabel = UILabel()
    private let iconView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        [backgroundImageView, overlayView, iconView, titleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        backgroundImageView.contentMode = .scaleAspectFill
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 16, weight: .heavy)
        titleLabel.numberOfLines = 0
        iconView.tintColor = .white.withAlphaComponent(0.8)
        iconView.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            overlayView.topAnchor.constraint(equalTo: contentView.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            iconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            iconView.widthAnchor.constraint(equalToConstant: 35),
            iconView.heightAnchor.constraint(equalToConstant: 35),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    func configure(title: String, imageUrl: String?, iconName: String) {
        titleLabel.text = title.uppercased()
        iconView.image = UIImage(systemName: iconName)
        if let url = imageUrl { ImageLoader.shared.loadImage(from: url, into: backgroundImageView) }
        else { backgroundImageView.backgroundColor = .systemGray4 }
    }
    required init?(coder: NSCoder) { fatalError() }
}

class SearchResultListCell: UICollectionViewCell {
    private let thumbView = UIImageView()
    private let nameLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        thumbView.layer.cornerRadius = 8
        thumbView.clipsToBounds = true
        thumbView.contentMode = .scaleAspectFill
        thumbView.backgroundColor = .systemGray6
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        nameLabel.numberOfLines = 2
        [thumbView, nameLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        NSLayoutConstraint.activate([
            thumbView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbView.widthAnchor.constraint(equalToConstant: 60),
            thumbView.heightAnchor.constraint(equalToConstant: 60),
            nameLabel.leadingAnchor.constraint(equalTo: thumbView.trailingAnchor, constant: 15),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    func configure(with item: NewsItem) {
        nameLabel.text = item.title
        ImageLoader.shared.loadImage(from: item.imageURL, into: thumbView)
    }
    required init?(coder: NSCoder) { fatalError() }
}

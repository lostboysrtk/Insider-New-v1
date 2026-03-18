//
//import UIKit
//
//class NewAudioViewController: UIViewController {
//    
//    // MARK: - Properties
//    private var collectionView: UICollectionView!
//    private let store = AudioDataStore.shared
//    
//    // API Data Storage
//    private var breakingNewsItems: [BreakingNewsItem] = []
//    private var technicalBriefs: [TopChoiceItem] = []
//    
//    private var isLoadingData = false
//    private let refreshControl = UIRefreshControl()
//    private let loadingView = UIActivityIndicatorView(style: .large)
//    
//    // Daily refresh tracking
//    private let lastBreakingNewsRefreshKey = "lastBreakingNewsRefreshDate"
//    private let maxBreakingNewsCount = 5
//    
//    // UPDATED: Section order with View All at the end
//    enum Section: Int, CaseIterable {
//        case breakingNews
//        case devToolkits
//        case technicalBriefs
//        case viewAllButton
//        
//        var title: String? {
//            switch self {
//            case .breakingNews: return nil
//            case .devToolkits: return "Essential Dev Toolkits"
//            case .technicalBriefs: return "Today's Technical Briefs"
//            case .viewAllButton: return nil
//            }
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        loadDataFromDatabase()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        // Silently refresh breaking news if it's a new day
//        checkAndRefreshBreakingNewsIfNeeded()
//    }
//    
//    // MARK: - Setup
//    private func setupUI() {
//        title = "Audio"
//        self.tabBarItem.title = "Audio"
//        
//        view.backgroundColor = .systemBackground
//        navigationController?.navigationBar.prefersLargeTitles = true
//        
//        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
//        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        collectionView.backgroundColor = .clear
//        
//        collectionView.register(HeroHeadlineCell.self, forCellWithReuseIdentifier: "HeroCell")
//        collectionView.register(ToolkitPillCell.self, forCellWithReuseIdentifier: "ToolkitCell")
//        collectionView.register(ModernNewsListCell.self, forCellWithReuseIdentifier: "ListCell")
//        collectionView.register(MinimalViewAllCell.self, forCellWithReuseIdentifier: "ViewAllCell")
//        collectionView.register(AudioHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
//        
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        view.addSubview(collectionView)
//        
//        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
//        collectionView.refreshControl = refreshControl
//        
//        loadingView.translatesAutoresizingMaskIntoConstraints = false
//        loadingView.color = .systemIndigo
//        view.addSubview(loadingView)
//        
//        NSLayoutConstraint.activate([
//            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//    }
//    
//    // MARK: - Data Loading
//    
//    private func loadDataFromDatabase() {
//        guard !isLoadingData else { return }
//        isLoadingData = true
//        loadingView.startAnimating()
//        
//        let group = DispatchGroup()
//        
//        // Load Breaking News from Database — capped to top 5
//        group.enter()
//        store.loadBreakingNewsFromDatabase { [weak self] items in
//            guard let self = self else { group.leave(); return }
//            self.breakingNewsItems = Array(items.prefix(self.maxBreakingNewsCount))
//            group.leave()
//        }
//        
//        // Load Today's Technical Briefs (limit to 8 for main screen)
//        group.enter()
//        store.loadTodaysAudioFromDatabase { [weak self] items in
//            self?.technicalBriefs = Array(items.prefix(8))
//            group.leave()
//        }
//        
//        group.notify(queue: .main) { [weak self] in
//            self?.isLoadingData = false
//            self?.loadingView.stopAnimating()
//            self?.collectionView.reloadData()
//            
//            if self?.breakingNewsItems.isEmpty == true && self?.technicalBriefs.isEmpty == true {
//                self?.showNoContentAlert()
//            }
//        }
//    }
//    
//    // MARK: - Daily Breaking News Refresh
//    
//    /// Checks if breaking news was last fetched on a previous calendar day.
//    /// If so, silently refreshes from the API and saves the new date.
//    private func checkAndRefreshBreakingNewsIfNeeded() {
//        let defaults = UserDefaults.standard
//        let today = Calendar.current.startOfDay(for: Date())
//        
//        if let lastRefresh = defaults.object(forKey: lastBreakingNewsRefreshKey) as? Date {
//            let lastRefreshDay = Calendar.current.startOfDay(for: lastRefresh)
//            // Same day — no refresh needed
//            guard lastRefreshDay < today else { return }
//        }
//        
//        // New day (or first launch) — refresh breaking news from API
//        print("📅 New day detected — refreshing breaking news from API...")
//        store.refreshBreakingNewsOnly { [weak self] success in
//            DispatchQueue.main.async {
//                if success {
//                    UserDefaults.standard.set(Date(), forKey: self?.lastBreakingNewsRefreshKey ?? "")
//                    print("✅ Breaking news refreshed for today")
//                    // Reload only the breaking news section
//                    self?.store.loadBreakingNewsFromDatabase { items in
//                        DispatchQueue.main.async {
//                            guard let self = self else { return }
//                            self.breakingNewsItems = Array(items.prefix(self.maxBreakingNewsCount))
//                            self.collectionView.reloadSections(IndexSet(integer: Section.breakingNews.rawValue))
//                        }
//                    }
//                } else {
//                    print("⚠️ Breaking news daily refresh failed — will retry next launch")
//                }
//            }
//        }
//    }
//    
//    @objc private func refreshData() {
//        print("🔄 Refreshing audio content from API...")
//        
//        store.refreshAllAudioData { [weak self] success in
//            DispatchQueue.main.async {
//                self?.refreshControl.endRefreshing()
//                
//                if success {
//                    print("✅ Refresh successful, reloading data...")
//                    // Record refresh date so daily check doesn't double-refresh today
//                    UserDefaults.standard.set(Date(), forKey: self?.lastBreakingNewsRefreshKey ?? "")
//                    self?.loadDataFromDatabase()
//                    
//                    let generator = UINotificationFeedbackGenerator()
//                    generator.notificationOccurred(.success)
//                } else {
//                    print("⚠️ Refresh completed with some errors")
//                    self?.showRefreshErrorAlert()
//                }
//            }
//        }
//    }
//    
//    @objc private func viewAllTapped() {
//        let allAudioVC = AllAudioViewController()
//        navigationController?.pushViewController(allAudioVC, animated: true)
//    }
//    
//    // MARK: - Alert Helpers
//    
//    private func showNoContentAlert() {
//        let alert = UIAlertController(
//            title: "No Content Available",
//            message: "Pull down to refresh and load audio content from the API.",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//    
//    private func showRefreshErrorAlert() {
//        let alert = UIAlertController(
//            title: "Refresh Issue",
//            message: "Some content may not have updated. Check your internet connection and try again.",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//
//    // MARK: - Layout Creation
//    private func createLayout() -> UICollectionViewLayout {
//        return UICollectionViewCompositionalLayout { (sectionIdx, _) -> NSCollectionLayoutSection? in
//            guard let sectionType = Section(rawValue: sectionIdx) else { return nil }
//            
//            switch sectionType {
//            case .breakingNews:
//                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
//                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.92), heightDimension: .absolute(310)), subitems: [item])
//                let section = NSCollectionLayoutSection(group: group)
//                section.orthogonalScrollingBehavior = .groupPagingCentered
//                section.interGroupSpacing = 12
//                section.contentInsets = .init(top: 10, leading: 10, bottom: 20, trailing: 10)
//                return section
//
//            case .devToolkits:
//                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
//                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(150), heightDimension: .absolute(50)), subitems: [item])
//                let section = NSCollectionLayoutSection(group: group)
//                section.orthogonalScrollingBehavior = .continuous
//                section.interGroupSpacing = 12
//                section.contentInsets = .init(top: 10, leading: 0, bottom: 25, trailing: 20)
//                section.boundarySupplementaryItems = [self.createHeaderItem()]
//                return section
//                
//            case .technicalBriefs:
//                // UPDATED: Improved layout for modern list cells
//                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(130)))
//                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(130)), subitems: [item])
//                let section = NSCollectionLayoutSection(group: group)
//                section.interGroupSpacing = 0
//                section.contentInsets = .init(top: 10, leading: 0, bottom: 20, trailing: 0)
//                section.boundarySupplementaryItems = [self.createHeaderItem()]
//                return section
//                
//            case .viewAllButton:
//                // UPDATED: Minimal button layout
//                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44)))
//                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44)), subitems: [item])
//                let section = NSCollectionLayoutSection(group: group)
//                section.contentInsets = .init(top: 0, leading: 20, bottom: 30, trailing: 20)
//                return section
//            }
//        }
//    }
//    
//    private func createHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
//        return .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)),
//                     elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
//    }
//}
//
//// MARK: - Data Source & Delegate
//extension NewAudioViewController: UICollectionViewDataSource, UICollectionViewDelegate {
//    
//    func numberOfSections(in collectionView: UICollectionView) -> Int { Section.allCases.count }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        switch Section(rawValue: section) {
//        case .breakingNews: return breakingNewsItems.count
//        case .devToolkits: return store.devToolkits.count
//        case .technicalBriefs: return technicalBriefs.count
//        case .viewAllButton: return 1
//        default: return 0
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        switch Section(rawValue: indexPath.section) {
//        case .breakingNews:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeroCell", for: indexPath) as! HeroHeadlineCell
//            let newsItem = breakingNewsItems[indexPath.item]
//            cell.configure(category: newsItem.category, headline: newsItem.headline, source: newsItem.source, imageUrl: newsItem.imageUrl)
//            return cell
//
//        case .devToolkits:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ToolkitCell", for: indexPath) as! ToolkitPillCell
//            let toolkit = store.devToolkits[indexPath.item]
//            cell.configure(name: toolkit.name, icon: toolkit.icon, color: toolkit.color)
//            return cell
//            
//        case .technicalBriefs:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCell", for: indexPath) as! ModernNewsListCell
//            let brief = technicalBriefs[indexPath.item]
//            cell.configure(with: brief, imageUrl: brief.imageUrl)
//            return cell
//            
//        case .viewAllButton:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ViewAllCell", for: indexPath) as! MinimalViewAllCell
//            return cell
//            
//        default: return UICollectionViewCell()
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! AudioHeaderView
//        
//        if let title = Section(rawValue: indexPath.section)?.title {
//            header.titleLabel.text = title
//            header.isHidden = false
//        } else {
//            header.isHidden = true
//        }
//        
//        return header
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//        let section = Section(rawValue: indexPath.section)
//        
//        switch section {
//        case .breakingNews:
//            let breakingItem = breakingNewsItems[indexPath.item]
//            let topChoiceItem = TopChoiceItem(
//                title: breakingItem.headline,
//                date: DateFormatter.audioDateFormatter.string(from: Date()),
//                summary: "Breaking news from \(breakingItem.source)",
//                category: breakingItem.category,
//                imageUrl: breakingItem.imageUrl,
//                publishedDate: Date()
//            )
//            
//            // 🔥 UPDATED: Pass breaking news list to player
//            let playerVC = NewAudioPlayerViewController()
//            playerVC.newsItem = topChoiceItem
//            playerVC.transcriptIndex = indexPath.item
//            
//            // Convert breaking news items to TopChoiceItem array for navigation
//            playerVC.allBriefsList = breakingNewsItems.map { item in
//                TopChoiceItem(
//                    title: item.headline,
//                    date: DateFormatter.audioDateFormatter.string(from: Date()),
//                    summary: item.category,
//                    category: item.category,
//                    imageUrl: item.imageUrl,
//                    publishedDate: Date()
//                )
//            }
//            
//            playerVC.modalPresentationStyle = .fullScreen
//            print("🎵 Opening breaking news player with \(breakingNewsItems.count) items")
//            present(playerVC, animated: true)
//
//        case .devToolkits:
//            let toolkit = store.devToolkits[indexPath.item]
//            let detailVC = CategoryDetailViewController()
//            detailVC.toolkitName = toolkit.name
//            navigationController?.pushViewController(detailVC, animated: true)
//            
//        case .technicalBriefs:
//            // 🔥 UPDATED: Pass technical briefs list to player
//            let playerVC = NewAudioPlayerViewController()
//            playerVC.newsItem = technicalBriefs[indexPath.item]
//            playerVC.transcriptIndex = indexPath.item
//            playerVC.allBriefsList = technicalBriefs  // Pass the full list
//            playerVC.modalPresentationStyle = .fullScreen
//            
//            print("🎵 Opening technical briefs player with \(technicalBriefs.count) items")
//            present(playerVC, animated: true)
//            
//        case .viewAllButton:
//            viewAllTapped()
//            
//        default: break
//        }
//    }
//    
//    // 🔥 REMOVED: Old presentPlayer method - now handling directly in didSelectItemAt
//}
//
//// MARK: - UI Components
//
//class HeroHeadlineCell: UICollectionViewCell {
//    let heroImageView = UIImageView()
//    let categoryLabel = UILabel()
//    let headlineLabel = UILabel()
//    let sourceLabel = UILabel()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        heroImageView.backgroundColor = .systemGray6
//        heroImageView.layer.cornerRadius = 20
//        heroImageView.clipsToBounds = true
//        heroImageView.contentMode = .scaleAspectFill
//        
//        categoryLabel.font = .systemFont(ofSize: 11, weight: .bold)
//        categoryLabel.textColor = UIColor(red: 0.40, green: 0.52, blue: 0.89, alpha: 1.0)
//        
//        headlineLabel.font = .systemFont(ofSize: 18, weight: .bold)
//        headlineLabel.numberOfLines = 2
//        
//        sourceLabel.font = .systemFont(ofSize: 12, weight: .medium)
//        sourceLabel.textColor = .secondaryLabel
//        
//        [heroImageView, categoryLabel, headlineLabel, sourceLabel].forEach {
//            $0.translatesAutoresizingMaskIntoConstraints = false
//            contentView.addSubview($0)
//        }
//        
//        NSLayoutConstraint.activate([
//            heroImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            heroImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            heroImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            heroImageView.heightAnchor.constraint(equalToConstant: 200),
//            
//            categoryLabel.topAnchor.constraint(equalTo: heroImageView.bottomAnchor, constant: 10),
//            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
//            
//            headlineLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 4),
//            headlineLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
//            headlineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
//            
//            sourceLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 4),
//            sourceLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor)
//        ])
//    }
//    
//    func configure(category: String, headline: String, source: String, imageUrl: String?) {
//        categoryLabel.text = category.uppercased()
//        headlineLabel.text = headline
//        sourceLabel.text = source
//        AudioImageLoader.shared.loadImage(from: imageUrl, into: heroImageView)
//    }
//    required init?(coder: NSCoder) { fatalError() }
//}
//
//class ToolkitPillCell: UICollectionViewCell {
//    let titleLabel = UILabel()
//    let iconView = UIImageView()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        contentView.backgroundColor = .secondarySystemBackground
//        contentView.layer.cornerRadius = 25
//        
//        iconView.contentMode = .scaleAspectFit
//        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
//        
//        [iconView, titleLabel].forEach {
//            $0.translatesAutoresizingMaskIntoConstraints = false
//            contentView.addSubview($0)
//        }
//        
//        NSLayoutConstraint.activate([
//            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
//            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            iconView.widthAnchor.constraint(equalToConstant: 22),
//            iconView.heightAnchor.constraint(equalToConstant: 22),
//            
//            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
//            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
//            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
//        ])
//    }
//    
//    func configure(name: String, icon: String, color: UIColor) {
//        titleLabel.text = name
//        iconView.image = UIImage(systemName: icon)
//        iconView.tintColor = color
//    }
//    required init?(coder: NSCoder) { fatalError() }
//}
//
//// UPDATED: Modern News List Cell (matching screenshot design)
//class ModernNewsListCell: UICollectionViewCell {
//    let titleLabel = UILabel()
//    let summaryLabel = UILabel()
//    let dateLabel = UILabel()
//    let thumbnailImageView = UIImageView()
//    let separator = UIView()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        // Title styling - matches screenshot
//        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
//        titleLabel.numberOfLines = 2
//        titleLabel.textColor = .label
//        
//        // Summary styling - matches screenshot
//        summaryLabel.font = .systemFont(ofSize: 15, weight: .regular)
//        summaryLabel.textColor = .secondaryLabel
//        summaryLabel.numberOfLines = 2
//        
//        // Date styling - matches screenshot (blue, uppercase)
//        dateLabel.font = .systemFont(ofSize: 13, weight: .semibold)
//        dateLabel.textColor = .systemBlue
//        
//        // Thumbnail styling - matches screenshot
//        thumbnailImageView.contentMode = .scaleAspectFill
//        thumbnailImageView.layer.cornerRadius = 12
//        thumbnailImageView.clipsToBounds = true
//        thumbnailImageView.backgroundColor = .systemGray6
//        
//        // Separator
//        separator.backgroundColor = .separator.withAlphaComponent(0.3)
//        
//        [titleLabel, summaryLabel, dateLabel, thumbnailImageView, separator].forEach {
//            $0.translatesAutoresizingMaskIntoConstraints = false
//            contentView.addSubview($0)
//        }
//        
//        NSLayoutConstraint.activate([
//            // Thumbnail on the right (matching screenshot)
//            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            thumbnailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            thumbnailImageView.widthAnchor.constraint(equalToConstant: 90),
//            thumbnailImageView.heightAnchor.constraint(equalToConstant: 90),
//            
//            // Title at top
//            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
//            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            titleLabel.trailingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: -12),
//            
//            // Summary below title
//            summaryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
//            summaryLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            summaryLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
//            
//            // Date below summary (matching screenshot)
//            dateLabel.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 8),
//            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
//            
//            // Separator at bottom
//            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//            separator.heightAnchor.constraint(equalToConstant: 0.5)
//        ])
//    }
//    
//    func configure(with item: TopChoiceItem, imageUrl: String?) {
//        titleLabel.text = item.title
//        summaryLabel.text = item.summary
//        
//        // Format date to match screenshot (e.g., "04 FEB 26")
//        if let publishedDate = item.publishedDate {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "dd MMM yy"
//            dateLabel.text = formatter.string(from: publishedDate).uppercased()
//        } else {
//            dateLabel.text = item.date.uppercased()
//        }
//        
//        AudioImageLoader.shared.loadImage(from: imageUrl, into: thumbnailImageView)
//    }
//    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        thumbnailImageView.image = nil
//        titleLabel.text = nil
//        summaryLabel.text = nil
//        dateLabel.text = nil
//    }
//    
//    required init?(coder: NSCoder) { fatalError() }
//}
//
//// UPDATED: Minimal View All Button Cell
//class MinimalViewAllCell: UICollectionViewCell {
//    let label = UILabel()
//    let chevron = UIImageView()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        // Minimal design - just text and chevron
//        label.text = "View All"
//        label.font = .systemFont(ofSize: 16, weight: .medium)
//        label.textColor = .systemIndigo
//        label.translatesAutoresizingMaskIntoConstraints = false
//        
//        chevron.image = UIImage(systemName: "chevron.right")
//        chevron.tintColor = .systemIndigo
//        chevron.contentMode = .scaleAspectFit
//        chevron.translatesAutoresizingMaskIntoConstraints = false
//        
//        contentView.addSubview(label)
//        contentView.addSubview(chevron)
//        
//        NSLayoutConstraint.activate([
//            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -10),
//            
//            chevron.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 6),
//            chevron.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            chevron.widthAnchor.constraint(equalToConstant: 14),
//            chevron.heightAnchor.constraint(equalToConstant: 14)
//        ])
//    }
//    
//    required init?(coder: NSCoder) { fatalError() }
//}
//
//class AudioHeaderView: UICollectionReusableView {
//    let titleLabel = UILabel()
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
//        addSubview(titleLabel)
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
//            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
//        ])
//    }
//    required init?(coder: NSCoder) { fatalError() }
//}















//
//import UIKit
//
//class NewAudioViewController: UIViewController {
//    
//    // MARK: - Properties
//    private var collectionView: UICollectionView!
//    private let store = AudioDataStore.shared
//    
//    // API Data Storage
//    private var breakingNewsItems: [BreakingNewsItem] = []
//    private var technicalBriefs: [TopChoiceItem] = []
//    
//    private var isLoadingData = false
//    private let refreshControl = UIRefreshControl()
//    private let loadingView = UIActivityIndicatorView(style: .large)
//    
//    // UPDATED: Section order with View All at the end
//    enum Section: Int, CaseIterable {
//        case breakingNews
//        case devToolkits
//        case technicalBriefs
//        case viewAllButton
//        
//        var title: String? {
//            switch self {
//            case .breakingNews: return nil
//            case .devToolkits: return "Essential Dev Toolkits"
//            case .technicalBriefs: return "Today's Technical Briefs"
//            case .viewAllButton: return nil
//            }
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        loadDataFromDatabase()
//    }
//    
//    // MARK: - Setup
//    private func setupUI() {
//        title = "Audio"
//        self.tabBarItem.title = "Audio"
//        
//        view.backgroundColor = .systemBackground
//        navigationController?.navigationBar.prefersLargeTitles = true
//        
//        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
//        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        collectionView.backgroundColor = .clear
//        
//        collectionView.register(HeroHeadlineCell.self, forCellWithReuseIdentifier: "HeroCell")
//        collectionView.register(ToolkitPillCell.self, forCellWithReuseIdentifier: "ToolkitCell")
//        collectionView.register(ModernNewsListCell.self, forCellWithReuseIdentifier: "ListCell")
//        collectionView.register(MinimalViewAllCell.self, forCellWithReuseIdentifier: "ViewAllCell")
//        collectionView.register(AudioHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
//        
//        collectionView.dataSource = self
//        collectionView.delegate = self
//        view.addSubview(collectionView)
//        
//        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
//        collectionView.refreshControl = refreshControl
//        
//        loadingView.translatesAutoresizingMaskIntoConstraints = false
//        loadingView.color = .brand
//        view.addSubview(loadingView)
//        
//        NSLayoutConstraint.activate([
//            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//    }
//    
//    // MARK: - Data Loading
//    
//    private func loadDataFromDatabase() {
//        guard !isLoadingData else { return }
//        isLoadingData = true
//        loadingView.startAnimating()
//        
//        let group = DispatchGroup()
//        
//        // Load Breaking News from Database
//        group.enter()
//        store.loadBreakingNewsFromDatabase { [weak self] items in
//            self?.breakingNewsItems = items
//            group.leave()
//        }
//        
//        // UPDATED: Load Today's Technical Briefs (LIMIT TO 8 FOR MAIN SCREEN)
//        group.enter()
//        store.loadTodaysAudioFromDatabase { [weak self] items in
//            // Only show first 8 items on main screen, rest in "View All"
//            self?.technicalBriefs = Array(items.prefix(8))
//            group.leave()
//        }
//        
//        group.notify(queue: .main) { [weak self] in
//            self?.isLoadingData = false
//            self?.loadingView.stopAnimating()
//            self?.collectionView.reloadData()
//            
//            if self?.breakingNewsItems.isEmpty == true && self?.technicalBriefs.isEmpty == true {
//                self?.showNoContentAlert()
//            }
//        }
//    }
//    
//    @objc private func refreshData() {
//        print("🔄 Refreshing audio content from API...")
//        
//        store.refreshAllAudioData { [weak self] success in
//            DispatchQueue.main.async {
//                self?.refreshControl.endRefreshing()
//                
//                if success {
//                    print("✅ Refresh successful, reloading data...")
//                    self?.loadDataFromDatabase()
//                    
//                    let generator = UINotificationFeedbackGenerator()
//                    generator.notificationOccurred(.success)
//                } else {
//                    print("⚠️ Refresh completed with some errors")
//                    self?.showRefreshErrorAlert()
//                }
//            }
//        }
//    }
//    
//    @objc private func viewAllTapped() {
//        let allAudioVC = AllAudioViewController()
//        navigationController?.pushViewController(allAudioVC, animated: true)
//    }
//    
//    // MARK: - Alert Helpers
//    
//    private func showNoContentAlert() {
//        let alert = UIAlertController(
//            title: "No Content Available",
//            message: "Pull down to refresh and load audio content from the API.",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//    
//    private func showRefreshErrorAlert() {
//        let alert = UIAlertController(
//            title: "Refresh Issue",
//            message: "Some content may not have updated. Check your internet connection and try again.",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//
//    // MARK: - Layout Creation
//    private func createLayout() -> UICollectionViewLayout {
//        return UICollectionViewCompositionalLayout { (sectionIdx, _) -> NSCollectionLayoutSection? in
//            guard let sectionType = Section(rawValue: sectionIdx) else { return nil }
//            
//            switch sectionType {
//            case .breakingNews:
//                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
//                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.92), heightDimension: .absolute(310)), subitems: [item])
//                let section = NSCollectionLayoutSection(group: group)
//                section.orthogonalScrollingBehavior = .groupPagingCentered
//                section.interGroupSpacing = 12
//                section.contentInsets = .init(top: 10, leading: 0, bottom: 20, trailing: 0)
//                return section
//
//            case .devToolkits:
//                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
//                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(150), heightDimension: .absolute(50)), subitems: [item])
//                let section = NSCollectionLayoutSection(group: group)
//                section.orthogonalScrollingBehavior = .continuous
//                section.interGroupSpacing = 12
//                section.contentInsets = .init(top: 10, leading: 0, bottom: 25, trailing: 20)
//                section.boundarySupplementaryItems = [self.createHeaderItem()]
//                return section
//                
//            case .technicalBriefs:
//                // UPDATED: Improved layout for modern list cells
//                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(130)))
//                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(130)), subitems: [item])
//                let section = NSCollectionLayoutSection(group: group)
//                section.interGroupSpacing = 0
//                section.contentInsets = .init(top: 10, leading: 0, bottom: 20, trailing: 0)
//                section.boundarySupplementaryItems = [self.createHeaderItem()]
//                return section
//                
//            case .viewAllButton:
//                // UPDATED: Minimal button layout
//                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44)))
//                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44)), subitems: [item])
//                let section = NSCollectionLayoutSection(group: group)
//                section.contentInsets = .init(top: 0, leading: 20, bottom: 30, trailing: 20)
//                return section
//            }
//        }
//    }
//    
//    private func createHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
//        return .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)),
//                     elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
//    }
//}
//
//// MARK: - Data Source & Delegate
//extension NewAudioViewController: UICollectionViewDataSource, UICollectionViewDelegate {
//    
//    func numberOfSections(in collectionView: UICollectionView) -> Int { Section.allCases.count }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        switch Section(rawValue: section) {
//        case .breakingNews: return breakingNewsItems.count
//        case .devToolkits: return store.devToolkits.count
//        case .technicalBriefs: return technicalBriefs.count
//        case .viewAllButton: return 1
//        default: return 0
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        switch Section(rawValue: indexPath.section) {
//        case .breakingNews:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeroCell", for: indexPath) as! HeroHeadlineCell
//            let newsItem = breakingNewsItems[indexPath.item]
//            cell.configure(category: newsItem.category, headline: newsItem.headline, source: newsItem.source, imageUrl: newsItem.imageUrl)
//            return cell
//
//        case .devToolkits:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ToolkitCell", for: indexPath) as! ToolkitPillCell
//            let toolkit = store.devToolkits[indexPath.item]
//            cell.configure(name: toolkit.name, icon: toolkit.icon, color: toolkit.color)
//            return cell
//            
//        case .technicalBriefs:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCell", for: indexPath) as! ModernNewsListCell
//            let brief = technicalBriefs[indexPath.item]
//            cell.configure(with: brief, imageUrl: brief.imageUrl)
//            return cell
//            
//        case .viewAllButton:
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ViewAllCell", for: indexPath) as! MinimalViewAllCell
//            return cell
//            
//        default: return UICollectionViewCell()
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! AudioHeaderView
//        
//        if let title = Section(rawValue: indexPath.section)?.title {
//            header.titleLabel.text = title
//            header.isHidden = false
//        } else {
//            header.isHidden = true
//        }
//        
//        return header
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//        let section = Section(rawValue: indexPath.section)
//        
//        switch section {
//        case .breakingNews:
//            let breakingItem = breakingNewsItems[indexPath.item]
//            let topChoiceItem = TopChoiceItem(
//                title: breakingItem.headline,
//                date: DateFormatter.audioDateFormatter.string(from: Date()),
//                summary: "Breaking news from \(breakingItem.source)",
//                category: breakingItem.category,
//                imageUrl: breakingItem.imageUrl,
//                publishedDate: Date()
//            )
//            
//            // 🔥 UPDATED: Pass breaking news list to player
//            let playerVC = NewAudioPlayerViewController()
//            playerVC.newsItem = topChoiceItem
//            playerVC.transcriptIndex = indexPath.item
//            
//            // Convert breaking news items to TopChoiceItem array for navigation
//            playerVC.allBriefsList = breakingNewsItems.map { item in
//                TopChoiceItem(
//                    title: item.headline,
//                    date: DateFormatter.audioDateFormatter.string(from: Date()),
//                    summary: item.category,
//                    category: item.category,
//                    imageUrl: item.imageUrl,
//                    publishedDate: Date()
//                )
//            }
//            
//            playerVC.modalPresentationStyle = .fullScreen
//            print("🎵 Opening breaking news player with \(breakingNewsItems.count) items")
//            present(playerVC, animated: true)
//
//        case .devToolkits:
//            let toolkit = store.devToolkits[indexPath.item]
//            let detailVC = CategoryDetailViewController()
//            detailVC.toolkitName = toolkit.name
//            navigationController?.pushViewController(detailVC, animated: true)
//            
//        case .technicalBriefs:
//            // 🔥 UPDATED: Pass technical briefs list to player
//            let playerVC = NewAudioPlayerViewController()
//            playerVC.newsItem = technicalBriefs[indexPath.item]
//            playerVC.transcriptIndex = indexPath.item
//            playerVC.allBriefsList = technicalBriefs  // Pass the full list
//            playerVC.modalPresentationStyle = .fullScreen
//            
//            print("🎵 Opening technical briefs player with \(technicalBriefs.count) items")
//            present(playerVC, animated: true)
//            
//        case .viewAllButton:
//            viewAllTapped()
//            
//        default: break
//        }
//    }
//    
//    // 🔥 REMOVED: Old presentPlayer method - now handling directly in didSelectItemAt
//}
//
//// MARK: - UI Components
//
//class HeroHeadlineCell: UICollectionViewCell {
//    let heroImageView = UIImageView()
//    let categoryLabel = UILabel()
//    let headlineLabel = UILabel()
//    let sourceLabel = UILabel()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        heroImageView.backgroundColor = .systemGray6
//        heroImageView.layer.cornerRadius = 20
//        heroImageView.clipsToBounds = true
//        heroImageView.contentMode = .scaleAspectFill
//        
//        categoryLabel.font = .systemFont(ofSize: 11, weight: .bold)
//        categoryLabel.textColor = .brand
//        
//        headlineLabel.font = .systemFont(ofSize: 18, weight: .bold)
//        headlineLabel.numberOfLines = 2
//        
//        sourceLabel.font = .systemFont(ofSize: 12, weight: .medium)
//        sourceLabel.textColor = .secondaryLabel
//        
//        [heroImageView, categoryLabel, headlineLabel, sourceLabel].forEach {
//            $0.translatesAutoresizingMaskIntoConstraints = false
//            contentView.addSubview($0)
//        }
//        
//        NSLayoutConstraint.activate([
//            heroImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            heroImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            heroImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            heroImageView.heightAnchor.constraint(equalToConstant: 200),
//            
//            categoryLabel.topAnchor.constraint(equalTo: heroImageView.bottomAnchor, constant: 10),
//            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
//            
//            headlineLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 4),
//            headlineLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
//            headlineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
//            
//            sourceLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 4),
//            sourceLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor)
//        ])
//    }
//    
//    func configure(category: String, headline: String, source: String, imageUrl: String?) {
//        categoryLabel.text = category.uppercased()
//        headlineLabel.text = headline
//        sourceLabel.text = source
//        AudioImageLoader.shared.loadImage(from: imageUrl, into: heroImageView)
//    }
//    required init?(coder: NSCoder) { fatalError() }
//}
//
//class ToolkitPillCell: UICollectionViewCell {
//    let titleLabel = UILabel()
//    let iconView = UIImageView()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        contentView.backgroundColor = .secondarySystemBackground
//        contentView.layer.cornerRadius = 25
//        
//        iconView.contentMode = .scaleAspectFit
//        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
//        
//        [iconView, titleLabel].forEach {
//            $0.translatesAutoresizingMaskIntoConstraints = false
//            contentView.addSubview($0)
//        }
//        
//        NSLayoutConstraint.activate([
//            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
//            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            iconView.widthAnchor.constraint(equalToConstant: 22),
//            iconView.heightAnchor.constraint(equalToConstant: 22),
//            
//            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
//            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
//            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
//        ])
//    }
//    
//    func configure(name: String, icon: String, color: UIColor) {
//        titleLabel.text = name
//        iconView.image = UIImage(systemName: icon)
//        iconView.tintColor = color
//    }
//    required init?(coder: NSCoder) { fatalError() }
//}
//
//// UPDATED: Modern News List Cell (matching screenshot design)
//class ModernNewsListCell: UICollectionViewCell {
//    let titleLabel = UILabel()
//    let summaryLabel = UILabel()
//    let dateLabel = UILabel()
//    let thumbnailImageView = UIImageView()
//    let separator = UIView()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        // Title styling - matches screenshot
//        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
//        titleLabel.numberOfLines = 2
//        titleLabel.textColor = .label
//        
//        // Summary styling - matches screenshot
//        summaryLabel.font = .systemFont(ofSize: 15, weight: .regular)
//        summaryLabel.textColor = .secondaryLabel
//        summaryLabel.numberOfLines = 2
//        
//        // Date styling - matches screenshot (blue, uppercase)
//        dateLabel.font = .systemFont(ofSize: 13, weight: .semibold)
//        dateLabel.textColor = .brand
//        
//        // Thumbnail styling - matches screenshot
//        thumbnailImageView.contentMode = .scaleAspectFill
//        thumbnailImageView.layer.cornerRadius = 12
//        thumbnailImageView.clipsToBounds = true
//        thumbnailImageView.backgroundColor = .systemGray6
//        
//        // Separator
//        separator.backgroundColor = .separator.withAlphaComponent(0.3)
//        
//        [titleLabel, summaryLabel, dateLabel, thumbnailImageView, separator].forEach {
//            $0.translatesAutoresizingMaskIntoConstraints = false
//            contentView.addSubview($0)
//        }
//        
//        NSLayoutConstraint.activate([
//            // Thumbnail on the right (matching screenshot)
//            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            thumbnailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            thumbnailImageView.widthAnchor.constraint(equalToConstant: 90),
//            thumbnailImageView.heightAnchor.constraint(equalToConstant: 90),
//            
//            // Title at top
//            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
//            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            titleLabel.trailingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: -12),
//            
//            // Summary below title
//            summaryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
//            summaryLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            summaryLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
//            
//            // Date below summary (matching screenshot)
//            dateLabel.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 8),
//            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
//            
//            // Separator at bottom
//            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
//            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
//            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//            separator.heightAnchor.constraint(equalToConstant: 0.5)
//        ])
//    }
//    
//    func configure(with item: TopChoiceItem, imageUrl: String?) {
//        titleLabel.text = item.title
//        summaryLabel.text = item.summary
//        
//        // Format date to match screenshot (e.g., "04 FEB 26")
//        if let publishedDate = item.publishedDate {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "dd MMM yy"
//            dateLabel.text = formatter.string(from: publishedDate).uppercased()
//        } else {
//            dateLabel.text = item.date.uppercased()
//        }
//        
//        AudioImageLoader.shared.loadImage(from: imageUrl, into: thumbnailImageView)
//    }
//    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        thumbnailImageView.image = nil
//        titleLabel.text = nil
//        summaryLabel.text = nil
//        dateLabel.text = nil
//    }
//    
//    required init?(coder: NSCoder) { fatalError() }
//}
//
//// UPDATED: Minimal View All Button Cell
//class MinimalViewAllCell: UICollectionViewCell {
//    let label = UILabel()
//    let chevron = UIImageView()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        // Minimal design - just text and chevron
//        label.text = "View All"
//        label.font = .systemFont(ofSize: 16, weight: .medium)
//        label.textColor = .brand
//        label.translatesAutoresizingMaskIntoConstraints = false
//        
//        chevron.image = UIImage(systemName: "chevron.right")
//        chevron.tintColor = .brand
//        chevron.contentMode = .scaleAspectFit
//        chevron.translatesAutoresizingMaskIntoConstraints = false
//        
//        contentView.addSubview(label)
//        contentView.addSubview(chevron)
//        
//        NSLayoutConstraint.activate([
//            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -10),
//            
//            chevron.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 6),
//            chevron.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            chevron.widthAnchor.constraint(equalToConstant: 14),
//            chevron.heightAnchor.constraint(equalToConstant: 14)
//        ])
//    }
//    
//    required init?(coder: NSCoder) { fatalError() }
//}
//
//class AudioHeaderView: UICollectionReusableView {
//    let titleLabel = UILabel()
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
//        addSubview(titleLabel)
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
//            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
//        ])
//    }
//    required init?(coder: NSCoder) { fatalError() }
//}










import UIKit

class NewAudioViewController: UIViewController {
    
    // MARK: - Properties
    private var collectionView: UICollectionView!
    private let store = AudioDataStore.shared
    
    // API Data Storage
    private var breakingNewsItems: [BreakingNewsItem] = []
    private var technicalBriefs: [TopChoiceItem] = []
    
    private var isLoadingData = false
    private let refreshControl = UIRefreshControl()
    private let loadingView = UIActivityIndicatorView(style: .large)
    
    // Daily refresh tracking
    private let lastBreakingNewsRefreshKey = "lastBreakingNewsRefreshDate"
    private let maxBreakingNewsCount = 5

    // UPDATED: Section order with View All at the end
    enum Section: Int, CaseIterable {
        case breakingNews
        case devToolkits
        case technicalBriefs
        case viewAllButton
        
        var title: String? {
            switch self {
            case .breakingNews: return nil
            case .devToolkits: return "Essential Dev Toolkits"
            case .technicalBriefs: return "Today's Technical Briefs"
            case .viewAllButton: return nil
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadDataFromDatabase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Silently refresh breaking news if it's a new day
        checkAndRefreshBreakingNewsIfNeeded()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Audio"
        self.tabBarItem.title = "Audio"
        
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .clear
        
        collectionView.register(HeroHeadlineCell.self, forCellWithReuseIdentifier: "HeroCell")
        collectionView.register(ToolkitPillCell.self, forCellWithReuseIdentifier: "ToolkitCell")
        collectionView.register(ModernNewsListCell.self, forCellWithReuseIdentifier: "ListCell")
        collectionView.register(MinimalViewAllCell.self, forCellWithReuseIdentifier: "ViewAllCell")
        collectionView.register(AudioHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.color = .brand
        view.addSubview(loadingView)
        
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Data Loading
    
    private func loadDataFromDatabase() {
        guard !isLoadingData else { return }
        isLoadingData = true
        loadingView.startAnimating()
        
        let group = DispatchGroup()
        
        // Load Breaking News — capped to top 5
        group.enter()
        store.loadBreakingNewsFromDatabase { [weak self] items in
            guard let self = self else { group.leave(); return }
            self.breakingNewsItems = Array(items.prefix(self.maxBreakingNewsCount))
            group.leave()
        }
        
        // Load Today's Technical Briefs (limit to 8 for main screen)
        group.enter()
        store.loadTodaysAudioFromDatabase { [weak self] items in
            self?.technicalBriefs = Array(items.prefix(8))
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.isLoadingData = false
            self?.loadingView.stopAnimating()
            self?.collectionView.reloadData()
            
            if self?.breakingNewsItems.isEmpty == true && self?.technicalBriefs.isEmpty == true {
                self?.showNoContentAlert()
            }
        }
    }
    
    // MARK: - Daily Breaking News Refresh
    
    /// Checks if breaking news was last fetched on a previous calendar day.
    /// If so, silently refreshes from the API and saves the new date.
    private func checkAndRefreshBreakingNewsIfNeeded() {
        let defaults = UserDefaults.standard
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastRefresh = defaults.object(forKey: lastBreakingNewsRefreshKey) as? Date {
            let lastRefreshDay = Calendar.current.startOfDay(for: lastRefresh)
            guard lastRefreshDay < today else { return } // same day — skip
        }
        
        // New day (or first launch) — refresh breaking news from API
        print("📅 New day detected — refreshing breaking news from API...")
        store.refreshBreakingNewsOnly { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    UserDefaults.standard.set(Date(), forKey: self?.lastBreakingNewsRefreshKey ?? "")
                    print("✅ Breaking news refreshed for today")
                    self?.store.loadBreakingNewsFromDatabase { items in
                        DispatchQueue.main.async {
                            guard let self = self else { return }
                            self.breakingNewsItems = Array(items.prefix(self.maxBreakingNewsCount))
                            self.collectionView.reloadSections(IndexSet(integer: Section.breakingNews.rawValue))
                        }
                    }
                } else {
                    print("⚠️ Breaking news daily refresh failed — will retry next launch")
                }
            }
        }
    }
    
    @objc private func refreshData() {
        print("🔄 Refreshing audio content from API...")
        
        store.refreshAllAudioData { [weak self] success in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
                
                if success {
                    print("✅ Refresh successful, reloading data...")
                    // Record today so daily check won't double-refresh
                    UserDefaults.standard.set(Date(), forKey: self?.lastBreakingNewsRefreshKey ?? "")
                    self?.loadDataFromDatabase()
                    
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                } else {
                    print("⚠️ Refresh completed with some errors")
                    self?.showRefreshErrorAlert()
                }
            }
        }
    }
    
    @objc private func viewAllTapped() {
        let allAudioVC = AllAudioViewController()
        navigationController?.pushViewController(allAudioVC, animated: true)
    }
    
    // MARK: - Alert Helpers
    
    private func showNoContentAlert() {
        let alert = UIAlertController(
            title: "No Content Available",
            message: "Pull down to refresh and load audio content from the API.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showRefreshErrorAlert() {
        let alert = UIAlertController(
            title: "Refresh Issue",
            message: "Some content may not have updated. Check your internet connection and try again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Layout Creation
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { (sectionIdx, _) -> NSCollectionLayoutSection? in
            guard let sectionType = Section(rawValue: sectionIdx) else { return nil }
            
            switch sectionType {
            case .breakingNews:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(0.92), heightDimension: .absolute(310)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.interGroupSpacing = 12
                section.contentInsets = .init(top: 10, leading: 0, bottom: 20, trailing: 0)
                return section

            case .devToolkits:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .absolute(150), heightDimension: .absolute(50)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.interGroupSpacing = 12
                section.contentInsets = .init(top: 10, leading: 0, bottom: 25, trailing: 20)
                section.boundarySupplementaryItems = [self.createHeaderItem()]
                return section
                
            case .technicalBriefs:
                // UPDATED: Improved layout for modern list cells
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(130)))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(130)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 0
                section.contentInsets = .init(top: 10, leading: 0, bottom: 20, trailing: 0)
                section.boundarySupplementaryItems = [self.createHeaderItem()]
                return section
                
            case .viewAllButton:
                // UPDATED: Minimal button layout
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(44)), subitems: [item])
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 20, bottom: 30, trailing: 20)
                return section
            }
        }
    }
    
    private func createHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        return .init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)),
                     elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
    }
}

// MARK: - Data Source & Delegate
extension NewAudioViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int { Section.allCases.count }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .breakingNews: return breakingNewsItems.count
        case .devToolkits: return store.devToolkits.count
        case .technicalBriefs: return technicalBriefs.count
        case .viewAllButton: return 1
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch Section(rawValue: indexPath.section) {
        case .breakingNews:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeroCell", for: indexPath) as! HeroHeadlineCell
            let newsItem = breakingNewsItems[indexPath.item]
            cell.configure(category: newsItem.category, headline: newsItem.headline, source: newsItem.source, imageUrl: newsItem.imageUrl)
            return cell

        case .devToolkits:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ToolkitCell", for: indexPath) as! ToolkitPillCell
            let toolkit = store.devToolkits[indexPath.item]
            cell.configure(name: toolkit.name, icon: toolkit.icon, color: toolkit.color)
            return cell
            
        case .technicalBriefs:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCell", for: indexPath) as! ModernNewsListCell
            let brief = technicalBriefs[indexPath.item]
            cell.configure(with: brief, imageUrl: brief.imageUrl)
            return cell
            
        case .viewAllButton:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ViewAllCell", for: indexPath) as! MinimalViewAllCell
            return cell
            
        default: return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! AudioHeaderView
        
        if let title = Section(rawValue: indexPath.section)?.title {
            header.titleLabel.text = title
            header.isHidden = false
        } else {
            header.isHidden = true
        }
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let section = Section(rawValue: indexPath.section)
        
        switch section {
        case .breakingNews:
            let breakingItem = breakingNewsItems[indexPath.item]
            let topChoiceItem = TopChoiceItem(
                title: breakingItem.headline,
                date: DateFormatter.audioDateFormatter.string(from: Date()),
                summary: "Breaking news from \(breakingItem.source)",
                category: breakingItem.category,
                imageUrl: breakingItem.imageUrl,
                publishedDate: Date()
            )
            
            // 🔥 UPDATED: Pass breaking news list to player
            let playerVC = NewAudioPlayerViewController()
            playerVC.newsItem = topChoiceItem
            playerVC.transcriptIndex = indexPath.item
            
            // Convert breaking news items to TopChoiceItem array for navigation
            playerVC.allBriefsList = breakingNewsItems.map { item in
                TopChoiceItem(
                    title: item.headline,
                    date: DateFormatter.audioDateFormatter.string(from: Date()),
                    summary: item.category,
                    category: item.category,
                    imageUrl: item.imageUrl,
                    publishedDate: Date()
                )
            }
            
            playerVC.modalPresentationStyle = .fullScreen
            print("🎵 Opening breaking news player with \(breakingNewsItems.count) items")
            present(playerVC, animated: true)

        case .devToolkits:
            let toolkit = store.devToolkits[indexPath.item]
            let detailVC = CategoryDetailViewController()
            detailVC.toolkitName = toolkit.name
            navigationController?.pushViewController(detailVC, animated: true)
            
        case .technicalBriefs:
            // 🔥 UPDATED: Pass technical briefs list to player
            let playerVC = NewAudioPlayerViewController()
            playerVC.newsItem = technicalBriefs[indexPath.item]
            playerVC.transcriptIndex = indexPath.item
            playerVC.allBriefsList = technicalBriefs  // Pass the full list
            playerVC.modalPresentationStyle = .fullScreen
            
            print("🎵 Opening technical briefs player with \(technicalBriefs.count) items")
            present(playerVC, animated: true)
            
        case .viewAllButton:
            viewAllTapped()
            
        default: break
        }
    }
    
    // 🔥 REMOVED: Old presentPlayer method - now handling directly in didSelectItemAt
}

// MARK: - UI Components

class HeroHeadlineCell: UICollectionViewCell {
    let heroImageView = UIImageView()
    let categoryLabel = UILabel()
    let headlineLabel = UILabel()
    let sourceLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        heroImageView.backgroundColor = .systemGray6
        heroImageView.layer.cornerRadius = 20
        heroImageView.clipsToBounds = true
        heroImageView.contentMode = .scaleAspectFill
        
        categoryLabel.font = .systemFont(ofSize: 11, weight: .bold)
        categoryLabel.textColor = .brand
        
        headlineLabel.font = .systemFont(ofSize: 18, weight: .bold)
        headlineLabel.numberOfLines = 2
        
        sourceLabel.font = .systemFont(ofSize: 12, weight: .medium)
        sourceLabel.textColor = .secondaryLabel
        
        [heroImageView, categoryLabel, headlineLabel, sourceLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            heroImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            heroImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            heroImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            heroImageView.heightAnchor.constraint(equalToConstant: 200),
            
            categoryLabel.topAnchor.constraint(equalTo: heroImageView.bottomAnchor, constant: 10),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            
            headlineLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 4),
            headlineLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor),
            headlineLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            
            sourceLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 4),
            sourceLabel.leadingAnchor.constraint(equalTo: categoryLabel.leadingAnchor)
        ])
    }
    
    func configure(category: String, headline: String, source: String, imageUrl: String?) {
        categoryLabel.text = category.uppercased()
        headlineLabel.text = headline
        sourceLabel.text = source
        AudioImageLoader.shared.loadImage(from: imageUrl, into: heroImageView)
    }
    required init?(coder: NSCoder) { fatalError() }
}

class ToolkitPillCell: UICollectionViewCell {
    let titleLabel = UILabel()
    let iconView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 25
        
        iconView.contentMode = .scaleAspectFit
        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        
        [iconView, titleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(name: String, icon: String, color: UIColor) {
        titleLabel.text = name
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = color
    }
    required init?(coder: NSCoder) { fatalError() }
}

// UPDATED: Modern News List Cell (matching screenshot design)
class ModernNewsListCell: UICollectionViewCell {
    let titleLabel = UILabel()
    let summaryLabel = UILabel()
    let dateLabel = UILabel()
    let thumbnailImageView = UIImageView()
    let separator = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Title styling - matches screenshot
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .label
        
        // Summary styling - matches screenshot
        summaryLabel.font = .systemFont(ofSize: 15, weight: .regular)
        summaryLabel.textColor = .secondaryLabel
        summaryLabel.numberOfLines = 2
        
        // Date styling - matches screenshot (blue, uppercase)
        dateLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        dateLabel.textColor = .brand
        
        // Thumbnail styling - matches screenshot
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.layer.cornerRadius = 12
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.backgroundColor = .systemGray6
        
        // Separator
        separator.backgroundColor = .separator.withAlphaComponent(0.3)
        
        [titleLabel, summaryLabel, dateLabel, thumbnailImageView, separator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            // Thumbnail on the right (matching screenshot)
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            thumbnailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 90),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 90),
            
            // Title at top
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: -12),
            
            // Summary below title
            summaryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            summaryLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            summaryLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // Date below summary (matching screenshot)
            dateLabel.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            // Separator at bottom
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    func configure(with item: TopChoiceItem, imageUrl: String?) {
        titleLabel.text = item.title
        summaryLabel.text = item.summary
        
        // Format date to match screenshot (e.g., "04 FEB 26")
        if let publishedDate = item.publishedDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yy"
            dateLabel.text = formatter.string(from: publishedDate).uppercased()
        } else {
            dateLabel.text = item.date.uppercased()
        }
        
        AudioImageLoader.shared.loadImage(from: imageUrl, into: thumbnailImageView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        titleLabel.text = nil
        summaryLabel.text = nil
        dateLabel.text = nil
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// UPDATED: Minimal View All Button Cell
class MinimalViewAllCell: UICollectionViewCell {
    let label = UILabel()
    let chevron = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Minimal design - just text and chevron
        label.text = "View All"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .brand
        label.translatesAutoresizingMaskIntoConstraints = false
        
        chevron.image = UIImage(systemName: "chevron.right")
        chevron.tintColor = .brand
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(label)
        contentView.addSubview(chevron)
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -10),
            
            chevron.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 6),
            chevron.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 14),
            chevron.heightAnchor.constraint(equalToConstant: 14)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

class AudioHeaderView: UICollectionReusableView {
    let titleLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}

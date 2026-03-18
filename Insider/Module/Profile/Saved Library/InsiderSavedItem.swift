import UIKit

// MARK: - 1. Supporting Model
struct InsiderSavedItem: Hashable {
    let id = UUID()
    let title: String
    let itemCount: Int
    let articleImageUrl: String
    let category: String
    let apiCategory: NewsCategory
}

// MARK: - 2. Theme Extension


// MARK: - 3. Filter Pill Cell

// MARK: - 4. Library Controller
class InsiderSavedLibraryController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>!
    
    private let filters = ["All", "Audio", "Articles"]
    private var selectedFilter = "All"
    
    // Live data array
    private var libraryItems: [InsiderSavedItem] = []
    
    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.hidesWhenStopped = true
        return ai
    }()

    enum Section: Int, CaseIterable { case filters, grid }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTheme()
        setupCollectionView()
        configureDataSource()
        setupLoadingIndicator()
        fetchLibraryData()
    }
    
    // MARK: - Navigation Bar Fix
    private func setupTheme() {
        title = "Saved Library"
        view.backgroundColor = .systemBackground
        
        navigationItem.largeTitleDisplayMode = .never
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }
    
    private func setupLoadingIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - API Data Fetching
    private func fetchLibraryData() {
        activityIndicator.startAnimating()
        
        NewsPersistenceManager.shared.getBookmarkedCards { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                switch result {
                case .success(let cards):
                    let savedItem = InsiderSavedItem(
                        title: "Saved Posts",
                        itemCount: cards.count,
                        articleImageUrl: cards.first?.imageURL ?? "https://images.unsplash.com/photo-1506784983877-45594efa4cbe?auto=format&fit=crop&q=80&w=400",
                        category: "Articles",
                        apiCategory: .feed
                    )
                    self?.libraryItems = [savedItem]
                    self?.updateUI()
                case .failure:
                    self?.libraryItems = []
                    self?.updateUI()
                }
            }
        }
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        collectionView.register(InsiderFilterPillCell.self, forCellWithReuseIdentifier: InsiderFilterPillCell.reuseIdentifier)
        collectionView.register(InsiderGridFolderCell.self, forCellWithReuseIdentifier: InsiderGridFolderCell.reuseIdentifier)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            let section = Section(rawValue: sectionIndex)
            if section == .filters {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .estimated(80), heightDimension: .absolute(38)))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .estimated(80), heightDimension: .absolute(38)), subitems: [item])
                let sec = NSCollectionLayoutSection(group: group)
                sec.orthogonalScrollingBehavior = .continuous
                sec.interGroupSpacing = 8
                sec.contentInsets = .init(top: 16, leading: 16, bottom: 4, trailing: 16)
                return sec
            } else {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0)))
                item.contentInsets = .init(top: 2, leading: 6, bottom: 2, trailing: 6)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.55))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                let sec = NSCollectionLayoutSection(group: group)
                sec.contentInsets = .init(top: 4, leading: 10, bottom: 20, trailing: 10)
                return sec
            }
        }
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>(collectionView: collectionView) { (cv, ip, item) in
            if let filterTitle = item as? String {
                let cell = cv.dequeueReusableCell(withReuseIdentifier: InsiderFilterPillCell.reuseIdentifier, for: ip) as! InsiderFilterPillCell
                cell.configure(title: filterTitle, isSelected: filterTitle == self.selectedFilter)
                return cell
            } else if let libraryItem = item as? InsiderSavedItem {
                let cell = cv.dequeueReusableCell(withReuseIdentifier: InsiderGridFolderCell.reuseIdentifier, for: ip) as! InsiderGridFolderCell
                cell.configure(with: libraryItem)
                return cell
            }
            return nil
        }
    }
    
    private func updateUI() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        snapshot.appendSections([.filters, .grid])
        snapshot.appendItems(filters, toSection: .filters)
        
        let filteredData = selectedFilter == "All" ? libraryItems : libraryItems.filter { $0.category == selectedFilter }
        
        snapshot.appendItems(filteredData, toSection: .grid)
        snapshot.reloadSections([.filters])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension InsiderSavedLibraryController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            UISelectionFeedbackGenerator().selectionChanged()
            selectedFilter = filters[indexPath.item]
            updateUI()
        } else {
            let currentItems = selectedFilter == "All" ? libraryItems : libraryItems.filter { $0.category == selectedFilter }
            let selectedItem = currentItems[indexPath.item]
            let detailVC = LibraryDetailViewController(category: selectedItem.apiCategory, libraryTitle: selectedItem.title)
            if selectedItem.title == "Saved Posts" {
                detailVC.isSavedLibrary = true
            }
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

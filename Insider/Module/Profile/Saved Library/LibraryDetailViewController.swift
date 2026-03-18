import UIKit

// MARK: - Library Detail Controller
class LibraryDetailViewController: UIViewController {
    
    private let category: NewsCategory
    private let libraryTitle: String
    private var articles: [NewsItem] = []
    var isSavedLibrary: Bool = false
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    init(category: NewsCategory, libraryTitle: String) {
        self.category = category
        self.libraryTitle = libraryTitle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        setupFixedNavigationBar()
    }
    
    private func setupFixedNavigationBar() {
        guard let navBar = navigationController?.navigationBar else { return }
        
        // DISABLE LARGE TITLES to move text next to the back arrow
        navBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        self.title = libraryTitle
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        // Style for the Inline Title
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ]
        
        // Removes the fine line under the bar for a cleaner look
        appearance.shadowColor = .clear

        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.compactAppearance = appearance
        
        navBar.tintColor = .label
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Hides "Back" text so only the icon and library title show
        navigationItem.backButtonDisplayMode = .minimal
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(InsiderArticleRowCell.self, forCellReuseIdentifier: InsiderArticleRowCell.reuseIdentifier)
        tableView.contentInsetAdjustmentBehavior = .always
        
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func fetchData() {
        activityIndicator.startAnimating()
        
        if isSavedLibrary {
            NewsPersistenceManager.shared.getBookmarkedCards { [weak self] result in
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    if case .success(let dbCards) = result {
                        self?.articles = dbCards.map { $0.toNewsItem() }
                        self?.tableView.reloadData()
                    }
                }
            }
        } else {
            NewsAPIService.shared.fetchNews(for: category) { [weak self] result in
                DispatchQueue.main.async {
                    self?.activityIndicator.stopAnimating()
                    if case .success(let items) = result {
                        self?.articles = items
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }
}

extension LibraryDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: InsiderArticleRowCell.reuseIdentifier, for: indexPath) as? InsiderArticleRowCell else { return UITableViewCell() }
        cell.configure(with: articles[indexPath.row], isLast: indexPath.row == articles.count - 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = articles[indexPath.row]
        let articleVC = ArticleDetailViewController(article: article, libraryTitle: self.libraryTitle)
        articleVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(articleVC, animated: true)
    }
}

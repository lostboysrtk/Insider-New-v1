//
//
//
//
////
////  AllAudioViewController.swift
////  Insider
////
////  Rebuilt with sticky filter chips + date-grouped sections
////
//
//import UIKit
//
//// MARK: - Filter Model
//
//private struct AudioFilter {
//    let title: String
//    let keyword: String? // nil = "All"
//    let icon: String
//}
//
//// MARK: - AllAudioViewController
//
//class AllAudioViewController: UIViewController {
//
//    // MARK: - Constants
//
//    private let filters: [AudioFilter] = [
//        AudioFilter(title: "All",        keyword: nil,                 icon: "squares.below.rectangle"),
//        AudioFilter(title: "Today",      keyword: "__today__",         icon: "sun.max.fill"),
//        AudioFilter(title: "AI",         keyword: "artificial intelligence", icon: "brain.head.profile"),
//        AudioFilter(title: "Mobile",     keyword: "mobile",            icon: "iphone"),
//        AudioFilter(title: "Web",        keyword: "web",               icon: "globe"),
//        AudioFilter(title: "Python",     keyword: "python",            icon: "chart.bar.fill"),
//        AudioFilter(title: "DevOps",     keyword: "docker",            icon: "shippingbox.fill"),
//        AudioFilter(title: "AWS",        keyword: "aws",               icon: "cloud.fill"),
//        AudioFilter(title: "Security",   keyword: "security",          icon: "lock.shield.fill"),
//    ]
//
//    // MARK: - Properties
//
//    private let store = AudioDataStore.shared
//    private let refreshControl = UIRefreshControl()
//    private let loadingView = UIActivityIndicatorView(style: .large)
//
//    private var allBriefs: [TopChoiceItem] = []          // raw full list
//    private var filteredBriefs: [TopChoiceItem] = []     // after applying active filter
//    private var groupedSections: [(header: String, items: [TopChoiceItem])] = []
//
//    private var selectedFilterIndex: Int = 0
//    private var isLoading = false
//
//    // MARK: - UI
//
//    private lazy var filterCollectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.minimumInteritemSpacing = 10
//        layout.minimumLineSpacing = 10
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
//        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        cv.translatesAutoresizingMaskIntoConstraints = false
//        cv.showsHorizontalScrollIndicator = false
//        cv.backgroundColor = .systemBackground
//        cv.register(FilterChipCell.self, forCellWithReuseIdentifier: FilterChipCell.reuseId)
//        cv.dataSource = self
//        cv.delegate = self
//        cv.tag = 1 // distinguish from tableView
//        return cv
//    }()
//
//    private lazy var tableView: UITableView = {
//        let tv = UITableView(frame: .zero, style: .plain)
//        tv.translatesAutoresizingMaskIntoConstraints = false
//        tv.dataSource = self
//        tv.delegate = self
//        tv.register(ModernAudioBriefCell.self, forCellReuseIdentifier: ModernAudioBriefCell.reuseIdentifier)
//        tv.refreshControl = refreshControl
//        tv.rowHeight = UITableView.automaticDimension
//        tv.estimatedRowHeight = 120
//        tv.backgroundColor = .clear
//        tv.separatorStyle = .none
//        return tv
//    }()
//
//    // MARK: - Lifecycle
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        loadAllAudio()
//    }
//
//    // MARK: - Setup
//
//    private func setupUI() {
//        title = "All Audio Briefs"
//        view.backgroundColor = .systemBackground
//        navigationItem.largeTitleDisplayMode = .never
//
//        // Filter bar
//        view.addSubview(filterCollectionView)
//        view.addSubview(tableView)
//
//        // Loading indicator
//        loadingView.translatesAutoresizingMaskIntoConstraints = false
//        loadingView.color = .systemIndigo
//        view.addSubview(loadingView)
//
//        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
//
//        NSLayoutConstraint.activate([
//            // Filter chips strip — sits right under nav bar
//            filterCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            filterCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            filterCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            filterCollectionView.heightAnchor.constraint(equalToConstant: 52),
//
//            // Table view below filter bar
//            tableView.topAnchor.constraint(equalTo: filterCollectionView.bottomAnchor, constant: 4),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//
//            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//        ])
//    }
//
//    // MARK: - Data Loading
//
//    private func loadAllAudio() {
//        guard !isLoading else { return }
//        isLoading = true
//        loadingView.startAnimating()
//
//        store.loadAllTechnicalBriefsFromDatabase { [weak self] items in
//            DispatchQueue.main.async {
//                guard let self = self else { return }
//                self.isLoading = false
//                self.loadingView.stopAnimating()
//                self.refreshControl.endRefreshing()
//                self.allBriefs = items
//                self.applyFilter(at: self.selectedFilterIndex)
//                print("📊 Loaded \(items.count) audio briefs from database")
//            }
//        }
//    }
//
//    @objc private func refreshData() {
//        store.refreshAllAudioData { [weak self] success in
//            DispatchQueue.main.async {
//                if success {
//                    self?.loadAllAudio()
//                } else {
//                    self?.refreshControl.endRefreshing()
//                    self?.showErrorAlert("Failed to refresh content")
//                }
//            }
//        }
//    }
//
//    // MARK: - Filtering & Grouping
//
//    private func applyFilter(at index: Int) {
//        selectedFilterIndex = index
//        let filter = filters[index]
//
//        if filter.keyword == nil {
//            // "All"
//            filteredBriefs = allBriefs
//        } else if filter.keyword == "__today__" {
//            filteredBriefs = allBriefs.filter { item in
//                if let date = item.publishedDate {
//                    return Calendar.current.isDateInToday(date)
//                }
//                return false
//            }
//        } else {
//            let keyword = filter.keyword!.lowercased()
//            filteredBriefs = allBriefs.filter {
//                $0.category.lowercased().contains(keyword) ||
//                $0.title.lowercased().contains(keyword)
//            }
//        }
//
//        groupedSections = buildSections(from: filteredBriefs)
//
//        // Scroll to top and reload
//        tableView.reloadData()
//        if !groupedSections.isEmpty {
//            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
//        }
//        tableView.backgroundView = filteredBriefs.isEmpty ? emptyStateView(for: filter.title) : nil
//    }
//
//    /// Groups a flat list into date-labelled sections: Today, Yesterday, then "dd MMM yy"
//    private func buildSections(from items: [TopChoiceItem]) -> [(header: String, items: [TopChoiceItem])] {
//        var buckets: [(key: String, sortDate: Date, items: [TopChoiceItem])] = []
//        let calendar = Calendar.current
//        let today = calendar.startOfDay(for: Date())
//        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
//
//        for item in items {
//            let date = item.publishedDate ?? Date.distantPast
//            let day = calendar.startOfDay(for: date)
//
//            let label: String
//            if day == today {
//                label = "Today"
//            } else if day == yesterday {
//                label = "Yesterday"
//            } else {
//                let fmt = DateFormatter()
//                fmt.dateFormat = "dd MMM yyyy"
//                label = fmt.string(from: date)
//            }
//
//            if let idx = buckets.firstIndex(where: { $0.key == label }) {
//                buckets[idx].items.append(item)
//            } else {
//                buckets.append((key: label, sortDate: day, items: [item]))
//            }
//        }
//
//        // Sort buckets newest-first
//        buckets.sort { $0.sortDate > $1.sortDate }
//        return buckets.map { (header: $0.key, items: $0.items) }
//    }
//
//    // MARK: - Helpers
//
//    private func emptyStateView(for filterTitle: String) -> UIView {
//        let label = UILabel()
//        label.text = "No '\(filterTitle)' briefs found.\nPull down to refresh."
//        label.textAlignment = .center
//        label.textColor = .secondaryLabel
//        label.numberOfLines = 0
//        label.font = .systemFont(ofSize: 16, weight: .medium)
//        return label
//    }
//
//    private func showErrorAlert(_ message: String) {
//        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//}
//
//// MARK: - UICollectionViewDataSource (Filter Chips)
//
//extension AllAudioViewController: UICollectionViewDataSource {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return filters.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterChipCell.reuseId, for: indexPath) as! FilterChipCell
//        cell.configure(with: filters[indexPath.item], isSelected: indexPath.item == selectedFilterIndex)
//        return cell
//    }
//}
//
//// MARK: - UICollectionViewDelegate (Filter Chips)
//
//extension AllAudioViewController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard indexPath.item != selectedFilterIndex else { return }
//        UIImpactFeedbackGenerator(style: .light).impactOccurred()
//
//        let previous = selectedFilterIndex
//        selectedFilterIndex = indexPath.item
//
//        // Animate chip reselection
//        collectionView.reloadItems(at: [IndexPath(item: previous, section: 0), indexPath])
//        applyFilter(at: indexPath.item)
//    }
//}
//
//// MARK: - UITableViewDataSource
//
//extension AllAudioViewController: UITableViewDataSource {
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return groupedSections.count
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return groupedSections[section].items.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(
//            withIdentifier: ModernAudioBriefCell.reuseIdentifier, for: indexPath
//        ) as? ModernAudioBriefCell else { return UITableViewCell() }
//
//        let item = groupedSections[indexPath.section].items[indexPath.row]
//        cell.configure(with: item)
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return groupedSections[section].header
//    }
//}
//
//// MARK: - UITableViewDelegate
//
//extension AllAudioViewController: UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let header = UIView()
//        header.backgroundColor = .systemBackground
//
//        let label = UILabel()
//        label.text = groupedSections[section].header
//        label.font = .systemFont(ofSize: 13, weight: .semibold)
//        label.textColor = .secondaryLabel
//        label.translatesAutoresizingMaskIntoConstraints = false
//        header.addSubview(label)
//
//        let separator = UIView()
//        separator.backgroundColor = .separator.withAlphaComponent(0.4)
//        separator.translatesAutoresizingMaskIntoConstraints = false
//        header.addSubview(separator)
//
//        NSLayoutConstraint.activate([
//            label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 20),
//            label.centerYAnchor.constraint(equalTo: header.centerYAnchor),
//            separator.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 20),
//            separator.trailingAnchor.constraint(equalTo: header.trailingAnchor),
//            separator.bottomAnchor.constraint(equalTo: header.bottomAnchor),
//            separator.heightAnchor.constraint(equalToConstant: 0.5),
//        ])
//        return header
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 36
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//
//        let item = groupedSections[indexPath.section].items[indexPath.row]
//
//        // Pass only the items in the currently visible filtered list to the player
//        let flatList = groupedSections.flatMap { $0.items }
//        let globalIndex = flatList.firstIndex(where: { $0.title == item.title }) ?? indexPath.row
//
//        let playerVC = NewAudioPlayerViewController()
//        playerVC.newsItem = item
//        playerVC.transcriptIndex = globalIndex
//        playerVC.allBriefsList = flatList
//        playerVC.modalPresentationStyle = .fullScreen
//        present(playerVC, animated: true)
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//}
//
//// MARK: - Filter Chip Cell
//
//private class FilterChipCell: UICollectionViewCell {
//    static let reuseId = "FilterChipCell"
//
//    private let iconView: UIImageView = {
//        let iv = UIImageView()
//        iv.contentMode = .scaleAspectFit
//        iv.translatesAutoresizingMaskIntoConstraints = false
//        return iv
//    }()
//
//    private let label: UILabel = {
//        let l = UILabel()
//        l.font = .systemFont(ofSize: 13, weight: .semibold)
//        l.translatesAutoresizingMaskIntoConstraints = false
//        return l
//    }()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        contentView.layer.cornerRadius = 18
//        contentView.clipsToBounds = true
//        contentView.addSubview(iconView)
//        contentView.addSubview(label)
//        NSLayoutConstraint.activate([
//            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
//            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            iconView.widthAnchor.constraint(equalToConstant: 14),
//            iconView.heightAnchor.constraint(equalToConstant: 14),
//            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 6),
//            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
//            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//            contentView.heightAnchor.constraint(equalToConstant: 36),
//        ])
//    }
//
//    required init?(coder: NSCoder) { fatalError() }
//
//    func configure(with filter: AudioFilter, isSelected: Bool) {
//        label.text = filter.title
//        iconView.image = UIImage(systemName: filter.icon)
//
//        if isSelected {
//            contentView.backgroundColor = .systemIndigo
//            label.textColor = .white
//            iconView.tintColor = .white
//        } else {
//            contentView.backgroundColor = .secondarySystemBackground
//            label.textColor = .label
//            iconView.tintColor = .secondaryLabel
//        }
//    }
//}
//
//// MARK: - Modern Audio Brief Cell
//
//class ModernAudioBriefCell: UITableViewCell {
//
//    static let reuseIdentifier = "ModernAudioBriefCell"
//
//    private let containerView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .systemBackground
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    private let thumbnailImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.contentMode = .scaleAspectFill
//        imageView.clipsToBounds = true
//        imageView.layer.cornerRadius = 12
//        imageView.backgroundColor = .systemGray6
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        return imageView
//    }()
//
//    private let categoryBadge: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 10, weight: .bold)
//        label.textColor = .systemIndigo
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 16, weight: .bold)
//        label.numberOfLines = 2
//        label.textColor = .label
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    private let summaryLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 13, weight: .regular)
//        label.numberOfLines = 2
//        label.textColor = .secondaryLabel
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    private let dateLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 12, weight: .semibold)
//        label.textColor = .systemBlue
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    private let bottomSeparator: UIView = {
//        let view = UIView()
//        view.backgroundColor = .separator.withAlphaComponent(0.3)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupUI()
//    }
//
//    required init?(coder: NSCoder) { fatalError() }
//
//    private func setupUI() {
//        backgroundColor = .systemBackground
//        selectionStyle = .none
//
//        contentView.addSubview(containerView)
//        containerView.addSubview(thumbnailImageView)
//        containerView.addSubview(categoryBadge)
//        containerView.addSubview(titleLabel)
//        containerView.addSubview(summaryLabel)
//        containerView.addSubview(dateLabel)
//        containerView.addSubview(bottomSeparator)
//
//        NSLayoutConstraint.activate([
//            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
//            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//
//            thumbnailImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
//            thumbnailImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
//            thumbnailImageView.widthAnchor.constraint(equalToConstant: 80),
//            thumbnailImageView.heightAnchor.constraint(equalToConstant: 80),
//
//            categoryBadge.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
//            categoryBadge.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
//            categoryBadge.trailingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: -10),
//
//            titleLabel.topAnchor.constraint(equalTo: categoryBadge.bottomAnchor, constant: 3),
//            titleLabel.leadingAnchor.constraint(equalTo: categoryBadge.leadingAnchor),
//            titleLabel.trailingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: -10),
//
//            summaryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
//            summaryLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            summaryLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
//
//            dateLabel.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 6),
//            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
//            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -14),
//
//            bottomSeparator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
//            bottomSeparator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
//            bottomSeparator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
//            bottomSeparator.heightAnchor.constraint(equalToConstant: 0.5),
//        ])
//    }
//
//    func configure(with item: TopChoiceItem) {
//        categoryBadge.text = item.category.uppercased()
//        titleLabel.text = item.title
//        summaryLabel.text = item.summary
//
//        if let publishedDate = item.publishedDate {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "dd MMM yy"
//            dateLabel.text = formatter.string(from: publishedDate).uppercased()
//        } else {
//            dateLabel.text = item.date.uppercased()
//        }
//
//        if let imageUrl = item.imageUrl, !imageUrl.isEmpty {
//            AudioImageLoader.shared.loadImage(from: imageUrl, into: thumbnailImageView)
//        } else {
//            thumbnailImageView.image = UIImage(systemName: "waveform.circle.fill")
//            thumbnailImageView.tintColor = .systemGray4
//        }
//    }
//
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        thumbnailImageView.image = nil
//        titleLabel.text = nil
//        summaryLabel.text = nil
//        dateLabel.text = nil
//        categoryBadge.text = nil
//    }
//}







//
//  AllAudioViewController.swift
//  Insider
//
//  Rebuilt with sticky filter chips + date-grouped sections
//

import UIKit

// MARK: - Filter Model

private struct AudioFilter {
    let title: String
    let keyword: String? // nil = "All"
    let icon: String
}

// MARK: - AllAudioViewController

class AllAudioViewController: UIViewController {

    // MARK: - Constants

    private let filters: [AudioFilter] = [
        AudioFilter(title: "All",        keyword: nil,                 icon: "squares.below.rectangle"),
        AudioFilter(title: "Today",      keyword: "__today__",         icon: "sun.max.fill"),
        AudioFilter(title: "AI",         keyword: "artificial intelligence", icon: "brain.head.profile"),
        AudioFilter(title: "Mobile",     keyword: "mobile",            icon: "iphone"),
        AudioFilter(title: "Web",        keyword: "web",               icon: "globe"),
        AudioFilter(title: "Python",     keyword: "python",            icon: "chart.bar.fill"),
        AudioFilter(title: "DevOps",     keyword: "docker",            icon: "shippingbox.fill"),
        AudioFilter(title: "AWS",        keyword: "aws",               icon: "cloud.fill"),
        AudioFilter(title: "Security",   keyword: "security",          icon: "lock.shield.fill"),
    ]

    // MARK: - Properties

    private let store = AudioDataStore.shared
    private let refreshControl = UIRefreshControl()
    private let loadingView = UIActivityIndicatorView(style: .large)

    private var allBriefs: [TopChoiceItem] = []          // raw full list
    private var filteredBriefs: [TopChoiceItem] = []     // after applying active filter
    private var groupedSections: [(header: String, items: [TopChoiceItem])] = []

    private var selectedFilterIndex: Int = 0
    private var isLoading = false

    // MARK: - UI

    private lazy var filterCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .systemBackground
        cv.register(FilterChipCell.self, forCellWithReuseIdentifier: FilterChipCell.reuseId)
        cv.dataSource = self
        cv.delegate = self
        cv.tag = 1 // distinguish from tableView
        return cv
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.dataSource = self
        tv.delegate = self
        tv.register(ModernAudioBriefCell.self, forCellReuseIdentifier: ModernAudioBriefCell.reuseIdentifier)
        tv.refreshControl = refreshControl
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 120
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        return tv
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadAllAudio()
    }

    // MARK: - Setup

    private func setupUI() {
        title = "All Audio Briefs"
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        // Filter bar
        view.addSubview(filterCollectionView)
        view.addSubview(tableView)

        // Loading indicator
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.color = .brand
        view.addSubview(loadingView)

        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)

        NSLayoutConstraint.activate([
            // Filter chips strip — sits right under nav bar
            filterCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            filterCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterCollectionView.heightAnchor.constraint(equalToConstant: 52),

            // Table view below filter bar
            tableView.topAnchor.constraint(equalTo: filterCollectionView.bottomAnchor, constant: 4),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    // MARK: - Data Loading

    private func loadAllAudio() {
        guard !isLoading else { return }
        isLoading = true
        loadingView.startAnimating()

        store.loadAllTechnicalBriefsFromDatabase { [weak self] items in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                self.loadingView.stopAnimating()
                self.refreshControl.endRefreshing()
                self.allBriefs = items
                self.applyFilter(at: self.selectedFilterIndex)
                print("📊 Loaded \(items.count) audio briefs from database")
            }
        }
    }

    @objc private func refreshData() {
        store.refreshAllAudioData { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.loadAllAudio()
                } else {
                    self?.refreshControl.endRefreshing()
                    self?.showErrorAlert("Failed to refresh content")
                }
            }
        }
    }

    // MARK: - Filtering & Grouping

    private func applyFilter(at index: Int) {
        selectedFilterIndex = index
        let filter = filters[index]

        if filter.keyword == nil {
            // "All"
            filteredBriefs = allBriefs
        } else if filter.keyword == "__today__" {
            filteredBriefs = allBriefs.filter { item in
                if let date = item.publishedDate {
                    return Calendar.current.isDateInToday(date)
                }
                return false
            }
        } else {
            let keyword = filter.keyword!.lowercased()
            filteredBriefs = allBriefs.filter {
                $0.category.lowercased().contains(keyword) ||
                $0.title.lowercased().contains(keyword)
            }
        }

        groupedSections = buildSections(from: filteredBriefs)

        // Scroll to top and reload
        tableView.reloadData()
        if !groupedSections.isEmpty {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
        tableView.backgroundView = filteredBriefs.isEmpty ? emptyStateView(for: filter.title) : nil
    }

    /// Groups a flat list into date-labelled sections: Today, Yesterday, then "dd MMM yy"
    private func buildSections(from items: [TopChoiceItem]) -> [(header: String, items: [TopChoiceItem])] {
        var buckets: [(key: String, sortDate: Date, items: [TopChoiceItem])] = []
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        for item in items {
            let date = item.publishedDate ?? Date.distantPast
            let day = calendar.startOfDay(for: date)

            let label: String
            if day == today {
                label = "Today"
            } else if day == yesterday {
                label = "Yesterday"
            } else {
                let fmt = DateFormatter()
                fmt.dateFormat = "dd MMM yyyy"
                label = fmt.string(from: date)
            }

            if let idx = buckets.firstIndex(where: { $0.key == label }) {
                buckets[idx].items.append(item)
            } else {
                buckets.append((key: label, sortDate: day, items: [item]))
            }
        }

        // Sort buckets newest-first
        buckets.sort { $0.sortDate > $1.sortDate }
        return buckets.map { (header: $0.key, items: $0.items) }
    }

    // MARK: - Helpers

    private func emptyStateView(for filterTitle: String) -> UIView {
        let label = UILabel()
        label.text = "No '\(filterTitle)' briefs found.\nPull down to refresh."
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }

    private func showErrorAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource (Filter Chips)

extension AllAudioViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterChipCell.reuseId, for: indexPath) as! FilterChipCell
        cell.configure(with: filters[indexPath.item], isSelected: indexPath.item == selectedFilterIndex)
        return cell
    }
}

// MARK: - UICollectionViewDelegate (Filter Chips)

extension AllAudioViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item != selectedFilterIndex else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        let previous = selectedFilterIndex
        selectedFilterIndex = indexPath.item

        // Animate chip reselection
        collectionView.reloadItems(at: [IndexPath(item: previous, section: 0), indexPath])
        applyFilter(at: indexPath.item)
    }
}

// MARK: - UITableViewDataSource

extension AllAudioViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedSections[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ModernAudioBriefCell.reuseIdentifier, for: indexPath
        ) as? ModernAudioBriefCell else { return UITableViewCell() }

        let item = groupedSections[indexPath.section].items[indexPath.row]
        cell.configure(with: item)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groupedSections[section].header
    }
}

// MARK: - UITableViewDelegate

extension AllAudioViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = .systemBackground

        let label = UILabel()
        label.text = groupedSections[section].header
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(label)

        let separator = UIView()
        separator.backgroundColor = .separator.withAlphaComponent(0.4)
        separator.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(separator)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 20),
            label.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            separator.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 20),
            separator.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: header.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),
        ])
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        let item = groupedSections[indexPath.section].items[indexPath.row]

        // Pass only the items in the currently visible filtered list to the player
        let flatList = groupedSections.flatMap { $0.items }
        let globalIndex = flatList.firstIndex(where: { $0.title == item.title }) ?? indexPath.row

        let playerVC = NewAudioPlayerViewController()
        playerVC.newsItem = item
        playerVC.transcriptIndex = globalIndex
        playerVC.allBriefsList = flatList
        playerVC.modalPresentationStyle = .fullScreen
        present(playerVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Filter Chip Cell

private class FilterChipCell: UICollectionViewCell {
    static let reuseId = "FilterChipCell"

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let label: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 18
        contentView.clipsToBounds = true
        contentView.addSubview(iconView)
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 14),
            iconView.heightAnchor.constraint(equalToConstant: 14),
            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 6),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 36),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with filter: AudioFilter, isSelected: Bool) {
        label.text = filter.title
        iconView.image = UIImage(systemName: filter.icon)

        if isSelected {
            contentView.backgroundColor = .brand
            label.textColor = .white
            iconView.tintColor = .white
        } else {
            contentView.backgroundColor = .secondarySystemBackground
            label.textColor = .label
            iconView.tintColor = .secondaryLabel
        }
    }
}

// MARK: - Modern Audio Brief Cell

class ModernAudioBriefCell: UITableViewCell {

    static let reuseIdentifier = "ModernAudioBriefCell"

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .systemGray6
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let categoryBadge: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = .brand
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 2
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let summaryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 2
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .brand
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let bottomSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = .separator.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = .systemBackground
        selectionStyle = .none

        contentView.addSubview(containerView)
        containerView.addSubview(thumbnailImageView)
        containerView.addSubview(categoryBadge)
        containerView.addSubview(titleLabel)
        containerView.addSubview(summaryLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(bottomSeparator)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            thumbnailImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            thumbnailImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 80),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 80),

            categoryBadge.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            categoryBadge.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            categoryBadge.trailingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: -10),

            titleLabel.topAnchor.constraint(equalTo: categoryBadge.bottomAnchor, constant: 3),
            titleLabel.leadingAnchor.constraint(equalTo: categoryBadge.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: -10),

            summaryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            summaryLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            summaryLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            dateLabel.topAnchor.constraint(equalTo: summaryLabel.bottomAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -14),

            bottomSeparator.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            bottomSeparator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            bottomSeparator.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            bottomSeparator.heightAnchor.constraint(equalToConstant: 0.5),
        ])
    }

    func configure(with item: TopChoiceItem) {
        categoryBadge.text = item.category.uppercased()
        titleLabel.text = item.title
        summaryLabel.text = item.summary

        if let publishedDate = item.publishedDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yy"
            dateLabel.text = formatter.string(from: publishedDate).uppercased()
        } else {
            dateLabel.text = item.date.uppercased()
        }

        if let imageUrl = item.imageUrl, !imageUrl.isEmpty {
            AudioImageLoader.shared.loadImage(from: imageUrl, into: thumbnailImageView)
        } else {
            thumbnailImageView.image = UIImage(systemName: "waveform.circle.fill")
            thumbnailImageView.tintColor = .systemGray4
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        titleLabel.text = nil
        summaryLabel.text = nil
        dateLabel.text = nil
        categoryBadge.text = nil
    }
}

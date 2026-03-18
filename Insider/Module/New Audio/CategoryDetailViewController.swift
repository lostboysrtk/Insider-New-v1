//
//
////
////  CategoryDetailViewController+API.swift
////  Insider
////
////  Created by Sarthak Sharma on 15/01/26.
////
//
////
////  CategoryDetailViewController+API.swift
////  Insider
////
////  Updated to use real-time filtered API data
////
//
//import UIKit
//
//class CategoryDetailViewController: UIViewController {
//    var toolkitName: String?
//    private var tableView = UITableView()
//    private let store = AudioDataStore.shared
//    private let refreshControl = UIRefreshControl()
//    private let loadingView = UIActivityIndicatorView(style: .large)
//    
//    // Filtered data based on the selected toolkit
//    private var filteredBriefs: [TopChoiceItem] = []
//    private var isLoadingData = false
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupDetailUI()
//        loadFilteredData()
//    }
//    
//    // MARK: - API Data Loading
//    
//    private func loadFilteredData() {
//        guard let toolkitName = toolkitName, !isLoadingData else { return }
//        isLoadingData = true
//        loadingView.startAnimating()
//        
//        store.loadFilteredBriefs(for: toolkitName) { [weak self] items in
//            DispatchQueue.main.async {
//                self?.isLoadingData = false
//                self?.loadingView.stopAnimating()
//                self?.filteredBriefs = items
//                self?.tableView.reloadData()
//                self?.updateCountLabel()
//            }
//        }
//    }
//    
//    @objc private func refreshData() {
//        loadFilteredData()
//        refreshControl.endRefreshing()
//    }
//    
//    private func updateCountLabel() {
//        // Update the count label in the header
//        if let headerView = tableView.tableHeaderView {
//            for subview in headerView.subviews {
//                if let label = subview as? UILabel, label.tag == 100 {
//                    label.text = "\(filteredBriefs.count) episodes"
//                }
//            }
//        }
//    }
//    
//    // MARK: - Setup UI
//    
//    private func setupDetailUI() {
//        view.backgroundColor = .systemBackground
//        title = toolkitName
//        navigationItem.largeTitleDisplayMode = .never
//        
//        // Get the toolkit object for colors and icons
//        let toolkit = store.getToolkit(named: toolkitName ?? "")
//        
//        // Aesthetic Header with dynamic color
//        let headerHeight: CGFloat = 300
//        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: headerHeight))
//        
//        let img = UIImageView(frame: CGRect(x: (view.frame.width - 180)/2, y: 20, width: 180, height: 180))
//        
//        // Dynamic colors and icons based on toolkit
//        img.backgroundColor = toolkit?.color ?? .systemIndigo
//        img.layer.cornerRadius = 24
//        img.layer.shadowColor = UIColor.black.cgColor
//        img.layer.shadowOpacity = 0.2
//        img.layer.shadowOffset = CGSize(width: 0, height: 10)
//        img.layer.shadowRadius = 15
//        img.contentMode = .center
//        img.tintColor = .white
//        img.image = UIImage(systemName: toolkit?.icon ?? "cpu",
//                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 60))
//        headerView.addSubview(img)
//        
//        let playBtn = UIButton(type: .system)
//        var config = UIButton.Configuration.filled()
//        config.title = "Play All \(toolkitName ?? "Briefs")"
//        config.image = UIImage(systemName: "play.fill")
//        config.imagePadding = 10
//        config.baseBackgroundColor = toolkit?.color ?? .systemIndigo
//        config.cornerStyle = .capsule
//        playBtn.configuration = config
//        playBtn.frame = CGRect(x: (view.frame.width/2) - 110, y: 215, width: 220, height: 50)
//        playBtn.addTarget(self, action: #selector(playAllTapped), for: .touchUpInside)
//        headerView.addSubview(playBtn)
//        
//        // Add count label - positioned BELOW the button
//        let countLabel = UILabel(frame: CGRect(x: 20, y: 275, width: view.frame.width - 40, height: 20))
//        countLabel.tag = 100 // For easy identification
//        countLabel.text = "Loading..."
//        countLabel.font = .systemFont(ofSize: 14, weight: .medium)
//        countLabel.textColor = .secondaryLabel
//        countLabel.textAlignment = .center
//        headerView.addSubview(countLabel)
//        
//        tableView.tableHeaderView = headerView
//        tableView.frame = view.bounds
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        
//        // Pull to Refresh
//        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
//        tableView.refreshControl = refreshControl
//        
//        view.addSubview(tableView)
//        
//        // Loading Indicator
//        loadingView.translatesAutoresizingMaskIntoConstraints = false
//        loadingView.color = toolkit?.color ?? .systemIndigo
//        view.addSubview(loadingView)
//        
//        NSLayoutConstraint.activate([
//            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//    }
//    
//    @objc private func playAllTapped() {
//        guard !filteredBriefs.isEmpty else {
//            showAlert("No episodes available to play")
//            return
//        }
//        
//        let playerVC = NewAudioPlayerViewController()
//        playerVC.newsItem = filteredBriefs[0]
//        playerVC.transcriptIndex = 0
//        playerVC.modalPresentationStyle = .fullScreen
//        present(playerVC, animated: true)
//    }
//    
//    private func showAlert(_ message: String) {
//        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//}
//
//// MARK: - TableView Data Source & Delegate
//extension CategoryDetailViewController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return filteredBriefs.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
//        let item = filteredBriefs[indexPath.row]
//        
//        // Get toolkit color
//        let toolkit = store.getToolkit(named: toolkitName ?? "")
//        
//        cell.textLabel?.text = item.title
//        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .bold)
//        cell.textLabel?.numberOfLines = 2
//        cell.detailTextLabel?.text = item.date
//        cell.detailTextLabel?.textColor = .secondaryLabel
//        cell.imageView?.image = UIImage(systemName: "waveform")
//        cell.imageView?.tintColor = toolkit?.color ?? .systemIndigo
//        cell.accessoryType = .disclosureIndicator
//        
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//        
//        // Open the Audio Player for this specific filtered brief
//        let playerVC = NewAudioPlayerViewController()
//        playerVC.newsItem = filteredBriefs[indexPath.row]
//        playerVC.transcriptIndex = indexPath.row % 6
//        playerVC.modalPresentationStyle = .fullScreen
//        present(playerVC, animated: true)
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 80
//    }
//}









//
//  CategoryDetailViewController+API.swift
//  Insider
//
//  Created by Sarthak Sharma on 15/01/26.
//

//
//  CategoryDetailViewController+API.swift
//  Insider
//
//  Updated to use real-time filtered API data
//

import UIKit

class CategoryDetailViewController: UIViewController {
    var toolkitName: String?
    private var tableView = UITableView()
    private let store = AudioDataStore.shared
    private let refreshControl = UIRefreshControl()
    private let loadingView = UIActivityIndicatorView(style: .large)
    
    // Filtered data based on the selected toolkit
    private var filteredBriefs: [TopChoiceItem] = []
    private var isLoadingData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDetailUI()
        loadFilteredData()
    }
    
    // MARK: - API Data Loading
    
    private func loadFilteredData() {
        guard let toolkitName = toolkitName, !isLoadingData else { return }
        isLoadingData = true
        loadingView.startAnimating()
        
        store.loadFilteredBriefs(for: toolkitName) { [weak self] items in
            DispatchQueue.main.async {
                self?.isLoadingData = false
                self?.loadingView.stopAnimating()
                self?.filteredBriefs = items
                self?.tableView.reloadData()
                self?.updateCountLabel()
            }
        }
    }
    
    @objc private func refreshData() {
        loadFilteredData()
        refreshControl.endRefreshing()
    }
    
    private func updateCountLabel() {
        // Update the count label in the header
        if let headerView = tableView.tableHeaderView {
            for subview in headerView.subviews {
                if let label = subview as? UILabel, label.tag == 100 {
                    label.text = "\(filteredBriefs.count) episodes"
                }
            }
        }
    }
    
    // MARK: - Setup UI
    
    private func setupDetailUI() {
        view.backgroundColor = .systemBackground
        title = toolkitName
        navigationItem.largeTitleDisplayMode = .never
        
        // Get the toolkit object for colors and icons
        let toolkit = store.getToolkit(named: toolkitName ?? "")
        
        // Aesthetic Header with dynamic color
        let headerHeight: CGFloat = 300
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: headerHeight))
        
        let img = UIImageView(frame: CGRect(x: (view.frame.width - 180)/2, y: 20, width: 180, height: 180))
        
        // Dynamic colors and icons based on toolkit
        img.backgroundColor = toolkit?.color ?? .brand
        img.layer.cornerRadius = 24
        img.layer.shadowColor = UIColor.black.cgColor
        img.layer.shadowOpacity = 0.2
        img.layer.shadowOffset = CGSize(width: 0, height: 10)
        img.layer.shadowRadius = 15
        img.contentMode = .center
        img.tintColor = .white
        img.image = UIImage(systemName: toolkit?.icon ?? "cpu",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 60))
        headerView.addSubview(img)
        
        let playBtn = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "Play All \(toolkitName ?? "Briefs")"
        config.image = UIImage(systemName: "play.fill")
        config.imagePadding = 10
        config.baseBackgroundColor = toolkit?.color ?? .brand
        config.cornerStyle = .capsule
        playBtn.configuration = config
        playBtn.frame = CGRect(x: (view.frame.width/2) - 110, y: 215, width: 220, height: 50)
        playBtn.addTarget(self, action: #selector(playAllTapped), for: .touchUpInside)
        headerView.addSubview(playBtn)
        
        // Add count label - positioned BELOW the button
        let countLabel = UILabel(frame: CGRect(x: 20, y: 275, width: view.frame.width - 40, height: 20))
        countLabel.tag = 100 // For easy identification
        countLabel.text = "Loading..."
        countLabel.font = .systemFont(ofSize: 14, weight: .medium)
        countLabel.textColor = .secondaryLabel
        countLabel.textAlignment = .center
        headerView.addSubview(countLabel)
        
        tableView.tableHeaderView = headerView
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Pull to Refresh
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        view.addSubview(tableView)
        
        // Loading Indicator
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.color = toolkit?.color ?? .brand
        view.addSubview(loadingView)
        
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func playAllTapped() {
        guard !filteredBriefs.isEmpty else {
            showAlert("No episodes available to play")
            return
        }
        
        let playerVC = NewAudioPlayerViewController()
        playerVC.newsItem = filteredBriefs[0]
        playerVC.transcriptIndex = 0
        playerVC.modalPresentationStyle = .fullScreen
        present(playerVC, animated: true)
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - TableView Data Source & Delegate
extension CategoryDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredBriefs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let item = filteredBriefs[indexPath.row]
        
        // Get toolkit color
        let toolkit = store.getToolkit(named: toolkitName ?? "")
        
        cell.textLabel?.text = item.title
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        cell.textLabel?.numberOfLines = 2
        cell.detailTextLabel?.text = item.date
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.imageView?.image = UIImage(systemName: "waveform")
        cell.imageView?.tintColor = toolkit?.color ?? .brand
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        // Open the Audio Player for this specific filtered brief
        let playerVC = NewAudioPlayerViewController()
        playerVC.newsItem = filteredBriefs[indexPath.row]
        playerVC.transcriptIndex = indexPath.row % 6
        playerVC.modalPresentationStyle = .fullScreen
        present(playerVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

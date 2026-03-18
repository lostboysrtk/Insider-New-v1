//import UIKit
//
//class PersonalizeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//
//    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
//    
//    // MARK: - State
//    private var selectedDomains: [String] = ["None", "None"]
//    private var followingItems: [String] = []
//    private var readingTime: String = "15 news"
//    private var blockedTopics: [String] = []
//    private var professionalGoal: String = "General Knowledge"
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        loadSavedPreferences()
//    }
//
//    private func setupUI () {
//        title = "Personalize Feed"
//        view.backgroundColor = .systemGroupedBackground
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(tableView)
//        
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: view.topAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//
//    private func loadSavedPreferences() {
//        let prefs = UserDefaults.standard
//        // Get the cleaned list (no "None") and map back to slots for the UI
//        let saved = prefs.stringArray(forKey: "UserSelectedDomains") ?? []
//        selectedDomains = ["None", "None"]
//        for (index, domain) in saved.enumerated() where index < 2 {
//            selectedDomains[index] = domain
//        }
//        
//        followingItems = prefs.stringArray(forKey: "FollowingItems") ?? []
//        readingTime = prefs.string(forKey: "ReadingTime") ?? "15 news"
//        blockedTopics = prefs.stringArray(forKey: "BlockedTopics") ?? []
//        professionalGoal = prefs.string(forKey: "ProfessionalGoal") ?? "General Knowledge"
//        
//        tableView.reloadData()
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int { return 5 }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 { return 2 }
//        if section == 1 { return followingItems.count + 1 }
//        if section == 3 { return blockedTopics.count + 1 }
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let header = UIView()
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 13, weight: .bold)
//        label.textColor = .secondaryLabel
//        let titles = ["HOME TABS", "FOLLOWING", "CONTENT VOLUME", "HIDDEN TOPICS", "PROFESSIONAL GOAL"]
//        label.text = titles[section]
//        label.translatesAutoresizingMaskIntoConstraints = false
//        header.addSubview(label)
//        NSLayoutConstraint.activate([label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16), label.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -8)])
//        return header
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
//        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
//        
//        switch indexPath.section {
//        case 0: // HOME TABS
//            let domain = selectedDomains[indexPath.row]
//            cell.textLabel?.text = "Slot \(indexPath.row + 1): \(domain)"
//            cell.imageView?.image = UIImage(systemName: "square.grid.2x2.fill", withConfiguration: config)
//            cell.imageView?.tintColor = .systemBlue
//            if domain != "None" {
//                cell.detailTextLabel?.text = "Tap to change or remove"
//                cell.detailTextLabel?.textColor = .secondaryLabel
//            }
//            cell.accessoryType = .disclosureIndicator
//        case 1, 3:
//            let list = indexPath.section == 1 ? followingItems : blockedTopics
//            if indexPath.row < list.count {
//                cell.textLabel?.text = list[indexPath.row]
//                cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
//                cell.imageView?.image = UIImage(systemName: indexPath.section == 1 ? "checkmark.circle.fill" : "xmark.octagon.fill", withConfiguration: config)
//                cell.imageView?.tintColor = indexPath.section == 1 ? .systemOrange : .systemRed
//                cell.detailTextLabel?.text = "Tap to remove"
//            } else {
//                cell.textLabel?.text = "Add New..."
//                cell.textLabel?.textColor = .systemBlue
//                cell.imageView?.image = UIImage(systemName: "plus.circle.fill", withConfiguration: config)
//                cell.imageView?.tintColor = .systemBlue
//            }
//        case 2:
//            cell.textLabel?.text = readingTime
//            cell.imageView?.image = UIImage(systemName: "clock.fill", withConfiguration: config)
//            cell.imageView?.tintColor = .systemGreen
//        case 4:
//            cell.textLabel?.text = professionalGoal
//            cell.imageView?.image = UIImage(systemName: "target", withConfiguration: config)
//            cell.imageView?.tintColor = .systemPurple
//        default: break
//        }
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        if indexPath.section == 0 {
//            showDomainPicker(index: indexPath.row)
//        } else if indexPath.section == 1 || indexPath.section == 3 {
//            let list = indexPath.section == 1 ? followingItems : blockedTopics
//            if indexPath.row < list.count {
//                showRemoveAlert(index: indexPath.row, section: indexPath.section)
//            } else {
//                showAddAlert(section: indexPath.section)
//            }
//        } else if indexPath.section == 2 {
//            showOptionsPicker(title: "News Count", options: ["10 news", "15 news", "20 news", "25 news"], key: "ReadingTime")
//        } else if indexPath.section == 4 {
//            showOptionsPicker(title: "Your Goal", options: ["Landing an Internship", "Starting a Business", "Mastering Swift", "General Knowledge"], key: "ProfessionalGoal")
//        }
//    }
//
//    private func showDomainPicker(index: Int) {
//        let picker = UIAlertController(title: "Select Topic", message: nil, preferredStyle: .actionSheet)
//        let domains = ["Python", "Swift", "React", "AI/ML", "DevOps", "Data Science", "Cybersecurity", "Blockchain"].sorted()
//        
//        for d in domains {
//            picker.addAction(UIAlertAction(title: d, style: .default) { _ in
//                self.selectedDomains[index] = d
//                self.saveToDisk()
//            })
//        }
//        
//        // Add option to delete/clear the preference
//        picker.addAction(UIAlertAction(title: "Remove Preference", style: .destructive) { _ in
//            self.selectedDomains[index] = "None"
//            self.saveToDisk()
//        })
//        
//        picker.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        present(picker, animated: true)
//    }
//
//    private func showAddAlert(section: Int) {
//        let isFollow = section == 1
//        let alert = UIAlertController(title: isFollow ? "Follow New" : "Block Topic", message: "Enter keyword", preferredStyle: .alert)
//        alert.addTextField { $0.placeholder = "Keyword..." }
//        alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
//            guard let text = alert.textFields?.first?.text, !text.isEmpty else { return }
//            if isFollow { self.followingItems.append(text) } else { self.blockedTopics.append(text) }
//            self.saveToDisk()
//        })
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        present(alert, animated: true)
//    }
//
//    private func showRemoveAlert(index: Int, section: Int) {
//        let alert = UIAlertController(title: "Remove Item?", message: nil, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { _ in
//            if section == 1 { self.followingItems.remove(at: index) } else { self.blockedTopics.remove(at: index) }
//            self.saveToDisk()
//        })
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        present(alert, animated: true)
//    }
//
//    private func saveToDisk() {
//        let prefs = UserDefaults.standard
//        prefs.set(followingItems, forKey: "FollowingItems")
//        prefs.set(blockedTopics, forKey: "BlockedTopics")
//        
//        // CRITICAL: Filter out "None" so only real categories go to the Home Screen
//        let validDomains = selectedDomains.filter { $0 != "None" }
//        prefs.set(validDomains, forKey: "UserSelectedDomains")
//        
//        loadSavedPreferences()
//    }
//
//    private func showOptionsPicker(title: String, options: [String], key: String) {
//        let picker = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
//        for o in options {
//            picker.addAction(UIAlertAction(title: o, style: .default) { _ in
//                UserDefaults.standard.set(o, forKey: key)
//                self.saveToDisk()
//            })
//        }
//        picker.addAction(UIAlertAction(title: "Cancel", style: .cancel)); present(picker, animated: true)
//    }
//}










// PersonalizeViewController.swift
// Syncs all feed-preference changes to the user_profiles table in Supabase.

import UIKit
internal import Auth

class PersonalizeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    // MARK: - State
    private var selectedDomains: [String] = ["None", "None"]
    private var followingItems: [String] = []
    private var readingTime: String = "15 news"
    private var blockedTopics: [String] = []
    private var professionalGoal: String = "General Knowledge"
    
    // Dynamically loaded from Database
    private var availableCategories: [String] = []

    // MARK: - Current user id (resolved once on load)
    private var currentUserId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadCurrentUserId()
        loadSavedPreferences()
        loadAvailableCategories()
    }
    
    private func loadAvailableCategories() {
        NewsPersistenceManager.shared.fetchAllUniqueCategories { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let categories):
                    // Define strict allowed categories to prevent bad/random AI-generated tags from showing
                    let allowedCategories = [
                        "AI", "Artificial Intelligence", "Swift", "Python", "React",
                        "Data Science", "Machine Learning", "Web Development",
                        "Cybersecurity", "Blockchain", "DevOps", "Cloud Computing"
                    ]
                    
                    self?.availableCategories = categories.filter { category in
                        // Filter out None/Technology and ensure it's in our sensible list (case-insensitive)
                        guard category != "None" && category.lowercased() != "technology" else { return false }
                        return allowedCategories.contains { allowed in
                            category.lowercased() == allowed.lowercased() ||
                            category.lowercased().contains(allowed.lowercased())
                        }
                    }
                    
                    // If none matched, provide some defaults so the picker isn't empty
                    if self?.availableCategories.isEmpty == true {
                        self?.availableCategories = ["AI", "Swift", "Python", "React", "Cybersecurity"]
                    }
                case .failure(let error):
                    print("⚠️ Failed to load dynamic categories:", error)
                }
            }
        }
    }

    // MARK: - Fetch current user id from Supabase Auth

    private func loadCurrentUserId() {
        Task {
            if let user = try? await SupabaseManager.shared.getCurrentUser() {
                await MainActor.run { self.currentUserId = user.id.uuidString }
            }
        }
    }

    private func setupUI() {
        title = "Personalize Feed"
        view.backgroundColor = .systemGroupedBackground
        
        navigationItem.largeTitleDisplayMode = .never
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadSavedPreferences() {
        let prefs = UserDefaults.standard
        let saved = prefs.stringArray(forKey: "UserSelectedDomains") ?? []
        selectedDomains = ["None", "None"]
        for (index, domain) in saved.enumerated() where index < 2 {
            selectedDomains[index] = domain
        }
        followingItems    = prefs.stringArray(forKey: "FollowingItems")  ?? []
        readingTime       = prefs.string(forKey: "ReadingTime")          ?? "15 news"
        blockedTopics     = prefs.stringArray(forKey: "BlockedTopics")   ?? []
        professionalGoal  = prefs.string(forKey: "ProfessionalGoal")     ?? "General Knowledge"
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int { 5 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 2 }
        if section == 1 { return followingItems.count + 1 }
        if section == 3 { return blockedTopics.count + 1 }
        return 1
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = .secondaryLabel
        let titles = ["HOME TABS", "FOLLOWING", "CONTENT VOLUME", "HIDDEN TOPICS", "PROFESSIONAL GOAL"]
        label.text = titles[section]
        label.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -8)
        ])
        return header
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        
        switch indexPath.section {
        case 0:
            let domain = selectedDomains[indexPath.row]
            cell.textLabel?.text = "Slot \(indexPath.row + 1): \(domain)"
            cell.imageView?.image = UIImage(systemName: "square.grid.2x2.fill", withConfiguration: config)
            cell.imageView?.tintColor = .systemBlue
            if domain != "None" {
                cell.detailTextLabel?.text = "Tap to change or remove"
                cell.detailTextLabel?.textColor = .secondaryLabel
            }
            cell.accessoryType = .disclosureIndicator
        case 1, 3:
            let list = indexPath.section == 1 ? followingItems : blockedTopics
            if indexPath.row < list.count {
                cell.textLabel?.text = list[indexPath.row]
                cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
                cell.imageView?.image = UIImage(systemName: indexPath.section == 1
                    ? "checkmark.circle.fill" : "xmark.octagon.fill", withConfiguration: config)
                cell.imageView?.tintColor = indexPath.section == 1 ? .systemOrange : .systemRed
                cell.detailTextLabel?.text = "Tap to remove"
            } else {
                cell.textLabel?.text = "Add New..."
                cell.textLabel?.textColor = .systemBlue
                cell.imageView?.image = UIImage(systemName: "plus.circle.fill", withConfiguration: config)
                cell.imageView?.tintColor = .systemBlue
            }
        case 2:
            cell.textLabel?.text = readingTime
            cell.imageView?.image = UIImage(systemName: "clock.fill", withConfiguration: config)
            cell.imageView?.tintColor = .systemGreen
        case 4:
            cell.textLabel?.text = professionalGoal
            cell.imageView?.image = UIImage(systemName: "target", withConfiguration: config)
            cell.imageView?.tintColor = .systemPurple
        default: break
        }
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            showDomainPicker(index: indexPath.row)
        } else if indexPath.section == 1 || indexPath.section == 3 {
            let list = indexPath.section == 1 ? followingItems : blockedTopics
            if indexPath.row < list.count {
                showRemoveAlert(index: indexPath.row, section: indexPath.section)
            } else {
                showAddAlert(section: indexPath.section)
            }
        } else if indexPath.section == 2 {
            showOptionsPicker(title: "News Count",
                              options: ["10 news", "15 news", "20 news", "25 news"],
                              key: "ReadingTime")
        } else if indexPath.section == 4 {
            showOptionsPicker(title: "Your Goal",
                              options: ["Landing an Internship", "Starting a Business",
                                        "Mastering Swift", "General Knowledge"],
                              key: "ProfessionalGoal")
        }
    }

    // MARK: - Pickers & Alerts

    private func showDomainPicker(index: Int) {
        let picker = UIAlertController(title: "Select Topic", message: nil, preferredStyle: .actionSheet)
        
        let domains = availableCategories.isEmpty 
            ? ["Python", "Swift", "React", "AI/ML", "DevOps", "Data Science", "Cybersecurity", "Blockchain"].sorted()
            : availableCategories
            
        for d in domains {
            picker.addAction(UIAlertAction(title: d, style: .default) { _ in
                self.selectedDomains[index] = d
                self.saveToDisk()
            })
        }
        picker.addAction(UIAlertAction(title: "Remove Preference", style: .destructive) { _ in
            self.selectedDomains[index] = "None"
            self.saveToDisk()
        })
        picker.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(picker, animated: true)
    }

    private func showAddAlert(section: Int) {
        let isFollow = section == 1
        let alert = UIAlertController(title: isFollow ? "Follow New" : "Block Topic",
                                      message: "Enter keyword", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Keyword..." }
        alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            guard let text = alert.textFields?.first?.text, !text.isEmpty else { return }
            if isFollow { self.followingItems.append(text) } else { self.blockedTopics.append(text) }
            self.saveToDisk()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func showRemoveAlert(index: Int, section: Int) {
        let alert = UIAlertController(title: "Remove Item?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { _ in
            if section == 1 { self.followingItems.remove(at: index) }
            else            { self.blockedTopics.remove(at: index)   }
            self.saveToDisk()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func showOptionsPicker(title: String, options: [String], key: String) {
        let picker = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        for o in options {
            picker.addAction(UIAlertAction(title: o, style: .default) { _ in
                UserDefaults.standard.set(o, forKey: key)
                self.saveToDisk()
            })
        }
        picker.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(picker, animated: true)
    }

    // MARK: - Persist (UserDefaults + Supabase)

    private func saveToDisk() {
        let prefs = UserDefaults.standard
        prefs.set(followingItems, forKey: "FollowingItems")
        prefs.set(blockedTopics,  forKey: "BlockedTopics")
        
        // Filter out "None" — only real categories go to Home Screen & DB
        let validDomains = selectedDomains.filter { $0 != "None" }
        prefs.set(validDomains, forKey: "UserSelectedDomains")
        
        // Sync to Supabase
        syncFeedPreferencesToDatabase(validDomains: validDomains)
        
        loadSavedPreferences()
    }

    private func syncFeedPreferencesToDatabase(validDomains: [String]) {
        guard let userId = currentUserId else {
            print("⚠️ [Personalize] No user id yet — skipping DB sync")
            return
        }
        UserProfilePersistenceManager.shared.updateFeedPreferences(
            userId: userId,
            selectedDomains: validDomains,
            followingTopics: followingItems,
            blockedTopics: blockedTopics,
            readingTime: readingTime,
            goal: professionalGoal
        ) { result in
            switch result {
            case .success:
                print("✅ [Personalize] Feed preferences saved to database")
            case .failure(let error):
                print("⚠️ [Personalize] DB sync failed: \(error.localizedDescription)")
            }
        }
    }
}

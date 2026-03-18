//import UIKit
//private class RightToLeftTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
//    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? { return self }
//    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { return 0.5 }
//    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        guard let toView = transitionContext.view(forKey: .to) else { return }
//        let containerView = transitionContext.containerView
//        let screenWidth = containerView.frame.width
//        toView.frame = CGRect(x: screenWidth, y: 0, width: screenWidth, height: containerView.frame.height)
//        containerView.addSubview(toView)
//        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .curveEaseOut) {
//            toView.frame = containerView.bounds
//        } completion: { finished in transitionContext.completeTransition(finished) }
//    }
//}
//
//private let customTransitionDelegate = RightToLeftTransitionDelegate()
//class PreferenceSelection2ViewController: UIViewController {
//    
//    // MARK: - Properties
//    private var selectedDomains: Set<String> = []
//    private let allDomains: [(name: String, icon: String, color: UIColor)] = [
//        ("Python", "terminal", .systemBlue), ("Swift", "swift", .systemOrange),
//        ("React", "atom", .systemTeal), ("AI/ML", "cpu", .systemPink),
//        ("DevOps", "cloud", .systemIndigo), ("Data", "database", .systemPurple),
//        ("Security", "shield", .systemRed), ("Web Dev", "safari", .systemGreen),
//        ("Android", "iphone", .systemMint), ("Go", "gear", .systemCyan),
//        ("Rust", "hammer", .systemBrown), ("Node.js", "leaf", .systemGreen)
//    ]
//    
//    // MARK: - UI Components
//    private let backButton: UIButton = {
//        let btn = UIButton(type: .system)
//        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
//        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
//        btn.tintColor = .black
//        btn.translatesAutoresizingMaskIntoConstraints = false
//        return btn
//    }()
//    
//    private let pageTitle: UILabel = {
//        let lbl = UILabel()
//        lbl.text = "Customize Your Feed"
//        lbl.font = .systemFont(ofSize: 14, weight: .semibold)
//        lbl.textColor = .secondaryLabel
//        lbl.textAlignment = .center
//        lbl.translatesAutoresizingMaskIntoConstraints = false
//        return lbl
//    }()
//    
//    private let mainQuestionLabel: UILabel = {
//        let lbl = UILabel()
//        lbl.text = "Which topics interest\nyou most?"
//        lbl.font = .systemFont(ofSize: 32, weight: .bold)
//        lbl.numberOfLines = 0
//        lbl.textColor = .black
//        lbl.textAlignment = .center
//        lbl.translatesAutoresizingMaskIntoConstraints = false
//        return lbl
//    }()
//    
//    private let subtitleLabel: UILabel = {
//        let lbl = UILabel()
//        lbl.text = "Select multiple domains"
//        lbl.font = .systemFont(ofSize: 15, weight: .medium)
//        lbl.textColor = .secondaryLabel
//        lbl.textAlignment = .center
//        lbl.translatesAutoresizingMaskIntoConstraints = false
//        return lbl
//    }()
//
//    private lazy var collectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.minimumLineSpacing = 15
//        layout.minimumInteritemSpacing = 15
//        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        cv.backgroundColor = .clear
//        cv.register(DomainGridCell.self, forCellWithReuseIdentifier: "DomainGridCell")
//        cv.delegate = self
//        cv.dataSource = self
//        cv.translatesAutoresizingMaskIntoConstraints = false
//        return cv
//    }()
//
//    private let continueButton: UIButton = {
//        let btn = UIButton(type: .system)
//        btn.setTitle("Finish Setup", for: .normal)
//        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
//        btn.setTitleColor(.white, for: .normal)
//        btn.backgroundColor = UIColor(red: 0.40, green: 0.55, blue: 0.85, alpha: 1.0)
//        btn.layer.cornerRadius = 28
//        btn.alpha = 0.5
//        btn.isEnabled = false
//        btn.translatesAutoresizingMaskIntoConstraints = false
//        return btn
//    }()
//
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        setupLayout()
//        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
//        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
//    }
//
//    private func setupLayout() {
//        view.addSubview(backButton)
//        view.addSubview(pageTitle)
//        view.addSubview(mainQuestionLabel)
//        view.addSubview(subtitleLabel)
//        view.addSubview(collectionView)
//        view.addSubview(continueButton)
//
//        NSLayoutConstraint.activate([
//            pageTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
//            pageTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            
//            backButton.centerYAnchor.constraint(equalTo: pageTitle.centerYAnchor),
//            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
//            
//            mainQuestionLabel.topAnchor.constraint(equalTo: pageTitle.bottomAnchor, constant: 35),
//            mainQuestionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
//            mainQuestionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
//            
//            subtitleLabel.topAnchor.constraint(equalTo: mainQuestionLabel.bottomAnchor, constant: 12),
//            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
//            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
//            
//            collectionView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
//            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            collectionView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -20),
//            
//            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
//            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            continueButton.heightAnchor.constraint(equalToConstant: 56)
//        ])
//    }
//
//    @objc private func backTapped() { dismiss(animated: true) }
//
//    @objc private func continueTapped() {
//        guard !selectedDomains.isEmpty else { return }
//        
//        let domains = Array(selectedDomains)
//        
//        // 1. Save locally for immediate UI building in ViewController
//        UserDefaults.standard.set(domains, forKey: "UserSelectedDomains")
//        UserDefaults.standard.set(true, forKey: "kHasCompletedSetup")
//        
//        // 2. Sync to Supabase table: user_preferences
//        syncPreferencesToSupabase(domains: domains)
//        
//        // 3. Transition to Main Screen
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        guard let mainTabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarControllerID") as? UITabBarController else { return }
//        
//        mainTabBarVC.modalPresentationStyle = .fullScreen
//        mainTabBarVC.transitioningDelegate = customTransitionDelegate
//        
//        if let window = self.view.window {
//            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
//                window.rootViewController = mainTabBarVC
//            }, completion: nil)
//        }
//    }
//    
//    private func syncPreferencesToSupabase(domains: [String]) {
//        // Retrieve deviceId established in NewsPersistenceManager
//        let deviceId = UserDefaults.standard.string(forKey: "deviceId") ?? UUID().uuidString
//        
//        let payload = UserPreferencesPayload(user_id: deviceId, selected_domains: domains)
//        
//        // Use generic SupabaseService post to 'user_preferences' table
//        SupabaseService.shared.post(endpoint: "user_preferences", body: payload) { (result: Result<[PreferenceSyncResponse], SupabaseError>) in
//            switch result {
//            case .success:
//                print("✅ Cloud preferences synced.")
//            case .failure(let error):
//                print("❌ Cloud sync failed: \(error.localizedDescription)")
//            }
//        }
//    }
//}
//
//// Model for API response
//struct PreferenceSyncResponse: Codable {}
//
//// Encodable payload for user_preferences
//private struct UserPreferencesPayload: Codable {
//    let user_id: String
//    let selected_domains: [String]
//}
//
//// MARK: - CollectionView Extensions
//extension PreferenceSelection2ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return allDomains.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DomainGridCell", for: indexPath) as! DomainGridCell
//        let domain = allDomains[indexPath.item]
//        cell.configure(name: domain.name, icon: domain.icon, color: domain.color, isSelected: selectedDomains.contains(domain.name))
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let domain = allDomains[indexPath.item].name
//        if selectedDomains.contains(domain) {
//            selectedDomains.remove(domain)
//        } else {
//            selectedDomains.insert(domain)
//        }
//        
//        collectionView.reloadItems(at: [indexPath])
//        let hasSelection = !selectedDomains.isEmpty
//        UIView.animate(withDuration: 0.3) {
//            self.continueButton.alpha = hasSelection ? 1.0 : 0.5
//            self.continueButton.isEnabled = hasSelection
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width = (collectionView.frame.width - 15) / 2
//        return CGSize(width: width, height: 110)
//    }
//}
//
//// MARK: - Domain Grid Cell
//class DomainGridCell: UICollectionViewCell {
//    private let titleLabel: UILabel = {
//        let label = UILabel()
//        label.textColor = .white
//        label.font = .systemFont(ofSize: 18, weight: .bold)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let iconView: UIImageView = {
//        let iv = UIImageView()
//        iv.tintColor = .white.withAlphaComponent(0.3)
//        iv.contentMode = .scaleAspectFit
//        iv.translatesAutoresizingMaskIntoConstraints = false
//        return iv
//    } ()
//
//    private let checkmark: UIImageView = {
//        let iv = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
//        iv.tintColor = .white
//        iv.translatesAutoresizingMaskIntoConstraints = false
//        iv.isHidden = true
//        return iv
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        contentView.layer.cornerRadius = 16
//        contentView.addSubview(iconView)
//        contentView.addSubview(titleLabel)
//        contentView.addSubview(checkmark)
//        
//        NSLayoutConstraint.activate([
//            iconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
//            iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
//            iconView.widthAnchor.constraint(equalToConstant: 50),
//            iconView.heightAnchor.constraint(equalToConstant: 50),
//            
//            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
//            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
//            
//            checkmark.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
//            checkmark.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
//            checkmark.widthAnchor.constraint(equalToConstant: 22),
//            checkmark.heightAnchor.constraint(equalToConstant: 22)
//        ])
//    }
//    
//    func configure(name: String, icon: String, color: UIColor, isSelected: Bool) {
//        titleLabel.text = name
//        iconView.image = UIImage(systemName: icon)
//        contentView.backgroundColor = isSelected ? color : color.withAlphaComponent(0.6)
//        checkmark.isHidden = !isSelected
//        contentView.layer.borderWidth = isSelected ? 3 : 0
//        contentView.layer.borderColor = UIColor.white.cgColor
//    }
//    
//    required init?(coder: NSCoder) { fatalError() }
//}






import UIKit

private class RightToLeftTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? { self }
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { 0.5 }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.view(forKey: .to) else { return }
        let container = transitionContext.containerView
        toView.frame = CGRect(x: container.frame.width, y: 0, width: container.frame.width, height: container.frame.height)
        container.addSubview(toView)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut) {
            toView.frame = container.bounds
        } completion: { transitionContext.completeTransition($0) }
    }
}

private let customTransitionDelegate = RightToLeftTransitionDelegate()

class PreferenceSelection2ViewController: UIViewController {
    
    // MARK: - State
    private var selectedDomains: Set<String> = []
    private let allDomains: [(name: String, icon: String, color: UIColor)] = [
        ("Python",   "terminal",  .systemBlue),   ("Swift",    "swift",     .systemOrange),
        ("React",    "atom",      .systemTeal),   ("AI/ML",    "cpu",       .systemPink),
        ("DevOps",   "cloud",     .systemIndigo), ("Data",     "database",  .systemPurple),
        ("Security", "shield",    .systemRed),    ("Web Dev",  "safari",    .systemGreen),
        ("Android",  "iphone",    .systemMint),   ("Go",       "gear",      .systemCyan),
        ("Rust",     "hammer",    .systemBrown),  ("Node.js",  "leaf",      .systemGreen)
    ]
    
    // MARK: - UI
    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.left",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)), for: .normal)
        btn.tintColor = .label
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    private let pageTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "Customize Your Feed"
        lbl.font = .systemFont(ofSize: 14, weight: .semibold)
        lbl.textColor = .secondaryLabel; lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    private let mainQuestionLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Which topics interest\nyou most?"
        lbl.font = .systemFont(ofSize: 32, weight: .bold)
        lbl.numberOfLines = 0; lbl.textColor = .label; lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    private let subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Select up to 2 domains"
        lbl.font = .systemFont(ofSize: 15, weight: .medium)
        lbl.textColor = .secondaryLabel; lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 15; layout.minimumInteritemSpacing = 15
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.register(DomainGridCell.self, forCellWithReuseIdentifier: "DomainGridCell")
        cv.delegate = self; cv.dataSource = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    private let continueButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Finish Setup", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 0.40, green: 0.55, blue: 0.85, alpha: 1)
        btn.layer.cornerRadius = 28; btn.alpha = 0.5; btn.isEnabled = false
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
    }
    
    private func setupLayout() {
        [backButton, pageTitle, mainQuestionLabel, subtitleLabel, collectionView, continueButton]
            .forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            pageTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            pageTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backButton.centerYAnchor.constraint(equalTo: pageTitle.centerYAnchor),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            mainQuestionLabel.topAnchor.constraint(equalTo: pageTitle.bottomAnchor, constant: 35),
            mainQuestionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            mainQuestionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            subtitleLabel.topAnchor.constraint(equalTo: mainQuestionLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            collectionView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -20),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    @objc private func backTapped() { dismiss(animated: true) }
    
    // MARK: - Finish Setup
    
    @objc private func continueTapped() {
        guard !selectedDomains.isEmpty else { return }
        let domains = Array(selectedDomains)
        
        // 1️⃣  Persist locally so the home screen can read them immediately
        UserDefaults.standard.set(domains, forKey: "UserSelectedDomains")
        UserDefaults.standard.set(true,    forKey: "kHasCompletedSetup")
        
        // 2️⃣  Sync ALL onboarding preferences to Supabase user_profiles
        //     Uses the real auth UUID cached by SignUpViewController — NOT a random device ID
        syncAllOnboardingPreferences(domains: domains)
        
        // 3️⃣  Go to main app
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let mainVC = storyboard.instantiateViewController(
            withIdentifier: "MainTabBarControllerID") as? UITabBarController else { return }
        mainVC.modalPresentationStyle = .fullScreen
        mainVC.transitioningDelegate  = customTransitionDelegate
        if let window = view.window {
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve,
                              animations: { window.rootViewController = mainVC })
        }
    }
    
    /// Combines choices from both onboarding screens and writes them to user_profiles in one PATCH call.
    private func syncAllOnboardingPreferences(domains: [String]) {
        // The real Supabase Auth UUID, cached in SignUpViewController right after auth succeeds
        guard let userId = UserDefaults.standard.string(forKey: "currentUserId")?.lowercased(), !userId.isEmpty else {
            print("⚠️ [Preferences] currentUserId missing — preferences not saved to DB")
            return
        }
        
        let prefs       = UserDefaults.standard
        let readingTime = prefs.string(forKey: "ReadingTime")      ?? "15 news"
        let goal        = prefs.string(forKey: "ProfessionalGoal") ?? "General Knowledge"
        let following   = prefs.stringArray(forKey: "FollowingItems")  ?? []
        let blocked     = prefs.stringArray(forKey: "BlockedTopics")   ?? []
        
        UserProfilePersistenceManager.shared.updateFeedPreferences(
            userId:          userId,
            selectedDomains: domains,
            followingTopics: following,
            blockedTopics:   blocked,
            readingTime:     readingTime,
            goal:            goal
        ) { result in
            switch result {
            case .success:
                print("✅ [Preferences] Onboarding preferences saved to user_profiles for \(userId)")
            case .failure(let error):
                print("⚠️ [Preferences] DB sync failed: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - CollectionView

extension PreferenceSelection2ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { allDomains.count }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DomainGridCell", for: indexPath) as! DomainGridCell
        let d = allDomains[indexPath.item]
        cell.configure(name: d.name, icon: d.icon, color: d.color, isSelected: selectedDomains.contains(d.name))
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let name = allDomains[indexPath.item].name
        if selectedDomains.contains(name) { 
            selectedDomains.remove(name) 
        } else { 
            if selectedDomains.count < 2 {
                selectedDomains.insert(name) 
            } else {
                return
            }
        }
        collectionView.reloadItems(at: [indexPath])
        let has = !selectedDomains.isEmpty
        UIView.animate(withDuration: 0.3) { self.continueButton.alpha = has ? 1 : 0.5; self.continueButton.isEnabled = has }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: (collectionView.frame.width - 15) / 2, height: 110)
    }
}

// MARK: - Domain Grid Cell

class DomainGridCell: UICollectionViewCell {
    private let titleLabel: UILabel = { let l = UILabel(); l.textColor = .white; l.font = .systemFont(ofSize: 18, weight: .bold); l.translatesAutoresizingMaskIntoConstraints = false; return l }()
    private let iconView: UIImageView = { let iv = UIImageView(); iv.tintColor = .white.withAlphaComponent(0.3); iv.contentMode = .scaleAspectFit; iv.translatesAutoresizingMaskIntoConstraints = false; return iv }()
    private let checkmark: UIImageView = { let iv = UIImageView(image: UIImage(systemName: "checkmark.circle.fill")); iv.tintColor = .white; iv.translatesAutoresizingMaskIntoConstraints = false; iv.isHidden = true; return iv }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 16
        [iconView, titleLabel, checkmark].forEach { contentView.addSubview($0) }
        NSLayoutConstraint.activate([
            iconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            iconView.widthAnchor.constraint(equalToConstant: 50), iconView.heightAnchor.constraint(equalToConstant: 50),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            checkmark.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            checkmark.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            checkmark.widthAnchor.constraint(equalToConstant: 22), checkmark.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    func configure(name: String, icon: String, color: UIColor, isSelected: Bool) {
        titleLabel.text = name; iconView.image = UIImage(systemName: icon)
        contentView.backgroundColor   = isSelected ? color : color.withAlphaComponent(0.6)
        checkmark.isHidden            = !isSelected
        contentView.layer.borderWidth = isSelected ? 3 : 0
        contentView.layer.borderColor = UIColor.white.cgColor
    }
    required init?(coder: NSCoder) { fatalError() }
}

// Kept for any legacy references
struct PreferenceSyncResponse: Codable {}

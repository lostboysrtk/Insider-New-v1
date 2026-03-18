import UIKit
internal import Auth

// MARK: - ProfileViewController
class ProfileViewController: UIViewController, UIScrollViewDelegate {

    private let scrollView = UIScrollView()
    private let contentView = UIStackView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    private let headerView = ProfileHeaderView()
    private let statsView = ProfileStatsView()
    

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.delegate = self

        setupNavigationBar()
        setupUI()

        headerView.parentViewController = self
        loadUserData()
        
        // Observe live streak updates
        NotificationCenter.default.addObserver(self, selector: #selector(refreshStats), name: .streakDidUpdate, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Navigation Bar

    private func setupNavigationBar() {
        title = "Profile"
        navigationItem.largeTitleDisplayMode = .never
    }
    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        contentView.axis = .vertical
        contentView.spacing = 16
        contentView.layoutMargins = UIEdgeInsets(top: 10, left: 16, bottom: 40, right: 16)
        contentView.isLayoutMarginsRelativeArrangement = true

        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addArrangedSubview(headerView)
        contentView.addArrangedSubview(statsView)

        // PREFERENCES
        addSectionLabel("PREFERENCES")
        contentView.addArrangedSubview(createGroupedCard(items: [
            ("Personalize Feed", .arrow, #selector(handlePersonalizeTap))
        ]))

        // ACCOUNT
        addSectionLabel("ACCOUNT")
        contentView.addArrangedSubview(createGroupedCard(items: [
            ("Saved Library", .arrow, #selector(handleSavedLibraryTap)),
            ("Account Settings", .arrow, #selector(handleAccountSettingsTap)),
            ("Sign Out", .arrow, #selector(handleSignOutTap))
        ]))

        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }


    // MARK: - Data

    private func loadUserData() {
        Task {
            do {
                if let user = try await SupabaseManager.shared.getCurrentUser() {
                    await MainActor.run {
                        let metadata = user.userMetadata
                        let fullName = metadata["full_name"]?.description.replacingOccurrences(of: "\"", with: "") ?? "User"
                        UserDefaults.standard.set(fullName, forKey: "currentUserFullName")
                        UserDefaults.standard.set(user.id.uuidString.lowercased(), forKey: "currentUserId")
                        let email = user.email ?? ""
                        let bio = metadata["bio"]?.description.replacingOccurrences(of: "\"", with: "")
                        headerView.configure(name: fullName, email: email, bio: bio)
                    }
                    
                    // Load streak data from database
                    let userId = user.id.uuidString.lowercased()
                    UserProfilePersistenceManager.shared.fetchProfile(userId: userId) { [weak self] result in
                        DispatchQueue.main.async {
                            if case .success(let profile?) = result {
                                StreakManager.shared.hydrateFromProfile(profile)
                                self?.statsView.configure(
                                    currentStreak: profile.currentStreak,
                                    recordStreak: profile.recordStreak,
                                    badges: profile.badgesCount,
                                    percentile: profile.badgePercentile
                                )
                            } else {
                                // Use local cache
                                self?.refreshStats()
                            }
                        }
                    }
                }
            } catch {
                print("Error loading user: \(error)")
            }
        }
    }
    
    @objc private func refreshStats() {
        statsView.configure(
            currentStreak: StreakManager.shared.currentStreak,
            recordStreak: StreakManager.shared.recordStreak,
            badges: UserDefaults.standard.integer(forKey: "BadgesCount"),
            percentile: UserDefaults.standard.string(forKey: "BadgePercentile")
        )
    }

    // MARK: - Actions

    @objc private func handlePersonalizeTap() {
        navigationController?.pushViewController(PersonalizeViewController(), animated: true)
    }

    @objc private func handleSavedLibraryTap() {
        navigationController?.pushViewController(InsiderSavedLibraryController(), animated: true)
    }

    @objc private func handleAccountSettingsTap() {
        let vc = AccountSettingsViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    @objc private func handleSignOutTap() {
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
            self?.performSignOut()
        })
        present(alert, animated: true)
    }

    private func performSignOut() {
        loadingIndicator.startAnimating()
        Task {
            do {
                try await SupabaseManager.shared.signOut()
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    let vc = SignInViewController()
                    vc.modalPresentationStyle = .fullScreen
                    self.view.window?.rootViewController = vc
                }
            } catch {
                loadingIndicator.stopAnimating()
            }
        }
    }

    // MARK: - UI Helpers

    enum RowType { case arrow, toggle }

    private func createGroupedCard(items: [(title: String, type: RowType, action: Selector?)]) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 20
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.05
        container.layer.shadowRadius = 8
        container.layer.shadowOffset = CGSize(width: 0, height: 2)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6)
        ])

        for (index, item) in items.enumerated() {
            let row = createRow(title: item.title, type: item.type, action: item.action)
            stack.addArrangedSubview(row)

            if index < items.count - 1 {
                let divider = UIView()
                divider.backgroundColor = .systemGray5
                divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
                stack.addArrangedSubview(divider)
                divider.leadingAnchor.constraint(equalTo: stack.leadingAnchor, constant: 16).isActive = true
            }
        }
        return container
    }

    private func createRow(title: String, type: RowType, action: Selector?) -> UIView {
        let row = UIView()
        row.heightAnchor.constraint(equalToConstant: 54).isActive = true

        if let action = action {
            row.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
        }

        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = (title == "Sign Out") ? .systemRed : .label
        label.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])

        if type == .arrow {
            let arrow = UIImageView(image: UIImage(systemName: "chevron.right"))
            arrow.tintColor = .tertiaryLabel
            arrow.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview(arrow)
            NSLayoutConstraint.activate([
                arrow.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
                arrow.centerYAnchor.constraint(equalTo: row.centerYAnchor)
            ])
        } else {
            let toggle = UISwitch()
            toggle.onTintColor = AppColor.brand
            toggle.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            toggle.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview(toggle)
            NSLayoutConstraint.activate([
                toggle.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
                toggle.centerYAnchor.constraint(equalTo: row.centerYAnchor)
            ])
        }
        return row
    }

    private func addSectionLabel(_ text: String) {
        let label = UILabel()
        label.text = "  " + text
        label.font = .systemFont(ofSize: 10, weight: .black)
        label.textColor = .secondaryLabel
        contentView.addArrangedSubview(label)
    }
}

// MARK: - ProfileHeaderView
class ProfileHeaderView: UIView {
    
    weak var parentViewController: UIViewController?
    
    private let cardContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 28
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.circle.fill")
        iv.tintColor = .systemGray4
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 50
        iv.layer.borderWidth = 4
        iv.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        iv.clipsToBounds = true
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "User"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = AppColor.brand
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let editButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Edit Profile"
        config.baseBackgroundColor = AppColor.brand
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        let button = UIButton(configuration: config)
        return button
    }()
    
    private let bioHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "ABOUT"
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.text = "iOS Developer | Tech Enthusiast | Love building amazing apps"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(name: String?, email: String?, bio: String?) {
        if let name = name, !name.isEmpty { nameLabel.text = name }
        emailLabel.text = email
        if let bio = bio, !bio.isEmpty {
            bioLabel.text = bio
        }
    }
    
    private func setupActions() {
        editButton.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
    }
    
    @objc private func editProfileTapped() {
        let editVC = EditProfileViewController()
        parentViewController?.navigationController?.pushViewController(editVC, animated: true)
    }
    
    private func setupLayout() {
        backgroundColor = .clear
        addSubview(cardContainer)
        cardContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let identityStack = UIStackView(arrangedSubviews: [avatarImageView, nameLabel, emailLabel, editButton])
        identityStack.axis = .vertical
        identityStack.alignment = .center
        identityStack.spacing = 10
        identityStack.setCustomSpacing(15, after: emailLabel)
        
        [identityStack, divider, bioHeaderLabel, bioLabel].forEach {
            cardContainer.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            cardContainer.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            cardContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100),
            
            identityStack.topAnchor.constraint(equalTo: cardContainer.topAnchor, constant: 25),
            identityStack.centerXAnchor.constraint(equalTo: cardContainer.centerXAnchor),
            
            divider.topAnchor.constraint(equalTo: identityStack.bottomAnchor, constant: 25),
            divider.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 30),
            divider.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -30),
            divider.heightAnchor.constraint(equalToConstant: 0.5),
            
            bioHeaderLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 20),
            bioHeaderLabel.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 25),
            
            bioLabel.topAnchor.constraint(equalTo: bioHeaderLabel.bottomAnchor, constant: 8),
            bioLabel.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 25),
            bioLabel.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -25),
            bioLabel.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor, constant: -25)
        ])
    }
}

// MARK: - ProfileStatsView
class ProfileStatsView: UIView {
    
    private let container = UIView()
    
    // Flame icon
    private let flameIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "flame.fill")
        iv.tintColor = .systemOrange
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    // "🔥 Reading Streak" header
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Reading Streak"
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Big streak number
    private let streakValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = .systemFont(ofSize: 48, weight: .heavy)
        label.textColor = AppColor.brand
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // "days" suffix
    private let daysSuffixLabel: UILabel = {
        let label = UILabel()
        label.text = "days"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Record label
    private let recordLabel: UILabel = {
        let label = UILabel()
        label.text = "Best: 0 days"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Motivational message
    private let motivationLabel: UILabel = {
        let label = UILabel()
        label.text = "Scroll through your feed to keep it going!"
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .quaternaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupLayout() {
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 20
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        
        // Header row: flame + "Reading Streak"
        let headerStack = UIStackView(arrangedSubviews: [flameIcon, headerLabel])
        headerStack.axis = .horizontal
        headerStack.spacing = 6
        headerStack.alignment = .center
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Value row: big number + "days"
        let valueStack = UIStackView(arrangedSubviews: [streakValueLabel, daysSuffixLabel])
        valueStack.axis = .horizontal
        valueStack.spacing = 6
        valueStack.alignment = .lastBaseline
        valueStack.translatesAutoresizingMaskIntoConstraints = false
        
        [headerStack, valueStack, recordLabel, motivationLabel].forEach { container.addSubview($0) }
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            flameIcon.widthAnchor.constraint(equalToConstant: 18),
            flameIcon.heightAnchor.constraint(equalToConstant: 18),
            
            headerStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 18),
            headerStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            
            valueStack.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 6),
            valueStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            
            recordLabel.topAnchor.constraint(equalTo: valueStack.bottomAnchor, constant: 4),
            recordLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            
            motivationLabel.topAnchor.constraint(equalTo: recordLabel.bottomAnchor, constant: 8),
            motivationLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            motivationLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            motivationLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -18)
        ])
    }
    
    func configure(currentStreak: Int, recordStreak: Int, badges: Int = 0, percentile: String? = nil) {
        streakValueLabel.text = "\(currentStreak)"
        recordLabel.text = "Best: \(recordStreak) days"
        
        // Dynamic motivation message
        if currentStreak == 0 {
            motivationLabel.text = "Start your streak by reading today's feed!"
            flameIcon.tintColor = .systemGray3
        } else if currentStreak >= 7 {
            motivationLabel.text = "You're on fire! 🔥 Keep the momentum going!"
            flameIcon.tintColor = .systemOrange
        } else {
            motivationLabel.text = "Nice! Scroll through your feed to keep it going!"
            flameIcon.tintColor = .systemOrange
        }
    }
}

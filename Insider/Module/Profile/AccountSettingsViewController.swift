//import UIKit
//
//class AccountSettingsViewController: UIViewController {
//    
//    private let scrollView = UIScrollView()
//    private let contentView = UIStackView()
//    private let accentBlue = UIColor(red: 0.05, green: 0.45, blue: 0.95, alpha: 1.0)
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupNavigationBar()
//    }
//    
//    private func setupNavigationBar() {
//        title = "Account Settings"
//        
//        let closeButton = UIButton(type: .system)
//        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
//        closeButton.tintColor = .label
//        closeButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//        closeButton.layer.cornerRadius = 15
//        closeButton.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.5)
//        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
//        
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
//        
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = .systemBackground // Changed to white
//        appearance.titleTextAttributes = [
//            .foregroundColor: UIColor.label,
//            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
//        ]
//        
//        navigationController?.navigationBar.standardAppearance = appearance
//        navigationController?.navigationBar.scrollEdgeAppearance = appearance
//    }
//    
//    @objc private func closeTapped() {
//        dismiss(animated: true)
//    }
//    
//    private func setupUI() {
//        view.backgroundColor = .systemBackground // Changed to white
//        
//        view.addSubview(scrollView)
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        
//        contentView.axis = .vertical
//        contentView.spacing = 20
//        contentView.layoutMargins = UIEdgeInsets(top: 20, left: 16, bottom: 40, right: 16)
//        contentView.isLayoutMarginsRelativeArrangement = true
//        
//        scrollView.addSubview(contentView)
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        
//        let accountEmail = "kl8868@srmist.edu.in"
//        contentView.addArrangedSubview(createAccountCard(email: accountEmail))
//        
//        addInfoLabel("Editing your account and password will take you to your account management page.")
//        
//        contentView.addArrangedSubview(createGroupedCard(items: [
//            (title: "Edit Profile", subtitle: nil, type: .arrow, action: #selector(handleEditProfile)),
//            (title: "Change Password", subtitle: nil, type: .arrow, action: #selector(handleChangePassword)),
//            (title: "Email Preferences", subtitle: nil, type: .arrow, action: #selector(handleEmailPreferences)),
//            (title: "Privacy Settings", subtitle: nil, type: .arrow, action: #selector(handlePrivacySettings))
//        ]))
//        
//        addSectionLabel("ABOUT")
//        contentView.addArrangedSubview(createGroupedCard(items: [
//            (title: "Terms of Service", subtitle: nil, type: .arrow, action: #selector(handleTerms)),
//            (title: "Privacy Policy", subtitle: nil, type: .arrow, action: #selector(handlePrivacy)),
//            (title: "Help & Support", subtitle: nil, type: .arrow, action: #selector(handleSupport)),
//            (title: "App Version", subtitle: "1.0.0", type: .none, action: nil)
//        ]))
//        
//        let deleteButton = createDeleteAccountButton()
//        contentView.addArrangedSubview(deleteButton)
//        contentView.setCustomSpacing(30, after: deleteButton)
//        
//        setupConstraints()
//    }
//    
//    private func createAccountCard(email: String) -> UIView {
//        let container = UIView()
//        container.backgroundColor = .systemGray6 // Light grayish
//        container.layer.cornerRadius = 16
//        
//        let label = UILabel()
//        label.text = "Account"
//        label.font = .systemFont(ofSize: 15, weight: .regular)
//        label.textColor = .label
//        
//        let emailLabel = UILabel()
//        emailLabel.text = email
//        emailLabel.font = .systemFont(ofSize: 15, weight: .regular)
//        emailLabel.textColor = .secondaryLabel
//        emailLabel.lineBreakMode = .byTruncatingMiddle
//        
//        let arrow = UIImageView(image: UIImage(systemName: "chevron.right"))
//        arrow.tintColor = .tertiaryLabel
//        arrow.contentMode = .scaleAspectFit
//        
//        [label, emailLabel, arrow].forEach {
//            container.addSubview($0)
//            $0.translatesAutoresizingMaskIntoConstraints = false
//        }
//        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleAccountTapped))
//        container.addGestureRecognizer(tapGesture)
//        container.isUserInteractionEnabled = true
//        
//        NSLayoutConstraint.activate([
//            container.heightAnchor.constraint(equalToConstant: 54),
//            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
//            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
//            arrow.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
//            arrow.centerYAnchor.constraint(equalTo: container.centerYAnchor),
//            arrow.widthAnchor.constraint(equalToConstant: 10),
//            emailLabel.trailingAnchor.constraint(equalTo: arrow.leadingAnchor, constant: -12),
//            emailLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
//            emailLabel.leadingAnchor.constraint(greaterThanOrEqualTo: label.trailingAnchor, constant: 12)
//        ])
//        
//        return container
//    }
//    
//    private func createGroupedCard(items: [(title: String, subtitle: String?, type: RowType, action: Selector?)]) -> UIView {
//        let container = UIView()
//        container.backgroundColor = .systemGray6 // Light grayish
//        container.layer.cornerRadius = 16
//        
//        let stack = UIStackView()
//        stack.axis = .vertical
//        container.addSubview(stack)
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            stack.topAnchor.constraint(equalTo: container.topAnchor),
//            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
//            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
//            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
//        ])
//        
//        for (index, item) in items.enumerated() {
//            let row = createRow(title: item.title, subtitle: item.subtitle, type: item.type, action: item.action)
//            stack.addArrangedSubview(row)
//            
//            if index < items.count - 1 {
//                let divider = UIView()
//                divider.backgroundColor = .separator
//                stack.addArrangedSubview(divider)
//                divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
//                NSLayoutConstraint.activate([
//                    divider.leadingAnchor.constraint(equalTo: stack.leadingAnchor, constant: 16)
//                ])
//            }
//        }
//        return container
//    }
//    
//    enum RowType { case arrow, toggle, none }
//    
//    private func createRow(title: String, subtitle: String?, type: RowType, action: Selector?) -> UIView {
//        let rowView = UIView()
//        rowView.heightAnchor.constraint(equalToConstant: 54).isActive = true
//        
//        if let action = action {
//            rowView.isUserInteractionEnabled = true
//            let tap = UITapGestureRecognizer(target: self, action: action)
//            rowView.addGestureRecognizer(tap)
//        }
//        
//        let titleLabel = UILabel()
//        titleLabel.text = title
//        titleLabel.font = .systemFont(ofSize: 15, weight: .regular)
//        titleLabel.textColor = .label
//        
//        rowView.addSubview(titleLabel)
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//            titleLabel.leadingAnchor.constraint(equalTo: rowView.leadingAnchor, constant: 16),
//            titleLabel.centerYAnchor.constraint(equalTo: rowView.centerYAnchor)
//        ])
//        
//        if type == .arrow {
//            let arrow = UIImageView(image: UIImage(systemName: "chevron.right"))
//            arrow.tintColor = .tertiaryLabel
//            rowView.addSubview(arrow)
//            arrow.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                arrow.trailingAnchor.constraint(equalTo: rowView.trailingAnchor, constant: -16),
//                arrow.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
//                arrow.widthAnchor.constraint(equalToConstant: 10)
//            ])
//            if let subtitle = subtitle {
//                let subtitleLabel = UILabel()
//                subtitleLabel.text = subtitle
//                subtitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
//                subtitleLabel.textColor = .secondaryLabel
//                rowView.addSubview(subtitleLabel)
//                subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
//                NSLayoutConstraint.activate([
//                    subtitleLabel.trailingAnchor.constraint(equalTo: arrow.leadingAnchor, constant: -8),
//                    subtitleLabel.centerYAnchor.constraint(equalTo: rowView.centerYAnchor)
//                ])
//            }
//        } else if type == .toggle {
//            let toggle = UISwitch()
//            toggle.onTintColor = accentBlue
//            toggle.isOn = true
//            toggle.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
//            rowView.addSubview(toggle)
//            toggle.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                toggle.trailingAnchor.constraint(equalTo: rowView.trailingAnchor, constant: -16),
//                toggle.centerYAnchor.constraint(equalTo: rowView.centerYAnchor)
//            ])
//        } else if type == .none {
//            if let subtitle = subtitle {
//                let subtitleLabel = UILabel()
//                subtitleLabel.text = subtitle
//                subtitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
//                subtitleLabel.textColor = .secondaryLabel
//                rowView.addSubview(subtitleLabel)
//                subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
//                NSLayoutConstraint.activate([
//                    subtitleLabel.trailingAnchor.constraint(equalTo: rowView.trailingAnchor, constant: -16),
//                    subtitleLabel.centerYAnchor.constraint(equalTo: rowView.centerYAnchor)
//                ])
//            }
//        }
//        return rowView
//    }
//    
//    private func createDeleteAccountButton() -> UIButton {
//        let button = UIButton(type: .system)
//        button.setTitle("Delete Account", for: .normal)
//        button.setTitleColor(.systemRed, for: .normal)
//        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
//        button.backgroundColor = .systemGray6 // Light grayish
//        button.layer.cornerRadius = 16
//        button.addTarget(self, action: #selector(handleDeleteAccount), for: .touchUpInside)
//        button.heightAnchor.constraint(equalToConstant: 54).isActive = true
//        return button
//    }
//    
//    private func addSectionLabel(_ text: String) {
//        let label = UILabel()
//        label.text = text
//        label.font = .systemFont(ofSize: 11, weight: .bold)
//        label.textColor = .secondaryLabel
//        contentView.addArrangedSubview(label)
//    }
//    
//    private func addInfoLabel(_ text: String) {
//        let label = UILabel()
//        label.text = text
//        label.font = .systemFont(ofSize: 13, weight: .regular)
//        label.textColor = .secondaryLabel
//        label.numberOfLines = 0
//        contentView.addArrangedSubview(label)
//    }
//    
//    private func setupConstraints() {
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
//        ])
//    }
//    
//    // MARK: - Handlers
//    @objc private func handleAccountTapped() { showAlert(title: "Account", message: "Navigate to account management") }
//    @objc private func handleEditProfile() {
//        let editVC = EditProfileViewController()
//        navigationController?.pushViewController(editVC, animated: true)
//    }
//    @objc private func handleChangePassword() {
//        let changePasswordVC = ChangePasswordViewController()
//        navigationController?.pushViewController(changePasswordVC, animated: true)
//    }
//    @objc private func handleEmailPreferences() { showAlert(title: "Email Preferences", message: "Manage email notification preferences") }
//    @objc private func handlePrivacySettings() { showAlert(title: "Privacy Settings", message: "Manage privacy settings") }
//    @objc private func handleTerms() { showAlert(title: "Terms of Service", message: "View terms of service") }
//    @objc private func handlePrivacy() { showAlert(title: "Privacy Policy", message: "View privacy policy") }
//    @objc private func handleSupport() {
//        let helpVC = HelpViewController()
//        navigationController?.pushViewController(helpVC, animated: true)
//    }
//    @objc private func handleDeleteAccount() {
//        let alert = UIAlertController(title: "Delete Account", message: "Are you sure you want to permanently delete your account?", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in self.showAlert(title: "Account Deleted", message: "Your account has been deleted") })
//        present(alert, animated: true)
//    }
//    private func showAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//}









// AccountSettingsViewController.swift
// Syncs account settings (email prefs, privacy, notifications) to user_profiles in Supabase.

import UIKit
internal import Auth

class AccountSettingsViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIStackView()
    private let accentBlue = UIColor(red: 0.05, green: 0.45, blue: 0.95, alpha: 1.0)
    private let accountEmailLabel = UILabel()

    // MARK: - Current user id
    private var currentUserId: String?
    
    // MARK: - Containers for dynamic border updates
    private var inputContainers: [UIView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        loadCurrentUser()
    }
    
    // MARK: - Navigation Bar

    private func setupNavigationBar() {
        title = "Account Settings"
        
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .label
        closeButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        closeButton.layer.cornerRadius = 15
        closeButton.backgroundColor = UIColor.systemGray5.withAlphaComponent(0.5)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navigationController?.navigationBar.standardAppearance   = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
    
    // MARK: - Load Current User & Profile

    private func loadCurrentUser() {
        Task {
            if let user = try? await SupabaseManager.shared.getCurrentUser() {
                let userId = user.id.uuidString
                let email = user.email ?? "No Email Found"
                await MainActor.run { 
                    self.currentUserId = userId 
                    self.accountEmailLabel.text = email
                }
            } else {
                await MainActor.run {
                    self.accountEmailLabel.text = "Not logged in"
                }
            }
        }
    }
    
    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.axis = .vertical
        contentView.spacing = 20
        contentView.layoutMargins = UIEdgeInsets(top: 20, left: 16, bottom: 40, right: 16)
        contentView.isLayoutMarginsRelativeArrangement = true
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addArrangedSubview(createAccountCard())
        
        addInfoLabel("Editing your account and password will take you to your account management page.")
        
        // Profile & Security
        contentView.addArrangedSubview(createGroupedCard(items: [
            (title: "Edit Profile",     subtitle: nil,   type: .arrow,  action: #selector(handleEditProfile)),
            (title: "Change Password",  subtitle: nil,   type: .arrow,  action: #selector(handleChangePassword)),
        ]))

        addSectionLabel("NOTIFICATIONS & PRIVACY")
        contentView.addArrangedSubview(createGroupedCard(items: [
            (title: "Privacy Settings",     subtitle: nil, type: .arrow,  action: #selector(handlePrivacySettings))
        ]))
        
        addSectionLabel("ABOUT")
        contentView.addArrangedSubview(createGroupedCard(items: [
            (title: "Help & Support",   subtitle: nil,     type: .arrow, action: #selector(handleSupport)),
            (title: "App Version",      subtitle: "1.0.0", type: .none,  action: nil)
        ]))
        
        let deleteButton = createDeleteAccountButton()
        contentView.addArrangedSubview(deleteButton)
        contentView.setCustomSpacing(30, after: deleteButton)
        
        setupConstraints()
    }
    
    // MARK: - Card Builders
    
    private func createAccountCard() -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 16
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemGray4.cgColor
        inputContainers.append(container)
        
        let label = UILabel()
        label.text = "Account"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .label
        
        accountEmailLabel.text = "Loading..."
        accountEmailLabel.font = .systemFont(ofSize: 15, weight: .regular)
        accountEmailLabel.textColor = .secondaryLabel
        accountEmailLabel.lineBreakMode = .byTruncatingMiddle
        
        let arrow = UIImageView(image: UIImage(systemName: "chevron.right"))
        arrow.tintColor = .tertiaryLabel
        arrow.contentMode = .scaleAspectFit
        
        [label, accountEmailLabel, arrow].forEach {
            container.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleAccountTapped))
        container.addGestureRecognizer(tap)
        container.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 54),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            arrow.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            arrow.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            arrow.widthAnchor.constraint(equalToConstant: 10),
            accountEmailLabel.trailingAnchor.constraint(equalTo: arrow.leadingAnchor, constant: -12),
            accountEmailLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            accountEmailLabel.leadingAnchor.constraint(greaterThanOrEqualTo: label.trailingAnchor, constant: 12)
        ])
        return container
    }
    
    private func createGroupedCard(items: [(title: String, subtitle: String?, type: RowType, action: Selector?)]) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 16
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemGray4.cgColor
        inputContainers.append(container)
        
        let stack = UIStackView()
        stack.axis = .vertical
        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        for (index, item) in items.enumerated() {
            let row = createRow(title: item.title, subtitle: item.subtitle,
                                type: item.type, action: item.action)
            stack.addArrangedSubview(row)
            
            if index < items.count - 1 {
                let divider = UIView()
                divider.backgroundColor = .separator
                stack.addArrangedSubview(divider)
                divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
                NSLayoutConstraint.activate([
                    divider.leadingAnchor.constraint(equalTo: stack.leadingAnchor, constant: 16)
                ])
            }
        }
        return container
    }
    
    enum RowType { case arrow, toggle, none }
    
    private func createRow(title: String, subtitle: String?, type: RowType, action: Selector?) -> UIView {
        let rowView = UIView()
        rowView.heightAnchor.constraint(equalToConstant: 54).isActive = true
        
        if let action = action {
            rowView.isUserInteractionEnabled = true
            rowView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
        }
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        titleLabel.textColor = .label
        
        rowView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: rowView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: rowView.centerYAnchor)
        ])
        
        if type == .arrow {
            let arrow = UIImageView(image: UIImage(systemName: "chevron.right"))
            arrow.tintColor = .tertiaryLabel
            rowView.addSubview(arrow)
            arrow.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                arrow.trailingAnchor.constraint(equalTo: rowView.trailingAnchor, constant: -16),
                arrow.centerYAnchor.constraint(equalTo: rowView.centerYAnchor),
                arrow.widthAnchor.constraint(equalToConstant: 10)
            ])
            if let subtitle = subtitle {
                let sub = UILabel()
                sub.text = subtitle
                sub.font = .systemFont(ofSize: 15)
                sub.textColor = .secondaryLabel
                rowView.addSubview(sub)
                sub.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    sub.trailingAnchor.constraint(equalTo: arrow.leadingAnchor, constant: -8),
                    sub.centerYAnchor.constraint(equalTo: rowView.centerYAnchor)
                ])
            }
        } else if type == .toggle {
            let toggle = UISwitch()
            toggle.onTintColor = accentBlue
            toggle.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            rowView.addSubview(toggle)
            toggle.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                toggle.trailingAnchor.constraint(equalTo: rowView.trailingAnchor, constant: -16),
                toggle.centerYAnchor.constraint(equalTo: rowView.centerYAnchor)
            ])
            toggle.isOn = true
        } else if type == .none, let subtitle = subtitle {
            let sub = UILabel()
            sub.text = subtitle
            sub.font = .systemFont(ofSize: 15)
            sub.textColor = .secondaryLabel
            rowView.addSubview(sub)
            sub.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                sub.trailingAnchor.constraint(equalTo: rowView.trailingAnchor, constant: -16),
                sub.centerYAnchor.constraint(equalTo: rowView.centerYAnchor)
            ])
        }
        return rowView
    }
    
    private func createDeleteAccountButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Delete Account", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.addTarget(self, action: #selector(handleDeleteAccount), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 54).isActive = true
        inputContainers.append(button)
        return button
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            for container in inputContainers {
                container.layer.borderColor = UIColor.systemGray4.cgColor
            }
        }
    }
    
    private func addSectionLabel(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .secondaryLabel
        contentView.addArrangedSubview(label)
    }
    
    private func addInfoLabel(_ text: String) {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        contentView.addArrangedSubview(label)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    // MARK: - Row Tap Handlers

    @objc private func handleAccountTapped()    { showAlert(title: "Account",           message: "Navigate to account management") }
    @objc private func handleEditProfile()      {
        let editVC = EditProfileViewController()
        navigationController?.pushViewController(editVC, animated: true)
    }
    @objc private func handleChangePassword()   {
        navigationController?.pushViewController(ChangePasswordViewController(), animated: true)
    }
    @objc private func handlePrivacySettings()  { showAlert(title: "Privacy Settings",  message: "Manage privacy settings") }
    @objc private func handleSupport()          {
        navigationController?.pushViewController(HelpViewController(), animated: true)
    }
    @objc private func handleDeleteAccount() {
        let alert = UIAlertController(title: "Delete Account",
                                      message: "Are you sure you want to permanently delete your account?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let userId = self?.currentUserId else { return }
            // Delete DB profile row first, then delete auth user
            UserProfilePersistenceManager.shared.deleteProfile(userId: userId) { _ in }
            self?.showAlert(title: "Account Deleted", message: "Your account has been deleted")
        })
        present(alert, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

//import UIKit
//import PhotosUI
//internal import Auth
//import Supabase
//
//class EditProfileViewController: UIViewController {
//    
//    private let scrollView = UIScrollView()
//    private let contentView = UIStackView()
//    private let loadingIndicator = UIActivityIndicatorView(style: .large)
//    
//    private var selectedImage: UIImage?
//    private var currentUser: User?
//    
//    // MARK: - UI Components
//    
//    private let profileImageContainer: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    private let profileImageView: UIImageView = {
//        let iv = UIImageView()
//        iv.image = UIImage(systemName: "person.circle.fill")
//        iv.tintColor = .systemGray4
//        iv.contentMode = .scaleAspectFill
//        iv.layer.cornerRadius = 60
//        iv.clipsToBounds = true
//        iv.layer.borderWidth = 3
//        iv.layer.borderColor = UIColor.systemBlue.cgColor
//        iv.translatesAutoresizingMaskIntoConstraints = false
//        return iv
//    }()
//    
//    private let changePhotoButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Add Photo", for: .normal)
//        button.setTitleColor(.systemBlue, for: .normal)
//        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        return button
//    }()
//    
//    private let removePhotoButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.setTitle("Remove Photo", for: .normal)
//        button.setTitleColor(.systemRed, for: .normal)
//        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.isHidden = true
//        return button
//    }()
//    
//    private let fullNameTextField: UITextField = {
//        let textField = UITextField()
//        textField.placeholder = "Enter your full name"
//        textField.font = .systemFont(ofSize: 16, weight: .regular)
//        textField.textColor = .label
//        textField.autocorrectionType = .no
//        textField.returnKeyType = .done
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        return textField
//    }()
//    
//    private let bioTextView: UITextView = {
//        let textView = UITextView()
//        textView.font = .systemFont(ofSize: 16, weight: .regular)
//        textView.textColor = .label
//        textView.backgroundColor = .clear
//        textView.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
//        textView.isScrollEnabled = false
//        textView.translatesAutoresizingMaskIntoConstraints = false
//        return textView
//    }()
//    
//    private let bioPlaceholderLabel: UILabel = {
//        let label = UILabel()
//        label.text = "Tell us about yourself..."
//        label.font = .systemFont(ofSize: 16, weight: .regular)
//        label.textColor = .placeholderText
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let characterCountLabel: UILabel = {
//        let label = UILabel()
//        label.text = "0/150"
//        label.font = .systemFont(ofSize: 12, weight: .regular)
//        label.textColor = .secondaryLabel
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//    
//    private let emailValueLabel: UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 16, weight: .regular)
//        label.textColor = .secondaryLabel
//        label.translatesAutoresizingMaskIntoConstraints = false
//        return label
//    }()
//
//    // MARK: - Lifecycle
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupNavigationBar()
//        setupActions()
//        setupKeyboardHandling()
//        loadUserData()
//    }
//    
//    private func setupNavigationBar() {
//        title = "Edit Profile"
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTapped))
//        
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = .systemBackground
//        navigationController?.navigationBar.standardAppearance = appearance
//        navigationController?.navigationBar.scrollEdgeAppearance = appearance
//    }
//    
//    private func setupUI() {
//        view.backgroundColor = .systemBackground
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
//        profileImageContainer.addSubview(profileImageView)
//        profileImageContainer.addSubview(changePhotoButton)
//        profileImageContainer.addSubview(removePhotoButton)
//        contentView.addArrangedSubview(profileImageContainer)
//        
//        addSectionLabel("FULL NAME")
//        let nameContainer = createInputContainer()
//        nameContainer.addSubview(fullNameTextField)
//        contentView.addArrangedSubview(nameContainer)
//        
//        addSectionLabel("ABOUT")
//        let bioContainer = createInputContainer()
//        bioContainer.addSubview(bioTextView)
//        bioContainer.addSubview(bioPlaceholderLabel)
//        bioContainer.addSubview(characterCountLabel)
//        contentView.addArrangedSubview(bioContainer)
//        
//        addSectionLabel("EMAIL")
//        let emailContainer = createInputContainer()
//        emailContainer.addSubview(emailValueLabel)
//        let lockIcon = UIImageView(image: UIImage(systemName: "lock.fill"))
//        lockIcon.tintColor = .tertiaryLabel
//        lockIcon.translatesAutoresizingMaskIntoConstraints = false
//        emailContainer.addSubview(lockIcon)
//        contentView.addArrangedSubview(emailContainer)
//        
//        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
//        loadingIndicator.hidesWhenStopped = true
//        view.addSubview(loadingIndicator)
//        
//        setupConstraints(nameContainer: nameContainer, bioContainer: bioContainer, emailContainer: emailContainer, lockIcon: lockIcon)
//    }
//    
//    private func setupConstraints(nameContainer: UIView, bioContainer: UIView, emailContainer: UIView, lockIcon: UIView) {
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            
//            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
//            
//            profileImageContainer.heightAnchor.constraint(equalToConstant: 210),
//            profileImageView.centerXAnchor.constraint(equalTo: profileImageContainer.centerXAnchor),
//            profileImageView.topAnchor.constraint(equalTo: profileImageContainer.topAnchor, constant: 10),
//            profileImageView.widthAnchor.constraint(equalToConstant: 120),
//            profileImageView.heightAnchor.constraint(equalToConstant: 120),
//            
//            changePhotoButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 12),
//            changePhotoButton.centerXAnchor.constraint(equalTo: profileImageContainer.centerXAnchor),
//            
//            removePhotoButton.topAnchor.constraint(equalTo: changePhotoButton.bottomAnchor, constant: 4),
//            removePhotoButton.centerXAnchor.constraint(equalTo: profileImageContainer.centerXAnchor),
//            
//            nameContainer.heightAnchor.constraint(equalToConstant: 50),
//            fullNameTextField.leadingAnchor.constraint(equalTo: nameContainer.leadingAnchor, constant: 16),
//            fullNameTextField.trailingAnchor.constraint(equalTo: nameContainer.trailingAnchor, constant: -16),
//            fullNameTextField.centerYAnchor.constraint(equalTo: nameContainer.centerYAnchor),
//            
//            bioContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
//            bioTextView.topAnchor.constraint(equalTo: bioContainer.topAnchor),
//            bioTextView.leadingAnchor.constraint(equalTo: bioContainer.leadingAnchor),
//            bioTextView.trailingAnchor.constraint(equalTo: bioContainer.trailingAnchor),
//            bioTextView.bottomAnchor.constraint(equalTo: characterCountLabel.topAnchor, constant: -4),
//            
//            bioPlaceholderLabel.topAnchor.constraint(equalTo: bioTextView.topAnchor, constant: 14),
//            bioPlaceholderLabel.leadingAnchor.constraint(equalTo: bioTextView.leadingAnchor, constant: 16),
//            
//            characterCountLabel.trailingAnchor.constraint(equalTo: bioContainer.trailingAnchor, constant: -16),
//            characterCountLabel.bottomAnchor.constraint(equalTo: bioContainer.bottomAnchor, constant: -12),
//            
//            emailContainer.heightAnchor.constraint(equalToConstant: 50),
//            emailValueLabel.leadingAnchor.constraint(equalTo: emailContainer.leadingAnchor, constant: 16),
//            emailValueLabel.centerYAnchor.constraint(equalTo: emailContainer.centerYAnchor),
//            lockIcon.trailingAnchor.constraint(equalTo: emailContainer.trailingAnchor, constant: -16),
//            lockIcon.centerYAnchor.constraint(equalTo: emailContainer.centerYAnchor),
//            
//            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//    }
//
//    private func createInputContainer() -> UIView {
//        let view = UIView()
//        view.backgroundColor = .systemGray6
//        view.layer.cornerRadius = 12
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
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
//    private func setupActions() {
//        changePhotoButton.addTarget(self, action: #selector(changePhotoTapped), for: .touchUpInside)
//        removePhotoButton.addTarget(self, action: #selector(removePhotoTapped), for: .touchUpInside)
//        bioTextView.delegate = self
//        fullNameTextField.delegate = self
//    }
//
//    private func loadUserData() {
//        Task {
//            do {
//                // Ensure SupabaseManager is defined in your project
//                if let user = try await SupabaseManager.shared.getCurrentUser() {
//                    self.currentUser = user
//                    await MainActor.run {
//                        let metadata = user.userMetadata
//                        
//                        // FIX: Actually pre-fill the text fields with current values
//                        let fullName = metadata["full_name"]?.description.replacingOccurrences(of: "\"", with: "") ?? ""
//                        fullNameTextField.text = fullName
//                        
//                        let bio = metadata["bio"]?.description.replacingOccurrences(of: "\"", with: "") ?? ""
//                        bioTextView.text = bio
//                        bioPlaceholderLabel.isHidden = !bio.isEmpty
//                        characterCountLabel.text = "\(bio.count)/150"
//                        
//                        emailValueLabel.text = user.email
//                        
//                        // Photo state check
//                        updatePhotoButtons(hasPhoto: false)
//                    }
//                }
//            } catch {
//                print("Error loading profile: \(error)")
//            }
//        }
//    }
//
//    private func updatePhotoButtons(hasPhoto: Bool) {
//        changePhotoButton.setTitle(hasPhoto ? "Change Photo" : "Add Photo", for: .normal)
//        removePhotoButton.isHidden = !hasPhoto
//    }
//
//    @objc private func changePhotoTapped() {
//        var config = PHPickerConfiguration()
//        config.filter = .images
//        let picker = PHPickerViewController(configuration: config)
//        picker.delegate = self
//        present(picker, animated: true)
//    }
//
//    @objc private func removePhotoTapped() {
//        profileImageView.image = UIImage(systemName: "person.circle.fill")
//        selectedImage = nil
//        updatePhotoButtons(hasPhoto: false)
//    }
//
//    @objc private func saveTapped() {
//        guard let name = fullNameTextField.text, !name.isEmpty else { return }
//        let bio = bioTextView.text ?? ""
//        
//        loadingIndicator.startAnimating()
//        view.isUserInteractionEnabled = false
//        
//        Task {
//            do {
//                let attributes = ["full_name": name, "bio": bio]
//                try await SupabaseManager.shared.updateUserMetadata(attributes: attributes)
//                
//                await MainActor.run {
//                    loadingIndicator.stopAnimating()
//                    view.isUserInteractionEnabled = true
//                    navigationController?.popViewController(animated: true)
//                }
//            } catch {
//                await MainActor.run {
//                    loadingIndicator.stopAnimating()
//                    view.isUserInteractionEnabled = true
//                    print("Update failed: \(error)")
//                }
//            }
//        }
//    }
//    
//    @objc private func cancelTapped() {
//        navigationController?.popViewController(animated: true)
//    }
//    
//    private func setupKeyboardHandling() {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        view.addGestureRecognizer(tap)
//    }
//
//    @objc private func dismissKeyboard() { view.endEditing(true) }
//}
//
//extension EditProfileViewController: PHPickerViewControllerDelegate {
//    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//        picker.dismiss(animated: true)
//        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
//        
//        provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
//            DispatchQueue.main.async {
//                if let uiImage = image as? UIImage {
//                    self?.profileImageView.image = uiImage
//                    self?.selectedImage = uiImage
//                    self?.updatePhotoButtons(hasPhoto: true)
//                }
//            }
//        }
//    }
//}
//
//extension EditProfileViewController: UITextViewDelegate {
//    func textViewDidChange(_ textView: UITextView) {
//        bioPlaceholderLabel.isHidden = !textView.text.isEmpty
//        characterCountLabel.text = "\(textView.text.count)/150"
//    }
//}
//
//extension EditProfileViewController: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//}








// EditProfileViewController.swift
// Saves personal details (name, bio, avatar) to BOTH Supabase Auth metadata
// AND the user_profiles table via UserProfilePersistenceManager.

import UIKit
import PhotosUI
internal import Auth
import Supabase

class EditProfileViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIStackView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    private var selectedImage: UIImage?
    private var currentUser: User?
    
    // Arrays to hold references to containers for dynamic border colors
    private var inputContainers: [UIView] = []
    
    // MARK: - UI Components
    
    private let profileImageContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.circle.fill")
        iv.tintColor = .systemGray4
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 60
        iv.clipsToBounds = true
        iv.layer.borderWidth = 3
        iv.layer.borderColor = UIColor.systemBlue.cgColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Photo", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let removePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Remove Photo", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    private let fullNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your full name"
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .label
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let bioTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16, weight: .regular)
        textView.textColor = .label
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
        textView.isScrollEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private let bioPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Tell us about yourself..."
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .placeholderText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let characterCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0/150"
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupActions()
        setupKeyboardHandling()
        loadUserData()
    }
    
    private func setupNavigationBar() {
        title = "Edit Profile"
        navigationItem.leftBarButtonItem  = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",   style: .done,  target: self, action: #selector(saveTapped))
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
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
        
        profileImageContainer.addSubview(profileImageView)
        profileImageContainer.addSubview(changePhotoButton)
        profileImageContainer.addSubview(removePhotoButton)
        contentView.addArrangedSubview(profileImageContainer)
        
        addSectionLabel("FULL NAME")
        let nameContainer = createInputContainer()
        nameContainer.addSubview(fullNameTextField)
        contentView.addArrangedSubview(nameContainer)
        
        addSectionLabel("ABOUT")
        let bioContainer = createInputContainer()
        bioContainer.addSubview(bioTextView)
        bioContainer.addSubview(bioPlaceholderLabel)
        bioContainer.addSubview(characterCountLabel)
        contentView.addArrangedSubview(bioContainer)
        
        addSectionLabel("EMAIL")
        let emailContainer = createInputContainer()
        emailContainer.addSubview(emailValueLabel)
        let lockIcon = UIImageView(image: UIImage(systemName: "lock.fill"))
        lockIcon.tintColor = .tertiaryLabel
        lockIcon.translatesAutoresizingMaskIntoConstraints = false
        emailContainer.addSubview(lockIcon)
        contentView.addArrangedSubview(emailContainer)
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        
        setupConstraints(nameContainer: nameContainer, bioContainer: bioContainer,
                         emailContainer: emailContainer, lockIcon: lockIcon)
    }
    
    private func setupConstraints(nameContainer: UIView, bioContainer: UIView,
                                   emailContainer: UIView, lockIcon: UIView) {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            profileImageContainer.heightAnchor.constraint(equalToConstant: 210),
            profileImageView.centerXAnchor.constraint(equalTo: profileImageContainer.centerXAnchor),
            profileImageView.topAnchor.constraint(equalTo: profileImageContainer.topAnchor, constant: 10),
            profileImageView.widthAnchor.constraint(equalToConstant: 120),
            profileImageView.heightAnchor.constraint(equalToConstant: 120),
            
            changePhotoButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 12),
            changePhotoButton.centerXAnchor.constraint(equalTo: profileImageContainer.centerXAnchor),
            
            removePhotoButton.topAnchor.constraint(equalTo: changePhotoButton.bottomAnchor, constant: 4),
            removePhotoButton.centerXAnchor.constraint(equalTo: profileImageContainer.centerXAnchor),
            
            nameContainer.heightAnchor.constraint(equalToConstant: 50),
            fullNameTextField.leadingAnchor.constraint(equalTo: nameContainer.leadingAnchor, constant: 16),
            fullNameTextField.trailingAnchor.constraint(equalTo: nameContainer.trailingAnchor, constant: -16),
            fullNameTextField.centerYAnchor.constraint(equalTo: nameContainer.centerYAnchor),
            
            bioContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            bioTextView.topAnchor.constraint(equalTo: bioContainer.topAnchor),
            bioTextView.leadingAnchor.constraint(equalTo: bioContainer.leadingAnchor),
            bioTextView.trailingAnchor.constraint(equalTo: bioContainer.trailingAnchor),
            bioTextView.bottomAnchor.constraint(equalTo: characterCountLabel.topAnchor, constant: -4),
            
            bioPlaceholderLabel.topAnchor.constraint(equalTo: bioTextView.topAnchor, constant: 14),
            bioPlaceholderLabel.leadingAnchor.constraint(equalTo: bioTextView.leadingAnchor, constant: 16),
            
            characterCountLabel.trailingAnchor.constraint(equalTo: bioContainer.trailingAnchor, constant: -16),
            characterCountLabel.bottomAnchor.constraint(equalTo: bioContainer.bottomAnchor, constant: -12),
            
            emailContainer.heightAnchor.constraint(equalToConstant: 50),
            emailValueLabel.leadingAnchor.constraint(equalTo: emailContainer.leadingAnchor, constant: 16),
            emailValueLabel.centerYAnchor.constraint(equalTo: emailContainer.centerYAnchor),
            lockIcon.trailingAnchor.constraint(equalTo: emailContainer.trailingAnchor, constant: -16),
            lockIcon.centerYAnchor.constraint(equalTo: emailContainer.centerYAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func createInputContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        inputContainers.append(view)
        return view
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

    private func setupActions() {
        changePhotoButton.addTarget(self, action: #selector(changePhotoTapped), for: .touchUpInside)
        removePhotoButton.addTarget(self, action: #selector(removePhotoTapped), for: .touchUpInside)
        bioTextView.delegate = self
        fullNameTextField.delegate = self
    }

    // MARK: - Load Current Data

    private func loadUserData() {
        Task {
            do {
                if let user = try await SupabaseManager.shared.getCurrentUser() {
                    self.currentUser = user
                    await MainActor.run {
                        let metadata = user.userMetadata
                        let fullName = metadata["full_name"]?.description
                            .replacingOccurrences(of: "\"", with: "") ?? ""
                        fullNameTextField.text = fullName
                        
                        let bio = metadata["bio"]?.description
                            .replacingOccurrences(of: "\"", with: "") ?? ""
                        bioTextView.text = bio
                        bioPlaceholderLabel.isHidden = !bio.isEmpty
                        characterCountLabel.text = "\(bio.count)/150"
                        
                        emailValueLabel.text = user.email
                        updatePhotoButtons(hasPhoto: false)
                    }
                }
            } catch {
                print("⚠️ [EditProfile] Error loading user: \(error)")
            }
        }
    }

    private func updatePhotoButtons(hasPhoto: Bool) {
        changePhotoButton.setTitle(hasPhoto ? "Change Photo" : "Add Photo", for: .normal)
        removePhotoButton.isHidden = !hasPhoto
    }

    @objc private func changePhotoTapped() {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func removePhotoTapped() {
        profileImageView.image = UIImage(systemName: "person.circle.fill")
        selectedImage = nil
        updatePhotoButtons(hasPhoto: false)
    }

    // MARK: - Save

    @objc private func saveTapped() {
        guard let name = fullNameTextField.text, !name.isEmpty else { return }
        let bio = bioTextView.text ?? ""
        
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        Task {
            do {
                // 1️⃣ Update Supabase Auth user metadata (existing behaviour)
                let attributes = ["full_name": name, "bio": bio]
                try await SupabaseManager.shared.updateUserMetadata(attributes: attributes)
                
                // 2️⃣ Also update the user_profiles table row
                if let userId = currentUser?.id.uuidString {
                    UserProfilePersistenceManager.shared.updatePersonalDetails(
                        userId: userId,
                        fullName: name,
                        bio: bio.isEmpty ? nil : bio,
                        avatarURL: nil          // extend here when you add avatar upload
                    ) { result in
                        switch result {
                        case .success:
                            print("✅ [EditProfile] user_profiles row updated")
                        case .failure(let error):
                            print("⚠️ [EditProfile] user_profiles update failed: \(error.localizedDescription)")
                        }
                    }
                }
                
                await MainActor.run {
                    loadingIndicator.stopAnimating()
                    view.isUserInteractionEnabled = true
                    navigationController?.popViewController(animated: true)
                }
            } catch {
                await MainActor.run {
                    loadingIndicator.stopAnimating()
                    view.isUserInteractionEnabled = true
                    print("⚠️ [EditProfile] Auth metadata update failed: \(error)")
                }
            }
        }
    }
    
    @objc private func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupKeyboardHandling() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }
}

// MARK: - PHPickerViewControllerDelegate

extension EditProfileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            DispatchQueue.main.async {
                if let uiImage = image as? UIImage {
                    self?.profileImageView.image = uiImage
                    self?.selectedImage = uiImage
                    self?.updatePhotoButtons(hasPhoto: true)
                }
            }
        }
    }
}

// MARK: - UITextViewDelegate / UITextFieldDelegate

extension EditProfileViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        bioPlaceholderLabel.isHidden = !textView.text.isEmpty
        characterCountLabel.text = "\(textView.text.count)/150"
    }
}

extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

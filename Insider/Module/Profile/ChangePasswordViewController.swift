import UIKit
internal import Auth

class ChangePasswordViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIStackView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - UI Components
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter your current password and choose a new one. Your password must be at least 6 characters long."
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let currentPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "CURRENT PASSWORD"
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let currentPasswordContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6 // Light grayish
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let currentPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter current password"
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .label
        textField.isSecureTextEntry = true
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .next
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let currentPasswordToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let newPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "NEW PASSWORD"
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let newPasswordContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6 // Light grayish
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let newPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter new password"
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .label
        textField.isSecureTextEntry = true
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .next
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let newPasswordToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let passwordStrengthView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let strengthBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let strengthFill: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var strengthFillWidthConstraint: NSLayoutConstraint?
    
    private let strengthLabel: UILabel = {
        let label = UILabel()
        label.text = "Password strength: Weak"
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let confirmPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "CONFIRM NEW PASSWORD"
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let confirmPasswordContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6 // Light grayish
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Re-enter new password"
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .label
        textField.isSecureTextEntry = true
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .done
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let confirmPasswordToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        button.tintColor = .systemBlue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let requirementsLabel: UILabel = {
        let label = UILabel()
        label.text = "Password Requirements:"
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let requirementsList: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let requirements = """
        • At least 6 characters
        • Mix of uppercase and lowercase letters (recommended)
        • Include numbers (recommended)
        • Include special characters (recommended)
        """
        
        label.attributedText = NSAttributedString(
            string: requirements,
            attributes: [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: UIColor.secondaryLabel
            ]
        )
        
        return label
    }()
    
    private let changePasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Password", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupActions()
        setupKeyboardHandling()
    }
    
    // MARK: - Setup
    
    private func setupNavigationBar() {
        title = "Change Password"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground // Changed to white
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .systemBlue
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground // Changed to white
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.axis = .vertical
        contentView.spacing = 20
        contentView.layoutMargins = UIEdgeInsets(top: 20, left: 16, bottom: 40, right: 16)
        contentView.isLayoutMarginsRelativeArrangement = true
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addArrangedSubview(instructionLabel)
        
        contentView.addArrangedSubview(currentPasswordLabel)
        currentPasswordContainer.addSubview(currentPasswordTextField)
        currentPasswordContainer.addSubview(currentPasswordToggleButton)
        contentView.addArrangedSubview(currentPasswordContainer)
        
        contentView.addArrangedSubview(newPasswordLabel)
        newPasswordContainer.addSubview(newPasswordTextField)
        newPasswordContainer.addSubview(newPasswordToggleButton)
        contentView.addArrangedSubview(newPasswordContainer)
        
        passwordStrengthView.addSubview(strengthBar)
        strengthBar.addSubview(strengthFill)
        passwordStrengthView.addSubview(strengthLabel)
        contentView.addArrangedSubview(passwordStrengthView)
        
        contentView.addArrangedSubview(confirmPasswordLabel)
        confirmPasswordContainer.addSubview(confirmPasswordTextField)
        confirmPasswordContainer.addSubview(confirmPasswordToggleButton)
        contentView.addArrangedSubview(confirmPasswordContainer)
        
        contentView.addArrangedSubview(requirementsLabel)
        contentView.addArrangedSubview(requirementsList)
        
        contentView.addArrangedSubview(changePasswordButton)
        
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        strengthFillWidthConstraint = strengthFill.widthAnchor.constraint(equalToConstant: 0)
        strengthFillWidthConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            currentPasswordContainer.heightAnchor.constraint(equalToConstant: 50),
            currentPasswordTextField.leadingAnchor.constraint(equalTo: currentPasswordContainer.leadingAnchor, constant: 16),
            currentPasswordTextField.trailingAnchor.constraint(equalTo: currentPasswordToggleButton.leadingAnchor, constant: -8),
            currentPasswordTextField.centerYAnchor.constraint(equalTo: currentPasswordContainer.centerYAnchor),
            currentPasswordToggleButton.trailingAnchor.constraint(equalTo: currentPasswordContainer.trailingAnchor, constant: -16),
            currentPasswordToggleButton.centerYAnchor.constraint(equalTo: currentPasswordContainer.centerYAnchor),
            currentPasswordToggleButton.widthAnchor.constraint(equalToConstant: 24),
            
            newPasswordContainer.heightAnchor.constraint(equalToConstant: 50),
            newPasswordTextField.leadingAnchor.constraint(equalTo: newPasswordContainer.leadingAnchor, constant: 16),
            newPasswordTextField.trailingAnchor.constraint(equalTo: newPasswordToggleButton.leadingAnchor, constant: -8),
            newPasswordTextField.centerYAnchor.constraint(equalTo: newPasswordContainer.centerYAnchor),
            newPasswordToggleButton.trailingAnchor.constraint(equalTo: newPasswordContainer.trailingAnchor, constant: -16),
            newPasswordToggleButton.centerYAnchor.constraint(equalTo: newPasswordContainer.centerYAnchor),
            newPasswordToggleButton.widthAnchor.constraint(equalToConstant: 24),
            
            passwordStrengthView.heightAnchor.constraint(equalToConstant: 40),
            strengthBar.topAnchor.constraint(equalTo: passwordStrengthView.topAnchor),
            strengthBar.leadingAnchor.constraint(equalTo: passwordStrengthView.leadingAnchor),
            strengthBar.trailingAnchor.constraint(equalTo: passwordStrengthView.trailingAnchor),
            strengthBar.heightAnchor.constraint(equalToConstant: 4),
            strengthFill.topAnchor.constraint(equalTo: strengthBar.topAnchor),
            strengthFill.leadingAnchor.constraint(equalTo: strengthBar.leadingAnchor),
            strengthFill.heightAnchor.constraint(equalToConstant: 4),
            strengthLabel.topAnchor.constraint(equalTo: strengthBar.bottomAnchor, constant: 8),
            strengthLabel.leadingAnchor.constraint(equalTo: passwordStrengthView.leadingAnchor),
            
            confirmPasswordContainer.heightAnchor.constraint(equalToConstant: 50),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: confirmPasswordContainer.leadingAnchor, constant: 16),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: confirmPasswordToggleButton.leadingAnchor, constant: -8),
            confirmPasswordTextField.centerYAnchor.constraint(equalTo: confirmPasswordContainer.centerYAnchor),
            confirmPasswordToggleButton.trailingAnchor.constraint(equalTo: confirmPasswordContainer.trailingAnchor, constant: -16),
            confirmPasswordToggleButton.centerYAnchor.constraint(equalTo: confirmPasswordContainer.centerYAnchor),
            confirmPasswordToggleButton.widthAnchor.constraint(equalToConstant: 24),
            
            changePasswordButton.heightAnchor.constraint(equalToConstant: 50),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        currentPasswordToggleButton.addTarget(self, action: #selector(toggleCurrentPassword), for: .touchUpInside)
        newPasswordToggleButton.addTarget(self, action: #selector(toggleNewPassword), for: .touchUpInside)
        confirmPasswordToggleButton.addTarget(self, action: #selector(toggleConfirmPassword), for: .touchUpInside)
        changePasswordButton.addTarget(self, action: #selector(changePasswordTapped), for: .touchUpInside)
        newPasswordTextField.addTarget(self, action: #selector(passwordTextChanged), for: .editingChanged)
        
        currentPasswordTextField.delegate = self
        newPasswordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    
    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView.contentInset.bottom = keyboardFrame.height
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardFrame.height
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
    
    @objc private func toggleCurrentPassword() {
        currentPasswordTextField.isSecureTextEntry.toggle()
        let iconName = currentPasswordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        currentPasswordToggleButton.setImage(UIImage(systemName: iconName), for: .normal)
    }
    
    @objc private func toggleNewPassword() {
        newPasswordTextField.isSecureTextEntry.toggle()
        let iconName = newPasswordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        newPasswordToggleButton.setImage(UIImage(systemName: iconName), for: .normal)
    }
    
    @objc private func toggleConfirmPassword() {
        confirmPasswordTextField.isSecureTextEntry.toggle()
        let iconName = confirmPasswordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        confirmPasswordToggleButton.setImage(UIImage(systemName: iconName), for: .normal)
    }
    
    @objc private func passwordTextChanged() {
        updatePasswordStrength()
    }
    
    @objc private func changePasswordTapped() {
        guard validateInputs() else { return }
        
        let currentPassword = currentPasswordTextField.text ?? ""
        let newPassword = newPasswordTextField.text ?? ""
        
        loadingIndicator.startAnimating()
        changePasswordButton.isEnabled = false
        view.isUserInteractionEnabled = false
        
        Task {
            do {
                guard let user = try await SupabaseManager.shared.getCurrentUser(),
                      let email = user.email else {
                    throw NSError(domain: "ChangePassword", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to get user email"])
                }
                
                do {
                    _ = try await SupabaseManager.shared.signIn(email: email, password: currentPassword)
                } catch {
                    await MainActor.run {
                        loadingIndicator.stopAnimating()
                        changePasswordButton.isEnabled = true
                        view.isUserInteractionEnabled = true
                        showAlert(title: "Error", message: "Current password is incorrect")
                    }
                    return
                }
                
                try await SupabaseManager.shared.updatePassword(newPassword: newPassword)
                
                await MainActor.run {
                    loadingIndicator.stopAnimating()
                    changePasswordButton.isEnabled = true
                    view.isUserInteractionEnabled = true
                    
                    let alert = UIAlertController(title: "Success", message: "Your password has been changed successfully", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                        self?.navigationController?.popViewController(animated: true)
                    })
                    present(alert, animated: true)
                }
            } catch {
                await MainActor.run {
                    loadingIndicator.stopAnimating()
                    changePasswordButton.isEnabled = true
                    view.isUserInteractionEnabled = true
                    showAlert(title: "Error", message: "Failed to change password. Please try again.")
                }
            }
        }
    }
    
    private func updatePasswordStrength() {
        let password = newPasswordTextField.text ?? ""
        let strength = calculatePasswordStrength(password)
        let maxWidth = strengthBar.frame.width
        let fillWidth = maxWidth * CGFloat(strength.percentage)
        
        UIView.animate(withDuration: 0.3) {
            self.strengthFillWidthConstraint?.constant = fillWidth
            self.strengthFill.backgroundColor = strength.color
            self.strengthLabel.text = "Password strength: \(strength.text)"
            self.strengthLabel.textColor = strength.color
            self.view.layoutIfNeeded()
        }
    }
    
    private func calculatePasswordStrength(_ password: String) -> (percentage: Double, color: UIColor, text: String) {
        if password.isEmpty { return (0.0, .systemGray, "") }
        var score = 0
        if password.count >= 6 { score += 1 }
        if password.count >= 8 { score += 1 }
        if password.count >= 12 { score += 1 }
        if password.range(of: "[a-z]", options: .regularExpression) != nil { score += 1 }
        if password.range(of: "[A-Z]", options: .regularExpression) != nil { score += 1 }
        if password.range(of: "[0-9]", options: .regularExpression) != nil { score += 1 }
        if password.range(of: "[^a-zA-Z0-9]", options: .regularExpression) != nil { score += 1 }
        
        switch score {
        case 0...2: return (0.25, .systemRed, "Weak")
        case 3...4: return (0.5, .systemOrange, "Fair")
        case 5...6: return (0.75, .systemYellow, "Good")
        default: return (1.0, .systemGreen, "Strong")
        }
    }
    
    private func validateInputs() -> Bool {
        let currentPassword = currentPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let newPassword = newPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let confirmPassword = confirmPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if currentPassword.isEmpty { showAlert(title: "Error", message: "Please enter your current password"); return false }
        if newPassword.isEmpty { showAlert(title: "Error", message: "Please enter a new password"); return false }
        if newPassword.count < 6 { showAlert(title: "Error", message: "New password must be at least 6 characters long"); return false }
        if currentPassword == newPassword { showAlert(title: "Error", message: "New password must be different from current password"); return false }
        if newPassword != confirmPassword { showAlert(title: "Error", message: "Passwords do not match"); return false }
        return true
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    deinit { NotificationCenter.default.removeObserver(self) }
}

extension ChangePasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case currentPasswordTextField: newPasswordTextField.becomeFirstResponder()
        case newPasswordTextField: confirmPasswordTextField.becomeFirstResponder()
        case confirmPasswordTextField: textField.resignFirstResponder(); changePasswordTapped()
        default: break
        }
        return true
    }
}

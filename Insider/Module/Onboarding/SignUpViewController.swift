//
//
//import UIKit
//
//class SignUpViewController: UIViewController {
//    
//    // MARK: - UI Components
//    private let scrollView = UIScrollView()
//    private let contentView = UIView()
//    private let loadingIndicator = UIActivityIndicatorView(style: .large)
//    
//    // 1. Gradient Layer (The Base)
//    private let gradientLayer: CAGradientLayer = {
//        let gradient = CAGradientLayer()
//        gradient.colors = [
//            UIColor(red: 0.93, green: 0.95, blue: 0.98, alpha: 1).cgColor,
//            UIColor(red: 0.88, green: 0.92, blue: 0.97, alpha: 1).cgColor,
//            UIColor(red: 0.85, green: 0.90, blue: 0.96, alpha: 1).cgColor
//        ]
//        gradient.locations = [0.0, 0.5, 1.0]
//        return gradient
//    }()
//    
//    // 2. Static Background Elements
//    private func setupStaticBubbles() {
//        let bubble1 = UIView(frame: CGRect(x: view.frame.width - 150, y: -50, width: 300, height: 300))
//        bubble1.backgroundColor = UIColor(red: 0.40, green: 0.55, blue: 0.85, alpha: 0.08)
//        bubble1.layer.cornerRadius = 150
//        view.insertSubview(bubble1, belowSubview: scrollView)
//        
//        let bubble2 = UIView(frame: CGRect(x: -60, y: view.frame.height * 0.4, width: 180, height: 180))
//        bubble2.backgroundColor = UIColor(red: 0.40, green: 0.55, blue: 0.85, alpha: 0.06)
//        bubble2.layer.cornerRadius = 90
//        view.insertSubview(bubble2, belowSubview: scrollView)
//        
//        let bubble3 = UIView(frame: CGRect(x: view.frame.width * 0.6, y: view.frame.height * 0.85, width: 250, height: 250))
//        bubble3.backgroundColor = UIColor(red: 0.20, green: 0.35, blue: 0.65, alpha: 0.05)
//        bubble3.layer.cornerRadius = 125
//        view.insertSubview(bubble3, belowSubview: scrollView)
//    }
//    
//    // Header
//    private let welcomeLabel: UILabel = {
//        let lbl = UILabel()
//        lbl.text = "Welcome"
//        lbl.font = UIFont.systemFont(ofSize: 42, weight: .bold)
//        lbl.textColor = UIColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1)
//        lbl.translatesAutoresizingMaskIntoConstraints = false
//        return lbl
//    }()
//    
//    private let createAccountLabel: UILabel = {
//        let lbl = UILabel()
//        lbl.text = "Create an account"
//        lbl.font = UIFont.systemFont(ofSize: 18, weight: .regular)
//        lbl.textColor = UIColor(red: 0.25, green: 0.25, blue: 0.28, alpha: 1)
//        lbl.translatesAutoresizingMaskIntoConstraints = false
//        return lbl
//    }()
//    
//    private let journeyLabel: UILabel = {
//        let lbl = UILabel()
//        lbl.text = "Start your tech journey with Insider"
//        lbl.font = UIFont.systemFont(ofSize: 14, weight: .medium)
//        lbl.textColor = UIColor(red: 0.40, green: 0.55, blue: 0.85, alpha: 1)
//        lbl.translatesAutoresizingMaskIntoConstraints = false
//        return lbl
//    }()
//    
//    // MARK: - Input Fields (Glass Style)
//    private func createTextField(_ placeholder: String, icon: String) -> UIView {
//        let container = UIView()
//        container.backgroundColor = UIColor.white.withAlphaComponent(0.75)
//        container.layer.cornerRadius = 18
//        container.layer.borderColor = UIColor.white.withAlphaComponent(0.9).cgColor
//        container.layer.borderWidth = 1.5
//        container.translatesAutoresizingMaskIntoConstraints = false
//        
//        container.layer.shadowColor = UIColor(red: 0.12, green: 0.25, blue: 0.55, alpha: 0.08).cgColor
//        container.layer.shadowOffset = CGSize(width: 0, height: 4)
//        container.layer.shadowRadius = 12
//        container.layer.shadowOpacity = 1
//        
//        let iconView = UIImageView(image: UIImage(systemName: icon))
//        iconView.tintColor = UIColor(red: 0.40, green: 0.55, blue: 0.85, alpha: 1)
//        iconView.translatesAutoresizingMaskIntoConstraints = false
//        iconView.contentMode = .scaleAspectFit
//        
//        let textField = UITextField()
//        textField.textColor = UIColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1)
//        textField.font = UIFont.systemFont(ofSize: 16, weight: .medium)
//        textField.attributedPlaceholder = NSAttributedString(
//            string: placeholder,
//            attributes: [.foregroundColor: UIColor(red: 0.40, green: 0.40, blue: 0.45, alpha: 1)]
//        )
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        textField.autocorrectionType = .no
//        textField.returnKeyType = .done
//        textField.autocapitalizationType = .none
//        
//        container.addSubview(iconView)
//        container.addSubview(textField)
//        
//        NSLayoutConstraint.activate([
//            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
//            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
//            iconView.widthAnchor.constraint(equalToConstant: 22),
//            iconView.heightAnchor.constraint(equalToConstant: 22),
//            
//            textField.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 14),
//            textField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
//            textField.centerYAnchor.constraint(equalTo: container.centerYAnchor),
//            textField.heightAnchor.constraint(equalTo: container.heightAnchor)
//        ])
//        
//        return container
//    }
//    
//    private lazy var fullNameContainer = createTextField("Full Name", icon: "person.fill")
//    private lazy var emailContainer = createTextField("Email Address", icon: "envelope.fill")
//    
//    private lazy var passwordContainer: UIView = {
//        let container = createTextField("Password", icon: "lock.fill")
//        if let textField = container.subviews.compactMap({ $0 as? UITextField }).first {
//            textField.isSecureTextEntry = true
//        }
//        return container
//    }()
//    
//    private lazy var confirmPasswordContainer: UIView = {
//        let container = createTextField("Confirm Password", icon: "lock.shield.fill")
//        if let textField = container.subviews.compactMap({ $0 as? UITextField }).first {
//            textField.isSecureTextEntry = true
//        }
//        return container
//    }()
//    
//    private let togglePasswordButton: UIButton = {
//        let btn = UIButton(type: .system)
//        btn.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
//        btn.tintColor = UIColor(red: 0.40, green: 0.55, blue: 0.85, alpha: 1)
//        btn.translatesAutoresizingMaskIntoConstraints = false
//        return btn
//    }()
//    
//    private let toggleConfirmPasswordButton: UIButton = {
//        let btn = UIButton(type: .system)
//        btn.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
//        btn.tintColor = UIColor(red: 0.40, green: 0.55, blue: 0.85, alpha: 1)
//        btn.translatesAutoresizingMaskIntoConstraints = false
//        return btn
//    }()
//    
//    // Sign Up Button
//    private let signUpButton: UIButton = {
//        let btn = UIButton(type: .system)
//        btn.setTitle("Sign Up", for: .normal)
//        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
//        btn.setTitleColor(.white, for: .normal)
//        btn.backgroundColor = UIColor(red: 0.40, green: 0.55, blue: 0.85, alpha: 1)
//        btn.layer.cornerRadius = 18
//        btn.translatesAutoresizingMaskIntoConstraints = false
//        
//        btn.layer.shadowColor = UIColor(red: 0.40, green: 0.55, blue: 0.85, alpha: 0.4).cgColor
//        btn.layer.shadowOffset = CGSize(width: 0, height: 8)
//        btn.layer.shadowRadius = 16
//        btn.layer.shadowOpacity = 1
//        return btn
//    }()
//    
//    // Divider
//    private let dividerView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        
//        let leftLine = UIView()
//        leftLine.backgroundColor = UIColor(red: 0.70, green: 0.70, blue: 0.75, alpha: 1)
//        leftLine.translatesAutoresizingMaskIntoConstraints = false
//        
//        let rightLine = UIView()
//        rightLine.backgroundColor = UIColor(red: 0.70, green: 0.70, blue: 0.75, alpha: 1)
//        rightLine.translatesAutoresizingMaskIntoConstraints = false
//        
//        let label = UILabel()
//        label.text = "or continue with"
//        label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
//        label.textColor = UIColor(red: 0.40, green: 0.40, blue: 0.45, alpha: 1)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        
//        view.addSubview(leftLine)
//        view.addSubview(rightLine)
//        view.addSubview(label)
//        
//        NSLayoutConstraint.activate([
//            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            
//            leftLine.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -12),
//            leftLine.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            leftLine.heightAnchor.constraint(equalToConstant: 1),
//            leftLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            
//            rightLine.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 12),
//            rightLine.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            rightLine.heightAnchor.constraint(equalToConstant: 1),
//            rightLine.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        ])
//        
//        return view
//    }()
//    
//    // Social Buttons
//    private let appleButton: UIButton = {
//        let btn = UIButton(type: .system)
//        btn.backgroundColor = UIColor.white.withAlphaComponent(0.75)
//        btn.layer.cornerRadius = 16
//        btn.layer.borderWidth = 1.5
//        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.9).cgColor
//        btn.translatesAutoresizingMaskIntoConstraints = false
//        
//        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
//        btn.setImage(UIImage(systemName: "apple.logo", withConfiguration: config), for: .normal)
//        btn.tintColor = UIColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1)
//        return btn
//    }()
//    
//    private let googleButton: UIButton = {
//        let btn = UIButton(type: .system)
//        btn.backgroundColor = UIColor.white.withAlphaComponent(0.75)
//        btn.layer.cornerRadius = 16
//        btn.layer.borderWidth = 1.5
//        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.9).cgColor
//        btn.translatesAutoresizingMaskIntoConstraints = false
//        
//        let label = UILabel()
//        label.text = "G"
//        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
//        label.textColor = UIColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        btn.addSubview(label)
//        
//        NSLayoutConstraint.activate([
//            label.centerXAnchor.constraint(equalTo: btn.centerXAnchor),
//            label.centerYAnchor.constraint(equalTo: btn.centerYAnchor)
//        ])
//        return btn
//    }()
//    
//    // Bottom Section
//    private let bottomStackView: UIStackView = {
//        let stack = UIStackView()
//        stack.axis = .horizontal
//        stack.spacing = 6
//        stack.alignment = .center
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        return stack
//    }()
//    
//    private let bottomLabel: UILabel = {
//        let lbl = UILabel()
//        lbl.text = "Already have an account?"
//        lbl.font = UIFont.systemFont(ofSize: 14, weight: .regular)
//        lbl.textColor = UIColor(red: 0.40, green: 0.40, blue: 0.45, alpha: 1)
//        return lbl
//    }()
//    
//    private let signInButton: UIButton = {
//        let btn = UIButton(type: .system)
//        btn.setTitle("Sign In", for: .normal)
//        btn.setTitleColor(UIColor(red: 0.40, green: 0.55, blue: 0.85, alpha: 1), for: .normal)
//        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
//        return btn
//    }()
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.layer.insertSublayer(gradientLayer, at: 0)
//        setupStaticBubbles()
//        setupUI()
//        setupActions()
//        setupKeyboardHandling()
//        setupLoadingIndicator()
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        gradientLayer.frame = view.bounds
//    }
//    
//    // MARK: - Loading Indicator
//    private func setupLoadingIndicator() {
//        loadingIndicator.color = UIColor(red: 0.40, green: 0.55, blue: 0.85, alpha: 1)
//        loadingIndicator.hidesWhenStopped = true
//        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(loadingIndicator)
//        
//        NSLayoutConstraint.activate([
//            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//    }
//    
//    // MARK: - Keyboard Handling
//    private func setupKeyboardHandling() {
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        view.addGestureRecognizer(tapGesture)
//        
//        let textFields = [fullNameContainer, emailContainer, passwordContainer, confirmPasswordContainer]
//            .compactMap { $0.subviews.first(where: { $0 is UITextField }) as? UITextField }
//        
//        textFields.forEach { $0.delegate = self }
//    }
//    
//    @objc private func dismissKeyboard() {
//        view.endEditing(true)
//    }
//
//    // MARK: - UI Setup
//    private func setupUI() {
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        
//        view.addSubview(scrollView)
//        scrollView.addSubview(contentView)
//        
//        NSLayoutConstraint.activate([
//            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
//            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            
//            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
//            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
//            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
//            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
//            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
//        ])
//        
//        [welcomeLabel, createAccountLabel, journeyLabel, fullNameContainer,
//         emailContainer, passwordContainer, confirmPasswordContainer,
//         togglePasswordButton, toggleConfirmPasswordButton, signUpButton,
//         dividerView, appleButton, googleButton, bottomStackView].forEach { contentView.addSubview($0) }
//        
//        bottomStackView.addArrangedSubview(bottomLabel)
//        bottomStackView.addArrangedSubview(signInButton)
//        
//        let padding: CGFloat = 32
//        
//        NSLayoutConstraint.activate([
//            welcomeLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 40),
//            welcomeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
//            
//            createAccountLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 4),
//            createAccountLabel.leadingAnchor.constraint(equalTo: welcomeLabel.leadingAnchor),
//            
//            journeyLabel.topAnchor.constraint(equalTo: createAccountLabel.bottomAnchor, constant: 8),
//            journeyLabel.leadingAnchor.constraint(equalTo: welcomeLabel.leadingAnchor),
//            
//            fullNameContainer.topAnchor.constraint(equalTo: journeyLabel.bottomAnchor, constant: 40),
//            fullNameContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
//            fullNameContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
//            fullNameContainer.heightAnchor.constraint(equalToConstant: 58),
//            
//            emailContainer.topAnchor.constraint(equalTo: fullNameContainer.bottomAnchor, constant: 16),
//            emailContainer.leadingAnchor.constraint(equalTo: fullNameContainer.leadingAnchor),
//            emailContainer.trailingAnchor.constraint(equalTo: fullNameContainer.trailingAnchor),
//            emailContainer.heightAnchor.constraint(equalToConstant: 58),
//            
//            passwordContainer.topAnchor.constraint(equalTo: emailContainer.bottomAnchor, constant: 16),
//            passwordContainer.leadingAnchor.constraint(equalTo: emailContainer.leadingAnchor),
//            passwordContainer.trailingAnchor.constraint(equalTo: emailContainer.trailingAnchor),
//            passwordContainer.heightAnchor.constraint(equalToConstant: 58),
//            
//            togglePasswordButton.trailingAnchor.constraint(equalTo: passwordContainer.trailingAnchor, constant: -20),
//            togglePasswordButton.centerYAnchor.constraint(equalTo: passwordContainer.centerYAnchor),
//            
//            confirmPasswordContainer.topAnchor.constraint(equalTo: passwordContainer.bottomAnchor, constant: 16),
//            confirmPasswordContainer.leadingAnchor.constraint(equalTo: passwordContainer.leadingAnchor),
//            confirmPasswordContainer.trailingAnchor.constraint(equalTo: passwordContainer.trailingAnchor),
//            confirmPasswordContainer.heightAnchor.constraint(equalToConstant: 58),
//            
//            toggleConfirmPasswordButton.trailingAnchor.constraint(equalTo: confirmPasswordContainer.trailingAnchor, constant: -20),
//            toggleConfirmPasswordButton.centerYAnchor.constraint(equalTo: confirmPasswordContainer.centerYAnchor),
//            
//            signUpButton.topAnchor.constraint(equalTo: confirmPasswordContainer.bottomAnchor, constant: 28),
//            signUpButton.leadingAnchor.constraint(equalTo: confirmPasswordContainer.leadingAnchor),
//            signUpButton.trailingAnchor.constraint(equalTo: confirmPasswordContainer.trailingAnchor),
//            signUpButton.heightAnchor.constraint(equalToConstant: 58),
//            
//            dividerView.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 28),
//            dividerView.leadingAnchor.constraint(equalTo: signUpButton.leadingAnchor),
//            dividerView.trailingAnchor.constraint(equalTo: signUpButton.trailingAnchor),
//            dividerView.heightAnchor.constraint(equalToConstant: 20),
//            
//            appleButton.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 20),
//            appleButton.leadingAnchor.constraint(equalTo: signUpButton.leadingAnchor),
//            appleButton.widthAnchor.constraint(equalTo: signUpButton.widthAnchor, multiplier: 0.48),
//            appleButton.heightAnchor.constraint(equalToConstant: 56),
//            
//            googleButton.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 20),
//            googleButton.trailingAnchor.constraint(equalTo: signUpButton.trailingAnchor),
//            googleButton.widthAnchor.constraint(equalTo: signUpButton.widthAnchor, multiplier: 0.48),
//            googleButton.heightAnchor.constraint(equalToConstant: 56),
//            
//            bottomStackView.topAnchor.constraint(equalTo: appleButton.bottomAnchor, constant: 32),
//            bottomStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            bottomStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
//        ])
//    }
//    
//    // MARK: - Actions
//    private func setupActions() {
//        togglePasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
//        toggleConfirmPasswordButton.addTarget(self, action: #selector(toggleConfirmPasswordVisibility), for: .touchUpInside)
//        
//        signUpButton.addTarget(self, action: #selector(signUpPressed), for: .touchUpInside)
//        signInButton.addTarget(self, action: #selector(goToSignIn), for: .touchUpInside)
//    }
//    
//    @objc private func togglePasswordVisibility() {
//        if let textField = passwordContainer.subviews.compactMap({ $0 as? UITextField }).first {
//            textField.isSecureTextEntry.toggle()
//            let iconName = textField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
//            togglePasswordButton.setImage(UIImage(systemName: iconName), for: .normal)
//        }
//    }
//    
//    @objc private func toggleConfirmPasswordVisibility() {
//        if let textField = confirmPasswordContainer.subviews.compactMap({ $0 as? UITextField }).first {
//            textField.isSecureTextEntry.toggle()
//            let iconName = textField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
//            toggleConfirmPasswordButton.setImage(UIImage(systemName: iconName), for: .normal)
//        }
//    }
//    
//    // MARK: - Helper Methods
//    private func getTextFieldValue(from container: UIView) -> String {
//        return container.subviews.compactMap({ $0 as? UITextField }).first?.text ?? ""
//    }
//    
//    private func validateInputs() -> Bool {
//        let fullName = getTextFieldValue(from: fullNameContainer).trimmingCharacters(in: .whitespaces)
//        let email = getTextFieldValue(from: emailContainer).trimmingCharacters(in: .whitespaces)
//        let password = getTextFieldValue(from: passwordContainer)
//        let confirmPassword = getTextFieldValue(from: confirmPasswordContainer)
//        
//        if fullName.isEmpty {
//            showAlert(title: "Error", message: "Please enter your full name")
//            return false
//        }
//        
//        if email.isEmpty || !isValidEmail(email) {
//            showAlert(title: "Error", message: "Please enter a valid email address")
//            return false
//        }
//        
//        if password.isEmpty {
//            showAlert(title: "Error", message: "Please enter a password")
//            return false
//        }
//        
//        if password.count < 6 {
//            showAlert(title: "Error", message: "Password must be at least 6 characters")
//            return false
//        }
//        
//        if password != confirmPassword {
//            showAlert(title: "Error", message: "Passwords do not match")
//            return false
//        }
//        
//        return true
//    }
//    
//    private func isValidEmail(_ email: String) -> Bool {
//        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
//        return emailPred.evaluate(with: email)
//    }
//    
//    private func showAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//        present(alert, animated: true)
//    }
//    
//    @objc private func signUpPressed() {
//        guard validateInputs() else { return }
//        
//        let fullName = getTextFieldValue(from: fullNameContainer).trimmingCharacters(in: .whitespaces)
//        let email = getTextFieldValue(from: emailContainer).trimmingCharacters(in: .whitespaces)
//        let password = getTextFieldValue(from: passwordContainer)
//        
//        // Show loading
//        loadingIndicator.startAnimating()
//        signUpButton.isEnabled = false
//        view.isUserInteractionEnabled = false
//        
//        Task {
//            do {
//                _ = try await SupabaseManager.shared.signUp(
//                    email: email,
//                    password: password,
//                    fullName: fullName
//                )
//                
//                await MainActor.run {
//                    loadingIndicator.stopAnimating()
//                    signUpButton.isEnabled = true
//                    view.isUserInteractionEnabled = true
//                    
//                    // Show success message
//                    let alert = UIAlertController(
//                        title: "Success!",
//                        message: "Account created successfully. Please check your email to verify your account.",
//                        preferredStyle: .alert
//                    )
//                    alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
//                        self?.navigateToPreferences()
//                    })
//                    present(alert, animated: true)
//                }
//            } catch {
//                await MainActor.run {
//                    loadingIndicator.stopAnimating()
//                    signUpButton.isEnabled = true
//                    view.isUserInteractionEnabled = true
//                    
//                    showAlert(title: "Sign Up Failed", message: error.localizedDescription)
//                }
//            }
//        }
//    }
//    
//    private func navigateToPreferences() {
//        UIView.animate(withDuration: 0.1, animations: {
//            self.signUpButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
//        }) { _ in
//            UIView.animate(withDuration: 0.1) {
//                self.signUpButton.transform = .identity
//            } completion: { _ in
//                let preferenceVC = PreferenceSelectionViewController()
//                preferenceVC.modalPresentationStyle = .fullScreen
//                preferenceVC.modalTransitionStyle = .crossDissolve
//                self.present(preferenceVC, animated: true)
//            }
//        }
//    }
//    
//    @objc private func goToSignIn() {
//        let signInVC = SignInViewController()
//        signInVC.modalPresentationStyle = .fullScreen
//        signInVC.modalTransitionStyle = .coverVertical
//        self.present(signInVC, animated: true)
//    }
//}
//
//// MARK: - TextField Delegate
//extension SignUpViewController: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//}










import UIKit
internal import Auth
import GoogleSignIn

class SignUpViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)

    
    private func setupStaticBubbles() {
        let bubble1 = UIView(frame: CGRect(x: view.frame.width - 150, y: -50, width: 300, height: 300))
        bubble1.backgroundColor = UIColor.brand.withAlphaComponent(0.08)
        bubble1.layer.cornerRadius = 150
        view.insertSubview(bubble1, belowSubview: scrollView)
        let bubble2 = UIView(frame: CGRect(x: -60, y: view.frame.height * 0.4, width: 180, height: 180))
        bubble2.backgroundColor = UIColor.brand.withAlphaComponent(0.06)
        bubble2.layer.cornerRadius = 90
        view.insertSubview(bubble2, belowSubview: scrollView)
        let bubble3 = UIView(frame: CGRect(x: view.frame.width * 0.6, y: view.frame.height * 0.85, width: 250, height: 250))
        bubble3.backgroundColor = UIColor.brand.withAlphaComponent(0.05)
        bubble3.layer.cornerRadius = 125
        view.insertSubview(bubble3, belowSubview: scrollView)
    }
    
    private let welcomeLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Welcome"
        lbl.font = UIFont.systemFont(ofSize: 42, weight: .bold)
        lbl.textColor = .label
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let createAccountLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Create an account"
        lbl.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        lbl.textColor = .secondaryLabel
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let journeyLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Start your tech journey with Insider"
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lbl.textColor = .brand
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    // MARK: - Input Fields (Glass Style)
    private func createTextField(_ placeholder: String, icon: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.secondarySystemGroupedBackground
        container.layer.cornerRadius = 29
        container.layer.borderColor = UIColor.separator.cgColor
        container.layer.borderWidth = 1.0
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.shadowColor = UIColor.label.withAlphaComponent(0.06).cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 4)
        container.layer.shadowRadius = 12
        container.layer.shadowOpacity = 1
        
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .brand
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        
        let textField = UITextField()
        textField.textColor = .label
        textField.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor.placeholderText]
        )
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.autocapitalizationType = .none
        
        container.addSubview(iconView)
        container.addSubview(textField)
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),
            textField.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 14),
            textField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            textField.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            textField.heightAnchor.constraint(equalTo: container.heightAnchor)
        ])
        return container
    }
    
    private lazy var fullNameContainer    = createTextField("Full Name",         icon: "person.fill")
    private lazy var emailContainer       = createTextField("Email Address",      icon: "envelope.fill")
    private lazy var passwordContainer: UIView = {
        let c = createTextField("Password", icon: "lock.fill")
        c.subviews.compactMap { $0 as? UITextField }.first?.isSecureTextEntry = true
        return c
    }()
    private lazy var confirmPasswordContainer: UIView = {
        let c = createTextField("Confirm Password", icon: "lock.shield.fill")
        c.subviews.compactMap { $0 as? UITextField }.first?.isSecureTextEntry = true
        return c
    }()
    
    private let togglePasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        btn.tintColor = .brand
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    private let toggleConfirmPasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        btn.tintColor = .brand
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let signUpButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Sign Up", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .brand
        btn.layer.cornerRadius = 29
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.shadowColor = UIColor.brand.withAlphaComponent(0.4).cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 8)
        btn.layer.shadowRadius = 16
        btn.layer.shadowOpacity = 1
        return btn
    }()
    
    private let dividerView: UIView = {
        let view = UIView(); view.translatesAutoresizingMaskIntoConstraints = false
        let leftLine = UIView(); leftLine.backgroundColor = .separator; leftLine.translatesAutoresizingMaskIntoConstraints = false
        let rightLine = UIView(); rightLine.backgroundColor = .separator; rightLine.translatesAutoresizingMaskIntoConstraints = false
        let label = UILabel(); label.text = "or continue with"; label.font = UIFont.systemFont(ofSize: 13, weight: .medium); label.textColor = .secondaryLabel; label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(leftLine); view.addSubview(rightLine); view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor), label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            leftLine.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -12), leftLine.centerYAnchor.constraint(equalTo: view.centerYAnchor), leftLine.heightAnchor.constraint(equalToConstant: 1), leftLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rightLine.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 12), rightLine.centerYAnchor.constraint(equalTo: view.centerYAnchor), rightLine.heightAnchor.constraint(equalToConstant: 1), rightLine.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        return view
    }()
    
    private let googleButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("  Google", for: .normal)
        if let gIcon = UIImage(named: "googleLogo") {
            let size = CGSize(width: 20, height: 20)
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            gIcon.draw(in: CGRect(origin: .zero, size: size))
            let resized = UIGraphicsGetImageFromCurrentImageContext()?.withRenderingMode(.alwaysOriginal)
            UIGraphicsEndImageContext()
            btn.setImage(resized, for: .normal)
        } else {
            btn.setImage(UIImage(systemName: "globe"), for: .normal)
            btn.tintColor = .label
        }
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        btn.setTitleColor(.label, for: .normal)
        btn.backgroundColor = .secondarySystemGroupedBackground
        btn.layer.cornerRadius = 28; btn.layer.borderColor = UIColor.separator.cgColor; btn.layer.borderWidth = 1.0
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private lazy var signInButton: UIButton = {
        let btn = UIButton(type: .system)
        let fullText = "Already have an account?  Sign In"
        let attr = NSMutableAttributedString(string: fullText)
        let fullRange = NSRange(location: 0, length: fullText.count)
        attr.addAttribute(.foregroundColor, value: UIColor.secondaryLabel, range: fullRange)
        attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .regular), range: fullRange)
        let range = (fullText as NSString).range(of: "Sign In")
        attr.addAttribute(.foregroundColor, value: UIColor.brand, range: range)
        attr.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .bold), range: range)
        btn.setAttributedTitle(attr, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupActions()
        setupKeyboardHandling()
        setupStaticBubbles()
        updateDynamicColors()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateDynamicColors()
        }
    }
    
    private func updateDynamicColors() {
        // Refresh CGColor properties that don't auto-adapt
        fullNameContainer.layer.borderColor = UIColor.separator.cgColor
        fullNameContainer.layer.shadowColor = UIColor.label.withAlphaComponent(0.06).cgColor
        emailContainer.layer.borderColor = UIColor.separator.cgColor
        emailContainer.layer.shadowColor = UIColor.label.withAlphaComponent(0.06).cgColor
        passwordContainer.layer.borderColor = UIColor.separator.cgColor
        passwordContainer.layer.shadowColor = UIColor.label.withAlphaComponent(0.06).cgColor
        confirmPasswordContainer.layer.borderColor = UIColor.separator.cgColor
        confirmPasswordContainer.layer.shadowColor = UIColor.label.withAlphaComponent(0.06).cgColor
        googleButton.layer.borderColor = UIColor.separator.cgColor
    }
    
    private func setupUI() {
        view.addSubview(scrollView); scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView); contentView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        
        let bottomStack = UIStackView(arrangedSubviews: [signInButton])
        bottomStack.axis = .vertical; bottomStack.alignment = .center
        bottomStack.translatesAutoresizingMaskIntoConstraints = false
        
        [welcomeLabel, createAccountLabel, journeyLabel,
         fullNameContainer, emailContainer, passwordContainer, confirmPasswordContainer,
         signUpButton, dividerView, googleButton, bottomStack].forEach { contentView.addSubview($0) }
        
        passwordContainer.addSubview(togglePasswordButton)
        confirmPasswordContainer.addSubview(toggleConfirmPasswordButton)
        
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
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            welcomeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 70),
            welcomeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            createAccountLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 8),
            createAccountLabel.leadingAnchor.constraint(equalTo: welcomeLabel.leadingAnchor),
            journeyLabel.topAnchor.constraint(equalTo: createAccountLabel.bottomAnchor, constant: 6),
            journeyLabel.leadingAnchor.constraint(equalTo: welcomeLabel.leadingAnchor),
            fullNameContainer.topAnchor.constraint(equalTo: journeyLabel.bottomAnchor, constant: 48),
            fullNameContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            fullNameContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            fullNameContainer.heightAnchor.constraint(equalToConstant: 60),
            emailContainer.topAnchor.constraint(equalTo: fullNameContainer.bottomAnchor, constant: 16),
            emailContainer.leadingAnchor.constraint(equalTo: fullNameContainer.leadingAnchor),
            emailContainer.trailingAnchor.constraint(equalTo: fullNameContainer.trailingAnchor),
            emailContainer.heightAnchor.constraint(equalToConstant: 60),
            passwordContainer.topAnchor.constraint(equalTo: emailContainer.bottomAnchor, constant: 16),
            passwordContainer.leadingAnchor.constraint(equalTo: fullNameContainer.leadingAnchor),
            passwordContainer.trailingAnchor.constraint(equalTo: fullNameContainer.trailingAnchor),
            passwordContainer.heightAnchor.constraint(equalToConstant: 60),
            togglePasswordButton.trailingAnchor.constraint(equalTo: passwordContainer.trailingAnchor, constant: -16),
            togglePasswordButton.centerYAnchor.constraint(equalTo: passwordContainer.centerYAnchor),
            confirmPasswordContainer.topAnchor.constraint(equalTo: passwordContainer.bottomAnchor, constant: 16),
            confirmPasswordContainer.leadingAnchor.constraint(equalTo: fullNameContainer.leadingAnchor),
            confirmPasswordContainer.trailingAnchor.constraint(equalTo: fullNameContainer.trailingAnchor),
            confirmPasswordContainer.heightAnchor.constraint(equalToConstant: 60),
            toggleConfirmPasswordButton.trailingAnchor.constraint(equalTo: confirmPasswordContainer.trailingAnchor, constant: -16),
            toggleConfirmPasswordButton.centerYAnchor.constraint(equalTo: confirmPasswordContainer.centerYAnchor),
            signUpButton.topAnchor.constraint(equalTo: confirmPasswordContainer.bottomAnchor, constant: 28),
            signUpButton.leadingAnchor.constraint(equalTo: confirmPasswordContainer.leadingAnchor),
            signUpButton.trailingAnchor.constraint(equalTo: confirmPasswordContainer.trailingAnchor),
            signUpButton.heightAnchor.constraint(equalToConstant: 58),
            dividerView.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 28),
            dividerView.leadingAnchor.constraint(equalTo: signUpButton.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: signUpButton.trailingAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: 20),
            googleButton.topAnchor.constraint(equalTo: dividerView.bottomAnchor, constant: 20),
            googleButton.leadingAnchor.constraint(equalTo: signUpButton.leadingAnchor),
            googleButton.trailingAnchor.constraint(equalTo: signUpButton.trailingAnchor),
            googleButton.heightAnchor.constraint(equalToConstant: 56),
            bottomStack.topAnchor.constraint(equalTo: googleButton.bottomAnchor, constant: 32),
            bottomStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            bottomStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
    
    // MARK: - Actions
    
    private func setupActions() {
        togglePasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        toggleConfirmPasswordButton.addTarget(self, action: #selector(toggleConfirmPasswordVisibility), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpPressed), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(goToSignIn), for: .touchUpInside)
        googleButton.addTarget(self, action: #selector(handleGoogleSignIn), for: .touchUpInside)
    }
    
    @objc private func togglePasswordVisibility() {
        guard let tf = passwordContainer.subviews.compactMap({ $0 as? UITextField }).first else { return }
        tf.isSecureTextEntry.toggle()
        togglePasswordButton.setImage(UIImage(systemName: tf.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"), for: .normal)
    }
    
    @objc private func toggleConfirmPasswordVisibility() {
        guard let tf = confirmPasswordContainer.subviews.compactMap({ $0 as? UITextField }).first else { return }
        tf.isSecureTextEntry.toggle()
        toggleConfirmPasswordButton.setImage(UIImage(systemName: tf.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"), for: .normal)
    }
    
    private func setupKeyboardHandling() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    @objc private func dismissKeyboard() { view.endEditing(true) }
    
    private func getTextFieldValue(from container: UIView) -> String {
        container.subviews.compactMap({ $0 as? UITextField }).first?.text ?? ""
    }
    
    private func validateInputs() -> Bool {
        let fullName        = getTextFieldValue(from: fullNameContainer).trimmingCharacters(in: .whitespaces)
        let email           = getTextFieldValue(from: emailContainer).trimmingCharacters(in: .whitespaces)
        let password        = getTextFieldValue(from: passwordContainer)
        let confirmPassword = getTextFieldValue(from: confirmPasswordContainer)
        
        if fullName.isEmpty      { showAlert(title: "Error", message: "Please enter your full name"); return false }
        if email.isEmpty || !isValidEmail(email) { showAlert(title: "Error", message: "Please enter a valid email address"); return false }
        if password.isEmpty      { showAlert(title: "Error", message: "Please enter a password"); return false }
        if password.count < 6    { showAlert(title: "Error", message: "Password must be at least 6 characters"); return false }
        if password != confirmPassword { showAlert(title: "Error", message: "Passwords do not match"); return false }
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}").evaluate(with: email)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Sign Up Flow
    
    @objc private func signUpPressed() {
        guard validateInputs() else { return }
        
        let fullName = getTextFieldValue(from: fullNameContainer).trimmingCharacters(in: .whitespaces)
        let email    = getTextFieldValue(from: emailContainer).trimmingCharacters(in: .whitespaces)
        let password = getTextFieldValue(from: passwordContainer)
        
        loadingIndicator.startAnimating()
        signUpButton.isEnabled = false
        view.isUserInteractionEnabled = false
        
        Task {
            do {
                // 1️⃣  Create Supabase Auth user
                let user = try await SupabaseManager.shared.signUp(
                    email: email,
                    password: password,
                    fullName: fullName
                )
                let userId = user.id.uuidString.lowercased()
                
                // 2️⃣  Create user_profiles row with default values
                //     This is the single source of truth for all profile data.
                let newProfile = UserProfileDB(userId: userId, fullName: fullName, email: email)
                UserProfilePersistenceManager.shared.createProfile(newProfile) { result in
                    switch result {
                    case .success:
                        print("✅ [SignUp] user_profiles row created for \(userId)")
                    case .failure(let error):
                        // Non-fatal – upsert on next sign-in will recover
                        print("⚠️ [SignUp] Profile row creation failed: \(error.localizedDescription)")
                    }
                }
                
                // 3️⃣  Cache identity locally so downstream onboarding screens
                //     can reference the real auth UUID without an extra async call
                UserDefaults.standard.set(userId.lowercased(),   forKey: "currentUserId")
                UserDefaults.standard.set(fullName, forKey: "currentUserFullName")
                UserDefaults.standard.set(email,    forKey: "currentUserEmail")
                
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.signUpButton.isEnabled = true
                    self.view.isUserInteractionEnabled = true
                    
                    let alert = UIAlertController(
                        title: "Success!",
                        message: "Account created! Please check your email to verify your account.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                        self?.navigateToPreferences()
                    })
                    self.present(alert, animated: true)
                }
            } catch {
                await MainActor.run {
                    self.loadingIndicator.stopAnimating()
                    self.signUpButton.isEnabled = true
                    self.view.isUserInteractionEnabled = true
                    self.showAlert(title: "Sign Up Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func navigateToPreferences() {
        UIView.animate(withDuration: 0.1, animations: {
            self.signUpButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) { self.signUpButton.transform = .identity } completion: { _ in
                let vc = PreferenceSelectionViewController()
                vc.modalPresentationStyle = .fullScreen
                vc.modalTransitionStyle   = .crossDissolve
                self.present(vc, animated: true)
            }
        }
    }
    
    @objc private func goToSignIn() {
        let vc = SignInViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle   = .coverVertical
        present(vc, animated: true)
    }
    
    // MARK: - Google Sign In
    @objc func handleGoogleSignIn() {
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        let nonce = CryptoUtils.randomNonceString()
        let hashedNonce = CryptoUtils.sha256(nonce)
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self, hint: nil, additionalScopes: nil, nonce: hashedNonce) { [weak self] signInResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.loadingIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                print("Google Sign-In failed: \(error.localizedDescription)")
                self.showAlert(title: "Google Sign-In Failed", message: error.localizedDescription)
                return
            }
            
            guard let idToken = signInResult?.user.idToken?.tokenString else {
                self.loadingIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
                self.showAlert(title: "Error", message: "Missing Google ID Token")
                return
            }
            let accessToken = signInResult?.user.accessToken.tokenString
            
            Task {
                do {
                    _ = try await SupabaseManager.shared.signInWithGoogle(idToken: idToken, accessToken: accessToken, nonce: nonce)
                    await MainActor.run {
                        self.loadingIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        self.navigateToPreferences()
                    }
                } catch {
                    await MainActor.run {
                        self.loadingIndicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        self.showAlert(title: "Sign In Failed", message: error.localizedDescription)
                    }
                }
            }
        }
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder(); return true
    }
}

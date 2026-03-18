import UIKit

class LaunchingViewController: UIViewController {
    
    // MARK: - UI Components
    
    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 32
        iv.clipsToBounds = true
        iv.alpha = 0
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Insider"
        label.font = .systemFont(ofSize: 42, weight: .black)
        label.textColor = .white
        label.textAlignment = .center
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.text = "Chaos to Clarity"
        if let descriptor = UIFont.systemFont(ofSize: 18, weight: .medium).fontDescriptor.withDesign(.rounded) {
            label.font = UIFont(descriptor: descriptor, size: 18)
        } else {
            label.font = .systemFont(ofSize: 18, weight: .medium)
        }
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.textAlignment = .center
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    // MARK: - Setup
    
    private func setupUI() {
        // Solid brand color background
        view.backgroundColor = .brand
        
        // Load app icon
        if let appIcon = UIImage(named: "AppIcon") {
            logoImageView.image = appIcon
        } else {
            // Fallback: use the app icon from the bundle
            if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
               let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
               let iconFiles = primary["CFBundleIconFiles"] as? [String],
               let lastIcon = iconFiles.last,
               let icon = UIImage(named: lastIcon) {
                logoImageView.image = icon
            } else {
                // Final fallback: SF Symbol
                let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .bold)
                logoImageView.image = UIImage(systemName: "newspaper.fill", withConfiguration: config)
                logoImageView.tintColor = .white
                logoImageView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
            }
        }
        
        view.addSubview(logoImageView)
        view.addSubview(appNameLabel)
        view.addSubview(taglineLabel)
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),
            
            appNameLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 24),
            appNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            taglineLabel.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 8),
            taglineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    // MARK: - Animation
    
    private func animateIn() {
        // Animate logo
        logoImageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.8, delay: 0.1, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.logoImageView.alpha = 1
            self.logoImageView.transform = .identity
        }
        
        // Animate app name
        UIView.animate(withDuration: 0.6, delay: 0.4, options: .curveEaseOut) {
            self.appNameLabel.alpha = 1
        }
        
        // Animate tagline
        UIView.animate(withDuration: 0.6, delay: 0.6, options: .curveEaseOut) {
            self.taglineLabel.alpha = 1
        }
        
        // Auto-transition after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.transitionToOnboarding()
        }
    }
    
    // MARK: - Transition
    
    private func transitionToOnboarding() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let getStartedVC: UIViewController
        
        if let vc = storyboard.instantiateViewController(withIdentifier: "GetStartedViewControllerID") as? GetStartedViewController {
            getStartedVC = vc
        } else {
            getStartedVC = GetStartedViewController()
        }
        
        if let window = view.window {
            window.rootViewController = getStartedVC
            UIView.transition(with: window, duration: 0.6, options: .transitionCrossDissolve, animations: nil)
        }
    }
}

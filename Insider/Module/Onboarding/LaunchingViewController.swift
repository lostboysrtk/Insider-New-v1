import UIKit

class LaunchingViewController: UIViewController {
    
    // MARK: - UI Components
    private let backgroundGradient = CAGradientLayer()
    
    private let hugeILabel: UILabel = {
        let label = UILabel()
        label.text = "I"
        label.font = .systemFont(ofSize: 240, weight: .black)
        label.textColor = .white
        label.textAlignment = .center
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let restOfLogoLabel: UILabel = {
        let label = UILabel()
        label.text = "nsider"
        label.font = .systemFont(ofSize: 56, weight: .black)
        label.textColor = .white
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.text = "Chaos to Clarity"
        if let descriptor = UIFont.systemFont(ofSize: 20, weight: .semibold).fontDescriptor.withDesign(.rounded) {
            label.font = UIFont(descriptor: descriptor, size: 20)
        } else {
            label.font = .systemFont(ofSize: 20, weight: .semibold)
        }
        label.textColor = .white
        label.textAlignment = .center
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let getStartedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Get Started", for: .normal)
        
        if let descriptor = UIFont.systemFont(ofSize: 18, weight: .bold).fontDescriptor.withDesign(.rounded) {
            button.titleLabel?.font = UIFont(descriptor: descriptor, size: 18)
        } else {
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        }
        
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = AppColor.Brand.button
        button.layer.cornerRadius = 16
        button.alpha = 0
        button.transform = CGAffineTransform(translationX: 0, y: 30)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Unified Shadow from Theme
        button.layer.shadowColor = AppColor.Brand.shadow.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 12
        button.layer.shadowOpacity = 1.0
        
        return button
    }()
    
    private var hugeItoFinalConstraint: NSLayoutConstraint?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAmazingAnimation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient.frame = view.bounds
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .white
        
        // Background Gradient from Theme
        backgroundGradient.colors = [
            AppColor.Gradient.top.cgColor,
            AppColor.Gradient.middle.cgColor,
            AppColor.Gradient.bottom.cgColor
        ]
        backgroundGradient.locations = [0.0, 0.5, 1.0]
        view.layer.insertSublayer(backgroundGradient, at: 0)
        
        view.addSubview(hugeILabel)
        view.addSubview(restOfLogoLabel)
        view.addSubview(taglineLabel)
        view.addSubview(getStartedButton)
        
        hugeItoFinalConstraint = hugeILabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        
        NSLayoutConstraint.activate([
            hugeItoFinalConstraint!,
            hugeILabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            
            restOfLogoLabel.centerYAnchor.constraint(equalTo: hugeILabel.centerYAnchor, constant: 18),
            restOfLogoLabel.leadingAnchor.constraint(equalTo: hugeILabel.centerXAnchor, constant: -10),
            
            taglineLabel.topAnchor.constraint(equalTo: hugeILabel.bottomAnchor, constant: 20),
            taglineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            getStartedButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            getStartedButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            getStartedButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            getStartedButton.heightAnchor.constraint(equalToConstant: 58)
        ])
        
        getStartedButton.addTarget(self, action: #selector(getStartedTapped), for: .touchUpInside)
    }
    
    // MARK: - Amazing Animation
    private func startAmazingAnimation() {
        // Prepare Huge I
        hugeILabel.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        hugeILabel.alpha = 0
        hugeILabel.layer.shadowColor = AppColor.brand.cgColor
        hugeILabel.layer.shadowRadius = 30
        hugeILabel.layer.shadowOpacity = 0
        
        // 1. Splash the huge 'I'
        UIView.animate(withDuration: 1.5, delay: 0.2, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.hugeILabel.alpha = 1
            self.hugeILabel.transform = .identity
            self.hugeILabel.layer.shadowOpacity = 0.5
        } completion: { _ in
            // 2. Shrink 'I' to its logo size and slide rest of letters out
            self.hugeItoFinalConstraint?.constant = -65 // Slide 'I' to left
            
            let animator = UIViewPropertyAnimator(duration: 1.0, dampingRatio: 0.8) {
                // Shrink text size (using transform instead of font for smoother animation if needed, but font is clearer here)
                self.hugeILabel.font = .systemFont(ofSize: 56, weight: .black)
                self.hugeILabel.textColor = .white 
                self.hugeILabel.layer.shadowOpacity = 0
                
                // Reveal rest of text
                self.restOfLogoLabel.alpha = 1
                self.restOfLogoLabel.transform = CGAffineTransform(translationX: 20, y: 0)
                
                self.view.layoutIfNeeded()
            }
            
            animator.addCompletion { _ in
                // 3. Reveal tagline and button
                UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseOut) {
                    self.taglineLabel.alpha = 1
                    self.taglineLabel.transform = .identity
                    
                    self.getStartedButton.alpha = 1
                    self.getStartedButton.transform = .identity
                }
            }
            
            animator.startAnimation()
        }
    }
    
    // MARK: - Actions
    @objc private func getStartedTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let getStartedVC = storyboard.instantiateViewController(withIdentifier: "GetStartedViewControllerID") as? GetStartedViewController else {
            return
        }
        
        if let window = view.window {
            window.rootViewController = getStartedVC
            UIView.transition(with: window, duration: 0.6, options: .transitionCrossDissolve, animations: nil)
        }
    }
}

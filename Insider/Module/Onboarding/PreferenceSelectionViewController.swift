import UIKit

class PreferenceSelectionViewController: UIViewController {
    
    // MARK: - Properties
    private var selectedOption: NewsVolume?
    
    // Updated Enum for News Volume
    enum NewsVolume: String {
        case low = "10 news"
        case medium = "15 news"
        case high = "20 news"
        
        var description: String {
            switch self {
            case .low: return "A quick briefing for busy days"
            case .medium: return "The perfect balance of information"
            case .high: return "Deep dive into everything new"
            }
        }
        
        var iconName: String {
            switch self {
            case .low: return "bolt.fill"
            case .medium: return "newspaper.fill"
            case .high: return "books.vertical.fill"
            }
        }
    }
    
    // MARK: - UI Components
    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1).cgColor,
            UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1).cgColor
        ]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        return gradient
    }()
    
    private let pageTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "Feed Settings"
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        lbl.textColor = UIColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.alpha = 0
        lbl.transform = CGAffineTransform(translationX: 0, y: -20)
        return lbl
    }()
    
    private let mainQuestionLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "How much news do you\nwant to see daily?"
        lbl.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        lbl.textColor = UIColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1)
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let subtitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Set your daily limit for the 'For You' page"
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        lbl.textColor = UIColor(red: 0.40, green: 0.40, blue: 0.45, alpha: 1)
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let optionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let pageIndicatorContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let savePreferenceButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Save Preference", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 0.35, green: 0.50, blue: 0.75, alpha: 1)
        btn.layer.cornerRadius = 28
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.alpha = 0.5
        btn.isEnabled = false
        btn.layer.shadowColor = UIColor(red: 0.35, green: 0.50, blue: 0.75, alpha: 0.4).cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 8)
        btn.layer.shadowRadius = 16
        btn.layer.shadowOpacity = 0
        return btn
    }()
    
    private var optionCards: [PreferenceCard] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupUI()
        setupPageIndicator()
        setupOptionCards()
        setupActions()
        animateEntrance()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    private func setupGradientBackground() {
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setupUI() {
        view.addSubview(pageTitle)
        view.addSubview(mainQuestionLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(optionsStackView)
        view.addSubview(pageIndicatorContainer)
        view.addSubview(savePreferenceButton)
        
        NSLayoutConstraint.activate([
            pageTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            pageTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            mainQuestionLabel.topAnchor.constraint(equalTo: pageTitle.bottomAnchor, constant: 48),
            mainQuestionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            mainQuestionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            subtitleLabel.topAnchor.constraint(equalTo: mainQuestionLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            
            optionsStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 56),
            optionsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            optionsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            pageIndicatorContainer.bottomAnchor.constraint(equalTo: savePreferenceButton.topAnchor, constant: -20),
            pageIndicatorContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageIndicatorContainer.heightAnchor.constraint(equalToConstant: 8),
            pageIndicatorContainer.widthAnchor.constraint(equalToConstant: 50),
            
            savePreferenceButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            savePreferenceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            savePreferenceButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            savePreferenceButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        [pageTitle, mainQuestionLabel, subtitleLabel, optionsStackView, savePreferenceButton].forEach {
            if $0 != pageTitle {
                $0.alpha = 0
                $0.transform = CGAffineTransform(translationX: 0, y: 30)
            }
        }
    }
    
    private func setupOptionCards() {
        let options: [NewsVolume] = [.low, .medium, .high]
        
        for level in options {
            let card = PreferenceCard(level: level)
            card.translatesAutoresizingMaskIntoConstraints = false
            card.heightAnchor.constraint(equalToConstant: 90).isActive = true
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
            card.addGestureRecognizer(tapGesture)
            card.tag = options.firstIndex(of: level) ?? 0
            
            optionsStackView.addArrangedSubview(card)
            optionCards.append(card)
        }
    }
    
    private func setupPageIndicator() {
        let dot1 = createDot(isActive: true)
        let dot2 = createDot(isActive: false)
        pageIndicatorContainer.addSubview(dot1)
        pageIndicatorContainer.addSubview(dot2)
        
        NSLayoutConstraint.activate([
            dot1.leadingAnchor.constraint(equalTo: pageIndicatorContainer.leadingAnchor),
            dot1.centerYAnchor.constraint(equalTo: pageIndicatorContainer.centerYAnchor),
            dot1.widthAnchor.constraint(equalToConstant: 8),
            dot1.heightAnchor.constraint(equalToConstant: 8),
            dot2.trailingAnchor.constraint(equalTo: pageIndicatorContainer.trailingAnchor),
            dot2.centerYAnchor.constraint(equalTo: pageIndicatorContainer.centerYAnchor),
            dot2.widthAnchor.constraint(equalToConstant: 8),
            dot2.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
    
    private func createDot(isActive: Bool) -> UIView {
        let dot = UIView()
        dot.layer.cornerRadius = 4
        dot.backgroundColor = isActive ? UIColor(red: 0.35, green: 0.50, blue: 0.75, alpha: 1) : UIColor(red: 0.85, green: 0.87, blue: 0.90, alpha: 1)
        dot.translatesAutoresizingMaskIntoConstraints = false
        return dot
    }
    
    private func setupActions() {
        savePreferenceButton.addTarget(self, action: #selector(savePreferenceTapped), for: .touchUpInside)
    }
    
    @objc private func cardTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedCard = gesture.view as? PreferenceCard else { return }
        let levels: [NewsVolume] = [.low, .medium, .high]
        let tappedLevel = levels[tappedCard.tag]
        
        if selectedOption == tappedLevel {
            selectedOption = nil
            tappedCard.setSelected(false)
            disableContinueButton()
        } else {
            optionCards.forEach { $0.setSelected(false) }
            selectedOption = tappedLevel
            tappedCard.setSelected(true)
            enableContinueButton()
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    @objc private func savePreferenceTapped() {
        guard let selectedLevel = selectedOption else { return }
        
        // SAVE TO DISK: Consistency with your other preference screens
        UserDefaults.standard.set(selectedLevel.rawValue, forKey: "ReadingTime")
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        
        UIView.animate(withDuration: 0.1, animations: {
            self.savePreferenceButton.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.savePreferenceButton.transform = .identity
            } completion: { [weak self] _ in
                // Proceed to next screen
                let nextVC = PreferenceSelection2ViewController()
                nextVC.modalPresentationStyle = .fullScreen
                self?.present(nextVC, animated: true)
            }
        }
    }
    
    private func enableContinueButton() {
        UIView.animate(withDuration: 0.3) {
            self.savePreferenceButton.alpha = 1
            self.savePreferenceButton.isEnabled = true
            self.savePreferenceButton.layer.shadowOpacity = 1
        }
    }
    
    private func disableContinueButton() {
        UIView.animate(withDuration: 0.3) {
            self.savePreferenceButton.alpha = 0.5
            self.savePreferenceButton.isEnabled = false
            self.savePreferenceButton.layer.shadowOpacity = 0
        }
    }
    
    private func animateEntrance() {
        let elements = [pageTitle, mainQuestionLabel, subtitleLabel, optionsStackView, savePreferenceButton]
        for (index, element) in elements.enumerated() {
            UIView.animate(withDuration: 0.8, delay: 0.1 + Double(index) * 0.08, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [.curveEaseOut]) {
                element.alpha = 1
                element.transform = .identity
            }
        }
    }
}

// MARK: - Updated PreferenceCard for NewsVolume
class PreferenceCard: UIView {
    
    private let level: PreferenceSelectionViewController.NewsVolume
    private var isSelectedState = false
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = UIColor(red: 0.35, green: 0.50, blue: 0.75, alpha: 1)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        lbl.textColor = UIColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbl.textColor = UIColor(red: 0.40, green: 0.40, blue: 0.45, alpha: 1)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let checkmarkIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        iv.tintColor = UIColor(red: 0.35, green: 0.50, blue: 0.75, alpha: 1)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.alpha = 0
        return iv
    }()
    
    init(level: PreferenceSelectionViewController.NewsVolume) {
        self.level = level
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        backgroundColor = UIColor.white.withAlphaComponent(0.85)
        layer.cornerRadius = 20
        layer.borderWidth = 1.5
        layer.borderColor = UIColor(red: 0.88, green: 0.90, blue: 0.93, alpha: 1).cgColor
        layer.shadowColor = UIColor(red: 0.12, green: 0.25, blue: 0.55, alpha: 0.08).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 12
        layer.shadowOpacity = 1
        
        addSubview(containerView)
        containerView.addSubview(iconView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(checkmarkIcon)
        
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        iconView.image = UIImage(systemName: level.iconName, withConfiguration: config)
        titleLabel.text = level.rawValue
        descriptionLabel.text = level.description
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            iconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 28),
            iconView.heightAnchor.constraint(equalToConstant: 28),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: checkmarkIcon.leadingAnchor, constant: -12),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            checkmarkIcon.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            checkmarkIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            checkmarkIcon.widthAnchor.constraint(equalToConstant: 26),
            checkmarkIcon.heightAnchor.constraint(equalToConstant: 26)
        ])
    }
    
    func setSelected(_ selected: Bool) {
        isSelectedState = selected
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: [.curveEaseOut]) {
            if selected {
                self.layer.borderColor = UIColor(red: 0.35, green: 0.50, blue: 0.75, alpha: 1).cgColor
                self.backgroundColor = UIColor(red: 0.35, green: 0.50, blue: 0.75, alpha: 0.12)
                self.layer.borderWidth = 2
                self.checkmarkIcon.alpha = 1
                self.transform = CGAffineTransform(scaleX: 1.01, y: 1.01)
                self.layer.shadowColor = UIColor(red: 0.35, green: 0.50, blue: 0.75, alpha: 0.2).cgColor
            } else {
                self.layer.borderColor = UIColor(red: 0.88, green: 0.90, blue: 0.93, alpha: 1).cgColor
                self.backgroundColor = UIColor.white.withAlphaComponent(0.85)
                self.layer.borderWidth = 1.5
                self.checkmarkIcon.alpha = 0
                self.transform = .identity
                self.layer.shadowColor = UIColor(red: 0.12, green: 0.25, blue: 0.55, alpha: 0.08).cgColor
            }
        }
    }
}

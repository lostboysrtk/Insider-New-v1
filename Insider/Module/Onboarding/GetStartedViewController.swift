import UIKit

class GetStartedViewController: UIViewController {
    
    // MARK: - Data (Restored original colors)
    private let items: [(title: String, desc: String, emoji: String, color: UIColor, isDarkText: Bool)] = [
        ("Insider", "Chaos to Clarity", "", UIColor(red: 0.85, green: 0.90, blue: 0.98, alpha: 1), true),
        ("Tech\nNews", "Latest developer trends delivered to your door.", "📰", UIColor(red: 0.35, green: 0.50, blue: 0.75, alpha: 1), false),
        ("Audio\nMode", "Listen to summaries while you commute.", "🎧", UIColor(red: 0.25, green: 0.40, blue: 0.65, alpha: 1), false),
        ("Smart\nFeed", "Content tailored to your specific interests.", "✨", UIColor(red: 0.15, green: 0.30, blue: 0.55, alpha: 1), false)
    ]
    
    // MARK: - UI Components
    private var collectionView: UICollectionView!
    private let nextButton = UIButton(type: .system)
    private let backButton = UIButton(type: .system)
    private let getStartedButton = UIButton(type: .system)
    private let skipButton = UIButton(type: .system) // NEW
    private let progressContainer = UIView()
    private let progressBar = UIView()
    private var progressWidthConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = items[0].color
        setupCollectionView()
        setupProgressBar()
        setupButtons()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = false
        collectionView.decelerationRate = .fast
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(TrainCell.self, forCellWithReuseIdentifier: "TrainCell")
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupProgressBar() {
        progressContainer.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        progressContainer.layer.cornerRadius = 3
        progressContainer.clipsToBounds = true
        progressContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressContainer)
        
        progressBar.backgroundColor = .white
        progressBar.layer.cornerRadius = 3
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressContainer.addSubview(progressBar)
        
        NSLayoutConstraint.activate([
            progressContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            progressContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            progressContainer.widthAnchor.constraint(equalToConstant: 80),
            progressContainer.heightAnchor.constraint(equalToConstant: 6),
            
            progressBar.leadingAnchor.constraint(equalTo: progressContainer.leadingAnchor),
            progressBar.topAnchor.constraint(equalTo: progressContainer.topAnchor),
            progressBar.bottomAnchor.constraint(equalTo: progressContainer.bottomAnchor)
        ])
        
        progressWidthConstraint = progressBar.widthAnchor.constraint(equalTo: progressContainer.widthAnchor, multiplier: 0.33)
        progressWidthConstraint?.isActive = true
    }
    
    private func setupButtons() {
        func styleCircular(btn: UIButton, title: String) {
            btn.setTitle(title, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .bold)
            btn.setTitleColor(.white, for: .normal)
            btn.backgroundColor = UIColor.black.withAlphaComponent(0.25)
            btn.layer.cornerRadius = 25
            btn.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(btn)
        }
        
        styleCircular(btn: nextButton, title: "SWIPE →")
        styleCircular(btn: backButton, title: "← BACK")
        
        nextButton.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        backButton.isHidden = true
        
        // Setup Skip Button
        skipButton.setTitle("SKIP", for: .normal)
        skipButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .black)
        skipButton.setTitleColor(.white, for: .normal)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.addTarget(self, action: #selector(getStartedTapped), for: .touchUpInside)
        view.addSubview(skipButton)
        
        getStartedButton.setTitle("GET STARTED", for: .normal)
        getStartedButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        getStartedButton.setTitleColor(.white, for: .normal)
        getStartedButton.backgroundColor = UIColor(red: 0.40, green: 0.55, blue: 0.85, alpha: 1)
        getStartedButton.layer.cornerRadius = 28
        getStartedButton.isHidden = true
        getStartedButton.translatesAutoresizingMaskIntoConstraints = false
        getStartedButton.addTarget(self, action: #selector(getStartedTapped), for: .touchUpInside)
        view.addSubview(getStartedButton)
        
        NSLayoutConstraint.activate([
            // Skip Button Constraints (Top Right, below progress bar)
            skipButton.topAnchor.constraint(equalTo: progressContainer.bottomAnchor, constant: 8),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            nextButton.widthAnchor.constraint(equalToConstant: 100),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            
            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            backButton.widthAnchor.constraint(equalToConstant: 100),
            backButton.heightAnchor.constraint(equalToConstant: 50),
            
            getStartedButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -35),
            getStartedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getStartedButton.widthAnchor.constraint(equalToConstant: 280),
            getStartedButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    @objc private func handleNext() {
        let cellWidth = view.frame.width / 2
        let currentX = collectionView.contentOffset.x
        let targetX = currentX + cellWidth
        
        if targetX < collectionView.contentSize.width {
            collectionView.setContentOffset(CGPoint(x: targetX, y: 0), animated: true)
        }
    }
    
    @objc private func handleBack() {
        let cellWidth = view.frame.width / 2
        let currentX = collectionView.contentOffset.x
        let targetX = currentX - cellWidth
        
        if targetX >= 0 {
            collectionView.setContentOffset(CGPoint(x: targetX, y: 0), animated: true)
        }
    }
    
    @objc private func getStartedTapped() {
        let signUpVC = SignUpViewController()
        signUpVC.modalPresentationStyle = .fullScreen
        signUpVC.modalTransitionStyle = .crossDissolve
        self.present(signUpVC, animated: true)
    }
    
    private func updateProgress(fraction: CGFloat) {
        progressWidthConstraint?.isActive = false
        progressWidthConstraint = progressBar.widthAnchor.constraint(equalTo: progressContainer.widthAnchor, multiplier: fraction)
        progressWidthConstraint?.isActive = true
        UIView.animate(withDuration: 0.3) {
            self.progressContainer.layoutIfNeeded()
        }
    }
}

extension GetStartedViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrainCell", for: indexPath) as! TrainCell
        cell.configure(data: items[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width / 2, height: view.frame.height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let cellWidth = view.frame.width / 2
        let progress = offsetX / cellWidth
        let pageIndex = Int(round(progress))
        
        if pageIndex < items.count {
            UIView.animate(withDuration: 0.2) {
                self.view.backgroundColor = self.items[pageIndex].color
                // Adjust skip button color for clarity on light/dark backgrounds
                self.skipButton.setTitleColor(self.items[pageIndex].isDarkText ? .black : .white, for: .normal)
            }
        }

        if progress <= 0.5 {
            backButton.isHidden = true
            nextButton.isHidden = false
            getStartedButton.isHidden = true
            skipButton.isHidden = false
            updateProgress(fraction: 0.33)
        } else if progress > 0.5 && progress <= 1.5 {
            backButton.isHidden = false
            nextButton.isHidden = false
            getStartedButton.isHidden = true
            skipButton.isHidden = false
            updateProgress(fraction: 0.66)
        } else {
            backButton.isHidden = true
            nextButton.isHidden = true
            getStartedButton.isHidden = false
            skipButton.isHidden = true // Hide skip on the final screen
            updateProgress(fraction: 1.0)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let cellWidth = view.frame.width / 2
        let index = round(targetContentOffset.pointee.x / cellWidth)
        targetContentOffset.pointee = CGPoint(x: index * cellWidth, y: 0)
    }
}

class TrainCell: UICollectionViewCell {
    private let stack = UIStackView()
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let descLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private func setupUI() {
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        emojiLabel.font = .systemFont(ofSize: 60)
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.numberOfLines = 0
        descLabel.font = .systemFont(ofSize: 16, weight: .medium)
        descLabel.numberOfLines = 0
        
        stack.addArrangedSubview(emojiLabel)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(descLabel)
        
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -20),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.alpha = 1.0
        descLabel.alpha = 1.0
        emojiLabel.alpha = 1.0
    }
    
    func configure(data: (title: String, desc: String, emoji: String, color: UIColor, isDarkText: Bool)) {
        contentView.backgroundColor = data.color
        titleLabel.text = data.title
        descLabel.text = data.desc
        emojiLabel.text = data.emoji
        
        let textColor: UIColor = data.isDarkText ? .black : .white
        titleLabel.textColor = textColor
        descLabel.textColor = textColor.withAlphaComponent(0.8)
        
        titleLabel.alpha = 1.0
        descLabel.alpha = 1.0
        emojiLabel.alpha = 1.0
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

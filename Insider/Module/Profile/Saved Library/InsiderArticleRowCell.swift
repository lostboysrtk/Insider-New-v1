// MARK: - Filter Pill Cell
import UIKit
extension UIColor {
    static let insiderThemeBlue = UIColor(red: 0.40, green: 0.55, blue: 0.85, alpha: 1.0)
}
class InsiderFilterPillCell: UICollectionViewCell {
    static let reuseIdentifier = "InsiderFilterPillCell"
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        contentView.layer.cornerRadius = 19
        contentView.clipsToBounds = true
        
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(title: String, isSelected: Bool) {
        titleLabel.text = title
        if isSelected {
            // RESTORED: Original theme blue and white text
            contentView.backgroundColor = .insiderThemeBlue
            titleLabel.textColor = .white
        } else {
            // Unselected: Subtle gray with secondary text color
            contentView.backgroundColor = .systemGray6
            titleLabel.textColor = .secondaryLabel
        }
    }
}

// MARK: - Grid Library Cell
class InsiderGridFolderCell: UICollectionViewCell {
    static let reuseIdentifier = "InsiderGridFolderCell"
    private let thumbnail = UIImageView()
    private let titleLabel = UILabel()
    private let countLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    private func setupUI() {
        thumbnail.layer.cornerRadius = 16
        thumbnail.clipsToBounds = true
        thumbnail.contentMode = .scaleAspectFill
        thumbnail.backgroundColor = .secondarySystemBackground
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        countLabel.font = .systemFont(ofSize: 12)
        countLabel.textColor = .secondaryLabel
        [thumbnail, titleLabel, countLabel].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            thumbnail.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbnail.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbnail.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            thumbnail.heightAnchor.constraint(equalTo: thumbnail.widthAnchor, multiplier: 0.8),
            titleLabel.topAnchor.constraint(equalTo: thumbnail.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            countLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            countLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
        ])
    }
    func configure(with item: InsiderSavedItem) {
        titleLabel.text = item.title
        countLabel.text = "\(item.itemCount) items"
        if let url = URL(string: item.articleImageUrl) {
            URLSession.shared.dataTask(with: url) { [weak self] d, _, _ in
                if let d = d { DispatchQueue.main.async { self?.thumbnail.image = UIImage(data: d) } }
            }.resume()
        }
    }
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - Article Row Cell
class InsiderArticleRowCell: UITableViewCell {
    static let reuseIdentifier = "InsiderArticleRowCell"
    private let newsHeadline = UILabel()
    private let descLabel = UILabel()
    private let newsImage = UIImageView()
    private let separator = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        [newsHeadline, descLabel, newsImage, separator].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        newsHeadline.font = .systemFont(ofSize: 16, weight: .bold)
        newsHeadline.numberOfLines = 2
        descLabel.font = .systemFont(ofSize: 13)
        descLabel.textColor = .secondaryLabel
        descLabel.numberOfLines = 2
        newsImage.layer.cornerRadius = 10
        newsImage.clipsToBounds = true
        newsImage.contentMode = .scaleAspectFill
        separator.backgroundColor = .separator
        
        NSLayoutConstraint.activate([
            newsImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            newsImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            newsImage.widthAnchor.constraint(equalToConstant: 80),
            newsImage.heightAnchor.constraint(equalToConstant: 80),
            newsHeadline.topAnchor.constraint(equalTo: newsImage.topAnchor),
            newsHeadline.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            newsHeadline.trailingAnchor.constraint(equalTo: newsImage.leadingAnchor, constant: -12),
            descLabel.topAnchor.constraint(equalTo: newsHeadline.bottomAnchor, constant: 4),
            descLabel.leadingAnchor.constraint(equalTo: newsHeadline.leadingAnchor),
            descLabel.trailingAnchor.constraint(equalTo: newsHeadline.trailingAnchor),
            descLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 112),
            separator.leadingAnchor.constraint(equalTo: newsHeadline.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: newsImage.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    func configure(with item: NewsItem, isLast: Bool) {
        newsHeadline.text = item.title
        descLabel.text = item.description
        separator.isHidden = isLast
        if let urlStr = item.imageURL, let url = URL(string: urlStr) {
            URLSession.shared.dataTask(with: url) { [weak self] d, _, _ in
                if let d = d { DispatchQueue.main.async { self?.newsImage.image = UIImage(data: d) } }
            }.resume()
        }
    }
    required init?(coder: NSCoder) { fatalError() }
}

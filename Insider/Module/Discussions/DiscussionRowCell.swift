import UIKit

class DiscussionRowCell: UITableViewCell {
    
    // MARK: - Programmatic UI Elements
    private let discussionHeadline: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()
    
    private let newsHeadline: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()
    
    private let newsImage: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .systemGray6 // Placeholder color
        return iv
    }()
    
    private let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()

    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupHierarchy()
        setupAesthetics()
        setupEnforcedConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupHierarchy() {
        contentView.addSubview(newsHeadline)
        contentView.addSubview(discussionHeadline)
        contentView.addSubview(newsImage)
        contentView.addSubview(separatorLine)
    }

    private func setupAesthetics() {
        self.backgroundColor = .secondarySystemGroupedBackground
        self.selectionStyle = .none
    }

    private func setupEnforcedConstraints() {
        [newsImage, discussionHeadline, newsHeadline, separatorLine].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // IMAGE ON THE RIGHT: 80x80
            newsImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            newsImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            newsImage.widthAnchor.constraint(equalToConstant: 80),
            newsImage.heightAnchor.constraint(equalToConstant: 80),
            
            // HEADING AT TOP (Left of image)
            newsHeadline.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            newsHeadline.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            newsHeadline.trailingAnchor.constraint(equalTo: newsImage.leadingAnchor, constant: -12),
            
            // COMMENT BELOW HEADING
            discussionHeadline.topAnchor.constraint(equalTo: newsHeadline.bottomAnchor, constant: 4),
            discussionHeadline.leadingAnchor.constraint(equalTo: newsHeadline.leadingAnchor),
            discussionHeadline.trailingAnchor.constraint(equalTo: newsHeadline.trailingAnchor),
            discussionHeadline.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -20),
            
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 112),
            
            // SEPARATOR LINE
            separatorLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }

    func configure(with item: NewsItem, commentText: String, replyCount: Int, isLast: Bool) {
        newsHeadline.text = item.title
        separatorLine.isHidden = isLast
        discussionHeadline.text = commentText
        
        // Update the reply/like counts (assuming we have a label for these in the cell, if not we'll just ignore for now)
        // Many generic cells might have a reply label, if so we hook it up here.

        if let urlStr = item.imageURL, let url = URL(string: urlStr) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        self?.newsImage.image = UIImage(data: data)
                    }
                }
            }.resume()
        } else {
            newsImage.image = UIImage(systemName: "newspaper") // Fallback image
        }
    }
}

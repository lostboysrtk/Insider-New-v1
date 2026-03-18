import UIKit

class ReplyCell: UITableViewCell {
    private let container = UIView()
    private let replyLabel = UILabel()
    private let contextLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        contentView.addSubview(container)
        container.addSubview(contextLabel)
        container.addSubview(replyLabel)
        
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 12
        
        [container, contextLabel, replyLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            contextLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            contextLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            contextLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            
            replyLabel.topAnchor.constraint(equalTo: contextLabel.bottomAnchor, constant: 8),
            replyLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            replyLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            replyLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])
    }

    func configure(reply: ReplyData) {
        contextLabel.text = "Re: \(reply.articleTitle)"
        contextLabel.font = .boldSystemFont(ofSize: 12)
        replyLabel.text = reply.replyText
    }
}

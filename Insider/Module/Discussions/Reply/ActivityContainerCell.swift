import UIKit
class ActivityContainerCell: UITableViewCell {
    private let mainCard = UIView()
    private let headlineLabel = UILabel()
    private let myPostBox = UIView()
    private let myLabel = UILabel()
    private let repliesStack = UIStackView()
    private let viewRepliesBtn = UIButton(type: .system)
    
    var onToggleReplies: (() -> Void)?
    var onVote: ((Int, Bool) -> Void)?
    var onReply: ((Int) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        contentView.addSubview(mainCard)
        mainCard.backgroundColor = .secondarySystemGroupedBackground
        mainCard.layer.cornerRadius = 20
        
        // Visual Hierarchy: Headline -> Comment -> Replies
        headlineLabel.font = .systemFont(ofSize: 15, weight: .bold)
        headlineLabel.numberOfLines = 2
        mainCard.addSubview(headlineLabel)
        
        myPostBox.backgroundColor = .tertiarySystemFill
        myPostBox.layer.cornerRadius = 10
        mainCard.addSubview(myPostBox)
        
        myLabel.font = .italicSystemFont(ofSize: 13)
        myLabel.textColor = .secondaryLabel
        myLabel.numberOfLines = 0
        myPostBox.addSubview(myLabel)
        
        repliesStack.axis = .vertical; repliesStack.spacing = 10
        mainCard.addSubview(repliesStack)
        
        viewRepliesBtn.titleLabel?.font = .boldSystemFont(ofSize: 13)
        viewRepliesBtn.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
        mainCard.addSubview(viewRepliesBtn)
        
        [mainCard, headlineLabel, myPostBox, myLabel, repliesStack, viewRepliesBtn].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            mainCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            headlineLabel.topAnchor.constraint(equalTo: mainCard.topAnchor, constant: 16),
            headlineLabel.leadingAnchor.constraint(equalTo: mainCard.leadingAnchor, constant: 16),
            headlineLabel.trailingAnchor.constraint(equalTo: mainCard.trailingAnchor, constant: -16),
            myPostBox.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 12),
            myPostBox.leadingAnchor.constraint(equalTo: mainCard.leadingAnchor, constant: 16),
            myPostBox.trailingAnchor.constraint(equalTo: mainCard.trailingAnchor, constant: -16),
            myLabel.topAnchor.constraint(equalTo: myPostBox.topAnchor, constant: 10),
            myLabel.leadingAnchor.constraint(equalTo: myPostBox.leadingAnchor, constant: 10),
            myLabel.trailingAnchor.constraint(equalTo: myPostBox.trailingAnchor, constant: -10),
            myLabel.bottomAnchor.constraint(equalTo: myPostBox.bottomAnchor, constant: -10),
            repliesStack.topAnchor.constraint(equalTo: myPostBox.bottomAnchor, constant: 16),
            repliesStack.leadingAnchor.constraint(equalTo: mainCard.leadingAnchor, constant: 16),
            repliesStack.trailingAnchor.constraint(equalTo: mainCard.trailingAnchor, constant: -16),
            viewRepliesBtn.topAnchor.constraint(equalTo: repliesStack.bottomAnchor, constant: 8),
            viewRepliesBtn.leadingAnchor.constraint(equalTo: mainCard.leadingAnchor, constant: 16),
            viewRepliesBtn.bottomAnchor.constraint(equalTo: mainCard.bottomAnchor, constant: -16)
        ])
    }

    @objc private func toggleTapped() { onToggleReplies?() }

    func configure(with data: ReplyData) {
        headlineLabel.text = data.articleTitle
        myLabel.text = "You: \"\(data.myOriginalComment)\""
        repliesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let repliesToShow = data.isExpanded ? data.repliesToMe : Array(data.repliesToMe.prefix(2))
        for (index, reply) in repliesToShow.enumerated() {
            repliesStack.addArrangedSubview(createInteractiveReplyView(for: reply, index: index))
        }
        let remaining = data.repliesToMe.count - 2
        viewRepliesBtn.isHidden = remaining <= 0
        viewRepliesBtn.setTitle(data.isExpanded ? "Show Less" : "view \(data.repliesToMe.count) more replies", for: .normal)
    }
    
    private func createInteractiveReplyView(for comment: Comment, index: Int) -> UIView {
        let container = UIView(); container.backgroundColor = .systemBackground; container.layer.cornerRadius = 12
        let name = UILabel(); name.text = comment.userName; name.font = .boldSystemFont(ofSize: 13)
        let text = UILabel(); text.text = comment.text; text.font = .systemFont(ofSize: 13); text.numberOfLines = 0
        
        let upvote = UIButton(type: .system)
        upvote.setImage(UIImage(systemName: comment.voteStatus == .upvoted ? "hand.thumbsup.fill" : "hand.thumbsup"), for: .normal)
        upvote.setTitle(" \(comment.likes)", for: .normal)
        upvote.tintColor = comment.voteStatus == .upvoted ? .systemBlue : .secondaryLabel
        upvote.addAction(UIAction { _ in self.onVote?(index, true) }, for: .touchUpInside)
        
        let downvote = UIButton(type: .system)
        downvote.setImage(UIImage(systemName: comment.voteStatus == .downvoted ? "hand.thumbsdown.fill" : "hand.thumbsdown"), for: .normal)
        downvote.tintColor = comment.voteStatus == .downvoted ? .systemRed : .secondaryLabel
        downvote.addAction(UIAction { _ in self.onVote?(index, false) }, for: .touchUpInside)
        
        let replyBtn = UIButton(type: .system); replyBtn.setTitle("Reply", for: .normal); replyBtn.titleLabel?.font = .boldSystemFont(ofSize: 12)
        replyBtn.addAction(UIAction { _ in self.onReply?(index) }, for: .touchUpInside)
        
        let btnStack = UIStackView(arrangedSubviews: [upvote, downvote, replyBtn, UIView()]); btnStack.spacing = 15
        let mainStack = UIStackView(arrangedSubviews: [name, text, btnStack]); mainStack.axis = .vertical; mainStack.spacing = 6
        
        container.addSubview(mainStack); mainStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            mainStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            mainStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            mainStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 10)
        ])
        return container
    }
}

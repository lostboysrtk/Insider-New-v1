//
//  ActivityReplyCell.swift
//  Insider
//
//  Created by admin79 on 18/12/25.
//


import UIKit

class ActivityReplyCell: UITableViewCell {
    
    // UI Elements
    private let container = UIView()
    private let contextBox = UIView() // For "What you wrote"
    private let myOriginalLabel = UILabel()
    private let replyAuthorLabel = UILabel()
    private let timeLabel = UILabel()
    private let replyTextLabel = UILabel()
    
    // Interaction Buttons
    private let upvoteBtn = UIButton(type: .system)
    private let downvoteBtn = UIButton(type: .system)
    private let replyBtn = UIButton(type: .system)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        contentView.addSubview(container)
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 16
        
        // Context Box Setup (Your original post)
        contextBox.backgroundColor = .tertiarySystemFill
        contextBox.layer.cornerRadius = 8
        
        let quoteLine = UIView()
        quoteLine.backgroundColor = .systemBlue
        quoteLine.layer.cornerRadius = 2
        
        container.addSubview(contextBox)
        contextBox.addSubview(quoteLine)
        contextBox.addSubview(myOriginalLabel)
        
        // Reply Elements
        container.addSubview(replyAuthorLabel)
        container.addSubview(timeLabel)
        container.addSubview(replyTextLabel)
        
        // Interaction Stack
        let actionStack = UIStackView(arrangedSubviews: [upvoteBtn, downvoteBtn, replyBtn, UIView()])
        actionStack.axis = .horizontal
        actionStack.spacing = 20
        container.addSubview(actionStack)
        
        [container, contextBox, quoteLine, myOriginalLabel, replyAuthorLabel, 
         timeLabel, replyTextLabel, actionStack].forEach { 
            $0.translatesAutoresizingMaskIntoConstraints = false 
        }

        setupConstraints(quoteLine: quoteLine, actionStack: actionStack)
        setupButtonStyles()
    }

    private func setupConstraints(quoteLine: UIView, actionStack: UIStackView) {
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Context Box
            contextBox.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            contextBox.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            contextBox.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            
            quoteLine.leadingAnchor.constraint(equalTo: contextBox.leadingAnchor, constant: 8),
            quoteLine.topAnchor.constraint(equalTo: contextBox.topAnchor, constant: 8),
            quoteLine.bottomAnchor.constraint(equalTo: contextBox.bottomAnchor, constant: -8),
            quoteLine.widthAnchor.constraint(equalToConstant: 3),
            
            myOriginalLabel.topAnchor.constraint(equalTo: contextBox.topAnchor, constant: 8),
            myOriginalLabel.leadingAnchor.constraint(equalTo: quoteLine.trailingAnchor, constant: 8),
            myOriginalLabel.trailingAnchor.constraint(equalTo: contextBox.trailingAnchor, constant: -8),
            myOriginalLabel.bottomAnchor.constraint(equalTo: contextBox.bottomAnchor, constant: -8),
            
            // Reply Section
            replyAuthorLabel.topAnchor.constraint(equalTo: contextBox.bottomAnchor, constant: 12),
            replyAuthorLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            
            timeLabel.centerYAnchor.constraint(equalTo: replyAuthorLabel.centerYAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            
            replyTextLabel.topAnchor.constraint(equalTo: replyAuthorLabel.bottomAnchor, constant: 6),
            replyTextLabel.leadingAnchor.constraint(equalTo: replyAuthorLabel.leadingAnchor),
            replyTextLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            
            // Action Stack
            actionStack.topAnchor.constraint(equalTo: replyTextLabel.bottomAnchor, constant: 12),
            actionStack.leadingAnchor.constraint(equalTo: replyAuthorLabel.leadingAnchor),
            actionStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            actionStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            actionStack.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    private func setupButtonStyles() {
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        upvoteBtn.setImage(UIImage(systemName: "arrow.up", withConfiguration: config), for: .normal)
        downvoteBtn.setImage(UIImage(systemName: "arrow.down", withConfiguration: config), for: .normal)
        replyBtn.setImage(UIImage(systemName: "arrowshape.turn.up.left", withConfiguration: config), for: .normal)
        
        [upvoteBtn, downvoteBtn, replyBtn].forEach { 
            $0.tintColor = .secondaryLabel
            $0.setTitleColor(.secondaryLabel, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 13)
        }
    }

    func configure(reply: ReplyData) {
        myOriginalLabel.text = "You: \"\(reply.myOriginalComment)\""
        myOriginalLabel.font = .italicSystemFont(ofSize: 13)
        myOriginalLabel.numberOfLines = 2
        
        replyAuthorLabel.text = reply.replyAuthor
        replyAuthorLabel.font = .boldSystemFont(ofSize: 15)
        
        replyTextLabel.text = reply.replyText
        replyTextLabel.numberOfLines = 0
        
        timeLabel.text = reply.timeAgo
        upvoteBtn.setTitle(" 12", for: .normal) // Dummy vote count
    }
}
//
// DevKnowsChatViewController.swift
// Insider
//

import UIKit

class DevKnowsChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // MARK: - Context passed from caller
    var newsItemContext: NewsItem?
    
    // MARK: - IBOutlets (from storyboard)
    @IBOutlet weak var chatTableView: UITableView!   // Your table view from storyboard
    
    // MARK: - Programmatic Input Bar
    private let inputBar = UIView()
    private let txtField = UITextField()
    private let sendButton = UIButton(type: .system)
    private var inputBarBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Chat Data
    enum ChatRow {
        case welcome
        case suggestion(String)
        case userMessage(String)
    }
    
    var chatContent: [ChatRow] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "DevKnows"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark"),
            style: .plain,
            target: self,
            action: #selector(closeChat))
        
        setupTableView()
        setupInputBar()           // <- NEW
        setupKeyboardNotifications()
        
        setupInitialMessages()
    }
    
    // MARK: - Table View Setup
    private func setupTableView() {
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.separatorStyle = .none
        chatTableView.keyboardDismissMode = .interactive
        chatTableView.rowHeight = UITableView.automaticDimension
        chatTableView.estimatedRowHeight = 120
    }
    
    // MARK: - Programmatic Input Bar
    private func setupInputBar() {
        
        inputBar.backgroundColor = .systemBackground
        inputBar.layer.shadowColor = UIColor.black.cgColor
        inputBar.layer.shadowOpacity = 0.08
        inputBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        inputBar.layer.shadowRadius = 6
        
        view.addSubview(inputBar)
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        
        inputBarBottomConstraint =
        inputBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            inputBarBottomConstraint,
            inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputBar.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        // ----- Text Field -----
        txtField.placeholder = "Ask Anything..."
        txtField.backgroundColor = .systemGray6
        txtField.layer.cornerRadius = 20
        txtField.font = .systemFont(ofSize: 16)
        txtField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        txtField.leftViewMode = .always
        txtField.delegate = self
        
        inputBar.addSubview(txtField)
        txtField.translatesAutoresizingMaskIntoConstraints = false
        
        // ----- Send Button -----
        let icon = UIImage(systemName: "arrow.up.circle.fill",
                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .bold))
        
        sendButton.setImage(icon, for: .normal)
        sendButton.tintColor = .systemBlue
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        
        inputBar.addSubview(sendButton)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            txtField.leadingAnchor.constraint(equalTo: inputBar.leadingAnchor, constant: 16),
            txtField.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            txtField.heightAnchor.constraint(equalToConstant: 40),
            txtField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -12),
            
            sendButton.trailingAnchor.constraint(equalTo: inputBar.trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 44),
            sendButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - Keyboard Handling
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        inputBarBottomConstraint.constant = -frame.height
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
        scrollToBottom()
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        inputBarBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }
    
    @objc private func closeChat() { dismiss(animated: true) }
    
    // MARK: - Chat Logic
    private func setupInitialMessages() {
        chatContent.append(.welcome)
        
        // If a news item context is provided, surface a contextual suggestion
        if let item = newsItemContext {
            let suggestionText = "Ask about: \(item.title)"
            chatContent.append(.suggestion(suggestionText))
        } else {
            chatContent.append(.suggestion("Show recent tech news"))
        }
        
        chatTableView.reloadData()
    }
    
    @objc private func sendMessage() {
        guard let text = txtField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        chatContent.append(.userMessage(text))
        txtField.text = ""
        txtField.resignFirstResponder()
        
        chatTableView.reloadData()
        scrollToBottom()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
    
    private func scrollToBottom() {
        if chatContent.count == 0 { return }
        let last = IndexPath(row: chatContent.count - 1, section: 0)
        chatTableView.scrollToRow(at: last, at: .bottom, animated: true)
    }
    
    // MARK: - TableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatContent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = chatContent[indexPath.row]
        
        switch row {
            
        case .welcome:
            let cell = tableView.dequeueReusableCell(withIdentifier: "WelcomeCell", for: indexPath) as! WelcomeTableViewCell
            cell.configure(
                greeting: "Hi! I am DevKnows, your AI-Assistant",
                question: "What Would You Like To Know ?"
            )
            return cell
        case .suggestion(let text):
            let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionButtonCell", for: indexPath)

            // Clean up previous
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            cell.selectionStyle = .none

            // Background card
            let card = UIView()
            card.backgroundColor = UIColor.systemGray6
            card.layer.cornerRadius = 14
            card.translatesAutoresizingMaskIntoConstraints = false

            // Label
            let label = UILabel()
            label.text = text
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            label.textAlignment = .center
            label.textColor = .label
            label.translatesAutoresizingMaskIntoConstraints = false

            cell.contentView.addSubview(card)
            card.addSubview(label)

            NSLayoutConstraint.activate([
                card.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                card.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                card.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
                card.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10),

                label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
                label.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
                label.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
            ])
            return cell
        case .userMessage(let message):
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatBubbleCell", for: indexPath)
            cell.selectionStyle = .none
            
            // Remove previous content
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            
            // Bubble background container
            let bubbleView = UIView()
            bubbleView.backgroundColor = .systemBlue
            bubbleView.layer.cornerRadius = 18
            bubbleView.translatesAutoresizingMaskIntoConstraints = false
            
            // Label inside bubble
            let label = UILabel()
            label.text = message
            label.textColor = .white
            label.font = UIFont.systemFont(ofSize: 17)
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            
            cell.contentView.addSubview(bubbleView)
            bubbleView.addSubview(label)
            
            NSLayoutConstraint.activate([
                bubbleView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 6),
                bubbleView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -6),
                
                // BUBBLE width constraint (fixes your ugly stretched bubble)
                bubbleView.widthAnchor.constraint(lessThanOrEqualToConstant: UIScreen.main.bounds.width * 0.70),
                
                // Align to right
                bubbleView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                
                // Label inside bubble padding
                label.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
                label.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
                label.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
                label.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -12)
            ])
            
            return cell
        }
    }
}

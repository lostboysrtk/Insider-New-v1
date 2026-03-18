import UIKit

// MARK: - Models
struct ChatMessage {
    let text: String
    let isUser: Bool
    let isError: Bool
}

class DevKnowsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    // MARK: - Properties
    var newsItemContext: NewsItem?
    private var messages: [ChatMessage] = []
    
    // Theme Colors
    private let getStartedBlue = UIColor(red: 0.40, green: 0.55, blue: 0.85, alpha: 1.0)
    private let apiKey = ""
    
    // MARK: - UI Elements
    private let topBar = UIView()
    private let backButton = UIButton(type: .system)
    private let tableView = UITableView()
    private let inputContainer = UIView()
    private let inputField = UITextField()
    private let sendButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        // ADAPTIVE: Use systemBackground instead of solid white
        view.backgroundColor = .systemBackground
        setupUI()
        setupConstraints()
        setupTableHeader()
        
        tableView.register(ChatBubbleCell.self, forCellReuseIdentifier: "ChatBubbleCell")
    }
    
    private func setupUI() {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        backButton.tintColor = .label // ADAPTIVE
        backButton.backgroundColor = .secondarySystemBackground // ADAPTIVE
        backButton.layer.cornerRadius = 20
        backButton.addTarget(self, action: #selector(dismissScreen), for: .touchUpInside)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.keyboardDismissMode = .interactive
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        
        // ADAPTIVE: Input bar styling
        inputContainer.backgroundColor = .secondarySystemBackground
        inputContainer.layer.cornerRadius = 28
        inputContainer.layer.borderWidth = 1
        inputContainer.layer.borderColor = UIColor.separator.cgColor
        
        inputField.placeholder = "Ask DevKnows..."
        inputField.font = .systemFont(ofSize: 16)
        inputField.textColor = .label // ADAPTIVE
        inputField.delegate = self
        inputField.returnKeyType = .send
        
        sendButton.backgroundColor = getStartedBlue
        let arrowConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .black)
        sendButton.setImage(UIImage(systemName: "arrow.up", withConfiguration: arrowConfig), for: .normal)
        sendButton.tintColor = .white
        sendButton.layer.cornerRadius = 20
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = getStartedBlue
        
        view.addSubview(tableView)
        view.addSubview(topBar)
        topBar.addSubview(backButton)
        view.addSubview(inputContainer)
        inputContainer.addSubview(inputField)
        inputContainer.addSubview(sendButton)
        inputContainer.addSubview(loadingIndicator)
    }
    
    private func setupTableHeader() {
        let headerView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = "Hi ! I am DevKnows"
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = .secondaryLabel // ADAPTIVE
        titleLabel.textAlignment = .center
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "What Would You Like\nTo Know ?"
        subtitleLabel.font = .systemFont(ofSize: 34, weight: .heavy)
        subtitleLabel.numberOfLines = 2
        subtitleLabel.textColor = .label // ADAPTIVE
        subtitleLabel.textAlignment = .center
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 14
        stackView.alignment = .center
        
        stackView.addArrangedSubview(createSuggestionBtn(title: "Tell me more"))
        stackView.addArrangedSubview(createSuggestionBtn(title: "Summarize this article"))
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        headerView.addSubview(stackView)
        
        [titleLabel, subtitleLabel, stackView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 60),
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 30),
            stackView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 250),
            stackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -30)
        ])
        
        headerView.layoutIfNeeded()
        let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: size.height)
        tableView.tableHeaderView = headerView
    }
    
    private func createSuggestionBtn(title: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle("  \(title)  ", for: .normal)
        btn.backgroundColor = .secondarySystemBackground // ADAPTIVE
        btn.setTitleColor(.label, for: .normal) // ADAPTIVE
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.layer.cornerRadius = 24
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.separator.cgColor
        btn.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        
        btn.addAction(UIAction { [weak self] _ in
            self?.performChatRequest(with: title)
        }, for: .touchUpInside)
        
        return btn
    }

    private func setupConstraints() {
        [topBar, backButton, tableView, inputContainer, inputField, sendButton, loadingIndicator].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 60),
            
            backButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),
            
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            inputContainer.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -20),
            inputContainer.heightAnchor.constraint(equalToConstant: 56),
            
            inputField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 20),
            inputField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            inputField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            
            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 40),
            sendButton.heightAnchor.constraint(equalToConstant: 40),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: sendButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor)
        ])
    }

    @objc private func dismissScreen() { dismiss(animated: true) }
    
    @objc private func sendMessage() {
        guard let text = inputField.text, !text.isEmpty else { return }
        performChatRequest(with: text)
    }
    
    func performChatRequest(with text: String) {
        messages.append(ChatMessage(text: text, isUser: true, isError: false))
        inputField.text = ""
        tableView.reloadData()
        scrollToBottom()
        fetchGroqResponse(for: text)
    }

    private func scrollToBottom() {
        if !messages.isEmpty {
            tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true)
        }
    }

    private func fetchGroqResponse(for prompt: String) {
        sendButton.isHidden = true
        loadingIndicator.startAnimating()
        
        var finalUserPrompt = prompt
        if let news = newsItemContext {
            finalUserPrompt = """
            ARTICLE TO REFERENCE:
            Title: \(news.title)
            Description: \(news.description)
            Source: \(news.source)
            
            USER QUESTION:
            \(prompt)
            """
        }
        
        let url = URL(string: "https://api.groq.com/openai/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonBody: [String: Any] = [
            "model": "llama-3.1-8b-instant",
            "messages": [
                ["role": "system", "content": "You are DevKnows, a helpful coding assistant. Use the provided article context to answer concisely."],
                ["role": "user", "content": finalUserPrompt]
            ],
            "temperature": 0.3,
            "max_tokens": 500
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: jsonBody)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.sendButton.isHidden = false
                self?.loadingIndicator.stopAnimating()
                
                if let error = error {
                    self?.addBotResponse("Connection error: \(error.localizedDescription)", isError: true)
                    return
                }
                
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let content = choices.first?["message"] as? [String: Any],
                   let text = content["content"] as? String {
                    self?.addBotResponse(text.trimmingCharacters(in: .whitespacesAndNewlines))
                } else {
                    self?.addBotResponse("I'm having trouble seeing the article right now. Please try again.", isError: true)
                }
            }
        }.resume()
    }
    
    private func addBotResponse(_ text: String, isError: Bool = false) {
        messages.append(ChatMessage(text: text, isUser: false, isError: isError))
        tableView.reloadData()
        scrollToBottom()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { messages.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatBubbleCell", for: indexPath) as! ChatBubbleCell
        cell.configure(with: messages[indexPath.row])
        return cell
    }
}

// MARK: - Custom Chat Cell (Adaptive Theme)
class ChatBubbleCell: UITableViewCell {
    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    private var leadingConstraint: NSLayoutConstraint!
    private var trailingConstraint: NSLayoutConstraint!
    
    private let getStartedBlue = UIColor(red: 0.40, green: 0.55, blue: 0.85, alpha: 1.0)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        
        bubbleView.layer.cornerRadius = 20
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleView)
        
        messageLabel.numberOfLines = 0
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            bubbleView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.80),
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -16)
        ])
        
        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
    }
    
    func configure(with message: ChatMessage) {
        messageLabel.text = message.text
        if message.isUser {
            bubbleView.backgroundColor = getStartedBlue
            messageLabel.textColor = .white
            leadingConstraint.isActive = false
            trailingConstraint.isActive = true
            bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner]
        } else {
            // ADAPTIVE: Use secondarySystemBackground for Bot bubbles
            bubbleView.backgroundColor = .secondarySystemBackground
            messageLabel.textColor = .label // Automatically turns white in dark mode
            trailingConstraint.isActive = false
            leadingConstraint.isActive = true
            bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

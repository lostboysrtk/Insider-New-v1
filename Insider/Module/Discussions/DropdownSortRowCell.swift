import UIKit

class DropdownSortRowCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let menuButton = UIButton(type: .system)
    private var onSelection: ((Int) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        backgroundColor = .secondarySystemGroupedBackground
        selectionStyle = .none
        
        titleLabel.text = "SORT BY"
        titleLabel.font = .systemFont(ofSize: 11, weight: .bold)
        titleLabel.textColor = .tertiaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Dropdown Button Setup
        menuButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        menuButton.setTitleColor(.label, for: .normal)
        menuButton.semanticContentAttribute = .forceRightToLeft
        menuButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        menuButton.tintColor = .secondaryLabel
        menuButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.showsMenuAsPrimaryAction = true // ⭐️ Crucial for dropdown behavior
        contentView.addSubview(menuButton)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            menuButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            menuButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            contentView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    func configure(selectedTitle: String, onSelection: @escaping (Int) -> Void) {
        self.onSelection = onSelection
        menuButton.setTitle(selectedTitle, for: .normal)
        
        // Define Menu Items
        let items = [
            UIAction(title: "Recent", image: UIImage(systemName: "clock")) { _ in onSelection(0) },
            UIAction(title: "Most Liked", image: UIImage(systemName: "hand.thumbsup")) { _ in onSelection(1) },
            UIAction(title: "Top Replies", image: UIImage(systemName: "bubble.left")) { _ in onSelection(2) }
        ]
        
        // Set specific checkmark to the current selection
        switch selectedTitle {
        case "Recent": items[0].state = .on
        case "Most Liked": items[1].state = .on
        case "Top Replies": items[2].state = .on
        default: break
        }
        
        menuButton.menu = UIMenu(title: "Sort Discussions", children: items)
    }
}

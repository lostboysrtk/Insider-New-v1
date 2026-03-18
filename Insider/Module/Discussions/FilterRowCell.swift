import UIKit

class FilterRowCell: UITableViewCell {
    let startedJoinedButton = UISegmentedControl(items: ["Started By Me", "Joined By Me"])
    var onFilterChanged: ((Int) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = .secondarySystemGroupedBackground
        selectionStyle = .none
        startedJoinedButton.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        startedJoinedButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(startedJoinedButton)
        
        NSLayoutConstraint.activate([
            // Minimal top constant to pull it closer to the graph cell
            startedJoinedButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            startedJoinedButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            startedJoinedButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            startedJoinedButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
    }

    @objc private func segmentChanged() { onFilterChanged?(startedJoinedButton.selectedSegmentIndex) }
}

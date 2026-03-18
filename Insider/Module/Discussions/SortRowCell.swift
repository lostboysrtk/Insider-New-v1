//
//  SortRowCell.swift
//  Insider
//
//  Created by admin79 on 21/12/25.
//


import UIKit

class SortRowCell: UITableViewCell {
    let sortSegmentedControl = UISegmentedControl(items: ["Recent", "Most Liked", "Top Replies"])
    var onSortChanged: ((Int) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        backgroundColor = .secondarySystemGroupedBackground
        selectionStyle = .none
        
        // Native iOS styling for secondary filters
        sortSegmentedControl.selectedSegmentTintColor = UIColor.systemGray5
        sortSegmentedControl.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 12, weight: .medium)], for: .normal)
        
        sortSegmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        sortSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(sortSegmentedControl)
        
        NSLayoutConstraint.activate([
            sortSegmentedControl.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            sortSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            sortSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            sortSegmentedControl.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 12),
            sortSegmentedControl.heightAnchor.constraint(equalToConstant: 28) // Slightly slimmer than main filter
        ])
    }

    @objc private func segmentChanged() {
        onSortChanged?(sortSegmentedControl.selectedSegmentIndex)
    }
}
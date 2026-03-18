//
//  ToolkitDetailViewController.swift
//  Insider
//
//  Created by Sarthak Sharma on 22/12/25.
//
import UIKit

class ToolkitDetailViewController: UIViewController {
    var toolkitName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = toolkitName
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let label = UILabel()
        label.text = "Browsing all \(toolkitName ?? "Tech") documentation and updates..."
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
}

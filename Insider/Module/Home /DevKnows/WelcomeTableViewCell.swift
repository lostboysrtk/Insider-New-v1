// WelcomeTableViewCell.swift

import UIKit

class WelcomeTableViewCell: UITableViewCell {

    // MARK: - IBOutlets (MUST BE CONNECTED FROM STORYBOARD)
    // You must connect the two labels in your prototype cell to these outlets.
    @IBOutlet weak var greetingLabel: UILabel!
    
    @IBOutlet weak var questionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // CRITICAL FIX: Explicitly hide the default labels inherited from UITableViewCell
        self.textLabel?.isHidden = true
        self.detailTextLabel?.isHidden = true
        
        // Set selection style to none since this is a static message cell
        self.selectionStyle = .none
    }

    func configure(greeting: String, question: String) {
        // Set text using your custom outlets
        greetingLabel.text = greeting
        questionLabel.text = question
    }
}

import UIKit

protocol DiscussionsHeaderDelegate: AnyObject {
    func didChangeFilter(to index: Int)
    func didTapGraphDay(dayIndex: Int) // Navigation Delegate
}


   
// MARK: - Local Hex Helper
// Renamed initializer to avoid redeclaration conflicts

//
//   Uicolor+brand .swift
//  Insider
//
//  Created by Sarthak Sharma on 10/03/26.
//

//
//  UIColor+Brand.swift
//  Insider
//
//  Single source of truth for the app's brand purple.
//  Use UIColor.brand everywhere instead of .systemBlue / .systemIndigo.
//

import UIKit

extension UIColor {
    /// The app's primary brand purple — matches the selected filter chip colour.
    static let brand = UIColor(red: 0.40, green: 0.52, blue: 0.89, alpha: 1.0)
}

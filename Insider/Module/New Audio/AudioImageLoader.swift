//
//  AudioImageLoader.swift
//  Insider
//
//  Created by Sarthak Sharma on 18/01/26.
//

// AudioImageLoader.swift

import UIKit

class AudioImageLoader {
    static let shared = AudioImageLoader()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        cache.countLimit = 100 // Prevent memory issues
    }
    
    func loadImage(from urlString: String?, into imageView: UIImageView) {
        imageView.image = nil
        
        guard let urlString = urlString, let url = URL(string: urlString) else {
            imageView.backgroundColor = .systemGray6
            imageView.image = UIImage(systemName: "photo")
            imageView.tintColor = .systemGray4
            return
        }
        
        let cacheKey = urlString as NSString
        if let cachedImage = cache.object(forKey: cacheKey) {
            imageView.image = cachedImage
            return
        }
        
        let tag = urlString.hashValue
        imageView.tag = tag
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data), let self = self else { return }
            
            self.cache.setObject(image, forKey: cacheKey)
            
            DispatchQueue.main.async {
                if imageView.tag == tag {
                    UIView.transition(with: imageView, duration: 0.3, options: .transitionCrossDissolve) {
                        imageView.image = image
                    }
                }
            }
        }.resume()
    }
}

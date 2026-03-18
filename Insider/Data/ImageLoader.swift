// ImageLoader.swift (Create this new file)

import UIKit

class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSString, UIImage>()
    private init() {}
    
    // Downloads and caches an image, setting it on a UIImageView
    func loadImage(from urlString: String?, into imageView: UIImageView) {
        // Clear previous download task/state
        imageView.image = nil
        imageView.backgroundColor = .systemGray6

        guard let urlString = urlString, let url = URL(string: urlString) else {
            imageView.backgroundColor = .systemGray5
            return
        }
        
        // Use the URL hash to track reuse during fast scrolling
        imageView.tag = urlString.hashValue
        
        // 1. Check cache first
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            imageView.image = cachedImage
            return
        }
        
        let initialTag = imageView.tag
        
        // 2. Download image asynchronously
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil,
                  let image = UIImage(data: data) else {
                
                DispatchQueue.main.async {
                    if imageView.tag == initialTag {
                        imageView.backgroundColor = .systemGray4
                    }
                }
                return
            }
            
            self.cache.setObject(image, forKey: urlString as NSString)
            
            DispatchQueue.main.async {
                // 3. Only set the image if the cell hasn't been reused for a different URL
                if imageView.tag == initialTag {
                     imageView.image = image
                }
            }
        }.resume()
    }
}

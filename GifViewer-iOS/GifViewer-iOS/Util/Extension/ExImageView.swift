//
//  ExImageView.swift
//  GifViewer
//
//  Created by Chang-Hoon Han on 2020/08/03.
//  Copyright © 2020 Chang-Hoon Han. All rights reserved.
//

import UIKit

extension UIImageView {

    public func loadGif(name: String) {
        /**
         * OperationQueue 사용법
         * https://zeddios.tistory.com/512?category=682195
         *
         OperationQueue().addOperation {
             let image = UIImage.gif(name: name)
             OperationQueue.main.addOperation {
                self.image = image
             }
         }*/
        
        /**
         * DispatchQueue 사용법
         * https://zeddios.tistory.com/516
         */
        DispatchQueue.global().async {
            let image = UIImage.gif(name: name)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }

    @available(iOS 9.0, *)
    public func loadGif(asset: String) {
        /*
        OperationQueue().addOperation {
            let image = UIImage.gif(asset: asset)
            OperationQueue.main.addOperation {
                self.image = image
            }
        }*/
        DispatchQueue.global().async {
            let image = UIImage.gif(asset: asset)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }

}

extension UIImageView {
    /// Loads image from web asynchronosly and caches it, in case you have to load url
    /// again, it will be loaded from cache if available
    func load(url: URL, placeholder: UIImage?, cache: URLCache? = nil) {
        let cache = cache ?? URLCache.shared
        let request = URLRequest(url: url)
        if let data = cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) {
            self.image = image
        } else {
            self.image = placeholder
            URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let data = data, let response = response, ((response as? HTTPURLResponse)?.statusCode ?? 500) < 300, let image = UIImage(data: data) {
                    let cachedData = CachedURLResponse(response: response, data: data)
                    cache.storeCachedResponse(cachedData, for: request)
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
            }).resume()
        }
    }
}

//
//  PhotosDownloadService.swift
//  PhotoSearcher
//
//  Created by Mihaela Simion on 11/3/20.
//

import UIKit

struct PhotosDownloadService {

  static func downloadPhotoFrom(previewUrl: URL?,
                                largeImageUrl: URL?,
                                completion: @escaping (UIImage?) -> Void) {
    let url = previewUrl != nil ? previewUrl : largeImageUrl
    guard let imageUrl = url else {
      completion(nil)
      return
    }
    URLSession.shared.dataTask(with: imageUrl) { data, _, error in
      if error == nil,
         let data = data,
         let image = UIImage(data: data) {
        DispatchQueue.main.async {
          completion(image)
        }
      } else {
        DispatchQueue.main.async {
          completion(nil)
        }
      }
    }.resume()
  }
}

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
                                completionDispatchQueue: DispatchQueue = DispatchQueue.main,
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
        completionDispatchQueue.async {
          completion(image)
        }
      } else {
        completionDispatchQueue.async {
          completion(nil)
        }
      }
    }.resume()
  }
}

//
//  FullScreenViewModel.swift
//  PhotoSearcher
//
//  Created by Mihaela Simion on 11/5/20.
//

import UIKit.UIImage

class FullScreenViewModel {
  var photos: [LargePhoto] = []

  func downloadLargePhotoForCellAt(indexPath: IndexPath,
                                   completion: @escaping (UIImage?) -> Void) {
    guard let url = URL(string: photos[indexPath.row].url) else {
      completion(nil)
      return }
    PhotosDownloadService.downloadPhotoFrom(previewUrl: nil,
                                            largeImageUrl: url) { image in
      self.photos[indexPath.row].largeImage = image
      completion(image)
    }
  }

  func getPhotoFor(indexPath: IndexPath) -> UIImage? {
    return photos[indexPath.row].largeImage
  }
}

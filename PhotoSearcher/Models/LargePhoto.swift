//
//  LargePhoto.swift
//  PhotoSearcher
//
//  Created by Mihaela Simion on 11/3/20.
//

import UIKit

class LargePhoto {
  let url: String
  var largeImage: UIImage?

  init(photoData: PhotoData) {
    self.url = photoData.largeImageURL
  }
}

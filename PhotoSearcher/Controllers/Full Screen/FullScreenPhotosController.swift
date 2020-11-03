//
//  FullScreenPhotosVC.swift
//  PhotoSearcher
//
//  Created by Mihaela Simion on 11/2/20.
//

import UIKit

class FullScreenPhotosController: UIViewController {
  var selectedPhotoIndex: Int?
  var photos: [LargePhoto] = []

  override func viewDidLoad() {
    super.viewDidLoad()
  }
}
// always have selected image at load, then at swipe if image is nil, show activity indicator and download large image

//
//  PhotoCollectionViewCell.swift
//  PhotoSearcher
//
//  Created by Mihaela Simion on 11/2/20.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var containerView: UIView!
  @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
  
  func display(previewPhoto: UIImage?) {
    containerView.layer.cornerRadius = 8
    containerView.backgroundColor = .lightGray
    imageView.image = previewPhoto
  }
  
  func display(largePhoto: UIImage?) {
    containerView.backgroundColor = .white
    imageView.image = largePhoto
  }
  
  func isImageNil() -> Bool {
    return imageView.image == nil
  }
  
  func startActivityIndicator() {
    activityIndicator.startAnimating()
  }
  
  func stopActivityIndicator() {
    activityIndicator.stopAnimating()
  }
  
  func isActivityIndicatorAnimating() -> Bool {
    return activityIndicator.isAnimating
  }
}

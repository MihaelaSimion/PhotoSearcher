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

  func display(previewPhoto: UIImage?) {
    containerView.layer.cornerRadius = 8
    containerView.backgroundColor = .lightGray
    imageView.image = previewPhoto
  }

  func display(largePhoto: UIImage?) {
    containerView.backgroundColor = .clear
    imageView.image = largePhoto
  }
}

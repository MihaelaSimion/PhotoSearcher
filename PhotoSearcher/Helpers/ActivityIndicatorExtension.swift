//
//  ActivityIndicatorExtension.swift
//  PhotoSearcher
//
//  Created by Mihaela Simion on 11/3/20.
//

import UIKit

extension UIActivityIndicatorView {
  func showActivityIndicatorInView(view: UIView) {
    guard self.isAnimating == false else { return }
    self.center = view.center
    self.hidesWhenStopped = true
    self.style = .large
    self.color = .black
    view.addSubview(self)
    self.startAnimating()
    view.isUserInteractionEnabled = false
  }

  func stopActivityIndicator(view: UIView) {
    self.stopAnimating()
    view.isUserInteractionEnabled = true
  }
}

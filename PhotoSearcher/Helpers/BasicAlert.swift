//
//  BasicAlert.swift
//  PhotoSearcher
//
//  Created by Mihaela Simion on 11/3/20.
//

import UIKit

struct BasicAlert {
  static func showAlert(message: String,
                        viewController: UIViewController,
                        handler: ((UIAlertAction) -> Void)? = nil) {
    let alertController = UIAlertController(title: nil,
                                            message: message,
                                            preferredStyle: .alert)
    let action = UIAlertAction(title: "OK",
                               style: .default,
                               handler: handler)
    alertController.addAction(action)

    viewController.present(alertController, animated: true)
  }
}

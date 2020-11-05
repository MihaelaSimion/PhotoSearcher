//
//  SuccessfulSearchTableViewCell.swift
//  PhotoSearcher
//
//  Created by Mihaela Simion on 11/2/20.
//

import UIKit

class SugestedSearchTableViewCell: UITableViewCell {

  @IBOutlet private weak var queryLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    selectionStyle = .none
  }

  func showSearchQuery(query: String) {
    queryLabel.text = query
  }
}

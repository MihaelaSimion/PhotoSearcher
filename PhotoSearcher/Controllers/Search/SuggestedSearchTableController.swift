//
//  SuggestedSearchTableViewController.swift
//  PhotoSearcher
//
//  Created by Mihaela Simion on 11/2/20.
//

import UIKit

class SuggestedSearchTableController: UITableViewController {
  var previousSuccessfulSearches = ["cat", "dog", "parrots"]

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(UINib(nibName: "SugestedSearchTableCell", bundle: nil),
                       forCellReuseIdentifier: "SugestedSearchTableCell")
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return previousSuccessfulSearches.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let searchCell = tableView.dequeueReusableCell(withIdentifier: "SugestedSearchTableCell",
                                                   for: indexPath) as? SugestedSearchTableViewCell
    searchCell?.showSearchQuery(query: previousSuccessfulSearches[indexPath.row])

    return searchCell ?? UITableViewCell()
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // TODO - perform search
  }
}

extension SuggestedSearchTableController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    if searchController.searchBar.text?.isEmpty == true {
      view.isHidden = false
      // fetch last 10 searches from DB
      tableView.reloadData()
    } else {
      view.isHidden = true
    }
  }
}

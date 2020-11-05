//
//  SuggestedSearchTableViewController.swift
//  PhotoSearcher
//
//  Created by Mihaela Simion on 11/2/20.
//

import UIKit

protocol SuggestedSearchDelegate: AnyObject {
  func performSearchFor(query: String)
}

class SuggestedSearchTableController: UITableViewController {
  var previousSuccessfulSearches: [String] = []
  lazy var successfulSearchHandler: SuccessfulSearchHandler = CoreDataManager()
  weak var suggestedSearchDelegate: SuggestedSearchDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(UINib(nibName: "SugestedSearchTableCell", bundle: nil),
                       forCellReuseIdentifier: "SugestedSearchTableCell")
  }

  // MARK: - TableView delegates
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
    let selectedQuery = previousSuccessfulSearches[indexPath.row]
    suggestedSearchDelegate?.performSearchFor(query: selectedQuery)
  }
}

extension SuggestedSearchTableController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    if searchController.searchBar.text?.isEmpty == true {
      view.isHidden = false
      previousSuccessfulSearches = successfulSearchHandler.fetchSearchQueries()
      tableView.reloadData()
    } else {
      view.isHidden = true
    }
  }
}

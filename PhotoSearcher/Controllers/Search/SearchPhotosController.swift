//
//  ViewController.swift
//  PhotoSearcher
//
//  Created by Mihaela Simion on 11/2/20.
//

import UIKit

class SearchPhotosController: UIViewController {
  var searchController: UISearchController?

  @IBOutlet private weak var photosCollectionView: UICollectionView!

  override func viewDidLoad() {
    super.viewDidLoad()
    photosCollectionView.dataSource = self
    photosCollectionView.delegate = self
    photosCollectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil),
                                  forCellWithReuseIdentifier: "PhotoCollectionViewCell")
    setUpSearchController()
    configureCollectionItemSize()
  }

  func setUpSearchController() {
    let suggestedSearchTableController = SuggestedSearchTableController()
    searchController = UISearchController(searchResultsController: suggestedSearchTableController)
    searchController?.searchResultsUpdater = suggestedSearchTableController
    searchController?.obscuresBackgroundDuringPresentation = false
    searchController?.searchBar.placeholder = "Search photos"
    searchController?.searchBar.tintColor = .black
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
  }

  func configureCollectionItemSize() {
    guard let layout = photosCollectionView.collectionViewLayout
            as? UICollectionViewFlowLayout else { return }
    let trailingAndLeadingContstraints: CGFloat = 24 * 2
    let spacing: CGFloat = 16
    let splitScreenWidthIn: CGFloat = 2
    let width = (view.frame.width - trailingAndLeadingContstraints - spacing) / splitScreenWidthIn
    layout.itemSize = CGSize(width: width, height: 180)
  }
}

extension SearchPhotosController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 4
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let photoCell = photosCollectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell",
                                                             for: indexPath) as? PhotoCollectionViewCell

    photoCell?.display(previewPhoto: nil)
    // download preview and large then set again - dispatch group
    return photoCell ?? UICollectionViewCell()
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // TODO - show full screen
  }
}


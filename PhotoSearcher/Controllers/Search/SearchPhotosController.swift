//
//  ViewController.swift
//  PhotoSearcher
//
//  Created by Mihaela Simion on 11/2/20.
//

import UIKit

final class SearchPhotosController: UIViewController {
  private let searchViewModel = SearchViewModel()
  private var searchController: UISearchController?
  private var itemSize: CGSize?
  private let itemsSpacing: CGFloat = 16
  private lazy var activityIndicator = UIActivityIndicatorView()
  private var selectedPreviewPhotoIndexPath: IndexPath?
  
  @IBOutlet private weak var previewsCollectionView: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    previewsCollectionView.dataSource = self
    previewsCollectionView.delegate = self
    previewsCollectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil),
                                    forCellWithReuseIdentifier: "PhotoCollectionViewCell")
    previewsCollectionView.contentInset.top = 16
    previewsCollectionView.contentInset.bottom = 16

    addObservers()
    setUpSearchController()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == "ShowFullScreen",
          let fullScreenPhotosController = segue.destination as? FullScreenPhotosController else { return }
    fullScreenPhotosController.initialPhotoIndex = selectedPreviewPhotoIndexPath?.row
    fullScreenPhotosController.photos = searchViewModel.largePhotos
  }

  func addObservers() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(scrollToLastPhotoViewedInFullScreen(_:)),
                                           name: .UserSwipedToNewPhotoInFullScreen,
                                           object: nil)
  }

  @objc
  func scrollToLastPhotoViewedInFullScreen(_ notification: Notification) {
    guard let userInfo = notification.userInfo as? [String: Int],
          let photoIndex = userInfo["newPhotoIndex"] else { return }
    previewsCollectionView.scrollToItem(at: IndexPath(item: photoIndex, section: 0),
                                        at: .centeredVertically,
                                        animated: false)
  }
  
  func setUpSearchController() {
    let suggestedSearchTableController = SuggestedSearchTableController()
    suggestedSearchTableController.suggestedSearchDelegate = self // for search from suggested queries
    searchController = UISearchController(searchResultsController: suggestedSearchTableController)
    searchController?.searchResultsUpdater = suggestedSearchTableController
    searchController?.obscuresBackgroundDuringPresentation = false
    searchController?.searchBar.delegate = self
    searchController?.searchBar.placeholder = "Search photos"
    searchController?.searchBar.tintColor = .black
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
  }

  // MARK: - Actions
  func searchTapped(newSearch: Bool) {
    guard let searchText = searchController?.searchBar.text else { return }
    if newSearch {
      searchViewModel.resetSearchResults()
      previewsCollectionView.reloadData()
    }
    activityIndicator.showActivityIndicatorInView(view: view)

    searchViewModel.searchPhotos(searchText: searchText,
                                 newSearch: newSearch) { [weak self] error in
      guard let self = self else { return }
      self.activityIndicator.stopActivityIndicator(view: self.view)
      if let error = error {
        BasicAlert.showAlert(message: error, viewController: self)
      } else {
        self.previewsCollectionView.reloadData()
      }
    }
  }

  func displayPreviewPhotoForCellAt(indexPath: IndexPath) {
    searchViewModel.downloadPreviewPhotoForCellAt(indexPath: indexPath) { [weak self] image in
      guard let previewImage = image,
            let cell = self?.previewsCollectionView.cellForItem(at: indexPath)
              as? PhotoCollectionViewCell else { return }
      cell.display(previewPhoto: previewImage)
    }
  }
}

extension SearchPhotosController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    searchTapped(newSearch: true)
  }
}

extension SearchPhotosController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return searchViewModel.photoDataResults.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let photoCell = previewsCollectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell",
                                                               for: indexPath) as? PhotoCollectionViewCell
    
    photoCell?.display(previewPhoto: nil) // reset photo
    return photoCell ?? UICollectionViewCell()
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    selectedPreviewPhotoIndexPath = indexPath
    performSegue(withIdentifier: "ShowFullScreen", sender: self)
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
                      forItemAt indexPath: IndexPath) {
    if indexPath.item == searchViewModel.photoDataResults.count - 1,
       searchViewModel.didFetchAllPhotosFromServer() == false {
      searchViewModel.currentSearchPage += 1
      searchTapped(newSearch: false)
    }

    if let collectionCell = cell as? PhotoCollectionViewCell,
       collectionCell.isImageNil() {
      displayPreviewPhotoForCellAt(indexPath: indexPath)
    }
  }
}

extension SearchPhotosController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    if itemSize == nil {
      let trailingAndLeadingConstraints: CGFloat = 24 * 2
      let splitScreenWidthIn: CGFloat = 2
      let width = (view.frame.width - trailingAndLeadingConstraints - itemsSpacing) / splitScreenWidthIn
      itemSize = CGSize(width: width, height: width)
    }
    return itemSize! // safe as it receives a value above
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return itemsSpacing
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return itemsSpacing
  }
}

extension SearchPhotosController: SuggestedSearchDelegate {
  func performSearchFor(query: String) {
    searchController?.searchBar.text = query
    searchController?.searchBar.resignFirstResponder()
    searchTapped(newSearch: true)
  }
}

//
//  ViewController.swift
//  PhotoSearcher
//
//  Created by Mihaela Simion on 11/2/20.
//

import UIKit

class SearchPhotosController: UIViewController {
  lazy var activityIndicator = UIActivityIndicatorView()
  var itemSize: CGSize?
  let itemsSpacing: CGFloat = 16
  lazy var successfulSearchHandler: SuccessfulSearchHandler = CoreDataManager()
  var searchController: UISearchController?
  var totalSearchResults = 0
  var currentSearchPage = 1
  var photoDataResults: [PhotoData] = []
  // To pass to FullScreenPhotosController
  var largePhotos: [LargePhoto] = []
  var selectedPreviewPhotoIndexPath: IndexPath?
  
  @IBOutlet private weak var photosCollectionView: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    photosCollectionView.dataSource = self
    photosCollectionView.delegate = self

    photosCollectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil),
                                  forCellWithReuseIdentifier: "PhotoCollectionViewCell")

    photosCollectionView.contentInset.top = 16
    photosCollectionView.contentInset.bottom = 16

    addObservers()
    setUpSearchController()
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
    photosCollectionView.scrollToItem(at: IndexPath(item: photoIndex, section: 0),
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
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == "ShowFullScreen",
          let fullScreenPhotosController = segue.destination as? FullScreenPhotosController else { return }
    fullScreenPhotosController.initialPhotoIndex = selectedPreviewPhotoIndexPath?.row
    fullScreenPhotosController.photos = largePhotos
  }
  
  func resetSearchResults() {
    totalSearchResults = 0
    currentSearchPage = 1
    photoDataResults = []
    largePhotos = []
    photosCollectionView.reloadData()
  }
  
  func searchPhotos(pageNumber: Int) {
    guard let searchText = searchController?.searchBar.text else { return }
    activityIndicator.showActivityIndicatorInView(view: view)
    PhotosSearchService.shared.searchPhotosWith(searchTerm: searchText,
                                                page: pageNumber) { searchResult, error in
      defer { self.activityIndicator.stopActivityIndicator(view: self.view) }
      if let error = error {
        BasicAlert.showAlert(message: error, viewController: self)
      } else if let result = searchResult,
                result.hits.isEmpty == false {
        self.saveSearchResultsInMemory(result: result)
        self.saveSuccessfulSearch(query: searchText)
        self.photosCollectionView.reloadData()
      } else if searchResult?.hits.isEmpty == true {
        BasicAlert.showAlert(message: "No results. Please try with other key words.",
                             viewController: self)
      }
    }
  }
  
  func saveSearchResultsInMemory(result: PhotoQuerySearchResult) {
    totalSearchResults = result.totalHits
    photoDataResults.append(contentsOf: result.hits)
    let newLargePhotos = result.hits.map { photoData in
      return LargePhoto(photoData: photoData)
    }
    largePhotos.append(contentsOf: newLargePhotos)
  }
  
  func saveSuccessfulSearch(query: String) {
    guard query.trimmingCharacters(in: .whitespaces).isEmpty == false else { return }
    successfulSearchHandler.saveSearch(query: query)
    successfulSearchHandler.keepOnlyLastTenSearches()
  }
  
  func downloadPreviewPhotoForCellAt(indexPath: IndexPath) {
    guard let previewUrl = URL(string: photoDataResults[indexPath.row].previewURL) else { return }
    PhotosDownloadService.downloadPhotoFrom(previewUrl: previewUrl,
                                            largeImageUrl: nil) { image in
      guard let previewImage = image,
            let cell = self.photosCollectionView.cellForItem(at: indexPath)
              as? PhotoCollectionViewCell else { return }
      cell.display(previewPhoto: previewImage)
    }
  }
}

extension SearchPhotosController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    resetSearchResults()
    searchPhotos(pageNumber: 1)
  }
}

extension SearchPhotosController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return photoDataResults.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let photoCell = photosCollectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell",
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
    if indexPath.item == photoDataResults.count - 1,
       photoDataResults.count != totalSearchResults {
      currentSearchPage += 1
      searchPhotos(pageNumber: currentSearchPage)
    }
    if let collectionCell = cell as? PhotoCollectionViewCell,
       collectionCell.isImageNil() {
      downloadPreviewPhotoForCellAt(indexPath: indexPath)
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
    resetSearchResults()
    searchPhotos(pageNumber: 1)
  }
}

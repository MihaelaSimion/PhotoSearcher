//
//  ViewController.swift
//  PhotoSearcher
//
//  Created by Mihaela Simion on 11/2/20.
//

import UIKit

class SearchPhotosController: UIViewController {
  lazy var activityIndicator = UIActivityIndicatorView()
  var searchController: UISearchController?
  var totalSearchResults = 0
  var currentSearchPage = 1
  var photoDataResults: [PhotoData] = []
  var largePhotos: [LargePhoto] = []
  var selectedCollectionItemIndexPath: IndexPath?

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

  func configureCollectionItemSize() {
    guard let layout = photosCollectionView.collectionViewLayout
            as? UICollectionViewFlowLayout else { return }
    let trailingAndLeadingContstraints: CGFloat = 24 * 2
    let spacing: CGFloat = 16
    let splitScreenWidthIn: CGFloat = 2
    let width = (view.frame.width - trailingAndLeadingContstraints - spacing) / splitScreenWidthIn
    layout.itemSize = CGSize(width: width, height: width)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == "ShowFullScreen",
          let fullScreenPhotosController = segue.destination as? FullScreenPhotosController else { return }
    fullScreenPhotosController.selectedPhotoIndex = selectedCollectionItemIndexPath?.row
    fullScreenPhotosController.photos = largePhotos
  }

  func resetSearchResults() {
    totalSearchResults = 0
    photoDataResults = []
    largePhotos = []
    photosCollectionView.reloadData()
  }

  func searchPhotos(pageNumber: Int) {
    guard let searchText = searchController?.searchBar.text else { return }
    activityIndicator.showActivityIndicatorInView(view: view)
    PhotosSearchService.shared.searchPhotosWith(searchTerm: searchText,
                                                page: pageNumber) { [weak self] searchResult, error in
      guard let self = self else { return }
      defer { self.activityIndicator.stopActivityIndicator(view: self.view) }
      if let error = error {
        BasicAlert.showAlert(message: error, viewController: self)
      } else if let result = searchResult,
                result.hits.isEmpty == false {
        self.totalSearchResults = result.totalHits
        self.photoDataResults.append(contentsOf: result.hits)
        let newLargePhotos = result.hits.map { photoData in
          return LargePhoto(photoData: photoData)
        }
        self.largePhotos.append(contentsOf: newLargePhotos)
        self.photosCollectionView.reloadData()
      } else if searchResult?.hits.isEmpty == true {
        BasicAlert.showAlert(message: "No results. Please try with other key words.",
                             viewController: self)
      }
    }
  }

  func downloadPreviewPhotoForCellAt(indexPath: IndexPath) {
    guard let previewUrl = URL(string: photoDataResults[indexPath.row].previewURL) else { return }
    PhotosDownloadService.downloadPhotoFrom(previewUrl: previewUrl,
                                            largeImageUrl: nil) { [weak self] image in
      guard let previewImage = image,
            let cell = self?.photosCollectionView.cellForItem(at: indexPath)
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

    photoCell?.display(previewPhoto: nil)
    downloadPreviewPhotoForCellAt(indexPath: indexPath)
    return photoCell ?? UICollectionViewCell()
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    selectedCollectionItemIndexPath = indexPath
    // download large image and set it to the object before performing segue
    activityIndicator.showActivityIndicatorInView(view: view)
    performSegue(withIdentifier: "ShowFullScreen", sender: self)
  }

  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell,
                      forItemAt indexPath: IndexPath) {
    if indexPath.row == photoDataResults.count - 1,
       photoDataResults.count != totalSearchResults {
      currentSearchPage += 1
      searchPhotos(pageNumber: currentSearchPage)
    } else if let collectionCell = cell as? PhotoCollectionViewCell,
              collectionCell.isImageNil() {
      downloadPreviewPhotoForCellAt(indexPath: indexPath)
    }
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

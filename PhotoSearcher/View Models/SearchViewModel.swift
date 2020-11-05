//
//  SearchViewModel.swift
//  PhotoSearcher
//
//  Created by Mihaela Simion on 11/5/20.
//

import UIKit.UIImage

class SearchViewModel {
  private lazy var successfulSearchHandler: SuccessfulSearchHandler = CoreDataManager()
  var totalSearchResults = 0
  var currentSearchPage = 1
  var photoDataResults: [PhotoData] = []
  var largePhotos: [LargePhoto] = []

  func resetSearchResults() {
    totalSearchResults = 0
    currentSearchPage = 1
    photoDataResults = []
    largePhotos = []
  }

  func searchPhotos(searchText: String,
                    newSearch: Bool,
                    completion: @escaping (_ errorDescription: String?) -> Void) {
    let pageNumber = newSearch ? 1 : currentSearchPage
    PhotosSearchService.shared.searchPhotosWith(searchTerm: searchText,
                                                page: pageNumber) { searchResult, error in
      if let error = error {
        completion(error)
      } else if let result = searchResult,
                result.hits.isEmpty == false {
        self.saveSearchResultsInMemory(result: result)
        self.saveSuccessfulSearch(query: searchText)
        completion(nil)
      } else if searchResult?.hits.isEmpty == true {
        completion("No results. Please try with other key words.")
      }
    }
  }

  func downloadPreviewPhotoForCellAt(indexPath: IndexPath,
                                     completion: @escaping (UIImage?) -> Void) {
    guard let previewUrl = URL(string: photoDataResults[indexPath.row].previewURL) else {
      completion(nil)
      return }
    PhotosDownloadService.downloadPhotoFrom(previewUrl: previewUrl,
                                            largeImageUrl: nil) { image in
      completion(image)
    }
  }

  func didFetchAllPhotosFromServer() -> Bool {
    return photoDataResults.count == totalSearchResults
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
}

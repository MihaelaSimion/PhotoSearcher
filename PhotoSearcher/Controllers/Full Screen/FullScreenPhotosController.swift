//
//  FullScreenPhotosVC.swift
//  PhotoSearcher
//
//  Created by Mihaela Simion on 11/2/20.
//

import UIKit

class FullScreenPhotosController: UIViewController {
  var initialPhotoIndex: Int?
  var photos: [LargePhoto] = []

  @IBOutlet private weak var largePhotosCollectionView: UICollectionView!

  override func viewDidLoad() {
    super.viewDidLoad()
    largePhotosCollectionView.delegate = self
    largePhotosCollectionView.dataSource = self
    largePhotosCollectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil),
                                       forCellWithReuseIdentifier: "PhotoCollectionViewCell")
    largePhotosCollectionView.isPagingEnabled = true
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    guard let row = initialPhotoIndex else { return }
    let selectedPhotoIndexPath = IndexPath(row: row, section: 0)
    largePhotosCollectionView.scrollToItem(at: selectedPhotoIndexPath,
                                           at: .centeredHorizontally,
                                           animated: false)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    guard let visibleCell = largePhotosCollectionView.visibleCells.first,
          let photoIndex = largePhotosCollectionView.indexPath(for: visibleCell)?.row else { return }
    let userInfo = ["newPhotoIndex": photoIndex]
    NotificationCenter.default.post(name: .UserSwipedToNewPhotoInFullScreen,
                                    object: nil,
                                    userInfo: userInfo)
  }

  func downloadLargePhotoForCellAt(indexPath: IndexPath) {
    guard let url = URL(string: photos[indexPath.row].url) else { return }
    PhotosDownloadService.downloadPhotoFrom(previewUrl: nil,
                                            largeImageUrl: url) { image in
      guard let largeImage = image else { return }
      self.photos[indexPath.row].largeImage = largeImage
      guard let stillVisibleCell = self.largePhotosCollectionView.cellForItem(at: indexPath)
              as? PhotoCollectionViewCell else { return }
      stillVisibleCell.stopActivityIndicator()
      stillVisibleCell.display(largePhoto: largeImage)
    }
  }
}

extension FullScreenPhotosController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView,
                      numberOfItemsInSection section: Int) -> Int {
    return photos.count
  }

  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let fullScreenCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell",
                                                            for: indexPath) as? PhotoCollectionViewCell
    if indexPath.row == initialPhotoIndex {
      // no photo is displayed until the scroll reaches the selected item and this becomes nil
      initialPhotoIndex = nil
    }

    if initialPhotoIndex != nil {
      fullScreenCell?.display(largePhoto: nil)
    } else if let photo = photos[indexPath.row].largeImage {
      fullScreenCell?.display(largePhoto: photo)
    } else {
      fullScreenCell?.display(largePhoto: nil)
      fullScreenCell?.startActivityIndicator()
      downloadLargePhotoForCellAt(indexPath: indexPath)
    }

    return fullScreenCell ?? UICollectionViewCell()
  }

  func collectionView(_ collectionView: UICollectionView,
                      willDisplay cell: UICollectionViewCell,
                      forItemAt indexPath: IndexPath) {
    if initialPhotoIndex == nil,
       indexPath.row == 0,
       photos[0].largeImage == nil,
       let photoCell = cell as? PhotoCollectionViewCell {
      // in case it was skipped until the selected image was displayed
      photoCell.startActivityIndicator()
      downloadLargePhotoForCellAt(indexPath: indexPath)
    } else if let photoCell = cell as? PhotoCollectionViewCell,
              photoCell.isImageNil(),
              let image = photos[indexPath.row].largeImage {
      photoCell.display(largePhoto: image)
      if photoCell.isActivityIndicatorAnimating() {
        photoCell.stopActivityIndicator()
      }
    }
  }
}

extension FullScreenPhotosController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    let size = CGSize(width: view.frame.width, height: view.frame.height)

    return size
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
}


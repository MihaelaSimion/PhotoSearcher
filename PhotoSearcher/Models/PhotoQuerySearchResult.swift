//
//  PhotoQuerySearchResult.swift
//  PhotoSearcher
//
//  Created by Mihaela Simion on 11/3/20.
//

import Foundation

struct PhotoQuerySearchResult: Decodable {
  let totalHits: Int
  let hits: [PhotoData]
}

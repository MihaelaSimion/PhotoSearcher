//
//  SuccessfulSearchHandler.swift
//  PhotoSearcher
//
//  Created by Mihaela Simion on 11/3/20.
//

import Foundation

protocol SuccessfulSearchHandler {
  func saveSearch(query: String)
  func fetchSearchQueries() -> [String]
  func keepOnlyLastTenSearches()
}


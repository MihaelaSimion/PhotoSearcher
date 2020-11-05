//
//  APIKeys.swift
//  PhotoSearcher
//
//  Created by Mihaela Simion on 11/2/20.
//

import Foundation

struct APIKeys {
  static var pixabayApiKey: String? { // in the Resources file add a new file pixabaySecretApiKey.json with you API key
    guard let url = Bundle.main.url(forResource: "pixabaySecretApiKey",
                                    withExtension: "json") else { return nil }
    do {
      let data = try Data(contentsOf: url)
      let key = try JSONDecoder().decode(String.self, from: data)
      return key
    } catch {
      return nil
    }
  }
}

//
//  PhotosSearchService.swift
//  PhotoSearcher
//
//  Created by Mihaela Simion on 11/3/20.
//

import Foundation

enum ServerResponseContentType {
  case json
}

class PhotosSearchService {
  private let baseUrl = URL(string: "https://pixabay.com/api/")
  private let urlSession = URLSession.shared
  static let shared = PhotosSearchService()
  private let genericErrorMessage = "We encountered a problem. Please try again"

  func searchPhotosWith(searchTerm: String,
                        page: Int,
                        completionDispatchQueue: DispatchQueue = DispatchQueue.main,
                        completion: @escaping (PhotoQuerySearchResult?, _ errorDescription: String?) -> Void) {
    let photoSearchParams = ["q": searchTerm,
                             "image_type": "photo",
                             "page": String(page)]
    guard let request = buildRequest(queryParams: photoSearchParams) else {
      completionDispatchQueue.async {
        completion(nil, self.genericErrorMessage)
      }
      return
    }

    let dataTask = urlSession.dataTask(with: request) { data, _, error in
      if let error = error {
        completionDispatchQueue.async {
          completion(nil, error.localizedDescription)
        }
      } else if let data = data {
        let result: (PhotoQuerySearchResult?, Error?) = self.decode(data: data, contentType: .json)
        let error = result.1 != nil ? self.genericErrorMessage : nil // json decoder error is not displayable to the user, so replace it
        completionDispatchQueue.async {
          completion(result.0, error)
        }
      }
    }

    dataTask.resume()
  }

  // MARK: - Request
  private func buildRequest(method: String = "GET",
                            contentType: ServerResponseContentType = .json,
                            queryParams: [String: String]) -> URLRequest? {
    guard let baseUrl = baseUrl,
          let apiKey = APIKeys.pixabayApiKey else { return nil }
    var request = URLRequest(url: baseUrl)

    var queryItems: [URLQueryItem] = []

    let apiKeyParam = URLQueryItem(name: "key", value: apiKey)
    queryItems.append(apiKeyParam)

    for (key, value) in queryParams {
      let queryItem = URLQueryItem(name: key, value: value)
      queryItems.append(queryItem)
    }

    var urlComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)
    urlComponents?.queryItems = queryItems

    guard let components = urlComponents else { return nil }
    request.url = components.url
    request.httpMethod = method
    if contentType == .json {
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }

    return request
  }

  // MARK: - Decoding
  private func decode<T: Decodable>(data: Data,
                                    contentType: ServerResponseContentType) -> (T?, Error?) {
    var result: (T?, Error?)
    if contentType == .json {
      result = decodeJson(data: data)
    }

    return result
  }

  private func decodeJson<T: Decodable>(data: Data) -> (T?, Error?) {
    do {
      let result = try JSONDecoder().decode(T.self, from: data)
      return (result, nil)
    } catch let error {
      return (nil, error)
    }
  }
}

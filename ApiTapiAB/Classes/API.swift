//
//  API.swift
//  ApiTapiAB
//
//  Created by Appbooster on 02/09/2019.
//  Copyright © 2019 Appbooster. All rights reserved.
//

import Foundation

typealias ResultType = (Result<Data, Error>) -> Void

enum ABError: Error {

  case invalidResponse
  case invalidData
  case serverError(statusCode: Int)

  var description: String {
    switch self {
    case .invalidResponse: return "Invalid response from server"
    case .invalidData: return "Invalid response data"
    case .serverError(let statusCode): return "Server error, status code: \(statusCode)"
    }
  }

}

struct API {

  static let modifier: String = "api"
  static let versionModifier: String = "v"
  static let version: Int = 1
  static let path: String = "experiments"

  static func get(_ url: URL,
                  headers: [String: String]?,
                  completion: @escaping ResultType) {
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "GET"
    urlRequest.allHTTPHeaderFields = headers

    URLSession.shared.dataTask(with: urlRequest) { data, response, error in
      if let error = error {
        DispatchQueue.main.async {
          completion(.failure(error))
        }

        return
      }

      guard let response = response as? HTTPURLResponse else {
        DispatchQueue.main.async {
          completion(.failure(ABError.invalidResponse))
        }

        return
      }

      guard 200 ... 299 ~= response.statusCode else {
        DispatchQueue.main.async {
          completion(.failure(ABError.serverError(statusCode: response.statusCode)))
        }

        return
      }

      guard let data = data else {
        DispatchQueue.main.async {
          completion(.failure(ABError.invalidData))
        }

        return
      }

      DispatchQueue.main.async {
        completion(.success(data))
      }
      }.resume()
  }

}

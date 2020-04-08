//
//  ApiTapiAB.swift
//  ApiTapiAB
//
//  Created by Appbooster on 02/09/2019.
//  Copyright © 2019 Appbooster. All rights reserved.
//

import UIKit
import AdSupport

private let defaultServerUrl: String = "https://new.apitapi.com"

public final class ApiTapiAB: NSObject {

  private let serverUrl: String
  private let authToken: String
  private let deviceToken: String

  public init(serverUrl: String? = nil, authToken: String, deviceToken: String) {
    self.serverUrl = serverUrl ?? defaultServerUrl
    self.authToken = authToken
    self.deviceToken = deviceToken

    super.init()
  }

  private var tests: [ApiTapiTest] = State.tests {
    didSet {
      State.tests = tests
    }
  }

  public var showDebug: Bool = false
  public var log: ((String) -> Void)?

  public var lastOperationDuration: TimeInterval = 0.0

  public func fetch(knownKeys: [String],
                    timeoutInterval: TimeInterval = 3.0,
                    completion: @escaping (_ abError: ApiTapiABError?) -> Void) {
    let urlPath = [serverUrl, API.modifier, "\(API.versionModifier)\(API.version)", API.path]
      .joined(separator: "/")

    var urlComponents = URLComponents(string: urlPath)
    urlComponents?.queryItems = knownKeys.map({ URLQueryItem(name: "knownKeys[]", value: $0) })

    guard let url = urlComponents?.url else {
      let abError = ApiTapiABError(error: "Invalid url",
                                   code: 0)

      debugAndLog("[ApiTapiAB] Error – \(abError.error), error code: \(abError.code)")

      completion(abError)

      return
    }

    let headers = [
      "Content-Type": "application/json",
      "Authorization": authToken,
      "DeviceToken": deviceToken,
      "AppVersion": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    ]

    let startDate = Date()

    API.get(url,
            headers: headers,
            timeoutInterval: timeoutInterval,
            completion: { [weak self] data, abError in
              guard let self = self else { return }

              self.lastOperationDuration = Date().timeIntervalSince(startDate)

              if let abError = abError {
                self.debugAndLog("[ApiTapiAB] Error – \(abError.error), error code: \(abError.code)")

                completion(abError)
              } else if let data = data {
                do {
                  let tests = try JSONDecoder().decode([ApiTapiTest].self, from: data)

                  self.tests = tests

                  completion(nil)
                }
                catch {
                  let abError = ApiTapiABError(error: "Tests decoding error: \(error.localizedDescription)",
                    code: 0)

                  self.debugAndLog("[ApiTapiAB] Error – \(abError.error), error code: \(abError.code)")

                  completion(abError)
                }
              }
    })
  }

  // MARK: Getters

  public func value<T>(_ key: String) -> T? {
    return tests.filter({ $0.key == key }).first?.value.value as? T
  }

  public func value<T>(_ key: String, or: T) -> T {
    return value(key) ?? or
  }

  public subscript<T>(key: String) -> T? {
    return value(key)
  }

  public var userProperties: [String: Any] {
    var userProperties: [String: Any] = [:]

    for test in tests {
      userProperties[test.key] = test.value.value
    }

    return userProperties
  }

  // MARK: Service

  private func debugAndLog(_ text: String) {
    if showDebug {
      #if DEBUG
      print(text)
      #endif
    }

    log?(text)
  }

}

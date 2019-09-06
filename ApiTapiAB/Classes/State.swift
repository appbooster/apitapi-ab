//
//  State.swift
//  ApiTapiAB
//
//  Created by Appbooster on 03/09/2019.
//  Copyright © 2019 Appbooster. All rights reserved.
//

import Foundation

struct State {

  static var tests: [ApiTapiTest] {
    get {
      if let data = UserDefaults.standard.object(forKey: #function) as? Data,
        let value = try? JSONDecoder().decode([ApiTapiTest].self, from: data) {
        return value
      }

      return []
    }
    set(newValue) {
      if let data = try? JSONEncoder().encode(newValue) {
        UserDefaults.standard.set(data, forKey: #function)
        UserDefaults.standard.synchronize()
      }
    }
  }

}

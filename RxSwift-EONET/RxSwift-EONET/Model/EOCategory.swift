//
//  EOCategory.swift
//  RxSwift-EONET
//
//  Created by Jaycee on 2020/01/15.
//  Copyright © 2020 Jaycee. All rights reserved.
//


import Foundation

struct EOCategory: Equatable {
  let id: Int
  let name: String
  let description: String
  let endpoint: String
  var events = [EOEvent]()

  init?(json: [String: Any]) {
    guard let id = json["id"] as? Int,
        let name = json["title"] as? String,
        let description = json["description"] as? String else {
      return nil
    }
    self.id = id
    self.name = name
    self.description = description
    self.endpoint = "\(EONET.categoriesEndpoint)/\(id)"
  }

  // MARK: - Equatable
  static func ==(lhs: EOCategory, rhs: EOCategory) -> Bool {
    return lhs.id == rhs.id
  }
}

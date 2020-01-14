//
//  EOError.swift
//  RxSwift-EONET
//
//  Created by Jaycee on 2020/01/15.
//  Copyright © 2020 Jaycee. All rights reserved.
//


import Foundation

enum EOError: Error {
  case invalidURL(String) //url이 잘못됐을때
  case invalidParameter(String, Any) //파라미터가 잘못되었을때
  case invalidJSON(String) //json이 잘못되었을때
}

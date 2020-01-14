//
//  EventCell.swift
//  RxSwift-EONET
//
//  Created by Jaycee on 2020/01/15.
//  Copyright © 2020 Jaycee. All rights reserved.
//

import UIKit

class EventCell : UITableViewCell {
  @IBOutlet var title: UILabel!
  @IBOutlet var date: UILabel!
  @IBOutlet var details: UILabel!

  func configure(event: EOEvent) {
    title.text = event.title
    details.text = event.description

    let formatter = DateFormatter()
    formatter.dateStyle = .short
    if let when = event.closeDate {
      date.text = formatter.string(for: when)
    } else {
      date.text = ""
    }
  }
}

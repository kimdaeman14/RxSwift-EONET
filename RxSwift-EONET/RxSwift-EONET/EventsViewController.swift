//
//  EventsViewController.swift
//  RxSwift-EONET
//
//  Created by Jaycee on 2020/01/15.
//  Copyright © 2020 Jaycee. All rights reserved.
//

import UIKit
import RxSwift

class EventsViewController: UIViewController, UITableViewDataSource {
    
    
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var slider: UISlider!
    @IBOutlet var daysLabel: UILabel!
    
    
    
    let events = Variable<[EOEvent]>([])
    let disposeBag = DisposeBag()
    
    let days = Variable<Int>(360)
    let filteredEvents = Variable<[EOEvent]>([])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredEvents.asObservable()
            .subscribe(onNext: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(days.asObservable(), events.asObservable()) { (days, events) -> [EOEvent] in
            let maxInterval = TimeInterval(days * 24 * 3600)
            return events.filter { event in
                if let date = event.closeDate {
                    return abs(date.timeIntervalSinceNow) < maxInterval
                }
                return true
            }
        }
        .bind(to: filteredEvents)
        .disposed(by: disposeBag)
        
        days.asObservable()
            .subscribe(onNext: { [weak self] days in
                self?.daysLabel.text = "Last \(days) days"
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func sliderAction(slider: UISlider) {
        days.value = Int(slider.value)
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredEvents.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventCell
        let event = filteredEvents.value[indexPath.row]
        cell.configure(event: event)
        return cell
        
    }
    
    
    
}

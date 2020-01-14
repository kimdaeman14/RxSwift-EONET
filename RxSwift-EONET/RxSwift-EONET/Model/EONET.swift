//
//  EONET.swift
//  RxSwift-EONET
//
//  Created by Jaycee on 2020/01/15.
//  Copyright © 2020 Jaycee. All rights reserved.
//


import Foundation
import RxSwift
import RxCocoa

class EONET {
    static let API = "https://eonet.sci.gsfc.nasa.gov/api/v2.1"
    static let categoriesEndpoint = "/categories"
    static let eventsEndpoint = "/events"
    
    static var ISODateReader: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        return formatter
    }()
    
    static func filteredEvents(events: [EOEvent], forCategory category: EOCategory) -> [EOEvent] {
        return events.filter { event in
            return event.categories.contains(category.id) &&
                !category.events.contains {
                    $0.id == event.id
            }
            }
            .sorted(by: EOEvent.compareDates)
    }
    
    
    
    
    static func request(endpoint: String, query: [String: Any] = [:]) -> Observable<[String: Any]> {
        do {
            // URL에 엔드포인트 추가해서 옵셔널 바인딩이 안되면( 주소가 URL양식이 아니거나 하면 에러를 발생
            
    
            
         
            guard let url = URL(string: API)?.appendingPathComponent(endpoint),
                var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                    throw EOError.invalidURL(endpoint)
            }
            // URL이 있으면 query를 추가합니다. 나중에 event request에 사용할 것입니다.
            components.queryItems = try query.compactMap { (key, value) in
                guard let v = value as? CustomStringConvertible else {
                    throw EOError.invalidParameter(key, value)
                }
                return URLQueryItem(name: key, value: v.description)
            }
            
            
            guard let finalURL = components.url else {
                throw EOError.invalidURL(endpoint)
            }
            let request = URLRequest(url: finalURL)
            
            
            
            
        
            return URLSession.shared.rx.response(request: request)
                .map { _, data -> [String: Any] in
                    guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                        let result = jsonObject as? [String: Any] else {
                            throw EOError.invalidJSON(finalURL.absoluteString)
                    }
                    return result
            }
        } catch {
            return Observable.empty()
        }
    }
    
    
    
    static var categories: Observable<[EOCategory]> = {
                
     
        
        
        
        return EONET.request(endpoint: categoriesEndpoint)
            .map { data in
                let categories = data["categories"] as? [[String: Any]] ?? []
                return categories
                    .compactMap(EOCategory.init)
                    .sorted { $0.name < $1.name }
            }
            .catchErrorJustReturn([])
            .share(replay: 1, scope: .forever)
    }()
    
    
    
    
    
        
 
    
    
    
    fileprivate static func events(forLast days: Int, closed: Bool, endpoint: String) -> Observable<[EOEvent]> {
        
      
        return request(endpoint: eventsEndpoint, query: [
            "days": NSNumber(value: days),
            "status": (closed ? "closed" : "open")
            ])
            .map { json in
          
                
                guard let raw = json["events"] as? [[String: Any]] else {
//                    throw EOError.invalidJSON(eventsEndpoint)
                    throw EOError.invalidJSON(endpoint)
                }
                return raw.compactMap(EOEvent.init)
            }
            
            .catchErrorJustReturn([])
    }
    

    
    static func events(forLast days: Int = 360, category: EOCategory) -> Observable<[EOEvent]> {
        print(category.endpoint, "endpoint")

        let openEvents = events(forLast: days, closed: false, endpoint: category.endpoint)
        let closedEvents = events(forLast: days, closed: true, endpoint: category.endpoint)
        
//        return openEvents.concat(closedEvents)
        return Observable.of(openEvents, closedEvents).merge().reduce([]) { running, new in
            running + new
        }
        
        /*
         1. observable을 보고 있는 Observable을 생성
         2. observable 2개를 취해서 merge() // merge는 순서에 관계없이 시퀸스로 들어오는 값을 방출
         3. merge된 결과는 배열로 reduce 함. // reduce는 시작값과 조건을 받아 collection에서 값을 꺼내 해당 조건으로 작업 후 다시 collection에 담아 반환
         */
    }
    

    
    
}

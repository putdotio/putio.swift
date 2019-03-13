//
//  EventsApi.swift
//  Putio
//
//  Created by Altay Aydemir on 4.12.2017.
//  Copyright © 2017 Put.io. All rights reserved.
//

import Foundation
import SwiftyJSON

extension PutioKit {
    func getHistoryEvents(completion: @escaping (_ events: [PutioHistoryEvent]?, _ error: Error?) -> Void) {
        let URL = "/events/list"

        self.get(URL)
            .end { (response, error) in
                guard error == nil else {
                    return completion(nil, error)
                }

                let events = response!["events"].arrayValue.map {PutioHistoryEvent(json: $0)}

                return completion(events, nil)
        }
    }

    func clearHistoryEvents(completion: PutioKitBoolCompletion) {
        let URL = "/events/delete"

        self.post(URL)
            .end { (_, error) in
                guard let completion = completion else { return }

                guard error == nil else {
                    return completion(false, error)
                }

                return completion(true, nil)
        }
    }

    func deleteHistoryEvent(eventID: Int, completion: PutioKitBoolCompletion) {
        let URL = "/events/delete/\(eventID)"

        self.post(URL)
            .end { (_, error) in
                guard let completion = completion else { return }

                guard error == nil else {
                    return completion(false, error)
                }

                return completion(true, nil)
        }
    }
}
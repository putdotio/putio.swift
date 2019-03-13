//
//  VideoFileApi.swift
//  Putio
//
//  Created by Altay Aydemir on 21.11.2017.
//  Copyright © 2017 Put.io. All rights reserved.
//

import Foundation
import SwiftyJSON

extension PutioAPI {
    public func startMp4Conversion(fileID: Int, completion: PutioAPIBoolCompletion) {
        let URL = "/files/\(fileID)/mp4"

        self.post(URL)
            .end { (_, error) in
                guard let completion = completion else { return }

                guard error == nil else {
                    return completion(false, error)
                }

                return completion(true, nil)
        }
    }

    public func getMp4ConversionStatus(fileID: Int, completion: @escaping (_ status: PutioMp4Conversion?, _ error: Error?) -> Void) {
        let URL = "/files/\(fileID)/mp4"

        self.get(URL)
            .end { (response, error) in
                guard error == nil else {
                    return completion(nil, error)
                }

                return completion(PutioMp4Conversion(json: response!), nil)
        }
    }

    public func setStartFrom(fileID: Int, time: Int, completion: PutioAPIBoolCompletion) {
        let URL = "/files/\(fileID)/start-from/set"

        self.post(URL)
            .send(["time": time])
            .end { (_, error) in
                guard let completion = completion else { return }

                guard error == nil else {
                    return completion(false, error)
                }

                return completion(true, nil)
        }
    }

    public func resetStartFrom(fileID: Int, completion: PutioAPIBoolCompletion) {
        let URL = "/files/\(fileID)/start-from/delete"

        self.get(URL)
            .end { (_, error) in
                guard let completion = completion else { return }

                guard error == nil else {
                    return completion(false, error)
                }

                return completion(true, nil)
        }
    }
}

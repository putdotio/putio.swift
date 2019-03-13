//
//  FilesModel.swift
//  Putio
//
//  Created by Altay Aydemir on 7.11.2017.
//  Copyright © 2017 Put.io. All rights reserved.
//

import Foundation
import SwiftyJSON

struct PutioFile {
    enum FileType {
        case folder, video, audio, image, pdf, other
    }

    struct VideoMetadata {
        var height: Int
        var width: Int
        var codec: String
        var duration: Double
        var aspectRatio: Double

        init(json: JSON) {
            self.height = json["height"].intValue
            self.width = json["width"].intValue
            self.codec = json["codec"].stringValue
            self.duration = json["duration"].doubleValue
            self.aspectRatio = json["aspect_ratio"].doubleValue
        }
    }

    let id: Int
    var parentID: Int
    var name: String
    let type: FileType
    let typeRaw: String
    let isShared: Bool
    let isAccessed: Bool
    var icon: String

    var size: Int64
    var sizeReadable: String

    let createdAt: Date
    let createdAtRelative: String

    // MARK: Folder Properties
    var isSharedRoot: Bool = false

    // MARK: Video Properties
    var needConvert: Bool = false
    var hasMp4: Bool = false
    var startFrom: Int = 0
    var streamURL: String = ""
    var mp4StreamURL: String = ""
    var metaData: VideoMetadata?
    var screenshot: String = ""

    init(json: JSON) {
        self.id = json["id"].intValue
        self.parentID = json["parent_id"].intValue
        self.name = json["name"].stringValue
        self.isShared = json["is_shared"].boolValue
        self.isAccessed = !(json["first_accessed_at"].stringValue.isEmpty)
        self.icon = json["icon"].stringValue

        // Eg: 1024.0
        self.size = json["size"].int64Value

        // Eg: 1 MB
        self.sizeReadable = size.bytesToHumanReadable()

        // Put.io API currently does not provide dates compatible with iso8601 but may support in the future
        let formatter = ISO8601DateFormatter()
        self.createdAt = formatter.date(from: json["created_at"].stringValue) ?? formatter.date(from: "\(json["created_at"].stringValue)+00:00")!

        // Eg: 5 Days Ago
        self.createdAtRelative = createdAt.timeAgoSinceDate()

        switch json["file_type"].stringValue {
        case "FOLDER":
            self.type = .folder
        case "VIDEO":
            self.type = .video
        case "AUDIO":
            self.type = .audio
        case "IMAGE":
            self.type = .image
        case "PDF":
            self.type = .pdf
        default:
            self.type = .other
        }

        // Needed for analytics event (tried_to_open_unsupported_file)
        self.typeRaw = json["file_type"].stringValue

        if type == .folder {
            self.isSharedRoot = json["folder_type"].stringValue == "SHARED_ROOT"
        }

        if type == .video {
            self.hasMp4 = json["is_mp4_available"].boolValue
            self.needConvert = json["need_convert"].boolValue
            self.streamURL = json["stream_url"].stringValue
            self.mp4StreamURL = json["mp4_stream_url"].stringValue
            self.screenshot = json["screenshot"].stringValue

            if json["video_metadata"].dictionary != nil {
                self.metaData = VideoMetadata(json: json["video_metadata"])
            }
        }

        if type == .audio || type == .video {
            self.startFrom = json["start_from"].intValue
        }
    }

    func getHlsStreamURL(token: String) -> URL {
        let url = "\(PutioKit.apiURL)/files/\(self.id)/hls/media.m3u8?subtitle_key=all&oauth_token=\(token)"
        return URL(string: url)!
    }

    func getAudioStreamURL(token: String) -> URL {
        let url = "\(PutioKit.apiURL)/files/\(self.id)/stream?oauth_token=\(token)"
        return URL(string: url)!
    }

    func getDownloadURL(token: String) -> URL {
        let url = "\(PutioKit.apiURL)/files/\(self.id)/download?oauth_token=\(token)"
        return URL(string: url)!
    }

    func getMp4DownloadURL(token: String) -> URL {
        let url = "\(PutioKit.apiURL)/files/\(self.id)/mp4/download?oauth_token=\(token)"
        return URL(string: url)!
    }
}

struct PutioMp4Conversion {
    enum Status: String {
        case queued = "IN_QUEUE",
            converting = "CONVERTING",
            completed = "COMPLETED",
            error = "ERROR"
    }

    let percentDone: Float
    var status: Status

    init(json: JSON) {
        let mp4 = json["mp4"]
        self.percentDone = mp4["percent_done"].floatValue / 100
        self.status = Status.init(rawValue: mp4["status"].stringValue)!
    }
}

struct PutioNextFile {
    var id: Int
    var name: String
    var parentID: Int

    init(json: JSON) {
        self.id = json["id"].intValue
        self.parentID = json["parent_id"].intValue
        self.name = json["name"].stringValue
    }

    func getAudioStreamURL(token: String) -> URL {
        let url = "\(PutioKit.apiURL)/files/\(self.id)/stream?oauth_token=\(token)"
        return URL(string: url)!
    }
}
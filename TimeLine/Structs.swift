//
//  Structs.swift
//  TimeLine
//
//  Created by Ayushi Oswal on 3/11/25.
//

import Foundation

struct Invite {
    let timelineName: String
    let status: String
    let inviterName: String
    let timelineID: String
}

struct Timeline {
    var name: String
    var coverPhotoURL: URL?
    var creators: [String] = []
}

struct Day {
    var date: Date
    var images: [URL] = []
}

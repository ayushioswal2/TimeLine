//
//  Structs.swift
//  TimeLine
//
//  Created by Ayushi Oswal on 3/11/25.
//

import Foundation

struct Invite {
    let groupName: String
    let senderName: String
}

struct Timeline {
    var name: String
    var coverPhotoURL: URL?
    var users: [String] = []
}

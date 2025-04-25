//
//  Values.swift
//  TimeLine
//
//  Created by Adwita Gadre on 4/18/25.
//

import Foundation
import UIKit

var userTimelines: [String: String] = [:]

var currTimelineID = ""
var currTimeline: Timeline?
var currTimelineCoverImage: UIImage?

var days: [Day] = []

var currDay: Day?
var currDayImages: [UIImage] = []

var currImage: UIImage?
var currDayImageIndex: Int? // keep track of which image in this day's image list we are currently editing

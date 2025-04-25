//
//  loadScrapbookPageFunction.swift
//  TimeLine
//
//  Created by Ayushi Oswal on 4/24/25.
//

import Foundation
import UIKit

func loadScrapbookPageFunction() async throws { // -> figure out paramters and returns
    
    // need to get the current day image
    // need to take in canvas elements as well
    // create a new image view
    
    // load the background image
    // iterate throuhg canvas elements
    /*
     
     view.transform = CGAffineTransform(rotationAngle: rotation)
     multiple x, y, width, and height by parentView.bounds.height or width depending on what it is
     
     need to remember to multiple everything by the canvas size because rn x, y, width, and height are stored as percentages
     for element in canvasElements {
        if element.type == "drawing" {
            // convert from base 64 back to and overlay
            if let base64 = dict["base64"] as? String,
                let data = Data(base64Encoded: base64),
                let drawing = try? PKDrawing(data: data) {
                drawingCanvasView.drawing = drawing
             }
        } else if element.type == "text" {
            // create label (can call on function)
             let label = UILabel()
             label.text = element["text"]
             label.textColor = colorFromHex(element["color"])
             label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
     
             label.frame = CGRect(
               x: element["x"]*parentView.bounds.width - label.frame.width / 2,
               y: element["y"]*parentView.bounds.height - label.frame.height / 2,
               width: element["x"]*parentView.bounds.width,
               height: element["y"]*parentView.bounds.height
             )
             label.sizeToFit()
             label.frame.origin = CGPoint(
                 x: element["x"]*parentView.bounds.width - label.frame.width / 2,
                 y: element["y"]*parentView.bounds.height - label.frame.height / 2
             )
             if let rotation = data.rotation {
                 label.transform = CGAffineTransform(rotationAngle: rotation)
             }
     
            canvasUIView.addSubview(label)
        } else if element.type == "circle" {
            // create circle
     let circleView = UIView(frame: CGRect(
         x: element["x"]*parentView.bounds.width - element["width"]*parentView.bounds.width / 2,
         y: element["y"]*parentView.bounds.height - element["height"]*parentView.bounds.height / 2,
         width: element["width"]*parentView.bounds.width,
         height: element["height"]*parentView.bounds.height
     ))
     
     circleView.backgroundColor = colorFromHex(element["color"])
     circleView.layer.cornerRadius = element["height"]*parentView.bounds.height / 2
     
     canvasUIView.addSubview(circleView)
        } else if element.type == "rect" {
            // create rect
     let centerPoint = CGPoint(x: element["x"]*parentView.bounds.width, y: element["y"]*parentView.bounds.height)

     let rectView = UIView(frame: CGRect(
         x: centerPoint.x - element["width"]*parentView.bounds.width / 2,
         y: centerPoint.y - element["height"]*parentView.bounds.height / 2,
         width: element["width"]*parentView.bounds.width,
         height: element["height"]*parentView.bounds.height
     ))

     rectView.backgroundColor = colorFromHex(element["color"])
     parentView.addSubview(rectView)
        }
     
    }
     
     we can either return a UIView or smthing that has all this info or figure out another way to load it
     */
}

func colorFromHex(_ hex: String) -> UIColor {
    var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if hexSanitized.hasPrefix("#") {
        hexSanitized.removeFirst()
    }

    var rgb: UInt64 = 0
    Scanner(string: hexSanitized).scanHexInt64(&rgb)

    let r, g, b, a: CGFloat
    if hexSanitized.count == 8 {
        r = CGFloat((rgb & 0xFF000000) >> 24) / 255
        g = CGFloat((rgb & 0x00FF0000) >> 16) / 255
        b = CGFloat((rgb & 0x0000FF00) >> 8) / 255
        a = CGFloat(rgb & 0x000000FF) / 255
    } else {
        // fallback for 6-digit hex (no alpha)
        r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        b = CGFloat(rgb & 0x0000FF) / 255
        a = 1.0
    }

    return UIColor(red: r, green: g, blue: b, alpha: a)
}

//
//  ScrapbookViewController.swift
//  TimeLine
//
//  Created by Audrey Chen on 3/11/25.
//

import UIKit
import PencilKit

class ScrapbookViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var canvasUIView: UIView!
    var drawingCanvasView: PKCanvasView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateColorScheme), name: NSNotification.Name("ColorSchemeChanged"), object: nil)

        view.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 225/255, alpha: 1)

        dateLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        dateLabel.textColor = UIColor.appColorScheme(type: "primary")

        saveButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
        saveButton.backgroundColor = UIColor.appColorScheme(type: "secondary")
        
        // make canvas page noticable to the user
        canvasUIView.backgroundColor = .white
        canvasUIView.layer.shadowColor = UIColor.black.cgColor
        canvasUIView.layer.shadowOpacity = 0.2
        canvasUIView.layer.shadowOffset = CGSize(width: 0, height: 4)
        canvasUIView.layer.shadowRadius = 8
        canvasUIView.layer.cornerRadius = 12
        
        drawingCanvasView = PKCanvasView(frame: canvasUIView.bounds)
        drawingCanvasView.backgroundColor = .clear
        drawingCanvasView.drawingPolicy = .anyInput
        canvasUIView.addSubview(drawingCanvasView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Ensure canvas matches container size
        drawingCanvasView.frame = canvasUIView.bounds
    }
    
    @objc func updateFont() {
        dateLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        saveButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
    }
    
    @objc func updateColorScheme() {
        dateLabel.textColor = UIColor.appColorScheme(type: "primary")
        saveButton.backgroundColor = UIColor.appColorScheme(type: "secondary")

    }
    
    @IBAction func penButtonPressed(_ sender: Any) {
    }
    
    @IBAction func shapeButtonPressed(_ sender: Any) {
    }
    
    @IBAction func eraseButtonPressed(_ sender: Any) {
    }
    
    @IBAction func colorButtonPressed(_ sender: Any) {
    }
    
    @IBAction func addImageButtonPressed(_ sender: Any) {
    }
    
    @IBAction func addTextButtonPressed(_ sender: Any) {
    }
}

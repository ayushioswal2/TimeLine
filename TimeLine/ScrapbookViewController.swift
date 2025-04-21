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
    var currentDrawingColor: UIColor = .black
    var isDrawing: Bool = false
    var isShape: Bool = false
    var isText: Bool = false
    var isErasing: Bool = false

    
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
        
        // add drawing frame for the pencil function
        drawingCanvasView = PKCanvasView(frame: canvasUIView.bounds)
        drawingCanvasView.backgroundColor = .clear
        drawingCanvasView.drawingPolicy = .anyInput
        canvasUIView.addSubview(drawingCanvasView)
        drawingCanvasView.isUserInteractionEnabled = isDrawing

        print ("viewDidLoad")
        print ("\(isShape) - shape")
        print ("\(isDrawing) - drawing")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        isDrawing.toggle()
        drawingCanvasView.isUserInteractionEnabled = isDrawing
        
        if isDrawing {
            drawingCanvasView.tool = PKInkingTool(.pen, color: currentDrawingColor, width: 5)
            drawingCanvasView.becomeFirstResponder()
        }
        
        if let button = sender as? UIButton {
            button.tintColor = isDrawing ? .systemBlue : .label
        }
        
        print("pen")
        print ("\(isShape) - shape")
        print ("\(isDrawing) - drawing")
        
    }
    
    @IBAction func shapeButtonPressed(_ sender: Any) {
        isShape.toggle()
        if let button = sender as? UIButton {
            button.tintColor = isShape ? .systemBlue : .label
        }
        print("shape")
        print ("\(isShape) - shape")
        print ("\(isDrawing) - drawing")
    }
    
    @IBAction func drawShape(_ recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: canvasUIView)

        if isShape {
            let circleSize: CGFloat = 100
            let circleView = UIView(frame: CGRect(
                x: tapLocation.x - circleSize / 2,
                y: tapLocation.y - circleSize / 2,
                width: circleSize,
                height: circleSize
            ))
            
            circleView.backgroundColor = currentDrawingColor
            circleView.layer.cornerRadius = circleSize / 2
            circleView.clipsToBounds = true
            
            // make it resizable, deletable, etc. later
            circleView.isUserInteractionEnabled = true
            
            canvasUIView.addSubview(circleView)
        }
        
        if isText {
            let controller = UIAlertController(title: "Enter Text", message: "", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            controller.addTextField { (textField) in
                textField.placeholder = "Enter text here"
            }
            
            controller.addAction(UIAlertAction(title: "Add", style: .default) { [weak self] _ in
                guard let self = self else { return }
                let enteredText = controller.textFields![0].text ?? ""
                if !enteredText.isEmpty {
                    self.createLabel(with: enteredText, at: tapLocation)
                }
            })
            
            present(controller, animated: true)
        }
        
        if isErasing {
            handleEraseTap(recognizer)
        }
        
    }
    
    func createLabel(with text: String, at coor: CGPoint) {
        let label = UILabel()
        label.text = text
        label.textColor = currentDrawingColor
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.sizeToFit()
        label.frame.origin = CGPoint(
            x: coor.x - label.frame.width / 2,
            y: coor.y - label.frame.height / 2
        )
        
        label.isUserInteractionEnabled = true

        canvasUIView.addSubview(label)
    }
    
    @IBAction func eraseButtonPressed(_ sender: Any) {
        isErasing.toggle()
        drawingCanvasView.isUserInteractionEnabled = isDrawing
        if let button = sender as? UIButton {
            button.tintColor = isErasing ? .systemBlue : .label
        }
    }
    
    @objc func handleEraseTap(_ recognizer: UITapGestureRecognizer) {
        guard isErasing else { return }

        let location = recognizer.location(in: canvasUIView)

        // checking for shapes, text, etc.
        for subview in canvasUIView.subviews {
            if subview != drawingCanvasView && subview.frame.contains(location) {
                subview.removeFromSuperview()
                return
            }
        }
        
        // checking for anything from the pencil kit
        let drawing = drawingCanvasView.drawing
        let filteredStrokes = drawing.strokes.filter { stroke in
            let points = stroke.path.map { $0.location }
            let strokeBounds = boundingBox(for: points)
            return !strokeBounds.insetBy(dx: -10, dy: -10).contains(location)
        }

        drawingCanvasView.drawing = PKDrawing(strokes: filteredStrokes)
    }
    
    func boundingBox(for points: [CGPoint]) -> CGRect {
        guard let first = points.first else { return .zero }
        
        var minX = first.x
        var minY = first.y
        var maxX = first.x
        var maxY = first.y

        for point in points {
            minX = min(minX, point.x)
            minY = min(minY, point.y)
            maxX = max(maxX, point.x)
            maxY = max(maxY, point.y)
        }

        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }



    
    @IBAction func colorButtonPressed(_ sender: Any) {
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        colorPicker.selectedColor = currentDrawingColor
        present(colorPicker, animated: true, completion: nil)
    }
    
    @IBAction func addImageButtonPressed(_ sender: Any) {
    }
    
    @IBAction func addTextButtonPressed(_ sender: Any) {
        isText.toggle()
        
        if let button = sender as? UIButton {
            button.tintColor = isText ? .systemBlue : .label
        }
    }
}

extension ScrapbookViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        currentDrawingColor = viewController.selectedColor

        // If the pen is currently active, update its color immediately
        if isDrawing {
            drawingCanvasView.tool = PKInkingTool(.pen, color: currentDrawingColor, width: 5)
        }
    }
}

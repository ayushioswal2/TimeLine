//
//  ScrapbookViewController.swift
//  TimeLine
//
//  Created by Audrey Chen on 3/11/25.
//

import UIKit
import PencilKit
import FirebaseFirestore
import FirebaseStorage

class ScrapbookViewController: UIViewController, UIGestureRecognizerDelegate, UIColorPickerViewControllerDelegate {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    // TODO add back in outlet for imageView that we need to readd (call backgroundImageView)
    @IBOutlet weak var canvasUIView: UIView!
    var drawingCanvasView: PKCanvasView!
    var currentDrawingColor: UIColor = .black
    var isDrawing: Bool = false
    var isShape: Bool = false
    var isRect: Bool = false
    var isText: Bool = false
    var isErasing: Bool = false
    var selectedElement: UIView?
    var canvasElements: [[String: Any]] = [] // need to pull this from firebase (that way can add more elements on top if someone re-redits)
    var backgroundImageView: UIImageView!
    
    var newImageURL: String = ""
    var newImagesList: [String] = []
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateColorScheme), name: NSNotification.Name("ColorSchemeChanged"), object: nil)

        view.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 225/255, alpha: 1)

        dateLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        dateLabel.textColor = UIColor.appColorScheme(type: "primary")
        dateLabel.text = currDay!.date

        saveButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
        saveButton.backgroundColor = UIColor.appColorScheme(type: "secondary")
        
        // set up background image
        backgroundImageView = UIImageView()
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.image = currImage
        backgroundImageView.layer.shadowRadius = 8
        backgroundImageView.layer.cornerRadius = 12
        backgroundImageView.layer.masksToBounds = true
        backgroundImageView.isUserInteractionEnabled = false
        self.view.insertSubview(backgroundImageView, at: 0)
        
        // make canvas page noticable to the user
        canvasUIView.backgroundColor = .clear
        canvasUIView.layer.shadowColor = UIColor.black.cgColor
        canvasUIView.layer.shadowOpacity = 0.2
        canvasUIView.layer.shadowOffset = CGSize(width: 0, height: 4)
        canvasUIView.layer.shadowRadius = 8
        canvasUIView.layer.cornerRadius = 12
        canvasUIView.clipsToBounds = true
        
        // add drawing frame for the pencil function
        drawingCanvasView = PKCanvasView(frame: canvasUIView.bounds)
        drawingCanvasView.backgroundColor = .clear
        drawingCanvasView.drawingPolicy = .anyInput
        canvasUIView.addSubview(drawingCanvasView)
        drawingCanvasView.isUserInteractionEnabled = isDrawing

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundImageView.frame = canvasUIView.convert(canvasUIView.bounds, to: view)
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
        
    }
    
    @IBAction func rectButtonPressed(_ sender: Any) {
        isRect.toggle()
        
        if let button = sender as? UIButton {
            button.tintColor = isRect ? .systemBlue : .label
        }
    }
    
    
    @IBAction func shapeButtonPressed(_ sender: Any) {
        isShape.toggle()
        if let button = sender as? UIButton {
            button.tintColor = isShape ? .systemBlue : .label
        }
    }
    
    @IBAction func drawShape(_ recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: canvasUIView)
        
        if isErasing {
            handleEraseTap(recognizer)
        }
        
        for subview in canvasUIView.subviews {
            if subview != drawingCanvasView && subview.frame.contains(tapLocation) {
                // Select it instead of creating anything new
                handleTapToSelect(UITapGestureRecognizer(target: self, action: #selector(handleTapToSelect(_:))))
                return
            }
        }

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
            
            circleView.isUserInteractionEnabled = true
            
            canvasUIView.addSubview(circleView)
            makeElementInteractive(circleView)

        }
        
        if isRect {
            let defaultWidth: CGFloat = 150
            let defaultHeight: CGFloat = 50
            let centerPoint = CGPoint(x: tapLocation.x, y: tapLocation.y)

            let rectView = UIView(frame: CGRect(
                x: centerPoint.x - defaultWidth / 2,
                y: centerPoint.y - defaultHeight / 2,
                width: defaultWidth,
                height: defaultHeight
            ))

            rectView.backgroundColor = currentDrawingColor
            rectView.isUserInteractionEnabled = true

            canvasUIView.addSubview(rectView)

            makeElementInteractive(rectView)
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
        makeElementInteractive(label)

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
    
    func makeElementInteractive(_ view: UIView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapToSelect(_:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func handleTapToSelect(_ gesture: UITapGestureRecognizer) {
        guard let tappedView = gesture.view else { return }

        // Deselect current
        if let currentlySelected = selectedElement, currentlySelected != tappedView {
            currentlySelected.layer.borderWidth = 0
            removeEditGestures(from: currentlySelected)
        }

        // Select tapped
        selectedElement = tappedView
        tappedView.layer.borderColor = UIColor.systemBlue.cgColor
        tappedView.layer.borderWidth = 2

        addEditGestures(to: tappedView)
    }

    func addEditGestures(to view: UIView) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.name = "editPan"
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinch.name = "editPinch"
        
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        rotation.name = "editRotation"
        
        view.addGestureRecognizer(pan)
        view.addGestureRecognizer(pinch)
        view.addGestureRecognizer(rotation)
    }

    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        let translation = gesture.translation(in: canvasUIView)
        view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        gesture.setTranslation(.zero, in: canvasUIView)
    }

    @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }
        view.transform = view.transform.scaledBy(x: gesture.scale, y: gesture.scale)
        gesture.scale = 1.0
    }

    @objc func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        guard let view = gesture.view else { return }
        view.transform = view.transform.rotated(by: gesture.rotation)
        gesture.rotation = 0
    }


    func removeEditGestures(from view: UIView) {
        view.gestureRecognizers?.removeAll(where: {
            $0.name == "editPan" || $0.name == "editPinch" || $0.name == "editRotation"
        })
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: canvasUIView)
        
        if let selected = selectedElement, !selected.frame.contains(location) {
            selected.layer.borderWidth = 0
            removeEditGestures(from: selected)
            selectedElement = nil
        }
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
    
    // might remove
    @IBAction func addImageButtonPressed(_ sender: Any) {
    }
    
    @IBAction func addTextButtonPressed(_ sender: Any) {
        isText.toggle()
        
        if let button = sender as? UIButton {
            button.tintColor = isText ? .systemBlue : .label
        }
    }
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        currentDrawingColor = viewController.selectedColor

        // If the pen is currently selected, update its color immediately
        if isDrawing {
            drawingCanvasView.tool = PKInkingTool(.pen, color: currentDrawingColor, width: 5)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        print("Save pressed")
        for subview in canvasUIView.subviews {
            let newElement: [String: Any] = createCanvasElement(subview: subview)
            canvasElements.append(newElement)
        }
        
        Task {
            await self.saveNewImage()
            await self.updateDayData()
            await self.updateLocalVariables()
        }
        
        // add all elements to firestore here (append to existing array of canvasElements
        print(canvasElements)
    }
    
    func mergeCanvasAndBackground() -> UIImage? {
        let size = canvasUIView.bounds.size
            
        guard let backgroundImage = backgroundImageView.image else { return nil }
        guard let canvasImage = renderCanvasAsImage() else { return nil }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let finalImage = renderer.image { context in
            // Draw the background image first
            backgroundImage.draw(in: CGRect(origin: .zero, size: size))
            
            // Draw the canvas contents on top
            canvasImage.draw(in: CGRect(origin: .zero, size: size))
        }
        
        return finalImage
    }
    
    func saveNewImage() async {
        print("in SaveNewImage")
        if let snapshotImage = mergeCanvasAndBackground() {
            // store snapshotImageView in firestore (replace the current image URL with this new one)
            do {
                if let imageData = snapshotImage.jpegData(compressionQuality: 0.8) {
                    let storageRef = Storage.storage().reference()
                    
                    let uniqueID = UUID().uuidString
                    let imageRef = storageRef.child("timelines/\(currTimelineID)/\(currDay!.date)/\(uniqueID).jpg")
                    
                    
                    let _ = try await imageRef.putDataAsync(imageData, metadata: nil)
                    newImageURL = try await imageRef.downloadURL().absoluteString
                }
            } catch {
                printContent(error)
            }
            print("canvas captured")
        } else {
            print("failed to get snapshot")
        }
    }
    
    func updateDayData() async {
        print("in updateDayData")
        do {
            let snapshot = try await db.collection("timelines")
                .document(currTimelineID)
                .collection("days")
                .whereField("date", isEqualTo: currDay!.date)
                .getDocuments()
            
            guard let document = snapshot.documents.first else {
                print("No matching document found for date \(currDay!.date)")
                return
            }
            
            let dayRef = document.reference
    
            newImagesList = try await dayRef.getDocument().data()!["images"] as! [String]
            newImagesList[currDayImageIndex!] = newImageURL
            
            dayRef.updateData(["images": newImagesList]) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("Document successfully updated!")
                }
            }
            
        } catch {
            print("error updating day data: \(error)")
        }
    }
    
    func updateLocalVariables() async {
        // update days (update currDay then update days[currDayIndex])
        if var day = days.first(where: {$0.date == currDay!.date}) {
            day.images[currDayImageIndex!] = newImageURL
        }
        
        // update currDay (stores ImageURLs as Strings)
        currDay!.images[currDayImageIndex!] = newImageURL
        
        // update currDayImages (stores UIImages)
        do {
            let imageURL = URL(string: newImageURL)
            let (data, _) = try await URLSession.shared.data(from: imageURL!)
            let image = UIImage(data: data)
            currDayImages[currDayImageIndex!] = image!
        } catch {
            printContent(error)
        }
    }
    
    // this is to save newly created page as an image to use on other storyboards
    func renderCanvasAsImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: canvasUIView.bounds)
        return renderer.image { context in
            canvasUIView.layer.render(in: context.cgContext)
        }
    }
    
    // save canvas elements so that we can re-edit again
    func createCanvasElement(subview: UIView) -> [String: Any] {
        let canvasWidth = canvasUIView.frame.width
        let canvasHeight = canvasUIView.frame.height
        let transform = subview.transform
        let rotation = atan2(transform.b, transform.a)
        
        var type: String = ""
        var newElement = [String: Any]()
        
        if subview == drawingCanvasView {
            let drawingData = drawingCanvasView.drawing.dataRepresentation()
            let base64 = drawingData.base64EncodedString()
            newElement = [
                "type": "drawing",
                "base64": base64
            ]
        } else if let label = subview as? UILabel {
            type = "text"
            newElement = [
                "type": type,
                "text": label.text ?? "",
                "x": subview.frame.minX / canvasWidth,
                "y": subview.frame.minY / canvasHeight,
                "width": subview.frame.width / canvasWidth,
                "height": subview.frame.height / canvasHeight,
                "color": colorToHex(color: label.textColor),
                "rotation": rotation
            ]
        } else {
            type = subview.layer.cornerRadius > 0 ? "circle" : "rect"
            newElement = [
                "type": type,
                "x": subview.frame.minX / canvasWidth,
                "y": subview.frame.minY / canvasHeight,
                "width": subview.frame.width / canvasWidth,
                "height": subview.frame.height / canvasHeight,
                "color": colorToHex(color: subview.backgroundColor ?? .black),
                "rotation": rotation
            ]
        }
        
        // TODO delete - for debugging right now
        print(newElement)
        
        return newElement
    }
    
    func colorToHex(color: UIColor) -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)
        let a = Int(alpha * 255)

        return String(format: "#%02X%02X%02X%02X", r, g, b, a)
    }
}

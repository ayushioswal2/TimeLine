//
//  AddToTimelineViewController.swift
//  TimeLine
//
//  Created by Adwita Gadre on 4/18/25.
//

import UIKit
import PhotosUI
import FirebaseFirestore
import FirebaseStorage

class AddToTimelineViewController: UIViewController, PHPickerViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectDateLabel: UILabel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var doneButton: UIButton!
        
    @IBOutlet weak var collectionView: UICollectionView!
    var selectedImages: [UIImage] = []
    var imageURLs : [String] = []
    
    var db: Firestore!
    
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        formatter.dateFormat = "MMMM d, yyyy"
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateColorScheme), name: NSNotification.Name("ColorSchemeChanged"), object: nil)
        
        updateFont()
        updateColorScheme()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "imageCell")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        imageURLs.removeAll(keepingCapacity: false)
    }
    
    @objc func updateFont() {
        titleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        selectDateLabel.font = UIFont.appFont(forTextStyle: .body)
        doneButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body)
    }
    
    @objc func updateColorScheme() {
        titleLabel.textColor = UIColor.appColorScheme(type: "primary")
        doneButton.backgroundColor = UIColor.appColorScheme(type: "secondary")
    }
    
    @IBAction func addPhotosPressed(_ sender: Any) {
        var pickerConfig = PHPickerConfiguration()
        pickerConfig.selectionLimit = 0 // 0 means no limit
        pickerConfig.filter = .images
        
        let photopicker = PHPickerViewController(configuration: pickerConfig)
        photopicker.delegate = self
        
        present(photopicker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            print("Got image: \(image)")
                            self.selectedImages.append(image)
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        let formattedDate = formatter.string(from: datePicker.date)
        
        if days.contains(where: { $0.date == formattedDate }) {
            print("Entry already exists")
            let controller = UIAlertController(title: "Error", message: "This date has already been added to the timeline", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default) { _ in }
            controller.addAction(action)
            present(controller, animated: true)
            
        } else {
            Task {
                await storeImages(formattedDate: formattedDate)
                await storeDayData()
                
                let newDay = Day(
                    date: formattedDate,
                    images: imageURLs)
                
                days.append(newDay)
                
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func storeImages(formattedDate: String) async {
        for image in selectedImages {
            // extract image url to store in firestore
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                let storageRef = Storage.storage().reference()
                
                let uniqueID = UUID().uuidString
                let imageRef = storageRef.child("timelines/\(currTimelineID)/\(formattedDate)/\(uniqueID).jpg")
                
                do {
                    // store in Firebase storage
                    let _ = try await imageRef.putDataAsync(imageData, metadata: nil)
                    let imageURL = try await imageRef.downloadURL().absoluteString
                                        
                    self.imageURLs.append(imageURL)
                } catch {
                    printContent(error)
                }
            }
        }
    }
    
    func storeDayData() async {
        do {
            let timelineRef = db.collection("timelines").document(currTimelineID)
            
            let formattedDate = formatter.string(from: datePicker.date)
            
            try await timelineRef.collection("days").addDocument(data: [
                "date": formattedDate,
                "images": imageURLs
            ])
        } catch {
            print("error storing day data: \(error)")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let imageView = UIImageView(frame: cell.contentView.bounds)
        imageView.image = selectedImages[indexPath.item]
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        cell.contentView.addSubview(imageView)
        
        return cell
    }
}

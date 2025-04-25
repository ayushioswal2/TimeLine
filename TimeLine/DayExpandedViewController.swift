//
//  DayExpandedViewController.swift
//  TimeLine
//
//  Created by Audrey Chen on 3/11/25.
//

import UIKit
import PhotosUI
import FirebaseFirestore
import FirebaseStorage

class DayExpandedViewController: UIViewController, PHPickerViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var selectedImages: [UIImage] = []
    var selectedImageURLs: [String] = []
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()

        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateColorScheme), name: NSNotification.Name("ColorSchemeChanged"), object: nil)
        
        view.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 225/255, alpha: 1)
        
        dateLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        dateLabel.textColor = UIColor.appColorScheme(type: "primary")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "expandedImageCell")
        collectionView.backgroundColor = .clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await updateCurrDayImages()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    @objc func updateFont() {
        dateLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
    }
    
    @objc func updateColorScheme() {
        dateLabel.textColor = UIColor.appColorScheme(type: "primary")
    }
    
    @IBAction func onAddPhotoPressed(_ sender: Any) {
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
                        }
                    }
                }
            }
        }
        
        Task {
            await storeImages(formattedDate: currDay!.date)
        }
    }
    
    func storeImages(formattedDate: String) async {
        var selectedImageURLs: [String] = []
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
                                        
                    // store to local copy of this day's imageURL array
                    currDay!.images.append(imageURL)
                    selectedImageURLs.append(imageURL)
                } catch {
                    printContent(error)
                }
            }
        }
        
        // update documents in Firestore
        db.collection("timelines").document(currTimelineID).collection("days").whereField("date", isEqualTo: formattedDate).getDocuments() { (snapshot, error) in
            if let error = error {
                print("error fetching document: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents, !documents.isEmpty else {
                print("no matching document found")
                return
            }
            
            let docRef = documents[0].reference
//            docRef.updateData(["images": FieldValue.arrayUnion(selectedImageURLs)])
            docRef.updateData(["images": currDay!.images])
        }
    }
    
    func updateCurrDayImages() async {
        do {
            for imageURLString in selectedImageURLs {
                let imageURL = URL(string: imageURLString)
                let (data, _) = try await URLSession.shared.data(from: imageURL!)
                let image = UIImage(data: data)
                
                if let image = image {
                    currDayImages.append(image)
                }
            }
        } catch {
            printContent(error)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currDayImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "expandedImageCell", for: indexPath)
        
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let imageView = UIImageView(frame: cell.contentView.bounds)
        imageView.image = currDayImages[indexPath.item]
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        cell.contentView.addSubview(imageView)
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "DayPages", bundle: nil)
        
        // Instantiate the DateTimelineViewController directly
        if let scrapbookingVC = storyboard.instantiateViewController(withIdentifier: "ScrapbookingPageID") as? ScrapbookViewController {
            
            // Push onto the current navigation stack
            self.navigationController?.pushViewController(scrapbookingVC, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout = UICollectionViewFlowLayout()
        let containerWidth = collectionView.bounds.width
        let cellWidth = containerWidth / 2 - 20
        let cellHeight = (cellWidth / 13) * 20
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.collectionViewLayout = layout
    }
}

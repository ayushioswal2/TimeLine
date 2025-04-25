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
        dateLabel.text = currDay?.date
        
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
                self.collectionView.reloadData() // Reload after images are updated
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        selectedImages.removeAll()
        selectedImageURLs.removeAll()
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
        
        let dispatchGroup = DispatchGroup()
        
        for result in results {
            
            dispatchGroup.enter()
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            print("Got image: \(image)")
                            self.selectedImages.append(image)
                        }
                    }
                    dispatchGroup.leave()
                }
            } else {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("images selected")
            print("selected count: \(self.selectedImages.count)")
            Task {
                await self.storeImages()
                await self.updateDayData()
                await self.updateCurrDayImages()
                self.collectionView.reloadData()
                self.selectedImages.removeAll()
                self.selectedImageURLs.removeAll()
            }
        }
    }
    
    func storeImages() async {
        print("in store images")
        print (selectedImages.count)
        do {
            for image in selectedImages {
                print("for loop")
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    let storageRef = Storage.storage().reference()
                    
                    let uniqueID = UUID().uuidString
                    let imageRef = storageRef.child("timelines/\(currTimelineID)/\(currDay!.date)/\(uniqueID).jpg")
    
                    let _ = try await imageRef.putDataAsync(imageData, metadata: nil)
                    let imageURL = try await imageRef.downloadURL().absoluteString

                    selectedImageURLs.append(imageURL)
                }
            }
        } catch {
            print("error storing images: \(error)")
        }
        
    }
    
    func updateDayData() async {
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
            
            try await dayRef.updateData([
                "images": FieldValue.arrayUnion(selectedImageURLs)
            ])
            
        } catch {
            print("error updating day data: \(error)")
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
            print("Error loading images: \(error)")
        }
    }
}
    


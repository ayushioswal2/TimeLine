//
//  AddToTimelineViewController.swift
//  TimeLine
//
//  Created by Adwita Gadre on 4/18/25.
//

import UIKit
import PhotosUI

class AddToTimelineViewController: UIViewController, PHPickerViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectDateLabel: UILabel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var doneButton: UIButton!
        
    @IBOutlet weak var collectionView: UICollectionView!
    var selectedImages: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateColorScheme), name: NSNotification.Name("ColorSchemeChanged"), object: nil)
        
        updateFont()
        updateColorScheme()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "imageCell")
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
        if dates.contains(datePicker.date) {
            print("Entry already exists")
        } else {
            dates.append(datePicker.date)
            dates.sort()
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

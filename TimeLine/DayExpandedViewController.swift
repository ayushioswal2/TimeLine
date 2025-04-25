//
//  DayExpandedViewController.swift
//  TimeLine
//
//  Created by Audrey Chen on 3/11/25.
//

import UIKit
import PhotosUI

class DayExpandedViewController: UIViewController, PHPickerViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var selectedImages: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "expandedImageCell", for: indexPath)
        
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let imageView = UIImageView(frame: cell.contentView.bounds)
        imageView.image = selectedImages[indexPath.item]
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

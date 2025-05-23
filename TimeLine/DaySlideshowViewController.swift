//
//  DaySlideshowViewController.swift
//  TimeLine
//
//  Created by Audrey Chen on 3/11/25.
//

import UIKit

class DaySlideshowViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ellipsesStackView: UIStackView!
    
    var currImageIndex = 0
    var numImages = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateColorScheme), name: NSNotification.Name("ColorSchemeChanged"), object: nil)

        view.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 225/255, alpha: 1)
        
        dateLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        dateLabel.textColor = UIColor.appColorScheme(type: "primary")
        dateLabel.text = currDay?.date
        
        numImages = currDayImages.count
        
        // style each photo cell in collection view
        imageView.layer.cornerRadius = 10
        
        ellipsesStackView.setContentHuggingPriority(.required, for: .horizontal)
        ellipsesStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        // swiping for slideshow
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(recognizeRightSwipeGesture(recognizer:)))
        swipeRightRecognizer.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRightRecognizer)
        
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(recognizeLeftSwipeGesture(recognizer:)))
        swipeLeftRecognizer.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeftRecognizer)
                
        if numImages > 0 {
            for _ in 1...numImages {
                addEllipses()
            }
            
            fillEllipse()
            showImage()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        numImages = currDayImages.count
        let numAddedImages = numImages - ellipsesStackView.subviews.count
        
        if numAddedImages > 0 {
            for _ in 1...numAddedImages {
                addEllipses()
            }
        }
    }
    
    func addEllipses() {
        let ellipseView = UIImageView(image: UIImage(systemName: "circle"))
        let width = (self.view.frame.width / 3 * 2) / (CGFloat(numImages) * 2)
        NSLayoutConstraint.activate([ellipseView.widthAnchor.constraint(equalToConstant: width),
                                     ellipseView.heightAnchor.constraint(equalToConstant: 20)])
        ellipseView.tintColor = UIColor(red: 70/255.0, green: 38/255.0, blue: 27/255.0, alpha: 1.0)
        ellipseView.contentMode = .scaleAspectFit
        ellipsesStackView.addArrangedSubview(ellipseView)
    }
    
    func fillEllipse() {
        if let imageView = ellipsesStackView.subviews[currImageIndex] as? UIImageView {
            imageView.image = UIImage(systemName: "circle.fill")
        }
    }
    
    func unfillEllipse() {
        if let imageView = ellipsesStackView.subviews[currImageIndex] as? UIImageView {
            imageView.image = UIImage(systemName: "circle")
        }
    }
    
    @objc func updateFont() {
        dateLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
    }

    @IBAction func expandedViewButtonClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "DayPages", bundle: nil)
        
        // Instantiate the DateTimelineViewController directly
        if let dayExpandedVC = storyboard.instantiateViewController(withIdentifier: "DayPageExpandedID") as? DayExpandedViewController {
            
            // Push onto the current navigation stack
            self.navigationController?.pushViewController(dayExpandedVC, animated: true)
        }
    }
    
    @IBAction func editButtonClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "DayPages", bundle: nil)
        
        // Instantiate the DateTimelineViewController directly
        if let scrapbookingVC = storyboard.instantiateViewController(withIdentifier: "ScrapbookingPageID") as? ScrapbookViewController {
            
            // Push onto the current navigation stack
            self.navigationController?.pushViewController(scrapbookingVC, animated: true)
        }
    }
    
    @objc func updateColorScheme() {
        dateLabel.textColor = UIColor.appColorScheme(type: "primary")
    }
    
    @IBAction func recognizeRightSwipeGesture(recognizer: UISwipeGestureRecognizer) {
        unfillEllipse()
        currImageIndex = (currImageIndex + numImages - 1) % numImages
        slideRight()
    }
    
    @IBAction func recognizeLeftSwipeGesture(recognizer: UISwipeGestureRecognizer) {
        unfillEllipse()
        currImageIndex = (currImageIndex + 1) % numImages
        slideLeft()
    }
    
    func slideLeft() {
        // first slide out old image to left
        self.imageView.center.x = self.view.center.x
        
        UIView.animate(
            withDuration: 0.15,
            animations: {
                self.imageView.center.x -= self.view.bounds.width
            }, completion: {_ in
                self.showImage()
                
                // then slide in new image from right
                self.imageView.center.x = self.view.center.x + self.view.bounds.width
                
                UIView.animate(
                    withDuration: 0.15,
                    animations: {
                        self.imageView.center.x -= self.view.bounds.width
                    }, completion: { _ in
                        self.fillEllipse()
                    }
                )
            }
        )
    }
    
    func slideRight() {
        // slide out old image to right
        self.imageView.center.x = self.view.center.x
        
        UIView.animate(
            withDuration: 0.15,
            animations: {
                self.imageView.center.x += self.view.bounds.width
            }, completion: { _ in
                self.showImage()
                
                // slide in new image from left
                self.imageView.center.x = self.view.center.x - self.view.bounds.width
                
                UIView.animate(
                    withDuration: 0.15,
                    animations: {
                        self.imageView.center.x += self.view.bounds.width
                    }, completion: { _ in
                        self.fillEllipse()
                    }
                )
            }
        )
    }
    
    func showImage() {
        imageView.image = currDayImages[currImageIndex]
    }
}

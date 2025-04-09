//
//  ScrapbookViewController.swift
//  TimeLine
//
//  Created by Audrey Chen on 3/11/25.
//

import UIKit

class ScrapbookViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)

        view.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 225/255, alpha: 1)

        dateLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        saveButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
    }
    
    @objc func updateFont() {
        dateLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        saveButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
    }
    
//    @IBAction func addScrapbookButtonPressed(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "DayPages", bundle: nil)
//        
//        // Instantiate the DateTimelineViewController directly
//        if let scrapbookingVC = storyboard.instantiateViewController(withIdentifier: "ScrapbookingPageID") as? ScrapbookViewController {
//            
//            // Push onto the current navigation stack
//            self.navigationController?.pushViewController(scrapbookingVC, animated: true)
//        }
//    }
    
    
}

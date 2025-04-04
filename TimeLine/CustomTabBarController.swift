//
//  TabBarController.swift
//  TimeLine
//
//  Created by Adwita Gadre on 4/3/25.
//
 
import UIKit

class CustomTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateColorScheme), name: NSNotification.Name("ColorSchemeChanged"), object: nil)
        
        tabBar.backgroundColor = UIColor.appColorScheme(type: "primary")
    }
    
    @objc func updateColorScheme() {
        tabBar.backgroundColor = UIColor.appColorScheme(type: "primary")
    }
}

//
//  DateCell.swift
//  TimeLine
//
//  Created by Ayushi Oswal on 3/11/25.
//

import UIKit

class DateCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var dummyCoverPhotoView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateColorScheme), name: NSNotification.Name("ColorSchemeChanged"), object: nil)
                
        // Initially set the font and colors
        updateFont()
        updateColorScheme()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func updateFont() {
        dateLabel.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
    }
    
    @objc func updateColorScheme() {
        dummyCoverPhotoView.backgroundColor = UIColor.appColorScheme(type: "primary")
        dummyCoverPhotoView.backgroundColor = UIColor.appColorScheme(type: "primary")
    }
}

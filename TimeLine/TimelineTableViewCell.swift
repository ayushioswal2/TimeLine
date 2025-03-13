//
//  TimelineTableViewCell.swift
//  TimeLine
//
//  Created by Adwita Gadre on 3/9/25.
//

import UIKit

class TimelineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timelineNameLabel: UILabel!
    @IBOutlet weak var timelineCoverImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)
                
        // Initially set the font
        updateFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @objc func updateFont() {
        timelineNameLabel.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
    }
}

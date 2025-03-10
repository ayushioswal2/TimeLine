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
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

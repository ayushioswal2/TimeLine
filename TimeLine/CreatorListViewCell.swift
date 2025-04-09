//
//  CreatorListViewCell.swift
//  TimeLine
//
//  Created by Ayushi Oswal on 4/9/25.
//

import UIKit

class CreatorListViewCell: UITableViewCell {

    @IBOutlet weak var deleteCreatorButton: UIImageView!
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var profileIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

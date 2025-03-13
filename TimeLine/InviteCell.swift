//
//  InviteCell.swift
//  TimeLine
//
//  Created by Ayushi Oswal on 3/11/25.
//

import UIKit

class InviteCell: UITableViewCell {

    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var timelineNameLabel: UILabel!
    @IBOutlet weak var inviterNameLabel: UILabel!
    
    var acceptAction: (() -> Void)?
    var rejectAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func acceptPressed(_ sender: Any) {
        acceptAction?()
    }
    
    
    @IBAction func rejectPressed(_ sender: Any) {
        rejectAction?()
    }
    
}

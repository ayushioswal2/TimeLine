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
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateColorScheme), name: NSNotification.Name("ColorSchemeChanged"), object: nil)
        
        // Initially set the font
        updateFont()
        
        acceptButton.tintColor = UIColor.appColorScheme(type: "primary")
        rejectButton.tintColor = UIColor.appColorScheme(type: "primary")
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
    
    @objc func updateFont() {
        timelineNameLabel.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
        inviterNameLabel.font = UIFont.appFont(forTextStyle: .caption1, weight: .regular)
    }
    
    @objc func updateColorScheme() {
        acceptButton.tintColor = UIColor.appColorScheme(type: "primary")
        rejectButton.tintColor = UIColor.appColorScheme(type: "primary")
    }
}

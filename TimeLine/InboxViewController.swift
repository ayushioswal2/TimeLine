//
//  InboxViewController.swift
//  TimeLine
//
//  Created by Ayushi Oswal on 3/10/25.
//

import UIKit

class InboxViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var inboxTitleLabel: UILabel!
    @IBOutlet weak var inviteTableView: UITableView!
    
    var invites: [Invite] = [
            Invite(groupName: "6rain", senderName: "Audrey"),
            Invite(groupName: "AAPS", senderName: "Shehreen"),
            Invite(groupName: "Travel", senderName: "Arwen")
        ]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)

        view.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 225/255, alpha: 1)
        inboxTitleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        inviteTableView.dataSource = self
        inviteTableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return invites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InviteCell", for: indexPath) as? InviteCell else {
            return UITableViewCell()
        }

        let invite = invites[indexPath.row]
        cell.timelineNameLabel.text = invite.groupName
        cell.inviterNameLabel.text = "@\(invite.senderName)"

        cell.acceptAction = {
            print("Accepted invite to \(invite.groupName)")
            self.invites.remove(at: indexPath.row)
            self.inviteTableView.reloadData()
        }

        cell.rejectAction = {
            print("Rejected invite to \(invite.groupName)")
            self.invites.remove(at: indexPath.row)
            self.inviteTableView.reloadData()
        }

        return cell
    }
    
    @objc func updateFont() {
        inboxTitleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
    }
}

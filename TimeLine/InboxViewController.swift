//
//  InboxViewController.swift
//  TimeLine
//
//  Created by Ayushi Oswal on 3/10/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class InboxViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var inboxTitleLabel: UILabel!
    @IBOutlet weak var inviteTableView: UITableView!
    
    var invites: [Invite] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateColorScheme), name: NSNotification.Name("ColorSchemeChanged"), object: nil)

        view.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 225/255, alpha: 1)
        inboxTitleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        inboxTitleLabel.textColor = UIColor.appColorScheme(type: "primary")
        inviteTableView.dataSource = self
        inviteTableView.delegate = self
        
        fetchInvites()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return invites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InviteCell", for: indexPath) as? InviteCell else {
                return UITableViewCell()
            }

            let invite = invites[indexPath.row]
            cell.timelineNameLabel.text = invite.timelineName
            cell.inviterNameLabel.text = "@\(invite.senderName)"

            cell.acceptAction = {
                self.handleAccept(invite: invite, at: indexPath.row)
            }

            cell.rejectAction = {
                self.handleReject(invite: invite, at: indexPath.row)
            }

            return cell
    }
    
    func handleAccept(invite: Invite, at index: Int) {
        print("Accepted invite to \(invite.timelineName)")
        // TODO: Add current user to timeline, remove invite from Firestore
        invites.remove(at: index)
        inviteTableView.reloadData()
    }

    func handleReject(invite: Invite, at index: Int) {
        print("Rejected invite to \(invite.timelineName)")
        // TODO: Remove the invite from Firestore
        invites.remove(at: index)
        inviteTableView.reloadData()
    }
    
    @objc func updateFont() {
        inboxTitleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
    }
    
    @objc func updateColorScheme() {
        inboxTitleLabel.textColor = UIColor.appColorScheme(type: "primary")
    }
    
    func fetchInvites() {
        guard let userEmail = Auth.auth().currentUser?.email else { return }
            
        let db = Firestore.firestore()
        // get the user information
        db.collection("users")
            .whereField("email", isEqualTo: userEmail)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching user: \(error)")
                    return
                }
                    
            guard let document = snapshot?.documents.first else {
                print("User document not found")
                return
            }
                    
             // get the list of invites stored in user
            let data = document.data()
            if let inviteData = data["invites"] as? [[String: Any]] {
                self.invites = inviteData.compactMap { inviteDict in
                        guard
                            let timelineName = inviteDict["timelineName"] as? String,
                            let inviterName = inviteDict["inviterName"] as? String
                        else { return nil }

                        return Invite(timelineName: timelineName, senderName: inviterName)
                    }
                
                DispatchQueue.main.async {
                    self.inviteTableView.reloadData()
                }
            }
        }
    }
}

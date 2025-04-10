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
            cell.inviterNameLabel.text = "@\(invite.inviterName)"

            cell.acceptAction = {
                self.handleAccept(invite: invite, at: indexPath.row)
            }

            cell.rejectAction = {
                self.handleReject(invite: invite, at: indexPath.row)
            }

            return cell
    }
    
    func handleAccept(invite: Invite, at index: Int) {
        guard let user = Auth.auth().currentUser, let userEmail = user.email else { return }
        let db = Firestore.firestore()

        db.collection("users")
            .whereField("email", isEqualTo: userEmail)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error finding user: \(error)")
                    return
                }

                guard let userDoc = snapshot?.documents.first else {
                    print("User document not found")
                    return
                }

                let userRef = userDoc.reference

                let inviteDict: [String: Any] = [
                    "inviterName": invite.inviterName,
                    "timelineName": invite.timelineName,
                    "status": "pending",
                    "timelineID": invite.timelineID
                ]

                userRef.updateData([
                    "timelines": FieldValue.arrayUnion([invite.timelineName]),
                    "invites": FieldValue.arrayRemove([inviteDict])
                ]) { err in
                    if let err = err {
                        print("Error updating user document: \(err)")
                        return
                    }

                    print("User timelines updated and invite removed from user doc.")

                    let timelineRef = db.collection("timelines").document(invite.timelineID)
                    timelineRef.getDocument { snapshot, error in
                        if let error = error {
                            print("Error finding timeline: \(error)")
                            return
                        }

                        guard let snapshot = snapshot, snapshot.exists else {
                            print("Timeline not found for ID: \(invite.timelineID)")
                            return
                        }

                        timelineRef.updateData([
                            "creators": FieldValue.arrayUnion([userEmail])
                        ]) { err in
                            if let err = err {
                                print("Error updating timeline creators: \(err)")
                            } else {
                                print("User added to timeline creators successfully.")
                            }

                            DispatchQueue.main.async {
                                self.invites.remove(at: index)
                                self.inviteTableView.reloadData()
                            }
                        }
                    }

                }
            }
    }



    func handleReject(invite: Invite, at index: Int) {
        guard let userEmail = Auth.auth().currentUser?.email else { return }
        let db = Firestore.firestore()

        db.collection("users")
            .whereField("email", isEqualTo: userEmail)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error finding user: \(error)")
                    return
                }

                guard let userDoc = snapshot?.documents.first else {
                    print("User document not found")
                    return
                }

                let userRef = userDoc.reference
                let inviteDict: [String: Any] = [
                    "inviterName": invite.inviterName,
                    "timelineName": invite.timelineName
                ]

                userRef.updateData([
                    "invites": FieldValue.arrayRemove([inviteDict])
                ]) { err in
                    if let err = err {
                        print("Error removing invite: \(err)")
                        return
                    }

                    print("Invite rejected and removed")

                    DispatchQueue.main.async {
                        self.invites.remove(at: index)
                        self.inviteTableView.reloadData()
                    }
                }
            }
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
                        let status = inviteDict["status"] as? String,
                        let timelineID = inviteDict["timelineID"] as? String,
                        let inviterName = inviteDict["inviterName"] as? String
                    else {
                        return nil
                    }

                    return Invite(
                        timelineName: timelineName,
                        status: status,
                        inviterName: inviterName,
                        timelineID: timelineID
                    )
                }

                
                DispatchQueue.main.async {
                    self.inviteTableView.reloadData()
                }
            }
        }
    }
}

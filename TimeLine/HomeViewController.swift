//
//  HomeViewController.swift
//  TimeLine
//
//  Created by Adwita Gadre on 3/9/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

var userTimelineNames: [String] = []
var userTimelineIDs: [String] = []

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var homeTitle: UILabel!
    @IBOutlet weak var createTimelineButton: UIButton!
    @IBOutlet weak var timelinesTableView: UITableView!
        
    let timelineCellIdentifier = "timelineCellIdentifier"
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        fetchUserTimelines()
        currTimelineID = ""
        currTimeline = nil
                
        setupUI()
        
        timelinesTableView.delegate = self
        timelinesTableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateColorScheme), name: NSNotification.Name("ColorSchemeChanged"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchUserTimelines()
        timelinesTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userTimelineNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: timelineCellIdentifier, for: indexPath) as! TimelineTableViewCell
        cell.timelineNameLabel.text = userTimelineNames[indexPath.row]

        return cell
    }
    
    func setupUI() {
        homeTitle.text = "My Timelines"
        homeTitle.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        homeTitle.textColor = UIColor.appColorScheme(type: "primary")
        
        createTimelineButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
        createTimelineButton.backgroundColor = UIColor.appColorScheme(type: "secondary")
    }
    
    @objc func updateFont() {
        homeTitle.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        createTimelineButton.titleLabel?.font = UIFont.appFont(forTextStyle: .body, weight: .regular)
    }
    
    @IBAction func createNewTimelinePressed(_ sender: Any) {
//        performSegue(withIdentifier: "toTimelineCreationID", sender: sender)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currTimelineID = userTimelineIDs[indexPath.row]
        
        Task {
            await getTimelineData()

            let storyboard = UIStoryboard(name: "IndividualTimeline", bundle: nil)
            if let dateTimelineVC = storyboard.instantiateViewController(withIdentifier: "DateTimelineStoryboard") as? TimelineMainViewController {
                self.navigationController?.pushViewController(dateTimelineVC, animated: true)
            }
        }
    }
    
    @objc func updateColorScheme() {
        createTimelineButton.backgroundColor = UIColor.appColorScheme(type: "secondary")
        homeTitle.textColor = UIColor.appColorScheme(type: "primary")
    }

    func getTimelineData() async {
        do {
            let document = try await db.collection("timelines").document(currTimelineID).getDocument()
            
            guard let data = document.data() else {
                print("No data found in document")
                return
            }

            currTimeline = Timeline(
                name: data["timelineName"] as? String ?? "Unknown Name",
                coverPhotoURL: (data["coverPhotoURL"] as? String).flatMap { URL(string: $0) },
                creators: data["creators"] as? [String] ?? []
            )
        } catch {
            print("Firestore fetch error: \(error.localizedDescription)")
        }
    }
    
    func fetchUserTimelines() {
        guard let currUserEmail = Auth.auth().currentUser?.email else { return }
        
        db.collection("users").whereField("email", isEqualTo: currUserEmail).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching user document: \(error)")
                return
            }
            
            guard let document = snapshot?.documents.first else {
                print("No user document found")
                return
            }
            
            userTimelines = document["timelines"] as? [String: String] ?? [:]
            
            let sortedTimelines = userTimelines.sorted { $0.value < $1.value }

            userTimelineIDs = sortedTimelines.map { $0.key }
            userTimelineNames = sortedTimelines.map { $0.value }

            DispatchQueue.main.async {
                self.timelinesTableView.reloadData()
            }
        }
    }
}

// image stuff:
// bug for office hours: cover images are populating irregularly for wrong timelines
//        db.collection("timelines").whereField("timelineName", isEqualTo: timelines[indexPath.row]).getDocuments() { (snapshot, error) in
//            if let error = error {
//                print("error fetching document: \(error)")
//                return
//            }
//
//            guard let documents = snapshot?.documents, !documents.isEmpty else {
//                print("no matching document found")
//                return
//            }
//
//            let document = documents.first
//            let data = document?.data()
//            let coverImageURL = data?["coverPhotoURL"] as? String
//            guard let imageURL = URL(string: coverImageURL ?? "") else {
//                print("invalid cover image URL for \(timelines[indexPath.row])")
//                return
//            }
//            do {
//                let imageData = try Data(contentsOf: imageURL)
//                cell.timelineCoverImageView.image = UIImage(data: imageData)
//            } catch {
//                print ("error loading image: \(error)")
//            }
//        }

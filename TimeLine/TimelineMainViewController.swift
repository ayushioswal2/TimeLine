//
//  DateTimlineViewController.swift
//  TimeLine
//
//  Created by Ayushi Oswal on 3/11/25.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

var deletionOrLeaveOccurred: Bool = false

class TimelineMainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var datesTableView: UITableView!
    @IBOutlet weak var timelineTitleLabel: UILabel!
    @IBOutlet weak var addToTimelineButton: UIButton!
    @IBOutlet weak var timelineSettingsButton: UIButton!
    
    let formatter = DateFormatter()
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateFont), name: NSNotification.Name("FontChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateColorScheme), name: NSNotification.Name("ColorSchemeChanged"), object: nil)

        view.backgroundColor = UIColor.init(red: 255/255, green: 244/255, blue: 225/255, alpha: 1)
        timelineTitleLabel.textColor = UIColor(red: 75/255, green: 36/255, blue: 24/255, alpha: 1)

        timelineTitleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
        timelineTitleLabel.textColor = UIColor.appColorScheme(type: "primary")
        timelineTitleLabel.text = currTimeline?.name
        
        datesTableView.dataSource = self
        datesTableView.delegate = self
        self.datesTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        addToTimelineButton.backgroundColor = UIColor.appColorScheme(type: "secondary")
        timelineSettingsButton.tintColor = UIColor.appColorScheme(type: "secondary")

        formatter.dateFormat = "MMMM d, yyyy"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFont()
        updateColorScheme()
        
        timelineTitleLabel.text = currTimeline?.name

        Task {
            await retrieveDaysData()
            DispatchQueue.main.async {
                self.datesTableView.reloadData()
            }
        }
        
        if deletionOrLeaveOccurred {
            self.navigationController?.popViewController(animated: true)
            deletionOrLeaveOccurred = false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath) as! DateCell
                
        let thisDay = days[indexPath.row]
        cell.dateLabel.text = thisDay.date
        cell.dayCoverImage.image = nil
        cell.addToDayIcon.isHidden = false
        
        if let firstImageURLString = thisDay.images.first, let url = URL(string: firstImageURLString) {
            Task {
                let dayCoverImageURL = URL(string: thisDay.images[0])!
                let (data, _) = try await URLSession.shared.data(from: dayCoverImageURL)
                let image = UIImage(data: data)
                
                if let image = image {
                    if let currentIndexPath = tableView.indexPath(for: cell), currentIndexPath == indexPath {
                        DispatchQueue.main.async {
                            cell.dayCoverImage.image = image
                            cell.addToDayIcon.isHidden = true
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Select this Day as currDay for easier loading in other VCs
        currDay = days[indexPath.row]
        var selectedDayImages = [] as [UIImage]
        Task {
            for imageURLString in currDay!.images {
                let imageURL = URL(string: imageURLString)
                let (data, _) = try await URLSession.shared.data(from: imageURL!)
                let image = UIImage(data: data)
                
                if let image = image {
                    selectedDayImages.append(image)
                }
            }
            currDayImages = selectedDayImages            
            
            // Load the other storyboard
            let storyboard = UIStoryboard(name: "DayPages", bundle: nil)
            
            // Instantiate the DateTimelineViewController directly
            if let daySlideshowVC = storyboard.instantiateViewController(withIdentifier: "DayPageID") as? DaySlideshowViewController {
                
                // Push onto the current navigation stack
                self.navigationController?.pushViewController(daySlideshowVC, animated: true)
            }
        }
    }
    
    func retrieveDaysData() async {
        var fetchedDays: [Day] = []

        do {
            let daysRef = db.collection("timelines").document(currTimelineID).collection("days")
            let snapshot = try await daysRef.getDocuments()
            
            for doc in snapshot.documents {
                let data = doc.data()
                let date = data["date"] as? String ?? "Unknown Date"
                let images = data["images"] as? [String] ?? []
                
                let day = Day(date: date, images: images)
                fetchedDays.append(day)
            }
        } catch {
            print("Error fetching days: \(error)")
        }

        fetchedDays.sort { lhs, rhs in
            guard let lhsDate = formatter.date(from: lhs.date),
                  let rhsDate = formatter.date(from: rhs.date) else { return false }
            return lhsDate < rhsDate
        }
        
        days = fetchedDays
    }
        
    @IBAction func settingsButtonPressed(_ sender: Any) {
        // Load the other storyboard
        let storyboard = UIStoryboard(name: "IndividualTimeline", bundle: nil)

        // Instantiate the DateTimelineViewController directly
        if let dateTimelineVC = storyboard.instantiateViewController(withIdentifier: "SettingsDateTimelineId") as? TimelineSettingsViewController {

            // Push onto the current navigation stack
            self.navigationController?.pushViewController(dateTimelineVC, animated: true)
        }
    }
    
    @IBAction func addToTimelinePressed(_ sender: Any) {
        // Load the other storyboard
        let storyboard = UIStoryboard(name: "IndividualTimeline", bundle: nil)

        if let addToTimelineVC = storyboard.instantiateViewController(withIdentifier: "AddToTimelineID") as? AddToTimelineViewController {

            // Push onto the current navigation stack
            self.navigationController?.pushViewController(addToTimelineVC, animated: true)
        }
    }
    
    @objc func updateColorScheme() {
        timelineTitleLabel.textColor = UIColor.appColorScheme(type: "primary")
        addToTimelineButton.backgroundColor = UIColor.appColorScheme(type: "secondary")
        timelineSettingsButton.tintColor = UIColor.appColorScheme(type: "secondary")
    }
    
    @objc func updateFont() {
        timelineTitleLabel.font = UIFont.appFont(forTextStyle: .title1, weight: .bold)
    }
}


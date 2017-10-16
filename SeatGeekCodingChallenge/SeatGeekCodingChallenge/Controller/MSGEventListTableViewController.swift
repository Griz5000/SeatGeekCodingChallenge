//
//  MSGEventListTableViewController.swift
//  SeatGeekCodingChallenge
//
//  Created by Michael Grysikiewicz on 10/16/17.
//  Copyright © 2017 Michael Grysikiewicz. All rights reserved.
//

import UIKit

typealias JSONDictionary = [String: Any]
typealias QueryResult = ([MSGEventDescriptor]?, String) -> ()

class MSGEventListTableViewController: UITableViewController {
    
    let cellReuseIdentifier = "EventListingCell"
    let detailSegueIdentifier = "Event Detail Segue"
    
    var searchBar = UISearchBar()
    
    var eventList = [MSGEventDescriptor]()
    
    var dataTask: URLSessionDataTask?
    let defaultSession = URLSession(configuration: .default)
    
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.placeholder = "Search"
        searchBar.showsCancelButton = true
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        navigationController?.navigationBar.barTintColor = UIColor.lightGray
        
        restoreSavedEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let eventDetailController = segue.destination as? MSGEventDetailViewController {
            if let indexPath = sender as? IndexPath {
                
                let selectedEvent = eventList[indexPath.row]
                
                eventDetailController.eventToDisplay = selectedEvent
                
                //                let backItem = UIBarButtonItem()
                //                backItem.title = selectedEvent.title
                //                navigationItem.backBarButtonItem = backItem
            }
        }
    }
    
    fileprivate func dismissKeyboard() {
        searchBar.endEditing(true)
    }
    
    fileprivate func updateSearchResults(_ data: Data) {
        var response: JSONDictionary?
        restoreSavedEvents()
        
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            print("JSONSerialization error: \(parseError.localizedDescription)")
            return
        }
        
        // Get the results array
        guard let array = response!["events"] as? [Any] else {
            print("Dictionary does not contain events key")
            return
        }
        
        for eventDictionary in array {
            if let eventDictionary = eventDictionary as? JSONDictionary,
                let eventTitle = eventDictionary["title"] as? String,
                let dateTimeLocalString = eventDictionary["datetime_local"] as? String,
                let venueDictionary = eventDictionary["venue"] as? JSONDictionary,
                let displayLocationString = venueDictionary["display_location"] as? String,
                let performersArray = eventDictionary["performers"] as? [JSONDictionary],
                let eventId = eventDictionary["id"] as? Int {
                
                let inputDateFromStringFormatter = DateFormatter()
                inputDateFromStringFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                let outputDateFromStringFormatter = DateFormatter()
                outputDateFromStringFormatter.dateFormat = "EEE, dd LLL yyyy hh:mm a"
                let convertedDate = inputDateFromStringFormatter.date(from: dateTimeLocalString)
                if let convertedDate = convertedDate {
                    
                    let formattedDate = outputDateFromStringFormatter.string(from: convertedDate)
                    
                    for performerDictionary in performersArray {
                        if let locationImageURLString = performerDictionary["image"] as? String,
                            let locationImageURL = URL(string: locationImageURLString) {
                            
                            let newEvent = MSGEventDescriptor(uniqueId: eventId, imageDataURL: locationImageURLString, title: eventTitle, localTime: formattedDate, location: displayLocationString, isFavorite: false)
                            eventList.append(newEvent)
                            
                            getImageData(newEvent, with: locationImageURL)
                        }
                    }
                    
                    
                }
            } else {
                print("Problem parsing trackDictionary")
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    fileprivate func getImageData(_ forEvent: MSGEventDescriptor, with imageURL: URL) {
        let imageDataTask = defaultSession.dataTask(with: imageURL) { (data, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                forEvent.imageData = data
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
        }
        imageDataTask.resume()
    }
    
    fileprivate func restoreSavedEvents() {
        DispatchQueue.main.async {
            self.eventList.removeAll()
            
            // Restore all favorited event
            self.eventList = MSGEventDescriptor.retrieveFavoritedEvents()
            
            self.tableView.reloadData()
        }
    }
}

extension MSGEventListTableViewController {
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return eventList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! MSGEventTableViewCell
        
        // Configure the cell...
        let event = eventList[indexPath.row]
        
        // The UIImage should be saved somewhere instead of converted each time
        var imageToDisplay = UIImage(named: "lion_2")!
        if let imageData = event.imageData {
            imageToDisplay = UIImage(data: imageData)!
        } else {
            let locationImageURL = URL(string: event.imageDataURL)
            getImageData(event, with: locationImageURL!)
        }
        
        if event.isFavorite {
            cell.favoritedImageView.isHidden = false
        }
        cell.eventImageView.image = imageToDisplay
        cell.eventTitleLabel.text = event.title
        cell.eventLocationLabel.text = event.location
        cell.eventTimeLabel.text = event.localTime
        
        cell.eventImageView.layer.cornerRadius = ViewConstants.cornerRadius
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: detailSegueIdentifier, sender: indexPath)
    }
}

// MARK: - UISearchBarDelegate
extension MSGEventListTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchBar.text!.isEmpty {
            dataTask?.cancel()
            var urlComponents = URLComponents(string: "https://api.seatgeek.com/2/events?client_id=ODQ1ODI0N3wxNTAyMzE0MTU3Ljcy")
            urlComponents?.queryItems?.append(URLQueryItem(name: "q", value: searchBar.text!))
            guard let url = urlComponents?.url else { return }
            
            dataTask = defaultSession.dataTask(with: url) { (data, response, error) in
                defer {
                    self.dataTask = nil
                }
                
                if let error = error {
                    print(error.localizedDescription)
                } else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    self.updateSearchResults(data)
                }
            }
            dataTask?.resume()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        searchBar.text = ""
        restoreSavedEvents()
    }
}


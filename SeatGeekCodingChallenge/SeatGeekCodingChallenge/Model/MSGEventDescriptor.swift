//
//  MSGEventDescriptor.swift
//  SeatGeekCodingChallenge
//
//  Created by Michael Grysikiewicz on 10/16/17.
//  Copyright © 2017 Michael Grysikiewicz. All rights reserved.
//

import Foundation

class MSGEventDescriptor {
    
    static let defaultsPrefix = "MSGEventDescriptor:"
    
    
    var uniqueId = 0
    var imageData: Data?
    var imageDataURL = ""
    var title = ""
    var localTime = ""
    var location = ""
    var isFavorite = false {
        didSet {
            persist()
        }
    }
    
    convenience init(uniqueId: Int, imageDataURL: String, title: String, localTime: String, location: String, isFavorite: Bool) {
        self.init()
        self.uniqueId = uniqueId
        self.imageDataURL = imageDataURL
        self.title = title
        self.localTime = localTime
        self.location = location
        self.isFavorite = isFavorite
    }
    
    func toggleIsFavorite() {
        isFavorite = !isFavorite
    }
    
    func persist() {
        let userDefaults = UserDefaults.standard
        let uniqueIdString = "\(uniqueId)"
        let uniqueDefaultsKey = MSGEventDescriptor.defaultsPrefix + uniqueIdString
        
        // Only persist favorite events
        if isFavorite {
            let eventDictionary: [String: Any] = [
                "uniqueId": uniqueId,
                "imageDataURL": imageDataURL,
                "title": title,
                "localTime": localTime,
                "location": location,
                "isFavorite": isFavorite ]
            
            userDefaults.set(eventDictionary, forKey: uniqueDefaultsKey)
        } else {
            userDefaults.removeObject(forKey: uniqueDefaultsKey)
        }
    }
    
    class func retrieveFavoritedEvents() -> [MSGEventDescriptor] {
        var favoritedEventsArray: [MSGEventDescriptor] = []
        
        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
            if key.hasPrefix(MSGEventDescriptor.defaultsPrefix) {
                if let eventDictionary = value as? [String: Any] {
                    let favoriteEvent = MSGEventDescriptor(uniqueId: eventDictionary["uniqueId"] as! Int,
                                                           imageDataURL: eventDictionary["imageDataURL"] as! String,
                                                           title: eventDictionary["title"] as! String,
                                                           localTime: eventDictionary["localTime"] as! String,
                                                           location: eventDictionary["location"] as! String,
                                                           isFavorite: true) // Must be a favorite, it is in UserDefaults
                    favoritedEventsArray.append(favoriteEvent)
                    
                }
            }
        }
        
        return favoritedEventsArray
    }
}

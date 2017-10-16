//
//  MSGEventDetailViewController.swift
//  SeatGeekCodingChallenge
//
//  Created by Michael Grysikiewicz on 10/16/17.
//  Copyright © 2017 Michael Grysikiewicz. All rights reserved.
//

import UIKit

class MSGEventDetailViewController: UIViewController {
    
    enum EventFavoriteImage {
        case favorite
        case unfavorite
        
        var image: UIImage {
            switch self {
            case .favorite: return UIImage(named: "like-full")!
            case .unfavorite: return UIImage(named: "like-empty")!
            }
        }
    }
    
    // MARK: - Properties
    @IBOutlet weak var favoriteBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var eventDetailImageView: UIImageView!
    @IBOutlet weak var eventDetailTimeLabel: UILabel!
    @IBOutlet weak var eventDetailLocationLabel: UILabel!
    
    public var eventToDisplay: MSGEventDescriptor?
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if let eventToDisplay = eventToDisplay {
            updateIsFavoriteButton()
            
            eventDetailImageView.image = UIImage(named: "lion_2")!
            if let imageData = eventToDisplay.imageData {
                // The UIImage should be saved instead of converted each time
                eventDetailImageView.image = UIImage(data: imageData)
            }
            
            eventDetailImageView.layer.cornerRadius = ViewConstants.cornerRadius
            eventDetailTimeLabel.text = eventToDisplay.localTime
            eventDetailLocationLabel.text = eventToDisplay.location
            
            formatTitleBar()
        }
    }
    
    private func formatTitleBar() {
        if let eventToDisplay = eventToDisplay {
            
            guard let navBarFrameSize = navigationController?.navigationBar.frame.size else { return }
            let navBarTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: navBarFrameSize.width, height: navBarFrameSize.height * 2))
            navBarTitleLabel.numberOfLines = 0
            navBarTitleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
            navBarTitleLabel.textAlignment = .left
            navBarTitleLabel.text = eventToDisplay.title
            
            navigationItem.titleView = navBarTitleLabel
        }
    }
    
    @IBAction func toggleFavorite(_ sender: UIBarButtonItem) {
        if let eventToDisplay = eventToDisplay {
            eventToDisplay.toggleIsFavorite()
            updateIsFavoriteButton()
        }
    }
    
    private func updateIsFavoriteButton() {
        if let eventToDisplay = eventToDisplay {
            favoriteBarButtonItem.image = (eventToDisplay.isFavorite) ? EventFavoriteImage.favorite.image : EventFavoriteImage.unfavorite.image
        }
    }
}

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
    
    public weak var eventToDisplay: MSGEventDescriptor?
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if let unwrappedEventToDisplay = eventToDisplay {
            updateIsFavoriteButton()
            
            eventDetailImageView.image = UIImage(named: "lion_2")!
            if let imageData = unwrappedEventToDisplay.imageData {
                // The UIImage should be saved instead of converted each time
                eventDetailImageView.image = UIImage(data: imageData)
            }
            
            eventDetailImageView.layer.cornerRadius = ViewConstants.cornerRadius
            eventDetailTimeLabel.text = unwrappedEventToDisplay.localTime
            eventDetailLocationLabel.text = unwrappedEventToDisplay.location
            
            formatTitleBar()
        }
    }
    
    private func formatTitleBar() {
        if let unwrappedEventToDisplay = eventToDisplay {
            
            guard let navBarFrameSize = navigationController?.navigationBar.frame.size else { return }
            let navBarTitleLabel = UILabel(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: navBarFrameSize.width,
                                                         height: navBarFrameSize.height * 2))
            navBarTitleLabel.numberOfLines = 0
            navBarTitleLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
            navBarTitleLabel.textAlignment = .center
            navBarTitleLabel.adjustsFontSizeToFitWidth = true
            navBarTitleLabel.minimumScaleFactor = 0.5
            navBarTitleLabel.text = unwrappedEventToDisplay.title
            
            navigationItem.titleView = navBarTitleLabel
        }
    }
    
    @IBAction func toggleFavorite(_ sender: UIBarButtonItem) {
        if let unwrappedEventToDisplay = eventToDisplay {
            unwrappedEventToDisplay.toggleIsFavorite()
            updateIsFavoriteButton()
        }
    }
    
    private func updateIsFavoriteButton() {
        if let unwrappedEventToDisplay = eventToDisplay {
            favoriteBarButtonItem.image = (unwrappedEventToDisplay.isFavorite) ?
                                            EventFavoriteImage.favorite.image :
                                            EventFavoriteImage.unfavorite.image
        }
    }
}

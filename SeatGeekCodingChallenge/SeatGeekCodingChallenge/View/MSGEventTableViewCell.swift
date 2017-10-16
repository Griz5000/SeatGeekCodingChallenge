//
//  MSGEventTableViewCell.swift
//  SeatGeekCodingChallenge
//
//  Created by Michael Grysikiewicz on 10/16/17.
//  Copyright © 2017 Michael Grysikiewicz. All rights reserved.
//

import UIKit

class MSGEventTableViewCell: UITableViewCell {
    
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventLocationLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var favoritedImageView: UIImageView!
    
    override func prepareForReuse() {
        eventImageView.image = nil
        eventTitleLabel.text = nil
        eventLocationLabel.text = nil
        eventTimeLabel.text = nil
        favoritedImageView.isHidden = true
    }
}


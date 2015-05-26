//
//  TourItemCell.swift
//  There
//
//  Created by Carsten Witzke on 23/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

import UIKit

class TourItemCell: UITableViewCell {

    var item:GeoItem!
    @IBOutlet weak var waypointImageView: UIImageView!
    @IBOutlet weak var waypointLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setup(geoItem:GeoItem) {
        self.item = geoItem
        waypointLabel.text = "\(item.title)\n\(item.vicinity)"
    }
}

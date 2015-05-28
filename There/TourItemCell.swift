//
//  TourItemCell.swift
//  There
//
//  Created by Carsten Witzke on 23/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

import UIKit
import MapKit

class TourItemCell: UITableViewCell {
    
    var item:GeoItem!
    private let geoCoder = CLGeocoder()
    
    @IBOutlet weak var waypointImageView: UIImageView!
    @IBOutlet weak var waypointLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        waypointLabel.preferredMaxLayoutWidth = CGRectGetWidth(bounds) - CGRectGetMinX(frame)
    }

    func setup(geoItem:GeoItem, distanceFormatter formatter:NSLengthFormatter) {
        self.item = geoItem
        
        // headline: name and distance to waypoint
        var attributes = [
            NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        ]
        var headline = item.title!
        if item.distanceInMeters > 0 {
            let dist = formatter.stringFromMeters(Double(item.distanceInMeters))
            headline += " – \(dist)"
        }
        var labelString = NSMutableAttributedString(string: headline, attributes: attributes)
        
        // subhead: vicinity
        attributes = [
            NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        ]
        if item.vicinity != nil {
            let details = "\n\(item.vicinity!)"
            var subhead = NSAttributedString(string: details, attributes: attributes)
            labelString.appendAttributedString(subhead)
        }
        
        waypointLabel.attributedText = labelString
        
        // render background image
        render(waypoint: self.item, size: bounds.size) { (image) -> Void in
            self.waypointImageView.image = image
        }
    }
    
    func render(waypoint item:GeoItem, size:CGSize, completionBlock:(image:UIImage?) -> Void) {
        let loc = CLLocation(latitude: item.coordinate.latitude, longitude: item.coordinate.longitude)
        geoCoder.reverseGeocodeLocation(loc, completionHandler: { (placemarks, error) -> Void in
            if (error != nil) {
                completionBlock(image: nil)
            }
            
            if let pms = placemarks as? [CLPlacemark] {
                let placemark = pms.first
                if placemark == nil {
                    completionBlock(image: nil)
                }
                
                let options = MKMapSnapshotOptions()
                let region:CLCircularRegion = placemark!.region as! CLCircularRegion
                options.region = MKCoordinateRegionMakeWithDistance(region.center, region.radius, region.radius)
                options.scale = UIScreen.mainScreen().scale
                options.size = size
                options.showsPointsOfInterest = true
                
                let snapshotter = MKMapSnapshotter(options: options)
                snapshotter.startWithCompletionHandler({ (snapshot, error) -> Void in
                    var image = snapshot.image
                    completionBlock(image: image)
                })
            }
        })
    }
}

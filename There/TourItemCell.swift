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
    private let geoCoder = CLGeocoder()
    @IBOutlet weak var waypointImageView: UIImageView!
    @IBOutlet weak var waypointLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        waypointLabel.preferredMaxLayoutWidth = CGRectGetWidth(bounds)
    }

    func setup(geoItem:GeoItem) {
        self.item = geoItem
        waypointLabel.text = "\(item.title!)\n\(item.vicinity!)"
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

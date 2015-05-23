//
//  GeoItem.swift
//  There
//
//  Created by Carsten Witzke on 23/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

import UIKit
import MapKit

class GeoItem: NSObject {
    let href:String
    let coordinate: CLLocationCoordinate2D
    
    var id:String?
    var title:String?
    var vicinity:String?

    init(href:String, latitude lat:Double, longitude lng:Double) {
        self.href = href
        coordinate = CLLocationCoordinate2DMake(lat, lng)
    }
    
    init(dictionary dict:NSDictionary) {
        assert(dict["type"] as! String == "urn:nlp-types:place", "invalid data dictionary")
        
        if let href = dict["href"] as? String {
            self.href = href
        } else { // TODO: handle this case
            href = "undefined"
        }
        if let position = dict["position"] as? [Double] {
            coordinate = CLLocationCoordinate2DMake(position[0], position[1])
        } else {
            coordinate = CLLocationCoordinate2DMake(0, 0)
        }
        
        if let id = dict["id"] as? String {
            self.id = id
        }
        if let title = dict["title"] as? String {
            self.title = title
        }
        if let vicinity = dict["vicinity"] as? String {
            self.vicinity = vicinity
        }
    }
}

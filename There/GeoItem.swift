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
    let id:String
    let coordinate: CLLocationCoordinate2D
    
    var href:String?
    var title:String?
    var vicinity:String?

    init(identifier id:String, latitude lat:Double, longitude lng:Double) {
        self.id = id
        coordinate = CLLocationCoordinate2DMake(lat, lng)
    }
    
    init(dictionary dict:NSDictionary) {
        assert(dict["type"] as! String == "urn:nlp-types:place", "invalid data dictionary")
        
        if let id = dict["id"] as? String {
            self.id = id
        } else { // TODO: handle this case
            id = "undefined"
        }
        if let position = dict["position"] as? [Double] {
            coordinate = CLLocationCoordinate2DMake(position[0], position[1])
        } else {
            coordinate = CLLocationCoordinate2DMake(0, 0)
        }
        
        if let href = dict["href"] as? String {
            self.href = href
        }
        if let title = dict["title"] as? String {
            self.title = title
        }
        if let vicinity = dict["vicinity"] as? String {
            self.vicinity = vicinity
        }
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let object = object as? GeoItem {
            return id == object.id
        } else {
            return false
        }
    }
    
    override var hash: Int {
        return id.hashValue
    }
}

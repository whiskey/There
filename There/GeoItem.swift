//
//  GeoItem.swift
//  There
//
//  Created by Carsten Witzke on 23/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

import UIKit
import MapKit
import ThereSDK


class GeoItem: STLLinkObject {

    init(identifier id:String, latitude lat:Double, longitude lng:Double) {
//        identifier = id
//        coordinate = CLLocationCoordinate2DMake(lat, lng)
        super.init()
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let object = object as? GeoItem {
            return identifier == object.identifier
        } else {
            return false
        }
    }
    
    override var hash: Int {
        return identifier.hashValue
    }
}

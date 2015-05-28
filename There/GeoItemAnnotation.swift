//
//  GeoItemAnnotation.swift
//  There
//
//  Created by Carsten Witzke on 23/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

import UIKit
import MapKit


class GeoItemAnnotation: MKPointAnnotation {
    class func identifier() -> String {
        return "GeoItemAnnotation"
    }
    
    var geoItem:GeoItem!
    
    init(geoItem:GeoItem) {
        self.geoItem = geoItem
    }
    
    func annotationView() -> MKAnnotationView {
        let annotationView = MKPinAnnotationView(annotation: self, reuseIdentifier: GeoItemAnnotation.identifier())
        annotationView!.animatesDrop = true
        annotationView!.enabled = true
        annotationView!.canShowCallout = true
        annotationView!.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.ContactAdd) as! UIView
        return annotationView
    }
    
}

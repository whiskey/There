//
//  MapViewController.swift
//  There
//
//  Created by Carsten Witzke on 22/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {
    // Xcode/IB still struggle with the new UISearchController - let's do it manually
    var searchController:UISearchController!
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup search controller
        let src = SearchResultsController(style: .Plain) // currently
        searchController = UISearchController(searchResultsController: src)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = UISearchBarStyle.Minimal
        searchController.searchBar.placeholder = NSLocalizedString("searchbar.placeholder", comment: "")
        navigationItem.titleView = searchController.searchBar
        definesPresentationContext = true
    }
    
    override func viewDidAppear(animated: Bool) {
        // TODO: ask nicely
        switch CLLocationManager.authorizationStatus() {
        case CLAuthorizationStatus.NotDetermined:
            locationManager.requestWhenInUseAuthorization()
        case CLAuthorizationStatus.Denied:
            log.warning("user denied location lookup")
            askForGPS()
        default:
            startLocationManager()
        }
    }
    
    func askForGPS() {
        let alertController = UIAlertController(
            title: NSLocalizedString("nogpspermission.title", comment: ""),
            message: NSLocalizedString("nogpspermission.message", comment: ""),
            preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("label.cancel", comment: ""), style: .Cancel) { (action) in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let settingsAction = UIAlertAction(title: NSLocalizedString("label.settings", comment: ""), style: .Default) { (action) in
            if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
        alertController.addAction(settingsAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }

    // MARK: - LocationManager/-delegate
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
            log.verbose("location manager up")
            
            mapView.showsUserLocation = true
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedAlways || status == CLAuthorizationStatus.AuthorizedWhenInUse {
            startLocationManager()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let loc:CLLocation = locations.first as? CLLocation {
            // later...
        }
    }
    
}

//
//  MapViewController.swift
//  There
//
//  Created by Carsten Witzke on 22/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, UISearchResultsUpdating, SearchDelegate {
    // Xcode/IB still struggles with the new UISearchController - let's do it manually
    var searchController:UISearchController!
    let resultsController:SearchResultsController = {
        return SearchResultsController(style: .Plain)
    }()
    
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    let placeFetcher: STLPlaceFetcher = {
        STLPlaceFetcher.setAppID(LocalConfig.hereAppID(), appCode: LocalConfig.hereAppCode())
        return STLPlaceFetcher.sharedInstance()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup search controller
        resultsController.searchDelegate = self
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.searchBarStyle = UISearchBarStyle.Minimal
        searchController.searchBar.placeholder = NSLocalizedString("searchbar.placeholder", comment: "")
        navigationItem.titleView = searchController.searchBar
        definesPresentationContext = true
    }
    
    override func viewDidAppear(animated: Bool) {
        // TODO: ask nicely, e.g. via app tour
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

    // MARK: - Handle search results
    
    private func placeRequest() -> STLPlaceRequest {
        let request = STLPlaceRequest()
        if locationManager.location != nil {
            request.location = locationManager.location
        }
        request.mapRect = mapView.visibleMapRect
        request.queryString = searchController.searchBar.text
        return request
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        placeFetcher.searchSuggestionsForQuery(placeRequest(), complete: { (items, error) -> Void in
            if let items = items as? [String] {
                self.resultsController.resultItems = items
                self.resultsController.tableView.reloadData()
            }
            if error != nil {
                log.error("\(error.debugDescription)")
            }
        })
    }
    
    func didSelectSearchSuggestion(suggestion: String) {
        searchController.active = false
        searchController.searchBar.text = suggestion
        
        let request = placeRequest()
        request.queryString = suggestion
        
        placeFetcher.searchPlacesWithQuery(placeRequest(), complete: { (items, error) -> Void in
            log.debug("query: \(suggestion):\n\(items)")
        })
    }
    
    // MARK: - LocationManager/-delegate
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
            
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

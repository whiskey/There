//
//  MapViewController.swift
//  There
//
//  Created by Carsten Witzke on 22/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, UISearchResultsUpdating, SearchDelegate, MKMapViewDelegate {
    // Xcode/IB still struggles with the new UISearchController - let's do it manually
    var searchController:UISearchController!
    let resultsController:SearchResultsController = {
        return SearchResultsController(style: .Plain)
    }()
    
    let locationManager = CLLocationManager()
    let placeFetcher: STLPlaceFetcher = {
        STLPlaceFetcher.setAppID(LocalConfig.hereAppID(), appCode: LocalConfig.hereAppCode())
        return STLPlaceFetcher.sharedInstance()
    }()
    
    @IBOutlet weak var mapView: MKMapView!
    let model:TourModel = TourModel.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self

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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "tour.details" {
            let controller = segue.destinationViewController as! TourViewController
            controller.model = model
            // might be later a Core Data MOC
            // alternative design would be a TourViewDelegate implemented here to pass changes
        }
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
            log.verbose("query: \(suggestion): \(count(items)) items")
            // cleanup
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            // add new annotation - if any
            var annotations:[GeoItemAnnotation] = []
            for i in items {
                if let item = i as? GeoItem {
                    let a = GeoItemAnnotation(geoItem: item)
                    a.title = item.title
                    a.coordinate = item.coordinate
                    annotations.append(a)
                }
            }
            self.mapView.addAnnotations(annotations)
        })
    }
    
    // MARK: - MapView
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation.isKindOfClass(GeoItemAnnotation) {
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(GeoItemAnnotation.identifier())
            if annotationView == nil {
                if let ann = annotation as? GeoItemAnnotation {
                    annotationView = ann.annotationView()
                }
            } else {
                annotationView!.annotation = annotation
            }
            return annotationView
        } else {
            return nil
        }
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if let annotation = view.annotation as? GeoItemAnnotation {
            let item = annotation.geoItem
            model.addGeoItem(item)
            mapView.deselectAnnotation(annotation, animated: true)
        }
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
}

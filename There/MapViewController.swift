//
//  MapViewController.swift
//  There
//
//  Created by Carsten Witzke on 22/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

import UIKit
import MapKit
import ThereSDK

// a little too many protocols up here...
class MapViewController: UIViewController, CLLocationManagerDelegate, UISearchResultsUpdating, SearchDelegate, MKMapViewDelegate, TourModelDelegate {
    // Xcode/IB still struggles with the new UISearchController - let's do it manually
    var searchController:UISearchController!
    let resultsController:SearchResultsController = {
        return SearchResultsController(style: .Plain)
    }()
    
    let locationManager = CLLocationManager()
    let placeFetcher = STLPlaceFetcher(appID: LocalConfig.hereAppID(), appCode: LocalConfig.hereAppCode())
    let routeFetcher = STLRouteFetcher(appID: LocalConfig.hereAppID(), appCode: LocalConfig.hereAppCode())
    
    @IBOutlet weak var mapView: MKMapView!
    var polyline:MKPolyline?
    let model:TourModel = TourModel.sharedInstance

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        model.delegate = self
        
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
            if count(annotations) > 0 {
                self.mapView.addAnnotations(annotations)
                self.mapView.showAnnotations(annotations, animated: true)
            }
            
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
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = view.tintColor.colorWithAlphaComponent(0.7)
            polylineRenderer.lineWidth = 3
            return polylineRenderer
        } else {
            return nil
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
    
    // MARK: - TourModelDelegate
    
    func didUpdateTour() {
        let request = STLRouteRequest()
        var waypoints = model.waypoints()
        // user location is wp0
        if locationManager.location != nil {
            waypoints.insert(locationManager.location, atIndex: 0)
        }
        request.waypoints = waypoints
        
        if count(waypoints) < 2 {
            // we need two waypoints - skip this
            return
        }
        
        request.parameters = [ // static for the moment
            "representation":"display",
            "mode":"fastest;car;traffic:disabled",
        ]
        
        routeFetcher.routeWithRequest(request, complete: { (navpoints, error) -> Void in
            if let nps = navpoints as? [STLNavPoint] {
                log.debug("got \(count(nps)) navpoints")
                
                // cleanup
                if self.polyline != nil {
                    self.mapView.removeOverlay(self.polyline)
                }
                
                var coordinates = [CLLocationCoordinate2D]()
                for navpoint in nps {
                    coordinates.append(navpoint.location.coordinate)
                }
                
                self.polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
                // TODO: check for memory leaks due to 'coordinates'
                self.mapView.addOverlay(self.polyline)
            }
            if error != nil {
                log.error("\(error)")
            }
        })
    }
}

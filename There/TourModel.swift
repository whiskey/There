//
//  TourModel.swift
//  There
//
//  Created by Carsten Witzke on 23/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

import UIKit

protocol TourModelProtocol {
    var tourItems:[GeoItem] { get set }
    
    func addGeoItem(item: GeoItem)
    func moveItem(from sourceIndexPath: NSIndexPath, to destinationIndexPath: NSIndexPath)
    func removeItem(at indexPath: NSIndexPath)
}


private let _StaticTourModel = TourModel()
class TourModel: TourModelProtocol {
    static let sharedInstance = TourModel()
    
    var tourItems:[GeoItem] = []
    
    func addGeoItem(item:GeoItem) {
        if let index = find(tourItems, item) {
            // put the selected item at first index
            tourItems.removeAtIndex(index)
            tourItems.insert(item, atIndex: 0)
        } else {
            tourItems.append(item)
        }
    }
    
    func moveItem(from sourceIndexPath: NSIndexPath, to destinationIndexPath: NSIndexPath) {
        if sourceIndexPath.row < count(tourItems) && destinationIndexPath.row < count(tourItems) {
            let item = tourItems.removeAtIndex(sourceIndexPath.row)
            tourItems.insert(item, atIndex: destinationIndexPath.row)
        }
    }
    
    func removeItem(at indexPath: NSIndexPath) {
        if indexPath.row < count(tourItems) {
            tourItems.removeAtIndex(indexPath.row)
        }
    }
}

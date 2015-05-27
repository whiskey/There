//
//  TourModelTests.swift
//  There
//
//  Created by Carsten Witzke on 27/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

import UIKit
import XCTest

class TourModelTests: XCTestCase {

    func testAddition() {
        let model = TourModel()
        
        let item0 = GeoItem(identifier: "0", latitude: 0, longitude: 0)
        let item1 = GeoItem(identifier: "1", latitude: 0, longitude: 0)
        
        model.addGeoItem(item0)
        model.addGeoItem(item1)
        XCTAssertEqual(count(model.tourItems), 2, "expected two items")
        XCTAssert(model.tourItems.last == item1, "last item should be the latest item")
        
        model.addGeoItem(item1)
        XCTAssert(model.tourItems.first == item1, "re-adding an existing item should put it on top")
        XCTAssertEqual(count(model.tourItems), 2, "expected two items - still")
        
        // new object, existing id
        let item0a = GeoItem(identifier: "0", latitude: 42, longitude: 42)
        XCTAssertEqual(item0, item0a, "items with same ids should be equal")
        model.addGeoItem(item0a)
        XCTAssert(model.tourItems.first == item0a, "re-adding an existing item should put it on top")
        XCTAssertEqual(count(model.tourItems), 2, "expected two items - still")
    }

    func testRemoval() {
        let model = TourModel()
        let item0 = GeoItem(identifier: "0", latitude: 0, longitude: 0)
        
        // no ...Throw tests in Swift :(
        
        model.addGeoItem(item0)
        model.removeItem(at: NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertEqual(count(model.tourItems), 0, "should remove item at valid indexpath")
        
        model.addGeoItem(item0)
        model.removeItem(at: NSIndexPath(forRow: 0, inSection: 1))
        XCTAssertEqual(count(model.tourItems), 0, "should remove item at valid indexpath.row")
        
        model.addGeoItem(item0)
        model.removeItem(at: NSIndexPath(forRow: 1, inSection: 0))
        XCTAssertEqual(count(model.tourItems), 1, "should not remove item at invalid indexpath")
    }

    func testItemMovement() {
        let model = TourModel()
        let item0 = GeoItem(identifier: "0", latitude: 0, longitude: 0)
        let item1 = GeoItem(identifier: "1", latitude: 0, longitude: 0)
        let item2 = GeoItem(identifier: "2", latitude: 0, longitude: 0)
        model.addGeoItem(item0)
        model.addGeoItem(item1)
        model.addGeoItem(item2)
        
        let from = NSIndexPath(forRow: 0, inSection: 0)
        let to = NSIndexPath(forRow: 1, inSection: 0)
        XCTAssertEqual(count(model.tourItems), 3, "expected 3 items")
        model.moveItem(from: from, to: to)
        XCTAssertEqual(count(model.tourItems), 3, "should not remove any items")

        XCTAssertEqual(model.tourItems[0], item1, "wrong item order")
        XCTAssertEqual(model.tourItems[1], item0, "wrong item order")
        XCTAssertEqual(model.tourItems[2], item2, "wrong item order")
        
        // TODO: check invaid paths
    }
}

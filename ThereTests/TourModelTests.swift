//
//  TourModelTests.swift
//  There
//
//  Created by Carsten Witzke on 27/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

import UIKit
import XCTest
import ThereSDK

class TourModelTests: XCTestCase {

    func testAddition() {
        let model = TourModel()
        
        let item0 = STLLinkObject(identifier: "0")
        let item1 = STLLinkObject(identifier: "1")
        
        model.addSTLLinkObject(item0)
        model.addSTLLinkObject(item1)
        XCTAssertEqual(count(model.tourItems), 2, "expected two items")
        XCTAssert(model.tourItems.last == item1, "last item should be the latest item")
        
        model.addSTLLinkObject(item1)
        XCTAssert(model.tourItems.first == item1, "re-adding an existing item should put it on top")
        XCTAssertEqual(count(model.tourItems), 2, "expected two items - still")
        
        // new object, existing id
        let item0a = STLLinkObject(identifier: "0")
        XCTAssertEqual(item0, item0a, "items with same ids should be equal")
        model.addSTLLinkObject(item0a)
        XCTAssert(model.tourItems.first == item0a, "re-adding an existing item should put it on top")
        XCTAssertEqual(count(model.tourItems), 2, "expected two items - still")
    }

    func testRemoval() {
        let model = TourModel()
        let item0 = STLLinkObject(identifier: "0")
        
        // no ...Throw tests in Swift :(
        
        model.addSTLLinkObject(item0)
        model.removeItem(at: NSIndexPath(forRow: 0, inSection: 0))
        XCTAssertEqual(count(model.tourItems), 0, "should remove item at valid indexpath")
        
        model.addSTLLinkObject(item0)
        model.removeItem(at: NSIndexPath(forRow: 0, inSection: 1))
        XCTAssertEqual(count(model.tourItems), 0, "should remove item at valid indexpath.row")
        
        model.addSTLLinkObject(item0)
        model.removeItem(at: NSIndexPath(forRow: 1, inSection: 0))
        XCTAssertEqual(count(model.tourItems), 1, "should not remove item at invalid indexpath")
    }

    func testItemMovement() {
        let model = TourModel()
        let item0 = STLLinkObject(identifier: "0")
        let item1 = STLLinkObject(identifier: "1")
        let item2 = STLLinkObject(identifier: "2")
        model.addSTLLinkObject(item0)
        model.addSTLLinkObject(item1)
        model.addSTLLinkObject(item2)
        
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

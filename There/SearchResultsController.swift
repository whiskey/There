//
//  SearchResultsController.swift
//  There
//
//  Created by Carsten Witzke on 23/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

import UIKit

class SearchResultsController: UITableViewController {
    var resultItems:[AnyObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ...
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultItems.count
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

}

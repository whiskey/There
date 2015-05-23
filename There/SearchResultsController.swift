//
//  SearchResultsController.swift
//  There
//
//  Created by Carsten Witzke on 23/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

import UIKit

let cellIdentifier = "searchResultCell"

protocol SearchDelegate {
    func didSelectSearchSuggestion(suggestion:String)
}

class SearchResultsController: UITableViewController {
    var resultItems:[AnyObject] = []
    var searchDelegate:SearchDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(SearchResultCell.classForCoder(), forCellReuseIdentifier: cellIdentifier)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        if let item = resultItems[indexPath.row] as? String {
            cell.textLabel?.text = item
        }
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let item = resultItems[indexPath.row] as? String {
            searchDelegate?.didSelectSearchSuggestion(item)
        }
    }
}

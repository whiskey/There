//
//  TourViewController.swift
//  There
//
//  Created by Carsten Witzke on 23/05/15.
//  Copyright (c) 2015 staticline. All rights reserved.
//

import UIKit
import MapKit

class TourViewController: UITableViewController {

    @IBOutlet weak var tableHeaderLabel: UILabel!
    let geoCoder = CLGeocoder()
    let lengthFormatter:NSLengthFormatter = {
        // more flexible than MKDistanceFormatter (unit conversion!)
        let lf = NSLengthFormatter()
        lf.numberFormatter.maximumFractionDigits = 1
        return lf
    }()
    var model:TourModel!
    
    lazy var hintView:UIView = {
        // very simple tableview background
        var hintView = UIView(frame: self.tableView.bounds)
        hintView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        
        let iv = UIImageView(image: UIImage(named: "hint"))
        iv.frame = hintView.bounds
        iv.alpha = 0.3
        iv.contentMode = UIViewContentMode.ScaleAspectFit
        hintView.addSubview(iv)
        
        let label = UILabel(frame: iv.frame)
        label.font = UIFont.boldSystemFontOfSize(32)
        label.text = NSLocalizedString("label.hint.nowps", comment: "a hint how to add new waypoints")
        label.textColor = UIColor.blackColor()
        label.textAlignment = NSTextAlignment.Center
        label.numberOfLines = 0
        hintView.addSubview(label)
        
        return hintView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        updateTourFacts()
    }
    
    private func updateTourFacts() {
        if count(model.tourItems) > 0 {
            let nf = NSNumberFormatter()
            nf.numberStyle = NSNumberFormatterStyle.DecimalStyle
            
            let items = count(model.tourItems)
            let numPoints = nf.stringFromNumber(items)!
            
            // .stringsdict is better than this!
            // http://cldr.unicode.org/index/cldr-spec/plural-rules
            var format = ""
            if items == 0 {
                format = NSLocalizedString("label.tour.legs.zero", comment: "number of waypoints in the tour")
            } else if items == 1 {
                format = NSLocalizedString("label.tour.legs.one", comment: "number of waypoints in the tour")
            } else {
                format = NSLocalizedString("label.tour.legs.other", comment: "number of waypoints in the tour")
            }
            
            var string = String(format: format, numPoints)
            
            tableHeaderLabel.text = string
            
            tableView.tableHeaderView?.hidden = false
            self.editButtonItem().enabled = true
        } else {
            tableView.tableHeaderView?.hidden = true
            self.editButtonItem().enabled = false
        }
    }
    
    private func setHint(visible showView:Bool, animated animate:Bool) {
        let duration = animate ? 0 : 0.2
        UIView.animateWithDuration(duration, animations: { () -> Void in
            if showView {
                self.tableView.backgroundView = self.hintView
            } else {
                self.hintView.removeFromSuperview()
            }
        })
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = count(model.tourItems)
        setHint(visible: (rows == 0), animated: true)
        return rows
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tourItem", forIndexPath: indexPath) as! TourItemCell
        let item = model.tourItems[indexPath.row]
        cell.setup(item, distanceFormatter: lengthFormatter)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        model.moveItem(from: sourceIndexPath, to: destinationIndexPath)
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            model.removeItem(at: indexPath)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            updateTourFacts()
        }
    }
    
}

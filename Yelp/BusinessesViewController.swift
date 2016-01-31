//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import Foundation

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    var refreshControl: UIRefreshControl!
    
    var businesses: [Business]!
    var filteredData: [Business]?
    
    var lastSearched: String = ""
    var timer = NSTimer()
    var isFirstTime: Bool = true
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
            navigationBar.tintColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
            
            let shadow = NSShadow()
            shadow.shadowColor = UIColor.grayColor().colorWithAlphaComponent(0.5)
            shadow.shadowOffset = CGSizeMake(2, 2);
            shadow.shadowBlurRadius = 4;
            navigationBar.titleTextAttributes = [
                NSFontAttributeName : UIFont.boldSystemFontOfSize(22),
                NSForegroundColorAttributeName : UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8),
                NSShadowAttributeName : shadow
            ]
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let storedSearch = defaults.objectForKey("storedSearch") as? String {
            lastSearched = storedSearch
        }
        else {
            lastSearched = "Popular"
        }
        
        callYelpAPI(lastSearched)
        searchBar.text = lastSearched
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: Selector("updateMe"), userInfo: nil, repeats: true)

    }
    
    func updateMe() {
        if (isFirstTime) {
            
            let defaults = NSUserDefaults.standardUserDefaults()
            if let storedSearch = defaults.objectForKey("storedSearch") as? String {
                lastSearched = storedSearch
            }
            else {
                lastSearched = "Popular"
            }
            
            callYelpAPI(lastSearched)
            isFirstTime = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func callYelpAPI(input: String) {
        lastSearched = input
        Business.searchWithTerm(input, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.filteredData = businesses
            self.tableView.reloadData()
        })
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(input, forKey: "storedSearch")
        defaults.synchronize()
        
        /* Example of Yelp search with more search options specified
        Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
        self.businesses = businesses
        
        for business in businesses {
        print(business.name!)
        print(business.address!)
        }
        }
        */
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
//            return businesses!.count
            return filteredData!.count;
        }
        else {
            return 0
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        
//        cell.business = businesses[indexPath.row]
        cell.business = filteredData![indexPath.row]
        cell.backgroundColor = UIColor(red: 0.7, green: 0.2, blue: 0.2, alpha: 0.05)
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filteredData = businesses
        self.tableView.reloadData()
    }
//    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//        //let resultPredicate = NSPredicate(format: "name contains[c] %@", searchText)
//        filteredData = searchText.isEmpty ? businesses : businesses!.filter {
//            $0.name!.containsString(searchText)
//        }
//        
//        tableView.reloadData()
//    }
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        callYelpAPI(searchBar.text!)
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
        
        callYelpAPI(lastSearched)
        
        self.refreshControl?.endRefreshing()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "TableToMap") {
            
        }
        else if (segue.identifier == "TableToDetail") {
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            //            let movie = movies![indexPath!.row]
            let business = filteredData![indexPath!.row]
            
            let detailviewController = segue.destinationViewController as! BusinessDetailViewController
            detailviewController.business = business
        }
    }
}

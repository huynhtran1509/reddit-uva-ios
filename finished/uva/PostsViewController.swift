//
//  PostsViewController.swift
//  uva
//
//  Created by Andrew Carter on 3/28/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit
import SafariServices

class PostsViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet var tableView: UITableView!
    let client = RedditClient()
    let subreddit = "uva"
    var after: String?
    var loading = false
    var listings = [Listing]()
    var currentTask: NSURLSessionTask?
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadListing()
        setupTableView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        tableViewDidAppear()
    }
    
    // MARK: - Instance Methods
    
    func tableViewDidAppear() {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        tableView.flashScrollIndicators()
    }
    
    @IBAction func refreshBarButtonItemPressed(sender: UIBarButtonItem) {
        currentTask?.cancel()
        currentTask = nil
        after = nil
        listings.removeAll()
        tableView.reloadData()
        loadListing()
    }
    
    func configurePostCell(cell: PostTableViewCell, forIndexPath indexPath: NSIndexPath) {
        let listing = self.listings[indexPath.row]
        
        if let data = listing.data as? LinkData {
            cell.accessoryType = .DisclosureIndicator
            cell.titleLabel.text = data.title
            cell.detailLabel.text = "Submitted by \(data.author). Score \(data.score)"
        }
    }
    
    func setupTableView() {
        tableView.registerNib(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: PostTableViewCell.reuseIdentifier)
    }
    
    func presentNetworkErrorAlert() {
        let alertController = UIAlertController(title: "Network Error", message: "Please try again later.", preferredStyle: .Alert)
        
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertController.addAction(action)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func didLoadListing(listing: Listing) {
        guard let data = listing.data as? ListingData,
            let children = data.children else {
                return
        }
        
        self.after = data.after
        self.listings.appendContentsOf(children)
        self.tableView.reloadData()
        currentTask = nil
        loading = false
    }
    
    func loadListing() {
        guard loading == false else {
            return
        }
        loading = true
        
        do {
            currentTask = try client.getListings(subreddit, after: after) { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                
                switch result {
                case .Success(let listing):
                    dispatch_async(dispatch_get_main_queue()) { strongSelf.didLoadListing(listing) }
                    
                case .Failure:
                    dispatch_async(dispatch_get_main_queue()) { strongSelf.presentNetworkErrorAlert() }
                }
            }
        } catch {
            loading = false
            presentNetworkErrorAlert()
        }
    }
    
}

extension PostsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PostTableViewCell.reuseIdentifier, forIndexPath: indexPath) as! PostTableViewCell
        configurePostCell(cell, forIndexPath: indexPath)
        return cell
    }
}

extension PostsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == (listings.count - 1) {
            loadListing()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let listing = self.listings[indexPath.row]
        
        if let data = listing.data as? LinkData,
            let url = NSURL(string: data.url) {
            let controller = SFSafariViewController(URL: url)
            presentViewController(controller, animated: true, completion: nil)
        }
    }
}


//
//  MovieViewController.swift
//  movieapp
//
//  Created by Le Huynh Anh Tien on 7/5/16.
//  Copyright © 2016 Tien Le. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import SwiftyDrop

class MovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
   
    @IBOutlet weak var viewTypeToggle: UIBarButtonItem!
    @IBOutlet weak var movieCollectionView: UICollectionView!
    @IBOutlet weak var movieTableView: UITableView!
    
    var movies: [NSDictionary]?
    var endpoint: String!
    var refreshControl: UIRefreshControl!
    let loadingView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    var isMoreDataLoading = false
    var currentListView: UIScrollView?
    var isTable = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        refreshControl = UIRefreshControl()
        
        
        let tableFooterView: UIView = UIView(frame: CGRectMake(0, 0, 320, 50))
    
        loadingView.center = tableFooterView.center
        tableFooterView.addSubview(loadingView)
        self.movieTableView.tableFooterView = tableFooterView
        
        viewTypeToggle.image = UIImage(named: "collection-button")
        viewTypeToggle.title = ""
        
       
        useTableView()
        networkRequest(isTable)
        
        movieTableView.dataSource = self
        movieTableView.delegate = self
        movieCollectionView.dataSource = self
        movieCollectionView.delegate = self
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
        
    }
    func networkRequest(isTable: Bool) {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "http://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: {( dataOrNil, response, errorOrNil) in
            if errorOrNil != nil {
                Drop.down("Networking Error!", state: .Error)
                self.refreshControl.endRefreshing()
                self.isMoreDataLoading = false
                MBProgressHUD.hideHUDForView(self.view, animated: false)
            }
            if let data = dataOrNil {
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                    data, options:[]) as? NSDictionary {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.movies = (responseDictionary["results"] as! [NSDictionary])
                   
                    self.isMoreDataLoading = false
                    self.refreshControl.endRefreshing()
                    self.loadingView.stopAnimating()
                    if (isTable) {
                        self.movieTableView.reloadData()
                    } else {
                        self.movieCollectionView.reloadData()
                    }
                    
                }
            }
        })
        task.resume()

        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        let movie = movies![indexPath.row]
        let title  = movie["title"] as! String
        let overview = movie["overview"] as! String
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        if let posterPath = movie["poster_path"] as? String {
            let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
            let posterUrl = NSURL(string: posterBaseUrl + posterPath)
            cell.posterImage.setImageWithURL(posterUrl!)
            cell.posterImage.alpha = 0.0
            
            UIView.animateWithDuration(2.0, animations: { () -> Void in
                cell.posterImage.alpha = 1.0
            })
            
        }
        else {
            cell.posterImage.image = nil
        }
        
        return cell
    }
    
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var indexPath : Int?
        if segue.identifier == "fromMovieTableCell" {
            let cell = sender as! MovieCell
            indexPath =  movieTableView.indexPathForCell(cell)!.row
        }
        
        if segue.identifier == "fromMovieCollectionCell" {
            let cell = sender as! MovieCollectionViewCell
            indexPath =  movieCollectionView.indexPathForCell(cell)!.row
        }

        
        let movie = movies![indexPath!]
        
        let detailVC = segue.destinationViewController as! DetailsViewController
        detailVC.movie = movie
        
        print("prepare for segue call")
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if refreshControl.refreshing {
            networkRequest(isTable)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = movieTableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - movieTableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && movieTableView.dragging) {
                isMoreDataLoading = true
                networkRequest(isTable)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }

    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
       
        let movie = movies![indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath) as! MovieCollectionViewCell
        
        let title  = movie["vote_count"] as! Int
        let overview = movie["vote_average"] as! Int
        
        cell.titleLabel.text = "Watch: " + String(title)
        cell.rateLabel.text = "Point: " + String(overview)
        if let posterPath = movie["poster_path"] as? String {
            let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
            let posterUrl = NSURL(string: posterBaseUrl + posterPath)
            cell.imagePoster.setImageWithURL(posterUrl!)
            cell.imagePoster.alpha = 0.0
            
            UIView.animateWithDuration(2.0, animations: { () -> Void in
                cell.imagePoster.alpha = 1.0
            })
            
        }
        else {
            cell.imagePoster.image = nil
        }
        
      

        return cell
    }
    
    func useTableView() {
        movieCollectionView.hidden = true
        movieTableView.hidden = false
       
        refreshControl.removeFromSuperview()
         movieTableView.addSubview(refreshControl)
        viewTypeToggle.image = UIImage(named: "collection-button")
        movieTableView.contentInset = UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: 0, right: 0)
        currentListView = movieTableView
        isTable = true
        movieTableView.reloadData()
    }


    func useCollectionView() {
        movieTableView.hidden = true
        movieCollectionView.hidden = false
        movieCollectionView.backgroundColor = UIColor.whiteColor()
        refreshControl.removeFromSuperview()
        movieCollectionView.addSubview(refreshControl)
      
        movieCollectionView.contentInset = UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: 0, right: 0)
        
        viewTypeToggle.image = UIImage(named: "list-button")
        currentListView = movieCollectionView
        isTable = false
        movieCollectionView.reloadData()
    }
    
    func reloadData() {
        
        if currentListView == movieTableView {
            movieTableView.reloadData()
        }
        
        if currentListView == movieCollectionView {
            movieCollectionView.reloadData()
        }
        
    }

    
    
    @IBAction func toggleStyle(sender: UIBarButtonItem) {
        if (currentListView == movieTableView) {
            useCollectionView()
            
        } else {
            useTableView()
        }

    }
}

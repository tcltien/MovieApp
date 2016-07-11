//
//  DetailsViewController.swift
//  movieapp
//
//  Created by Le Huynh Anh Tien on 7/8/16.
//  Copyright © 2016 Tien Le. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    
    
    @IBOutlet weak var posterImageVIew: UIImageView!
    
    @IBOutlet weak var titleDetails: UILabel!
    
    @IBOutlet weak var overviewDetail: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var inforDetails: UIView!
    
    var movie = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let title = movie["title"]
        let ovierview = movie["overview"]
        
        
        titleDetails.text = title as? String
        overviewDetail.text = ovierview as? String
        overviewDetail.sizeToFit()
        self.overviewDetail.backgroundColor = UIColor(white: 0, alpha: 0.8)
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: inforDetails.frame.origin.y  + overviewDetail.frame.size.height)
        
        
        if let posterPath = movie["poster_path"] as? String {
            let posterBaseUrl = "http://image.tmdb.org/t/p/w500"
            let posterUrl = NSURL(string: posterBaseUrl + posterPath)
            self.posterImageVIew.setImageWithURL(posterUrl!)
        }
        else {
            self.posterImageVIew.image = nil
        }
        UIView.animateWithDuration(1.0, animations: {
            print(self.overviewDetail.frame.size.height)
            self.inforDetails.center.y -= self.inforDetails.frame.size.height - 50
            
        })
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

//
//  MoviePanel.swift
//  TraktTopTen
//
//  Created by Michael Haubenstock on 8/3/16.
//  Copyright © 2016 Michael Haubenstock. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import RateView
import AsyncImageDownloader

class MoviePanel : UIView
{
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var tagline: UILabel!
    @IBOutlet weak var rating: RateView!
    @IBOutlet weak var movieDescription: UITextView!
    @IBOutlet weak var watchTrailerButton : UIButton!
    @IBOutlet weak var shareButton : UIButton!
    
    var trailerURL : String?
    var delegate : MoviePanelDelegate?
    
    static func FromJSON(trendingMovieJSON : JSON) -> MoviePanel
    {
        let moviePanel = NSBundle.mainBundle().loadNibNamed(String(MoviePanel), owner: self, options: nil)[0] as! MoviePanel
        
        moviePanel.layer.cornerRadius = 5.0
        moviePanel.clipsToBounds = true
        
        moviePanel.movieTitle.text = trendingMovieJSON["movie"]["title"].string
        moviePanel.tagline.text = trendingMovieJSON["movie"]["tagline"].string
        moviePanel.rating.rating = trendingMovieJSON["movie"]["rating"].floatValue / 2
        moviePanel.movieDescription.text = trendingMovieJSON["movie"]["overview"].string
   
        //Set-up "Watch Trailer" button
        if let trailerURL = trendingMovieJSON["movie"]["trailer"].string
        {
            moviePanel.trailerURL = trailerURL
        }
        else
        {
            moviePanel.watchTrailerButton.hidden = true
            moviePanel.watchTrailerButton.enabled = false
        }
        
        //Download the poster image
        AsyncImageDownloader(mediaURL: trendingMovieJSON["movie"]["images"]["poster"]["full"].string,
            successBlock: { image in
            
                moviePanel.moviePoster.layer.cornerRadius = 5.0
                moviePanel.moviePoster.clipsToBounds = true
                moviePanel.moviePoster.image = image
                
                
            }, failBlock: { error in
                
                print(error)
        }).startDownload()
 
        return moviePanel
    }
    
    @IBAction func watchTrailer(sender: AnyObject) {
        
        //Load trailer
        UIApplication.sharedApplication().openURL(NSURL(string: trailerURL!)!)
    }
    
    @IBAction func share(sender: AnyObject) {
        
        delegate?.didRequestShareAction(self)
    }
    
}

protocol MoviePanelDelegate
{
    func didRequestShareAction(moviePanel : MoviePanel)
}
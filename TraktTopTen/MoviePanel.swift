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

class MoviePanel : UIView
{
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var tagline: UILabel!
    @IBOutlet weak var rating: RateView!
    @IBOutlet weak var movieDescription: UITextView!
    
    static func FromJSON(trendingMovieJSON : JSON) -> MoviePanel
    {
        let moviePanel = NSBundle.mainBundle().loadNibNamed(String(MoviePanel), owner: self, options: nil)[0] as! MoviePanel
        
        moviePanel.movieTitle.text = trendingMovieJSON["movie"]["title"].string
        moviePanel.tagline.text = trendingMovieJSON["movie"]["tagline"].string
        moviePanel.rating.rating = trendingMovieJSON["movie"]["rating"].floatValue / 2
        moviePanel.movieDescription.text = trendingMovieJSON["movie"]["overview"].string
        
        
        
        return moviePanel
    }
}
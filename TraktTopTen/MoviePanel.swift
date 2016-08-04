//
//  MoviePanel.swift
//  TraktTopTen
//
//  Created by Michael Haubenstock on 8/3/16.
//  Copyright © 2016 Michael Haubenstock. All rights reserved.
//

import Foundation
import UIKit

class MoviePanel : UIView
{
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var tagline: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var movieDescription: UITextView!
}
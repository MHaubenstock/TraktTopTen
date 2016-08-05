//
//  ViewController.swift
//  TraktTopTen
//
//  Created by Michael Haubenstock on 8/3/16.
//  Copyright © 2016 Michael Haubenstock. All rights reserved.
//

import UIKit
import SwiftyJSON
import Social

class TraktTopTen : UIViewController
{

    @IBOutlet weak var moviePanelContainer: UIScrollView!
    
    let moviePanelOffset : CGFloat = 5.0
    var moviePanels : [MoviePanel] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        TraktAPIController.delegate = self
        
        //Load from api and display asynchronously
        beginOAuth()
    }
    
    func beginOAuth()
    {
        //If access_token does not exists, get one
        if TraktAPIController.accessToken == nil
        {
            TraktAPIController.OAuthAuthorize()
        }
        //If it does exists and is expired, then refresh it
        else if TraktAPIController.accessToken != nil
                && NSDate().earlierDate(TraktAPIController.expirationDate!).isEqualToDate(TraktAPIController.expirationDate!)
        {
            TraktAPIController.OAuthExchangeRefreshTokenForAccessToken()
        }
        else
        {
            self.didAuthenticate()
        }
    }
    
    override func viewDidLayoutSubviews() {
        
        //Layout panels in scroll view
        for (index, panel) in moviePanels.enumerate()
        {
            let panelX = CGFloat(index / 2) * (moviePanelContainer.frame.size.width / 2 + moviePanelOffset)
            let panelY = CGFloat(index % 2) * ((moviePanelContainer.frame.size.height / 2) + moviePanelOffset)
            let panelWidth = (moviePanelContainer.frame.size.width / 2) - moviePanelOffset
            let panelHeight = (moviePanelContainer.frame.size.height / 2) - moviePanelOffset
            
            panel.frame = CGRect(x: panelX, y: panelY, width: panelWidth, height: panelHeight)
        }
        
        //Set content size of scroll view
        let panelCount = CGFloat(moviePanels.count / 2)
        moviePanelContainer.contentSize = CGSize(width: (panelCount * moviePanelContainer.frame.size.width / 2) + ((panelCount - 2) * moviePanelOffset), height: moviePanelContainer.frame.size.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refresh(sender: AnyObject)
    {
        TraktAPIController.getTrendingMovies()
    }
}

// MARK: TraktAPIControllerDelegate functions
extension TraktTopTen : TraktAPIControllerDelegate
{
    func didAuthenticate()
    {
        //Load the movie data
        TraktAPIController.getTrendingMovies()
    }
    
    func failedToAuthenticate()
    {
        print("App failed to authenticate with Trakt")
    }
    
    func didGetTrendingMovies(movieJSON : JSON)
    {
        dispatch_async(dispatch_get_main_queue(),{
            
            self.moviePanels.forEach { panel in panel.removeFromSuperview() }
            self.moviePanels = []
            
            movieJSON.arrayValue.forEach { movie in
                
                let moviePanel = MoviePanel.FromJSON(movie)
                
                moviePanel.delegate = self
                self.moviePanels.append(moviePanel)
                self.moviePanelContainer.addSubview(moviePanel)
                
            }
            
            self.view.setNeedsLayout()
            
        })
    }
}

// MARK: MoviePanelDelegate functions
extension TraktTopTen : MoviePanelDelegate
{
    func didRequestShareAction(moviePanel : MoviePanel)
    {
        let message = "I'm looking forward to seeing \(moviePanel.movieTitle.text!) soon!"
        let alertView = UIAlertController(title: "Share on Social Media", message: "Where would you like to share to?", preferredStyle: .ActionSheet)
        
        let shareFacebookAction = UIAlertAction(title: "Share on Facebook", style: .Default, handler: {
            
            action in
            
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)
            {
                let facebookComposeVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                
                facebookComposeVC.setInitialText(message)
                
                self.presentViewController(facebookComposeVC, animated: true, completion: nil)
            }
            else
            {
                print("You are not connected to your Facebook account.")
            }
        })
        
        let shareTwitterAction = UIAlertAction(title: "Share on Twitter", style: .Default, handler: {
            
            action in
            
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                let twitterComposeVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                
                // Set the note text as the default post message.
                if message.characters.count <= 140 {
                    twitterComposeVC.setInitialText(message)
                    
                    self.presentViewController(twitterComposeVC, animated: true, completion: nil)
                }
                else {
                    let subMessage = message.substringToIndex(message.startIndex.advancedBy(140))
                    twitterComposeVC.setInitialText(subMessage)
                }
            }
            else {
                print("You are not logged in to your Twitter account.")
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Destructive, handler: nil)
        
        alertView.addAction(shareFacebookAction)
        alertView.addAction(shareTwitterAction)
        alertView.addAction(cancelAction)
        
        let popoverPresentationController = alertView.popoverPresentationController!
        popoverPresentationController.sourceView = moviePanel.shareButton
        popoverPresentationController.sourceRect = moviePanel.shareButton.bounds
        
        self.presentViewController(alertView, animated: true, completion: nil)
    }
}


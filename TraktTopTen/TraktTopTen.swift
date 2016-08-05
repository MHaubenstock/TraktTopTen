//
//  ViewController.swift
//  TraktTopTen
//
//  Created by Michael Haubenstock on 8/3/16.
//  Copyright © 2016 Michael Haubenstock. All rights reserved.
//

import UIKit
import SwiftyJSON

class TraktTopTen : UIViewController
{

    @IBOutlet weak var moviePanelContainer: UIScrollView!
    
    let moviePanelOffset : CGFloat = 5.0
    
    var moviePanels : [UIView] = [] { didSet { updatePanels() } }
    
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
            self.didAuthenticate(true)
        }
    }
    
    func updatePanels()
    {
        
    }
    
    override func viewDidLayoutSubviews() {
        
        //Layout panels in scroll view
        for (index, panel) in moviePanels.enumerate()
        {
            panel.frame = CGRect(x: CGFloat(index) * (moviePanelContainer.frame.size.width + moviePanelOffset), y: 0.0, width: moviePanelContainer.frame.size.width, height: moviePanelContainer.frame.size.height)
        }
        
        //Set content size of scroll view
        let panelCount = CGFloat(moviePanels.count)
        moviePanelContainer.contentSize = CGSize(width: (panelCount * moviePanelContainer.frame.size.width) + ((panelCount - 1) * moviePanelOffset), height: moviePanelContainer.frame.size.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TraktTopTen : TraktAPIControllerDelegate
{
    func didAuthenticate(isAuthenticated: Bool)
    {
        if isAuthenticated
        {
            //Load the movie data
            TraktAPIController.getTrendingMovies()
        }
    }
    
    func didGetTrendingMovies(movieJSON : JSON)
    {
        dispatch_async(dispatch_get_main_queue(),{
            
            self.moviePanelContainer.subviews.forEach { subView in subView.removeFromSuperview() }
            
            movieJSON.arrayValue.forEach { movie in
                
                //moviePanelContainer.subviews.forEach { subView in subView.removeFromSuperview() }
                self.moviePanels.append(MoviePanel.FromJSON(movie))
                self.moviePanelContainer.addSubview(MoviePanel.FromJSON(movie))
                
            }
            
            self.view.setNeedsLayout()
            
        })
    }
}


//
//  ViewController.swift
//  TraktTopTen
//
//  Created by Michael Haubenstock on 8/3/16.
//  Copyright © 2016 Michael Haubenstock. All rights reserved.
//

import UIKit

class TraktTopTen : UIViewController
{

    @IBOutlet weak var moviePanelContainer: UIScrollView!
    
    var moviePanels : [UIView] = []
    let moviePanelOffset : CGFloat = 5.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /*
        //Load test map panel
        for _ in 0...9
        {
            let moviePanel = NSBundle.mainBundle().loadNibNamed(String(MoviePanel), owner: self, options: nil)[0] as! MoviePanel
            moviePanels.append(moviePanel)
            moviePanelContainer.addSubview(moviePanel)
        }
        */
        
        //Load from api and display async
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        TraktAPIController.delegate = self
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
    
    func didGetTrendingMovies()
    {
        
    }
}


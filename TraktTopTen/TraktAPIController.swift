//
//  APIController.swift
//  TraktTopTen
//
//  Created by Michael Haubenstock on 8/3/16.
//  Copyright © 2016 Michael Haubenstock. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class TraktAPIController : NSObject
{
    static var delegate : TraktAPIControllerDelegate?
    
    static let clientId = "9212cbb483a54edf4880711c140204d9e5d005317535c5a98bdd5d61d62f042f"
    static let clientSecret = "df2927e0d4f8535445c9df79dbaa4966726b8747bf31202ccf718caaa8b61437"
    static let redirectURI = "TraktTopTen://oauth2redirect"
    
    static let AccessTokenKey = "access_token"
    static let RefreshTokenKey = "refresh_token"
    static let ExpiresInKey = "expires_in"
    static let CreatedAtKey = "created_at"
    static let ExpirationDateKey = "TokenExpireDate"
    
    static var code : String?
    
    static var accessToken : String?
    {
        get{ return NSUserDefaults.standardUserDefaults().stringForKey(AccessTokenKey) }
        set{ NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: AccessTokenKey) }
    }
    
    static var refreshToken : String?
    {
        get{ return NSUserDefaults.standardUserDefaults().stringForKey(RefreshTokenKey) }
        set{ NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: RefreshTokenKey) }
    }
    
    static var expirationDate : NSDate?
    {
        get{ return NSUserDefaults.standardUserDefaults().objectForKey(ExpirationDateKey) as? NSDate }
        set{ NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: ExpirationDateKey) }
    }
}

// MARK: Data gathering functions
extension TraktAPIController
{
    static func getTrendingMovies()
    {
        let url = NSURL(string: "https://api.trakt.tv/movies/trending?extended=full,images&page=1&limit=10")!
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("2", forHTTPHeaderField: "trakt-api-version")
        request.addValue(clientId, forHTTPHeaderField: "trakt-api-key")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let data = data {
                
                do
                {
                    let jsonObject : AnyObject! = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
                    
                    delegate?.didGetTrendingMovies(JSON(jsonObject))
                }
                catch { }
                
            } else {
                print(error)
            }
        }
        
        task.resume()
    }
}

// MARK: OAuth functions
extension TraktAPIController
{
    static func OAuthAuthorize()
    {
        let url = NSURL(string: "https://trakt.tv/oauth/authorize?response_type=code&client_id=\(clientId)&redirect_uri=\(redirectURI)")!
        
        UIApplication.sharedApplication().openURL(url)
    }
    
    static func OAuthExchangeCodeForAccessToken()
    {
        let url = NSURL(string: "https://api.trakt.tv/oauth/token")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = "{\n  \"code\": \"\(code!)\",\n  \"client_id\": \"\(clientId)\",\n  \"client_secret\": \"\(clientSecret)\",\n  \"redirect_uri\": \"\(redirectURI)\",\n  \"grant_type\": \"authorization_code\"\n}".dataUsingEncoding(NSUTF8StringEncoding);
    
        ExecuteTokenRequest(request)
    }
    
    static func OAuthExchangeRefreshTokenForAccessToken()
    {
        let url = NSURL(string: "https://api.trakt.tv/oauth/token")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = "{\n  \"refresh_token\": \"\(refreshToken!)\",\n  \"client_id\": \"\(clientId)\",\n  \"client_secret\": \"\(clientSecret)\",\n  \"redirect_uri\": \"\(redirectURI)\",\n  \"grant_type\": \"refresh_token\"\n}".dataUsingEncoding(NSUTF8StringEncoding);
        
        ExecuteTokenRequest(request)
    }
    
    static func ExecuteTokenRequest(request : NSURLRequest)
    {
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let data = data {
                
                let json = JSON(data)
                
                //Populate nsuserdefaults with response result
                accessToken = json[AccessTokenKey].string
                refreshToken = json[RefreshTokenKey].string
                expirationDate = (NSDate(timeIntervalSince1970: json[CreatedAtKey].object as! NSTimeInterval)).dateByAddingTimeInterval(json[ExpiresInKey].object as! NSTimeInterval)
                
                delegate?.didAuthenticate(true)
                
            } else {
                delegate?.didAuthenticate(false)
                print(error)
            }
        }
        
        task.resume()
    }
}

protocol TraktAPIControllerDelegate
{
    func didAuthenticate(isAuthenticated : Bool)
    func didGetTrendingMovies(movieJSON : JSON)
}
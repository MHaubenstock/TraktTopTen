//
//  ViewController.swift
//  TraktTopTen
//
//  Created by Michael Haubenstock on 8/3/16.
//  Copyright © 2016 Michael Haubenstock. All rights reserved.
//

import UIKit

class TraktTopTen : UIViewController {

    @IBOutlet weak var moviePanelContainer: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Load test map panel
        for x in 0...9
        {
            print(x)
            let testPanel = NSBundle.mainBundle().loadNibNamed(String(MoviePanel), owner: self, options: nil)[0] as! MoviePanel
            testPanel.frame = CGRect(x: CGFloat(x), y: 0.0, width: moviePanelContainer.frame.size.width / 2, height: moviePanelContainer.frame.size.height)
            
            moviePanelContainer.addSubview(testPanel)
        }
        
        //Load from api and display async
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


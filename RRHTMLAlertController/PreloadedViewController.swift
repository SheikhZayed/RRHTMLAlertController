//
//  PreloadedViewController.swift
//  RRHTMLAlertController
//
//  Created by Rodrigo Rallo on 3/16/16.
//  Copyright © 2016 - Fotition. All rights reserved.
//

import UIKit

class PreloadedViewController: UIViewController {

    @IBOutlet weak var showButton: UIButton!
    
    private let htmlAlertController : RRHTMLViewController = RRHTMLViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

        //You could write and preload your own html file into your app bundle to show these alerts immediately:
        let htmlFile = NSBundle.mainBundle().pathForResource("CustomHTMLView", ofType: "html")
        if let htmlString = try? String(contentsOfFile: htmlFile!, encoding: NSUTF8StringEncoding){
            self.htmlAlertController.htmlString = htmlString
        }

        self.htmlAlertController.showWhenReady = false;
        self.htmlAlertController.enableAnimation = true;
        self.htmlAlertController.enableDismissOnBackgroundTap = false;
        self.htmlAlertController.closeURLString = "yourcompany://close"
        
    }
    
    @IBAction func showButtonTapped(sender: AnyObject) {
        self.presentViewController(self.htmlAlertController, animated: false, completion: nil)
    }

}


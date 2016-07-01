//
//  LazyViewController.swift
//  RRHTMLAlertController
//
//  Created by Rodrigo Rallo on 3/16/16.
//  Copyright © 2016 - Fotition. All rights reserved.
//

import UIKit

class LazyViewController: UIViewController, RRHTMLViewControllerDelegate {
    
    @IBOutlet weak var showButton: UIButton!
    
    private var htmlAlertController : RRHTMLViewController = RRHTMLViewController(paddings: UIEdgeInsetsMake(20, 20, 20, 20))
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func createAndShowAlertController(sender: AnyObject) {
        
        self.htmlAlertController = RRHTMLViewController(paddings: UIEdgeInsetsMake(0, 10, 0, 25))
        
        self.htmlAlertController.showWhenReady                  = true; //show webview as soon as it loads.
        
        self.htmlAlertController.enableAnimation                = true;
        
        self.htmlAlertController.enableDismissOnBackgroundTap   = true; //if you don't include 'closeURLS' you should enable this.
        
        self.htmlAlertController.enableNormalNavigation         = true; //If you want to let users navigate within the alert, enable this.
        
        self.htmlAlertController.delegate                       = self; //In this example only used to force the alert to re-download every time.
        
        self.htmlAlertController.webView.scrollView.scrollEnabled = true;
        
        self.htmlAlertController.htmlURL = NSURL(string: "https://www.google.com") //Specify the resource you want to load.
        self.presentViewController(self.htmlAlertController, animated: false, completion: nil);
        
    }
    
    func RRHTMLViewControllerDidHide(sender: RRHTMLViewController) {

        //I'm clearing the responses cache in this example only.
        NSURLCache.sharedURLCache().removeAllCachedResponses();
    }
    
}

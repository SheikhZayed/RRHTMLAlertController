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
        // Do any additional setup after loading the view, typically from a nib.
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createAndShowAlertController(sender: AnyObject) {
        
        self.htmlAlertController = RRHTMLViewController(paddings: UIEdgeInsetsMake(0, 10, 0, 25))
        self.htmlAlertController.showWhenReady = true;
        self.htmlAlertController.enableAnimation = true;
        self.htmlAlertController.enableDismissOnBackgroundTap = true;
        self.htmlAlertController.enableNormalNavigation = true;
        self.htmlAlertController.delegate = self;
        
        
        self.htmlAlertController.webView.scrollView.scrollEnabled = true;
        
        self.htmlAlertController.htmlURL = NSURL(string: "https://www.google.com")
        self.presentViewController(self.htmlAlertController, animated: false, completion: nil);
        
    }
    
    func RRHTMLViewControllerDidHide(sender: RRHTMLViewController) {

        //I'm clearing the responses cache in this example only.
        NSURLCache.sharedURLCache().removeAllCachedResponses();
    }
    
}

//
//  PreloadedViewController.swift
//  RRHTMLAlertController
//
//  Created by Rodrigo Rallo on 3/16/16.
//  Copyright © 2016 - Fotition. All rights reserved.
//

import UIKit
import SafariServices


class PreloadedViewController: UIViewController, RRHTMLViewControllerDelegate {

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
        
        self.htmlAlertController.delegate = self
        
    }
    
    @IBAction func showButtonTapped(sender: AnyObject) {
        self.presentViewController(self.htmlAlertController, animated: false, completion: nil)
    }
    
   
    
    //MARK: Reacting to controller navigation.
    func rRHTMLViewControllerWillOpenExternalResource(request: NSURLRequest, sender: RRHTMLViewController) {
        
        //You might not want to hide the alert, but here's an example how.
        sender.hideWithCompletion(true, completion: { () -> () in
            
            //If iOS 9.0+ use SFSafariViewController.
            if #available(iOS 9, *) {
                
                //Open in SFSafariVC
                let svc = SFSafariViewController(URL: request.URL!);
                svc.modalTransitionStyle = UIModalTransitionStyle.CoverVertical;
                self.presentViewController(svc, animated: true, completion: nil)
                //UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(svc, animated: true, completion: nil);
            }
            else{
                
                //Else, open in Safari externally.
                if let url = request.URL{
                    UIApplication.sharedApplication().openURL(url)
                }
            }
        })
    }

}


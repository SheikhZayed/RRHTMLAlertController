//
//  RRHTMLViewController.swift
//  RRHTMLView
//
//  Created by Rodrigo Rallo on 2/9/16.
//  Copyright © 2016 - Fotition. All rights reserved.
//


import UIKit
import SafariServices

let kHorizontalPadding : CGFloat = 25.0;
let kVerticalPadding : CGFloat = 45.0;
let kCornerRadius : CGFloat = 9.0;

@objc public protocol RRHTMLViewControllerDelegate{
  
    //MARK: Delegate Protocol
    optional func RRHTMLViewControllerDidHide(sender: RRHTMLViewController);
    optional func RRHTMLViewControllerDidShow(sender: RRHTMLViewController);
    optional func RRHTMLViewControllerDidFinishLoadingHTML(sender: RRHTMLViewController);

    optional func RRHTMLViewControllerWillDismissFromBackgroundTap(sender: RRHTMLViewController);
    optional func RRHTMLViewControllerWillDismissFromHTMLButton(sender: RRHTMLViewController);
    optional func RRHTMLViewControllerWillOpenExternalResource(request : NSURLRequest, sender :RRHTMLViewController);
}

public class RRHTMLViewController : UIViewController, UIGestureRecognizerDelegate, UIWebViewDelegate {
    
    //MARK: - Strings to look for in tapped actions.
    
    //Adding a closeURLString is important so that you can add your own custom HTML 'close' buttons.
    public var closeURLString : String?;
    public var enableOpenInSafari : Bool = true;
    public var enableActivityIndicator : Bool = true;
    
    public var delegate : RRHTMLViewControllerDelegate?;
    
    
    //Show when ready should ONLY be false if you are creating this view controller ahead of time.
    public var showWhenReady : Bool = true;
    
    //MARK: - Settings
    public var enableDismissOnBackgroundTap : Bool = true;
    public var enableAnimation : Bool = true;

    //You want to set either htmlString or the htmlURL, as they will override each other.
    //Most recent will take place.
    public var htmlString : String = ""{
        didSet{
            if(htmlString.characters.count > 0){
                self.webView.loadHTMLString(htmlString, baseURL: nil);
            }
        }
    }
    
    public var htmlURL : NSURL? = nil{
        didSet{

            if(htmlURL != nil){
                let request : NSURLRequest = NSURLRequest(URL: htmlURL!);
                self.webView.loadRequest(request);
            }
        }
    }
   
    public var webView:UIWebView = UIWebView(frame: CGRect(x: kHorizontalPadding, y: 0, width: (UIScreen.mainScreen().bounds.size.width - 2 * kHorizontalPadding), height: 50));
    
    public var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray);
    
    private var finishedLoading : Bool = false;
    private var heightConstraint : NSLayoutConstraint?;
    private var tapRecognizer:UITapGestureRecognizer?;
    private var backgroundColor: UIColor = UIColor(white: 0.1, alpha: 0.7);
    
    private static let kFadeAnimationDuration : Double = 0.20;
    private static let kHideDelayDuration : Double = 0.20;
    private static let kShowAnimationDuration : Double = 0.25;
    
    
    //MARK: - Initialization
    func commonInit(){
        self.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen;
        self.view.backgroundColor = UIColor.clearColor();
        self.webView.backgroundColor = UIColor.clearColor();
        self.webView.layer.cornerRadius = kCornerRadius;
        self.webView.layer.masksToBounds = true;
        self.webView.delegate = self;
        self.webView.scalesPageToFit = false;
        self.webView.scrollView.scrollEnabled = false;
        self.webView.alpha = 0.0;
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
        self.commonInit();
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.commonInit();
    }
    
    
    ////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////

    
    /* View controller is initially shown with its view's totally hidden.
    * This allows extra time to render any HTML, and any transition animation to finish.
    * In this current form, presenting this controller modally is totally enough.
    */
    public override func viewDidLoad() {
        super.viewDidLoad();
        
      
        self.view.addSubview(self.webView);
    }
    
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        self.webView.alpha = 0.0;
        self.view.alpha = 0.0;
    }
    
    
    //After view controller is done being presented, we show a spinner if enabled while the web content is loading.
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        
        
        self.addTapGestureRecognizer();
        self.showActivityIndicator();

        //If controller already finished loading, simply display it.
        if(self.finishedLoading){
            self.hideActivityIndicator();
            self.showWebView();
        }
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated);
        self.hideActivityIndicator();
        
        if(self.tapRecognizer != nil){
            self.view.removeGestureRecognizer(self.tapRecognizer!);
        }
        
        self.webView.alpha = 0.0;
        self.view.alpha = 0.0;
    }
    
    
    //MARK: Convenience methods.
    func addTapGestureRecognizer(){
        if(self.enableDismissOnBackgroundTap){
            self.tapRecognizer = UITapGestureRecognizer(target: self, action:Selector("handleTap:"))
            self.tapRecognizer?.delegate = self;
            
            if(self.tapRecognizer != nil){
                self.view.addGestureRecognizer(self.tapRecognizer!);
            }
        }
    }


    func showActivityIndicator(){
        
        if(self.enableActivityIndicator){
            self.activityIndicator.startAnimating();
            self.activityIndicator.removeFromSuperview();
            self.view.addSubview(self.activityIndicator);
            self.activityIndicator.center = self.view.center;
        }
        
        self.view.alpha = 0.0;
        self.view.backgroundColor = self.backgroundColor;
       
        let duration : Double = self.enableAnimation ? RRHTMLViewController.kFadeAnimationDuration : 0.0;
        UIView.animateWithDuration(duration) { () -> Void in
            self.view.alpha = 1.0;
        }
    }
    
    
    private func hideActivityIndicator(){
        //When done loading, add subview over activity indicator.
        self.activityIndicator.stopAnimating();
        self.activityIndicator.removeFromSuperview();
    }


    
    //Shows views and performs a slight pop animation as they appear.
    func showWebView(){
        
        if(self.finishedLoading){

            let duration : Double = self.enableAnimation ? RRHTMLViewController.kFadeAnimationDuration : 0.0;

            UIView.animateWithDuration(duration, animations: { () -> Void in
                
                self.webView.alpha = 1.0;
                self.view.alpha = 1.0;
               
                if(duration > 0.0){
                    self.popAnimationForView(self.webView, duration: duration);
                }
                
                },
                completion: { (finished) -> Void in
                    self.delegate?.RRHTMLViewControllerDidShow?(self);
            });
        }
    }
    
    
    //Gesture recognizer for background view.
    //Parametrized so that anyone can disable this behavior by default.
    func handleTap(recognizer: UITapGestureRecognizer) {
        self.delegate?.RRHTMLViewControllerWillDismissFromBackgroundTap?(self);
        self.hide();
    }
  
    
    //Convenience method to hide and dismiss view controller.
    public func hide(){
        self.hideWithCompletion(true, completion: nil);
    }

    
    //Directly animate a fade away and shrink, then dismiss view controller.
    //This function might become public in the near future.
    private func hideWithCompletion(animated: Bool, completion:(()->())?){
       
        let animationDuration = self.enableAnimation ? RRHTMLViewController.kShowAnimationDuration : 0.0;
        
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            
            self.view.alpha = 0.0;
            self.webView.alpha = 0.0;
            
            UIView.animateWithDuration(animationDuration*2,
                delay: 0.0,
                options: UIViewAnimationOptions.CurveLinear,
                animations: { () -> Void in
                    self.webView.transform = CGAffineTransformMakeScale(0.95, 0.95);
                },
                completion: nil);
            
            }){
                (finished) -> Void in

                self.webView.transform = CGAffineTransformIdentity;
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(RRHTMLViewController.kHideDelayDuration * Double(NSEC_PER_SEC)))

                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.dismissViewControllerAnimated(false, completion: { () -> Void in
                        
                        self.delegate?.RRHTMLViewControllerDidHide?(self);
                        if (completion != nil){
                            completion!();
                        }
                    })
                }
        };
    }

    
    
    //Bubble animation any view.
    //This might become a UIView extension in the near future.
    private func popAnimationForView(view : UIView, duration: Double){
        UIView.animateWithDuration(duration * 0.5) { () -> Void in
            view.transform = CGAffineTransformMakeScale(1.1, 1.1);
        }
        
        UIView.animateWithDuration(duration * 0.35, delay: duration * 0.5, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            view.transform = CGAffineTransformMakeScale(0.92, 0.92);
            }, completion: nil);
        
        UIView.animateWithDuration(duration * 0.15, delay: duration * 0.85, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            view.transform = CGAffineTransformMakeScale(1.0, 1.0);
            }, completion: nil);
    }


    
    //MARK: - Webview Rendering
    public func webViewDidFinishLoad(webView: UIWebView) {
        if(webView.isEqual(self.webView)){

            let screenHeight : CGFloat = UIScreen.mainScreen().bounds.size.height - 2 * kVerticalPadding;
            
            if let documentHeightString = webView.stringByEvaluatingJavaScriptFromString("document.height"){
                
                var documentHeight = CGFloat((documentHeightString as NSString).floatValue);
                
                //Chop off 2 decimals.
                let scaleFactor = floor(100*(screenHeight / (documentHeight)))/100.0;
                
                //Normalize size
                if(documentHeight > screenHeight){
                    
                    //Magic numbers to correct for non perfectly linear zoom scaling.
                    webView.stringByEvaluatingJavaScriptFromString("document.body.style.zoom = \(scaleFactor * (1 - 0.05) - 0.13);");
                    //NSLog(webView.stringByEvaluatingJavaScriptFromString("document.height")!);
                    
                    let documentHeightString2 = webView.stringByEvaluatingJavaScriptFromString("document.height")!;
                    documentHeight = CGFloat((documentHeightString2 as NSString).floatValue);
                }
                
                
                self.hideActivityIndicator();

                //Size the webview to match it's appripriate height and then apply autolayouts.
                self.webView.sizeToFit();
                let webViewHeight : CGFloat = min(documentHeight, UIScreen.mainScreen().bounds.size.height - 2 * kVerticalPadding);
                self.addWebViewConstraints(webViewHeight);
            }
        }
        
        
        //Finally show the webview when it is fully done loading and sizing.
        //NSLog("Finished loading");
        self.finishedLoading = true;
        
        self.delegate?.RRHTMLViewControllerDidFinishLoadingHTML?(self);
        self.showWebView();
    }
    

    
    //MARK: - Navigation
    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if(UIWebViewNavigationType.LinkClicked == navigationType){
            
            //Close URL
            if let closeString : String = self.closeURLString{
                if(request.URL?.absoluteString == closeString){
                    self.delegate?.RRHTMLViewControllerWillDismissFromHTMLButton?(self);
                    self.hide();
                    return false;
                }
            }

            
            if (!self.enableOpenInSafari){
                return false;
            }

            if let urlString = request.URL?.absoluteString{
                
                let index = urlString.startIndex.advancedBy(4);
                let subString : String = urlString.substringToIndex(index);
                if(subString == "http"){
                   
                    self.delegate?.RRHTMLViewControllerWillOpenExternalResource?(request, sender: self);
                    
                    self.hideWithCompletion(true, completion: { () -> () in
                        
                        //If iOS 9.0+ use SFSafariViewController.
                        if #available(iOS 9, *) {
                            
                            //Open in SFSafariVC
                            let svc = SFSafariViewController(URL: request.URL!);
                            svc.modalTransitionStyle = UIModalTransitionStyle.CoverVertical;
                            UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(svc, animated: true, completion: nil);
                        }
                        else{
                            
                            //Else, open in Safari externally.
                            if let url = request.URL{
                                UIApplication.sharedApplication().openURL(url)
                            }
                        }
                    })
                    
                    
                    return false;
                }
            }
        }
        
        return true;
    }

    
    //MARK: - Layout
    
    //Setup autolayout constraints for webview inside background view.
    //Webview is centered vertically and bounded horizontally.
    //There's also a max height bound to keep the alert within reasonable range.
    func addWebViewConstraints(height: CGFloat){
    
        self.webView.removeConstraints(self.webView.constraints);
        self.view.removeConstraints(self.view.constraints);
        
        self.webView.translatesAutoresizingMaskIntoConstraints = false;
        
        let leftAnchor : NSLayoutConstraint = NSLayoutConstraint(item: self.view,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.webView,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1.0,
            constant: -kHorizontalPadding);

        let rightAnchor : NSLayoutConstraint = NSLayoutConstraint(item: self.view,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.webView,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1.0,
            constant: kHorizontalPadding);

        let bottomAnchor : NSLayoutConstraint = NSLayoutConstraint(item: self.view,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.GreaterThanOrEqual,
            toItem: self.webView,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1.0,
            constant: kVerticalPadding);

        let topAnchor : NSLayoutConstraint = NSLayoutConstraint(item: self.view,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.LessThanOrEqual,
            toItem: self.webView,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1.0,
            constant: kVerticalPadding);
        
        let vertCenter : NSLayoutConstraint = NSLayoutConstraint(item: self.view,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.webView,
            attribute: NSLayoutAttribute.CenterY,
            multiplier: 1.0,
            constant: 0.0);

        self.heightConstraint = NSLayoutConstraint(item: self.webView,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1.0,
            constant: height);
        
            self.view.addConstraints([leftAnchor, rightAnchor, vertCenter, self.heightConstraint!, topAnchor, bottomAnchor]);
        }
    
    deinit{
        self.webView.removeFromSuperview();
        self.activityIndicator.removeFromSuperview();
        self.htmlString = "";
        self.htmlURL = nil;
        if(self.tapRecognizer != nil){
            self.view.removeGestureRecognizer(self.tapRecognizer!);
            self.tapRecognizer = nil;
        }
    }
}
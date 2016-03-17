# RRHTMLAlertController
RRHTMLAlertController is a fully responsive, UIAlertController alternative that can be styled entirely through HTML for a fully dynamic experience.

We invented this controller when building Fotition because we wanted to show customizable 'Thank you' messages after users participated in certain campaigns.

We've received great feedback so far, so we decided to open source this simple view controller.

Check us out:
www.fotition.com


Download our app:
https://itunes.apple.com/us/app/fotition-social-change-made/id960913360?mt=8


# Installation

Simply drag and drop the RRHTMLViewController.swift file into your project, it is entirely self sufficient.

Remember to build your project once before trying to import it into Objective-C files.

#Usage
The RRHTMLViewController can load HTML content both from your app bundle and from any URL.

###Static HTML string

Loading an HTML file from your bundle can be extremely fast and relatively light.
This allows you to create the RRHTMLViewController ahead of time so that the user never has to wait for it to load.

````
//Initialize it normally
private let htmlAlertController : RRHTMLViewController = RRHTMLViewController()
````
````
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
  
  //If you're implementing your own 'close button' you can disable
  //tapping on the background to dismiss the controller.
  self.htmlAlertController.enableDismissOnBackgroundTap = false;
  self.htmlAlertController.closeURLString = "yourcompany://close"
}
````

###Dynamic Content
The RRHTMLViewController can also load content from the web without much setup.

````
//Initialize normally
private var htmlAlertController : RRHTMLViewController = RRHTMLViewController()
````
````
@IBAction func createAndShowAlertControllerButtonTapped(sender: AnyObject) {
  
  //Initialize a new controller when you need it.
  self.htmlAlertController = RRHTMLViewController()

  //Tell the controller to display itself as soon as it finished loading the web content.
  self.htmlAlertController.showWhenReady = true;

  //Enable sweet fade in animation
  self.htmlAlertController.enableAnimation = true;

  //Let users tap outside the webview to dismiss the controller.
  //This is important since dynamic content likely won't have your 'close button.'
  self.htmlAlertController.enableDismissOnBackgroundTap = true;

  //Listen to the controller to get notified for key events in case you need to do additional setup.
  self.htmlAlertController.delegate = self;

  //Give the controller a resource URL (can also link to a file in the App bundle).
  self.htmlAlertController.htmlURL = NSURL(string: "https://www.google.com")

  //Present the view controller.
  self.presentViewController(self.htmlAlertController, animated: false, completion: nil);
}
````



# Settings
The following variables are default, but you're free to tweak them as you wish:
````
  //Provide a closeString for the webview to intercept loads and dismiss the controller.
  //E.X. "yourcompany://close"
  public var closeURLString : String?;

  //Control whether users can navigate inside this webview or not.
  //Will push to safari on iOS 8.x and will use SafariServices within the app if iOS 9.x or above.
  public var enableOpenInSafari : Bool = true;

  //Control whether you want to show an activity indicator while your content is loading.
  public var enableActivityIndicator : Bool = true;

  //Get notified of any important events such as didHide, or willDismiss.
  public var delegate : RRHTMLViewControllerDelegate?;

  //Show when ready should *ONLY* be false if you are creating this view controller ahead of time.
  public var showWhenReady : Bool = true;

  //Control whether users can tap on the background to dismiss the controller.
  public var enableDismissOnBackgroundTap : Bool = true;

  //Control whether the controller animates in or not.
  public var enableAnimation : Bool = true;
````

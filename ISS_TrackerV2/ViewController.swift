//
//  ViewController.swift
//  ISS_TrackerV2
//
//  Created by Puneet Singh Bagga on 2016-05-20.
//  Copyright © 2016 Puneet Singh Bagga. All rights reserved.
//

import UIKit
import MapKit
import Foundation

extension UIView {
    
    // A convenience function that saves us directly invoking the rather verbose
    // NSLayoutConstraint initializer on each and every object in the interface.
    func centerHorizontallyInSuperview(){
        let c: NSLayoutConstraint = NSLayoutConstraint(item: self,
                                                       attribute: NSLayoutAttribute.CenterX,
                                                       relatedBy: NSLayoutRelation.Equal,
                                                       toItem: self.superview,
                                                       attribute: NSLayoutAttribute.CenterX,
                                                       multiplier:1,
                                                       constant: 0)
        
        // Add this constraint to the superview
        self.superview?.addConstraint(c)
        
    }
    
}

class ViewController : UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    let latitudeValue = UILabel()
    let longitudeValue = UILabel()
    
    //longitude and latitude values are stored here
    var latitude : Double = 0.0
    var lat : String = ""
    var long : String = ""
    var longitude : Double = 0.0
    var map : MKMapView!
//    // Views that need to be accessible to all methods
//    let latitudeResult = UILabel()
//    let longitudeResult = UILabel()
    // If data is successfully retrieved from the server, we can parse it here
    func parseMyJSON(theData : NSData) {
        
        // Print the provided data
        print("")
        print("====== the data provided to parseMyJSON is as follows ======")
        print(theData)
        
        // De-serializing JSON can throw errors, so should be inside a do-catch structure
        do {
            
            // Do the initial de-serialization
            // Source JSON is here:
            // http://api.open-notify.org/iss-now.json
            //
            let json = try NSJSONSerialization.JSONObjectWithData(theData, options: NSJSONReadingOptions.AllowFragments) as! AnyObject
            
            // Print retrieved JSON
            print("")
            print("====== the retrieved JSON is as follows ======")
            print(json)
            
            // Now we can parse this...
            print("")
            print("Now, add your parsing code here...")
            
            if let issPosition = json["iss_position"] as? [String : Double] {
                print("=======LATITUDE=======")
                print(issPosition["latitude"])
                latitude = issPosition["latitude"]!
                print("=======LONGITUDE=======")
                print(issPosition["longitude"])
                longitude = issPosition["longitude"]!
            } else {
                
                
            }
            
            // Set up the map to show the closest cooling centre
            let issLatitude = CLLocationDegrees(self.latitude)
            let issLongitude = CLLocationDegrees(self.longitude)
            
            // Position the map
            let issCoordinates = CLLocationCoordinate2D(latitude: issLatitude, longitude: issLongitude + 0.001)
            self.map.setCenterCoordinate(issCoordinates, animated: true)
            let region = MKCoordinateRegion(center: issCoordinates, span: MKCoordinateSpan(latitudeDelta: 10.000, longitudeDelta: 10.000))
            //change both to 0.002
            self.map.setRegion(region, animated: true)
            
            // Add a pin at the location of the cooling centre
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: issLatitude, longitude: issLongitude - 0.0001)
            self.map.addAnnotation(annotation)
            
            
            // Now we can update the UI
            // (must be done asynchronously)
            dispatch_async(dispatch_get_main_queue()) {
                
                self.latitudeValue.text = String(issLatitude);
                //self.jsonResult.text = "parsed JSON should go here"
                self.longitudeValue.text = String(issLongitude);
                // Create a space in memory to store the current location
                //var currentLocation = CLLocation()
                
            }
            
            
        } catch let error as NSError {
            print ("Failed to load: \(error.localizedDescription)")
        }
        
        
    }
    
    // Set up and begin an asynchronous request for JSON data
    func getMyJSON() {
        
        // Define a completion handler
        // The completion handler is what gets called when this **asynchronous** network request is completed.
        // This is where we'd process the JSON retrieved
        let myCompletionHandler : (NSData?, NSURLResponse?, NSError?) -> Void = {
            
            (data, response, error) in
            
            // This is the code run when the network request completes
            // When the request completes:
            //
            // data - contains the data from the request
            // response - contains the HTTP response code(s)
            // error - contains any error messages, if applicable
            
            print("")
            print("====== data from the request follows ======")
            print(data)
            print("")
            print("====== response codes from the request follows ======")
            print(response)
            print("")
            print("====== errors from the request follows ======")
            print(error)
            
            // Cast the NSURLResponse object into an NSHTTPURLResponse objecct
            if let r = response as? NSHTTPURLResponse {
                
                // If the request was successful, parse the given data
                if r.statusCode == 200 {
                    
                    if let d = data {
                        
                        // Parse the retrieved data
                        self.parseMyJSON(d)
                        
                    }
                    
                }
                
            }
            
        }
        
        
        // Define a URL to retrieve a JSON file from
        let address : String = "http://api.open-notify.org/iss-now.json"
        
        // Try to make a URL request object
        if let url = NSURL(string: address) {
            
            // We have an valid URL to work with
            print(url)
            
            // Now we create a URL request object
            let urlRequest = NSURLRequest(URL: url)
            
            // Now we need to create an NSURLSession object to send the request to the server
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: config)
            
            // Now we create the data task and specify the completion handler
            let task = session.dataTaskWithRequest(urlRequest, completionHandler: myCompletionHandler)
            
            // Finally, we tell the task to start (despite the fact that the method is named "resume")
            task.resume()
            
        } else {
            
            // The NSURL object could not be created
            print("Error: Cannot create the NSURL object.")
            
        }
        

        
    }
    
    // This is the method that will run as soon as the view controller is created
    override func viewDidLoad() {
        
        // Sub-classes of UIViewController must invoke the superclass method viewDidLoad in their
        // own version of viewDidLoad()
        super.viewDidLoad()
        
        // Make the view's background be white
        // Trying to match colours expected on iOS
        // http://iosdesign.ivomynttinen.com/#color-palette
        view.backgroundColor = UIColor.whiteColor()
        
//        /*
//         * Further define label that will show JSON data
//         */
//        
//        // Set the label text and appearance
//        jsonResult.text = "..."
//        jsonResult.font = UIFont.systemFontOfSize(12)
//        jsonResult.numberOfLines = 0   // makes number of lines dynamic
//        // e.g.: multiple lines will show up
//        jsonResult.textAlignment = NSTextAlignment.Center
//        
//        // Required to autolayout this label
//        jsonResult.translatesAutoresizingMaskIntoConstraints = false
//        
//        // Add the label to the superview
//        view.addSubview(jsonResult)
        
        /*
         * Create label that will be the title
         */
        let title = UILabel()
        
        // Set the label text and appearance
        title.text = "ISS Tracker"
        title.font = UIFont.boldSystemFontOfSize(36)
        
        // Required to autolayout this label
        title.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the label to the superview
        view.addSubview(title)
        
        /*
         * Create label that will be the latitude value
         */
        let latitudeDisplay = UILabel()
        
        // Set the label text and appearance
        latitudeDisplay.text = "=======LATITUDE======="
        latitudeDisplay.font = UIFont.boldSystemFontOfSize(28)
        
        // Required to autolayout this label
        latitudeDisplay.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the label to the superview
        view.addSubview(latitudeDisplay)
        

        
//        // Set the label text and appearance
//        latitudeValue.text = String(latitude)
//        latitudeValue.font = UIFont.boldSystemFontOfSize(24)
//        
//        // Required to autolayout this label
//        latitudeValue.translatesAutoresizingMaskIntoConstraints = false
//        
//        // Add the label to the superview
//        view.addSubview(latitudeValue)
        
        /*
         * Create label that will be the latitude value
         */
        
        /*
         * Further define label that will show JSON data
         */
        
        // Set the label text and appearance
        latitudeValue.text = String(latitude)
        latitudeValue.font = UIFont.systemFontOfSize(24)
        latitudeValue.numberOfLines = 0   // makes number of lines dynamic
        // e.g.: multiple lines will show up
        latitudeValue.textAlignment = NSTextAlignment.Left
        
        // Required to autolayout this label
        latitudeValue.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the label to the superview
        view.addSubview(latitudeValue)
        
        /*
         * Create label that will be the longitude value
         */
        let longitudeDisplay = UILabel()
        
        // Set the label text and appearance
        longitudeDisplay.text = "=======LONGITUDE======="
        longitudeDisplay.font = UIFont.boldSystemFontOfSize(28)
        
        // Required to autolayout this label
        longitudeDisplay.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the label to the superview
        view.addSubview(longitudeDisplay)
        
        
        /*
         * Create label that will be the longitude value
         */

        
//        // Set the label text and appearance
//        longitudeValue.text = String(longitude)
//        longitudeValue.font = UIFont.boldSystemFontOfSize(24)
//        
//        // Required to autolayout this label
//        longitudeValue.translatesAutoresizingMaskIntoConstraints = false
//        
//        // Add the label to the superview
//        view.addSubview(longitudeValue)
//        
        
        /*
         * Further define label that will show JSON data
         */
        
        // Set the label text and appearance
        longitudeValue.text = String(longitude)
        longitudeValue.font = UIFont.systemFontOfSize(24)
        longitudeValue.numberOfLines = 0   // makes number of lines dynamic
        // e.g.: multiple lines will show up
        longitudeValue.textAlignment = NSTextAlignment.Left
        
        // Required to autolayout this label
        longitudeValue.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the label to the superview
        view.addSubview(longitudeValue)
        
        
        /*
         * Further define map
         */
        let mapContainer : UIView = UIView(frame: CGRectMake(0, 0, 640, 350))
        mapContainer.translatesAutoresizingMaskIntoConstraints = false
        map = MKMapView(frame: CGRectMake(0, 0, 640, 350))
        map.mapType = .Standard
        map.delegate = self
        //map.translatesAutoresizingMaskIntoConstraints = false
        mapContainer.addSubview(map)
        view.addSubview(mapContainer)
        
        
        /*
         * Add a button
         */
        let getData = UIButton(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
        
        // Make the button, when touched, run the calculate method
        getData.addTarget(self, action: #selector(ViewController.getMyJSON), forControlEvents: UIControlEvents.TouchUpInside)
        
        // Set the button's title
        getData.setTitle("TRACK ISS", forState: UIControlState.Normal)
        
        // Set the button's color
        getData.setTitleColor(UIColor.init(red: 0.329, green: 0.78, blue: 0.988, alpha: 1), forState: UIControlState.Normal)
        
        // Required to auto layout this button
        getData.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the button into the super view
        view.addSubview(getData)
        
        /*
         * Layout all the interface elements
         */
        
        // This is required to lay out the interface elements
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Create an empty list of constraints
        var allConstraints = [NSLayoutConstraint]()
        
        // Create a dictionary of views that will be used in the layout constraints defined below
        let viewsDictionary : [String : AnyObject] = [
            "title": title,
            "getData": getData,
            "map": mapContainer,
            "latitude": latitudeValue,
            "longitude": longitudeValue,
            "latitudeTitle": latitudeDisplay,
            "longitudeTitle": longitudeDisplay]
        
        // Define the vertical constraints
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-20-[title]-20-[getData]-30-[latitudeTitle]-5-[latitude]-10-[longitudeTitle]-5-[longitude]-30-[map]",
            options: [],
            metrics: nil,
            views: viewsDictionary)
        
        // Add the vertical constraints to the list of constraints
        allConstraints += verticalConstraints
        
        //centre everything
        title.centerHorizontallyInSuperview()
        getData.centerHorizontallyInSuperview()
        map.centerHorizontallyInSuperview()
        latitudeDisplay.centerHorizontallyInSuperview()
        latitudeValue.centerHorizontallyInSuperview()
        longitudeDisplay.centerHorizontallyInSuperview()
        longitudeValue.centerHorizontallyInSuperview()
        
        // Activate all defined constraints
        NSLayoutConstraint.activateConstraints(allConstraints)
        
    }
    
}



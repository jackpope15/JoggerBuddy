//
//  MapViewController.swift
//  JoggerBuddy
//
//  Created by Jack Pope on 12/14/19.
//  Copyright © 2019 Jack Pope. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()
    var endingLocation: CLLocation?
    var startingLocation : CLLocation?
    var distance : CLLocationDistance?
    var isChecked : Bool = true
    var seconds = 0
    var timer = Timer()
    let realm = try! Realm()
    let dataModel = DataModel()
    var totalSum : Double = 0
    let metersUnit : String = "meters"
    
    
    @IBOutlet weak var distanceRanTextField: UITextField!
    @IBOutlet weak var buttonText: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager()
        deleteData()
        loadData()

    }
    //Make sure the location functions are working properly and the user is prompted
    //to allow when in use location abilities
    func initializeLocationManager() {
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        initializeStartButton()
        
    }
    
    //interchanges starting and ending functionality in same function
    @IBAction func buttonPressed(_ sender: UIButton) {
        isChecked = !isChecked
        initializeStartButton()
        if !isChecked {
            initializeStartingPosition()
        }
        else {
            initializeEndingPosition()
        }
    }
    /* Sets the standard for the start button by changing the text/background color
    according to the property of isChecked */
    func initializeStartButton() {
        if isChecked == true {
            buttonText.setTitle("Start", for: .normal)
            buttonText.backgroundColor = UIColor.green
        }
        else {
            buttonText.setTitle("Stop", for: .normal)
            buttonText.backgroundColor = UIColor.red
        }
    }
    
    //This is called once the user hits the start button and it tracks the first location
    //they are at, as well as starting the timer
    func initializeStartingPosition() {
        locationManager.startUpdatingLocation()
        guard let initialLocation = locationManager.location else {return}
        startingLocation = initialLocation
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    //Continuously updates the location based on the startUpdatingLocation call
    //makes sure the endingLocation is the last location found in the locations array of the
    //didUpdateLocations parameter, then stops updating the location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.activityType = .fitness
        endingLocation = locations.last!
        self.locationManager.delegate = nil
        self.locationManager.stopUpdatingLocation()
    }
    
    /* Calculates the total distance between the starting and ending point, and it ends
    the timer, this function is called in the initializeEndingPosition function which
    is the used when the stop button is clicked, then the calculateDistance saves the
    distance to the realm database then performs a segue to go to the results VC */
    func calculateDistance(startingPoint: CLLocation, endingPoint: CLLocation) {
        distance = startingPoint.distance(from: endingPoint)
        timer.invalidate()
        guard let distanceNew = distance else {return}
        save(newDistance: distanceNew)
        performSegue(withIdentifier: "goToResults", sender: self)
    }
    
    //Reiterating the stopUpdatingLocation funcionality to make sure no possible more location
    //data can be found. I then created two guard let statements and plugged them into
    //the calculateDistance function.
    
    func initializeEndingPosition() {
        
        locationManager.stopUpdatingLocation()
        guard let startPoint = startingLocation else {return}
        guard let endPoint = endingLocation else {return}
        calculateDistance(startingPoint: startPoint, endingPoint: endPoint)
    }
    
    /*This function is essential for drawing the route the user ran on the mapView
    however, this function doesn't get called until the next view controller, since no
    mapView exists in the MapViewController. I did use StackOverflow as a resource to help
    figure out how to create this function to learn how to incorporate MapKit functionality */
    func createDistanceLine(start : CLLocation?, end: CLLocation?, useMapView: MKMapView) {
        
        guard let startPointV = start else {return}
        guard let endPointV = end else {return}
        
        let sourceLocation = startPointV.coordinate
        let destinationLocation = endPointV.coordinate
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .walking
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate { (response, error) in
            guard let responseCalculate = response else {return}
            
            let route = responseCalculate.routes[0]
            useMapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            useMapView.setRegion(MKCoordinateRegion.init(rect), animated: true)
        }
        
    }
    //Updates the timer in seconds
    @objc func updateTimer() {
        seconds += 1
    }
    
    //*REALM DATABASE FUNCTIONS*//
    
    //Saves each distance iteration created into the realm database
    func save(newDistance : CLLocationDistance) {
        dataModel.totalDistance = newDistance
        do {
            try realm.write {
                realm.add(dataModel)
            }
        }
        catch {
            print(error)
        }
    }
    /* Loads the total amount of meters ran in the database and formats the number
    into the distanceRanTextField textfield. */
    func loadData() {
        totalSum = realm.objects(DataModel.self).sum(ofProperty: "totalDistance")
        distanceRanTextField.text = String.localizedStringWithFormat("%.2f %@", totalSum, metersUnit)
    }
    /* Deletes the data after a 24 hour period from the database */
    func deleteData() {
        let yesterday = NSDate(timeIntervalSinceNow: -(24 * 60 * 60))
        let deleteItem = realm.objects(DataModel.self).filter("createdDate < %@", yesterday)
        
        try! realm.write {
            realm.delete(deleteItem)
        }
    }
    
    //Passes the distance, startingLocation, endingLocation and seconds elapsed
    //to the resultsViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToResults" {
            let viewController = segue.destination as! ResultsViewController
            viewController.passedValue = distance
            viewController.starting = startingLocation
            viewController.ending = endingLocation
            viewController.seconds = seconds
        }
    }
    
}

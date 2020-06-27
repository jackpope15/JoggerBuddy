//
//  ResultsViewController.swift
//  JoggerBuddy
//
//  Created by Jack Pope on 12/14/19.
//  Copyright © 2019 Jack Pope. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class ResultsViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()
    let mapController = MapViewController()
    
    var starting : CLLocation?
    var ending : CLLocation?
    var passedValue : CLLocationDistance?
    var displayTime : String = ""
    var seconds = 0

    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        initalizeLocationManager()
        initalizeMap()

    }
    //Starts up the location manager
    func initalizeLocationManager() {
        locationManager.delegate = self
        
    }
    //Calls the createDistanceLine function described in the MapViewController and
    //sets the mapView delegate property to self
    func initalizeMap() {
        
        mapView.delegate = self
        mapController.createDistanceLine(start: starting, end: ending, useMapView: mapView)
        
    }
    //This function draws a blue polyline in the mapView to highlight the route ran,
    //I did use StackOverflow as a resource to help figure out how to
    //incorporate this functionality
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        
        return renderer
    }
    //Once the viewResults button is pressed, it segues into the Summary View Controller
    @IBAction func resultsButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToSummary", sender: self)
    }
    //Passes the distance ran and the seconds elapsed to the SummaryViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSummary" {
            let testController = segue.destination as! SummaryViewController
            testController.passedValue = passedValue
            testController.seconds = seconds
            
        }
    }

}

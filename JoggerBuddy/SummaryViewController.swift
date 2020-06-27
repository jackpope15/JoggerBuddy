//
//  SummaryViewController.swift
//  JoggerBuddy
//
//  Created by Jack Pope on 12/14/19.
//  Copyright © 2019 Jack Pope. All rights reserved.
//

import UIKit
import MapKit

class SummaryViewController: UIViewController {
    
    var passedValue : CLLocationDistance?
    let metersUnit : String = "meters"
    var seconds = 0

    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var hoursTextField: UITextField!
    @IBOutlet weak var minutesTextField: UITextField!
    @IBOutlet weak var secondsTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayData()
    }
    

    //Displays the total distance ran for the specific instance on the distanceTextField
    //textfield, then calls the formatTimeString function
    func displayData() {
        guard let passingValue = passedValue else {return}
        distanceTextField.text = String.localizedStringWithFormat("%.2f %@", passingValue, metersUnit)
        formatTimeString()
        
    }
    //formats the display for the time elapsed while running into the hoursTextField,
    //minutesTextField, and secondsTextField accordingly.
    func formatTimeString() {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) / 60) % 60
        let convertedSeconds = Int(seconds) % 60
        hoursTextField.text = String(format: "%2i", hours)
        minutesTextField.text = String(format: "%2i", minutes)
        secondsTextField.text = String(format: "%2i", convertedSeconds)
    }
}

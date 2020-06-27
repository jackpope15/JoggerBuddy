//
//  DataModel.swift
//  JoggerBuddy
//
//  Created by Jack Pope on 12/14/19.
//  Copyright © 2019 Jack Pope. All rights reserved.
//


import Foundation
import RealmSwift


//Used Realm Documentation to figure out how to create a Data Model Realm Object
//and how to create variables to store in the database
class DataModel : Object {
    @objc dynamic var totalDistance : Double = 0
    @objc dynamic var createdDate = Date()
}



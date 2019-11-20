//
//  TripModel.swift
//  My Drive
//
//  Created by Ugo Falanga on 20/11/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import Foundation

class TripModel: Codable {
    
    var startTripDate : Date
    var finishTripDate : Date
    var distance : Float
    var averageSpeed : Float
    var maxSpeed : Float
    var timeTrip : Double
    
    init(startTripDate: Date, finishTripDate : Date, distance: Float, averageSpeed : Float, maxSpeed: Float, timeTrip: Double) {
        self.startTripDate = startTripDate
        self.finishTripDate = finishTripDate
        self.distance = distance
        self.averageSpeed = averageSpeed
        self.maxSpeed = maxSpeed
        self.timeTrip = timeTrip
    }
}

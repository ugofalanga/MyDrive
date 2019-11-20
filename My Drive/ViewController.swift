//
//  ViewController.swift
//  My Drive
//
//  Created by Ugo Falanga on 20/11/2019.
//  Copyright © 2019 Apple Inc. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // Declaration of Outlet
    @IBOutlet var viewCointainer: UIView!
    @IBOutlet var startButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var averageSpeedLabel: UILabel!
    @IBOutlet var timeTravelLabel: UILabel!
    
    
    // Declaration of location manager
    let locationManager : CLLocationManager = CLLocationManager()
    
    // Declaration of trips array
    var trips:[TripModel] = []
    
    // Declaration of variables latitude and longitude
    var latitude : Double = Double()
    var longitude : Double = Double()
    // Declaration of variables initial latitude and initial longitude
    var initLatitude : Double = Double()
    var initLongitude : Double = Double()
    // Declaration of variables semaphore to give access to start and stop buttons
    var startSemaphore = true
    var stopSemaphore = true
    // Declaration of Timer
    var timer = Timer()
    var count : Double = 0
    
    var tripTime : Double = 0
    
    var startDate : Date!
    var stopDate : Date!
    
    var distanceTraveled : Double = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.delegate = self
        
        viewCointainer.backgroundColor = .gray
        viewCointainer.layer.cornerRadius = 10
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Gps Function
        
        locationManager.requestWhenInUseAuthorization()
        
        // Updating
        locationManager.distanceFilter = 100
        
    }
    
    // Start action
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        print("Timer started")
        // Abilitate stop button
        stopButton.isEnabled = true
        stopButton.setTitleColor(.systemGray6, for: .normal)
        
        // Set start date
        if (startSemaphore) {
            startDate = Date()
        }
        // Start location update
        locationManager.startUpdatingLocation()
        
        // Set initial position
        initLatitude = (locationManager.location?.coordinate.latitude)!
        initLongitude = (locationManager.location?.coordinate.longitude)!
        
        if !timer.isValid {
            
            // Change start button in pause button
            self.startButton.setTitle("Pause", for: .normal)
            self.startButton.setBackgroundImage(UIImage(named: "pausa"), for: .normal)
            self.startButton.setTitleColor(.systemRed, for: .normal)
            
            startSemaphore = false
            
            // Start timer
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                
                // Check the amount of time
                if self.count == 10.0 {
                    
                    let content = UNMutableNotificationContent()
                    content.title = "3 hours driving"
                    content.body = "You have been driving for 3h,take a break!"
                    content.sound = UNNotificationSound.default
                    
                    let trigger = UNTimeIntervalNotificationTrigger (timeInterval: 0.000001, repeats: false)
                    let request = UNNotificationRequest (identifier: "testIdentifier", content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                    
                }
                
                // Increase variable count and print on screen the timer
                self.count += 1
                self.timerLabel.text = self.timeFormatter(self.count)
                
                // Set coordinates to calculate the distance from start
                let coordinates = CLLocation(latitude: self.initLatitude, longitude: self.initLongitude)
                let distance = self.locationManager.location?.distance(from: coordinates)
                self.distanceTraveled = distance!
                // Calculate the average speed
                let averageSpeed = (distance!/self.count) * 3.6
                self.averageSpeedLabel.text = "\(round(averageSpeed))"
                
            }
        } else {
            // Invalidate the timer
            timer.invalidate()
            
            print("Timer paused")
            
            // Mutate color and title of button
            startButton.setTitle("Resume", for: .normal)
            startButton.setTitleColor(.systemGreen, for: .normal)
            startButton.setBackgroundImage(UIImage(named: "buttonStart"), for: .normal)
            
            startSemaphore = false
        }
        stopSemaphore = true
        
    }
    
    // Stop action
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        // Invalidate timer
        timer.invalidate()
        
        // Set stop data
        if(stopSemaphore){
            stopDate = Date()
        }
        
        // This is a print of time you have been driving
        print(timeFormatter(count))
        tripTime = count
        timeTravelLabel.text = timeFormatter(count)
        
        self.startButton.setBackgroundImage(UIImage(named: "buttonStart"), for: .normal)
        
        let newTrip = TripModel.init(startTripDate: startDate, finishTripDate: stopDate, distance: Float(distanceTraveled), averageSpeed: 50.0, maxSpeed: 100, timeTrip: tripTime)
        
        // Add new trip to array
        trips.append(newTrip)
        
        // Print in console the array of trips
        for trip in trips{
            print(trip.startTripDate, trip.finishTripDate, trip.distance, trip.averageSpeed, trip.maxSpeed, trip.timeTrip)
        }
        
        // Reset count
        count = 0
        timerLabel.text = "00:00:00"
        
        print("Timer reset")
        
        
        // Resetting start button
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(.systemGreen, for: .normal)
        if(stopSemaphore){
            let simpleAlert = UIAlertController(title: "Complimenti",
                                                message: "Il tuo viaggio è durato \(timeFormatter(tripTime)) e ho memorizzato il parcheggio",
                preferredStyle: .alert)
            
            simpleAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            present(simpleAlert, animated: true, completion: nil)
            
        }
        // Disable stop button
        stopButton.isEnabled = false
        
        // Stop Gps position update
        locationManager.stopUpdatingLocation()
        
        
        stopSemaphore = false
        startSemaphore = true
        
    }
    
    
    // Utility function for data formatter
    func dataFormatter() -> String {
        let tempDate = Date()
        let tempFormatter = DateFormatter()
        tempFormatter.dateFormat = "hh:mm:ss dd/MM/yyyy"
        let dateFormatted = tempFormatter.string(from: tempDate)
        
        return dateFormatted
    }
    
    // Utility function for timer formatter
    func timeFormatter(_ time : TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60
        let seconds = time - Double(minutes) * 60
        return String(format: "%02i:%02i:%02i", hours, minutes, Int(seconds))
    }
    
    // Function for open apple maps
    func openMapForPlace() {
        
        // Declaration of coordinates for map
        let mapLatitude : CLLocationDegrees = latitude
        let mapLongitude : CLLocationDegrees = longitude
        // Set distance of view for map
        let regionDistance : CLLocationDistance = 5000
        
        
        let coordinates = CLLocationCoordinate2DMake(mapLatitude, mapLongitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "My Park"
        mapItem.openInMaps(launchOptions: options)
    }
    
    // Gps function
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        for currentlocation in locations{
            // Assign coordinate
            latitude = currentlocation.coordinate.latitude
            longitude = currentlocation.coordinate.longitude
            // Calculate speed in Kilometer per hours
            let speedKilometer = (currentlocation.speed) * 3.6
            // Declaration of coordinates to calculate distance
            let coordinates = CLLocation(latitude: initLatitude, longitude: initLongitude)
            // Calculate distance from start point (in Kilometer)
            let distanceInKm = (currentlocation.distance(from: coordinates))/1000
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        // To develop for understand user settings variation
        
    }
}

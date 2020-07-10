//
//  Service.swift
//  UBER
//
//  Created by Shrey Gupta on 07/07/20.
//  Copyright © 2020 Shrey Gupta. All rights reserved.
//

import Firebase
import CoreLocation
import GeoFire

let DB_REF = Database.database().reference()
let DB_REF_USERS = DB_REF.child("users")
let DB_REF_DRIVER_LOCATIONS = DB_REF.child("driver-locations")
let DB_REF_TRIPS = DB_REF.child("trips")

struct Service {
    
    static var shared = Service()
    
    
    func fetchUserData(currentUID: String, completion: @escaping(User) -> Void) {
        print("DEBUG: Fetching USER Data")
        DB_REF_USERS.child(currentUID).observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            
            let user = User(uid: currentUID, dictionary: dictionary)
            completion(user)
        }
    }
    
    func fetchDrivers(location: CLLocation, completion: @escaping(User)->Void ){
        let geofire = GeoFire(firebaseRef: DB_REF_DRIVER_LOCATIONS)
        
        DB_REF_DRIVER_LOCATIONS.observe(.value) { (snapshot) in
            geofire.query(at: location, withRadius: 50).observe( .keyEntered, with: { (uid, location) in
                self.fetchUserData(currentUID: uid) { (user) in
                    var driver = user
                    driver.location = location
                    completion(driver)
                }
            })
        }
    }
    
    func uploadTrip(from pickupCoordinates: CLLocationCoordinate2D, to destinationCoordinates: CLLocationCoordinate2D, completion: @escaping(Error? , DatabaseReference) -> Void ){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let pickupArray = [pickupCoordinates.latitude, pickupCoordinates.longitude]
        let destinationArray = [destinationCoordinates.latitude, destinationCoordinates.longitude]
        
        let values = ["pickupCoordinates": pickupArray, "destinationCoordinates": destinationArray, "state": TripState.isRequested.rawValue] as [String : Any]
        
        DB_REF_TRIPS.child(uid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    func observeTrips(completion: @escaping(Trip) -> Void){
        DB_REF_TRIPS.observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let uid = snapshot.key
            let trip = Trip(passengerUID: uid, dictionary: dictionary)
             completion(trip)
        }
    }
    
    func observeTripCancelled(trip: Trip, completion: @escaping() -> Void){
        DB_REF_TRIPS.child(trip.passengerUID).observeSingleEvent(of: .childRemoved, with: { (_) in
            completion()
        })
    }
    
    func acceptTrip(trip: Trip, completion: @escaping(Error? ,DatabaseReference) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let values = ["driverUID": uid, "state": TripState.isAccepted.rawValue] as [String : Any]
        
        DB_REF_TRIPS.child(trip.passengerUID).updateChildValues(values, withCompletionBlock: completion)
    }
    
    func obeseveCurrentTrip(completion: @escaping(Trip) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        DB_REF_TRIPS.child(uid).observe(.value) { (snapshot) in
            guard let dictionary = snapshot.value as? [String:Any] else { return }
            let uid = snapshot.key
            let trip = Trip(passengerUID: uid, dictionary: dictionary)
            completion(trip)
        }
    }
    
    func cancelTrip(completion: @escaping(Error?, DatabaseReference) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        DB_REF_TRIPS.child(uid).removeValue(completionBlock: completion)
    }
    
    func updateDriverLocation(location: CLLocation){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let geofire = GeoFire(firebaseRef: DB_REF_DRIVER_LOCATIONS)
        
        geofire.setLocation(location, forKey: uid)
    }
    
    func updateTripState(trip: Trip, state: TripState){
        DB_REF_TRIPS.child(trip.passengerUID).child("state").setValue(state.rawValue)
    }
}

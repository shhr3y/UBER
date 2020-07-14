//
//  Trip.swift
//  UBER
//
//  Created by Shrey Gupta on 09/07/20.
//  Copyright © 2020 Shrey Gupta. All rights reserved.
//

import CoreLocation

enum TripState: Int{
    case isRequested
    case isDenied
    case isAccepted
    case driverArrived
    case inProgress
    case arrivedAtDestination
    case isCompleted
}

struct Trip {
    var pickupCoordinates: CLLocationCoordinate2D!
    var destinationCoordinates: CLLocationCoordinate2D!
    var destinationTitleLabel: String!
    var destinationAddressLabel: String!
    var passengerFullname: String!
    let passengerUID: String!
    var driverUID: String?
    var state: TripState!
    
    init(passengerUID: String, dictionary: [String: Any]) {
        self.passengerUID = passengerUID
        
        
        if let pickupCoordinates = dictionary["pickupCoordinates"] as? NSArray {
            guard let lat = pickupCoordinates[0] as? CLLocationDegrees else { return }
            guard let long = pickupCoordinates[1] as? CLLocationDegrees else { return }
            self.pickupCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        if let destinationCoordinates = dictionary["destinationCoordinates"] as? NSArray {
            guard let lat = destinationCoordinates[0] as? CLLocationDegrees else { return }
            guard let long = destinationCoordinates[1] as? CLLocationDegrees else { return }
            self.destinationCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        self.passengerFullname = dictionary["passengerName"] as? String ?? ""
        self.destinationTitleLabel = dictionary["destinationTitle"] as? String ?? ""
        self.destinationAddressLabel = dictionary["destinationAddressx"] as? String ?? ""
        
        self.driverUID = dictionary["driverUID"] as? String ?? ""
        
        if let state = dictionary["state"] as? Int {
            self.state = TripState(rawValue: state)
        }
    }
}

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
}

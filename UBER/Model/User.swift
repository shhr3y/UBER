//
//  User.swift
//  UBER
//
//  Created by Shrey Gupta on 07/07/20.
//  Copyright © 2020 Shrey Gupta. All rights reserved.
//
import CoreLocation

enum AccountType: Int{
    case passenger
    case driver
}

struct User {
    let uid: String
    let fullname: String
    let email: String
    var accountType: AccountType!
    var location: CLLocation?
    
    var homeLocation: String?
    var workLocation: String?
    
    var previousTrip: [String: Any]?
    
    var firstInitial: String { return String(fullname.prefix(1))}

    init(uid:String, dictionary: [String: Any]) {
        self.uid = uid
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        
        if let home = dictionary["homeLocation"] as? String {
            self.homeLocation = home
        }
        
        if let work = dictionary["workLocation"] as? String {
            self.workLocation = work
        }
        
        if let index = dictionary["accountTypeIndex"] as? Int {
            self.accountType = AccountType(rawValue: index)!
        }
        
        if let previousTrips = dictionary["previousTrip"] as? [String: Any] {
            self.previousTrip = previousTrips
        }
    }
}

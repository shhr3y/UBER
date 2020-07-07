//
//  DriverAnnotation.swift
//  UBER
//
//  Created by Shrey Gupta on 07/07/20.
//  Copyright © 2020 Shrey Gupta. All rights reserved.
//

import MapKit

class DriverAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var uid: String
    
    init(uid: String, coordinate: CLLocationCoordinate2D) {
        self.uid = uid
        self.coordinate = coordinate
    }
    
    func updateAnnotationLocation(withCoordinate coordinate: CLLocationCoordinate2D ){
        UIView.animate(withDuration: 0.2) {
            self.coordinate = coordinate
        }
        
    }
}

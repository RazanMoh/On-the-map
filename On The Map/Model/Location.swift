//
//  Location.swift
//  On The Map
//
//  Created by Razan on 29/03/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import CoreLocation

struct Location {
    
    let mapString: String
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(latitude, longitude)
    }
}

//
//  User.swift
//  On The Map
//
//  Created by Razan on 26/03/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation

struct User: Codable {
    let userId: String
    let sessionId: String
    let userFirstName: String
    let userLastName: String
    //let objectId: String
    //let userLocationPosted: Bool
}

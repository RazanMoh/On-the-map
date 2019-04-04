//
//  ParseClient.swift
//  On The Map
//
//  Created by Razan on 26/03/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import CoreLocation

class ParseClient{
    
    static let appId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    static let forHTTPHeaderFieldAppId = "X-Parse-Application-Id"
    static let forHTTPHeaderFieldApiKey = "X-Parse-REST-API-Key"
    static let baseUrl = "https://parse.udacity.com/parse/classes/StudentLocation"

    static func getStudentLocations(completion: @escaping (LocationsContainer?)->Void){
        var studentLocations: [StudentLocation] = []
        var request = URLRequest(url: URL(string: "\(baseUrl)?limit=1")!)
        request.addValue(appId, forHTTPHeaderField: forHTTPHeaderFieldAppId)
        request.addValue(apiKey, forHTTPHeaderField: forHTTPHeaderFieldApiKey)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            if let json = try? JSONSerialization.jsonObject(with: data!, options: []),
                let dict = json as? [String:Any],
                let results = dict["results"] as? [Any] {

                results.forEach {
                    let data = try! JSONSerialization.data(withJSONObject: $0)
                    let studentLocation = try! JSONDecoder().decode(StudentLocation.self, from: data)
                    studentLocations.append(studentLocation)
                    print($0)
                }
            }
            DispatchQueue.main.async {
                completion(LocationsContainer(studentLocations: studentLocations))
            }
        }
        task.resume()
    }
    
    static func postStudentLocations(uniqueKey: String, firstName: String, lastName: String, locationName: String, link: String, coordinate:CLLocationCoordinate2D, completion: @escaping (_ result: [String:AnyObject]?, _ success: Bool, _ error: String?) -> Void){
        var request = URLRequest(url: URL(string: "\(baseUrl)")!)
        request.httpMethod = "POST"
        request.addValue(appId, forHTTPHeaderField: forHTTPHeaderFieldAppId)
        request.addValue(apiKey, forHTTPHeaderField: forHTTPHeaderFieldApiKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(locationName)\", \"mediaURL\": \"\(link)\",\"latitude\": \(coordinate.latitude), \"longitude\": \(coordinate.longitude)}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let parsedResult: AnyObject!
            
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as AnyObject!
            } catch {
                completion(nil, false, "There was an error parsing JSON")
                return
            }
            print(String(data: data!, encoding: .utf8)!)
            
            DispatchQueue.main.async {
                completion((parsedResult as! [String : AnyObject]),true, nil)
            }
        }
        task.resume()
    }
}

//
//  UdacityClient.swift
//  On The Map
//
//  Created by Razan on 29/03/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation

class UdacityClient {
    
    static let baseUrl = "https://onthemap-api.udacity.com/v1"
    static var sessionId:String!
    static var accountKey:String!
    
    static func login(email: String, password: String, completion: @escaping (_ accountKey: Any?, _ sessionId: Any?,_ success: Bool, _ error: String?) -> Void){
        var request = URLRequest(url: URL(string: "\(baseUrl)/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // encoding a JSON body from a string, can also use a Codable struct
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            
            let newData = data?.subdata(in: Range(5..<data!.count)) /* subset response data! */
            print(String(data: newData!, encoding: .utf8)!)
            
            // Parse the JSON data into a dictionary
            let parsedData: [String : AnyObject]!
            do {
                parsedData = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as? [String : AnyObject]
            } catch {
                completion(nil, nil, false, "POST request: Could not parse the JSON data")
                return
            }

            guard let sessionDictionary = parsedData["session"] as? [String : AnyObject] else {
                completion(nil, nil, false, "Wrong email or password")
                return
            }
            
            guard let sessionId = sessionDictionary["id"] as? String else {
                completion(nil, nil, false, "Wrong email or password")
                return
            }
            
            guard let accountDictionary = parsedData["account"] as? [String : AnyObject] else {
                completion(nil, nil, false, "Wrong email or password")
                return
            }
            
            guard let accountKey = accountDictionary["key"] as? String else {
                completion(nil, nil, false, "Wrong email or password")
                return
            }
            
            self.sessionId = sessionId
            self.accountKey = accountKey
            
            completion(accountKey, sessionId, true, nil)

        }
        task.resume()
    }
    
    static func logout(completion: @escaping (_ success: Bool, _ error: String?) -> Void){
        var request = URLRequest(url: URL(string: "\(baseUrl)/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                return
                    completion( false, error as! String)
            }
            let newData = data?.subdata(in: Range(5..<data!.count)) /* subset response data! */
            print(String(data: newData!, encoding: .utf8)!)
            DispatchQueue.main.async {
                completion( true, nil)
            }
        }
        task.resume()
    }
    
    
    
    static func getUser(completion: @escaping (_ firstName: Any?, _ lastName: Any?, _ accountKey: Any?,_ success: Bool, _ error: String?) -> Void){
        let request = URLRequest(url: URL(string: "\(baseUrl)/users/\(self.accountKey!)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil { // Handle error...
                return
            }
            let newData = data?.subdata(in: Range(5..<data!.count)) /* subset response data! */
            // Parse the JSON data into a dictionary
            let parsedData: [String : AnyObject]!
            do {
                parsedData = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as? [String : AnyObject]
            } catch {
                completion(nil, nil, nil, false, "POST request: Could not parse the JSON data")
                return
            }
            guard let firstName = parsedData["first_name"] as? String else {
                completion(nil, nil, nil, false, "POST request: Could not find the \"first_name\" key in the JSON data")
                return
            }
            
            guard let lastName = parsedData["last_name"] as? String else {
                completion(nil, nil, nil, false, "POST request: Could not find the \"last_name\" key in the JSON data")
                return
            }
            completion(firstName, lastName, self.accountKey, true, nil)

        }
        task.resume()
    }
    
}

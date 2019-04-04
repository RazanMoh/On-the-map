//
//  ViewController.swift
//  PinSample
//
//  Created by Jason on 3/23/15.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    //var loginUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStudentsLocations()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    /*func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            
            if let toOpen = view.annotation?.subtitle!,
                let url = URL(string: toOpen), app.canOpenURL(url) {
                app.open(url, options: [:], completionHandler: nil)
            
            }
        }
        
    }*/
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
    
            if let toOpen = view.annotation?.subtitle!,
                let url = URL(string: toOpen), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            else{
                self.showAlert(msg: "Incorrect URL")
            }
            
        }
    }
    
    func loadStudentsLocations() {
        ParseClient.getStudentLocations { (data) in
            guard let data = data else {
                self.showAlert(msg: "No internet connection found")
                print("No internet connection found")
                return
            }
            guard data.studentLocations.count > 0 else {
                self.showAlert(msg: "No locations found")
                return
            }
        
        let locations = data.studentLocations
        var annotations = [MKPointAnnotation]()
        
        for dictionary in locations {
            let coordinate = CLLocationCoordinate2D(latitude: dictionary.latitude, longitude: dictionary.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(dictionary.firstName) \(dictionary.lastName)"
            annotation.subtitle = dictionary.mediaURL
            annotations.append(annotation)
        }
        
        self.mapView.addAnnotations(annotations)
    }
    }
    
    func showAlert(msg: String) {
        let alertVC = UIAlertController(title: "Load Failed", message: msg, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    
    @IBAction func onRefresh(_ sender: Any) {
        loadStudentsLocations()
    }
    
    @IBAction func onLogout(_ sender: Any) {
        print("onLogout")
        UdacityClient.logout() { (success, error) in
            if success {
               self.showAlert(msg: "you have loagged out seccessful")
                self.performSegue(withIdentifier: "logout", sender: self)
            } else {
                self.showAlert(msg: error!)
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logout"{
           let destVC : LoginViewController = segue.destination as! LoginViewController
        }
    }
}

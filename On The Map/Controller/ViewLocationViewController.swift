//
//  ViewLocationViewController.swift
//  On The Map
//
//  Created by Razan on 29/03/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewLocationViewController: UIViewController, MKMapViewDelegate {

    var coordinate = CLLocationCoordinate2D()
    var locationName = ""
    var link = ""
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var finishButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        placePin()
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            
            if let toOpen = view.annotation?.subtitle!,
                let url = URL(string: toOpen), app.canOpenURL(url) {
                app.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    private func placePin(){
        let coordinate = CLLocationCoordinate2D(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = locationName
        self.mapView.addAnnotation(annotation)
    }
    @IBAction func onBack(_ sender: Any) {
         dismiss(animated: true, completion: nil)
    }
   
    @IBAction func onFinish(_ sender: Any) {
        UdacityClient.getUser { (firstName, lastName, uniqueKey, success, error) in
            if success {
                self.postStudentLocation(firstName: firstName as! String, lastName: lastName as! String, uniqueKey: uniqueKey as! String)
            }
            else {
                self.showAlert(msg: error!)
            }
        }
    }
    
    func postStudentLocation(firstName:String, lastName:String, uniqueKey:String) {
        print("ttt\(uniqueKey)")
        ParseClient.postStudentLocations(uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, locationName: locationName, link: self.link, coordinate: self.coordinate) { (data, success, error)   in
            guard let data = data else {
                self.showAlert(msg: "No internet connection found")
                return
            }
            self.showLoadingState(isLoading: false)
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "passData", sender: self)
            }
        }
    }
    
    private func showLoadingState(isLoading: Bool) {
        finishButton.isEnabled = !isLoading
        activityIndicator.isHidden = !isLoading
        
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func showAlert(msg: String) {
        let alertVC = UIAlertController(title: "Load Failed", message: msg, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "passData"{
            let tabCtrl: UITabBarController = segue.destination as! UITabBarController
            let destinationVC = tabCtrl.viewControllers![0] as! MapViewController
        }
    }
}

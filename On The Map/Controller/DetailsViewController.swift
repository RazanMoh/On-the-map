//
//  DetailsViewController.swift
//  On The Map
//
//  Created by Razan on 29/03/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import CoreLocation

class DetailsViewController: UIViewController {


    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var coordinate = CLLocationCoordinate2D()
    var locationName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showLoadingState(isLoading: false)
        locationTextField.text = ""
        linkTextField.text = ""
        
    }
    
    @IBAction func onFindLocation(_ sender: Any) {
        guard let location = locationTextField.text , !location.isEmpty else {
            showLoadingState(isLoading: false)
            displaySearchFailure(msg: "The location is empty :(")
            return
        }
        
        guard let link = linkTextField.text , !link.isEmpty else {
            showLoadingState(isLoading: false)
            displaySearchFailure(msg: "The link is empty :(")
            return
        }
        showLoadingState(isLoading: true)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func displaySearchFailure(msg: String) {
        let alertVC = UIAlertController(title: "Search Failed", message: msg, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    
    private func showLoadingState(isLoading: Bool) {
        searchButton.isEnabled = !isLoading
        activityIndicator.isHidden = !isLoading
        
        if isLoading {
           activityIndicator.startAnimating()
            searchLocation()
        } else {
           activityIndicator.stopAnimating()
        }
    }
    private func searchLocation(){
    
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(locationTextField.text!) { (placemarks, error) in
            
            if error != nil {
                self.showAlert(msg:"Can't find location")
                self.showLoadingState(isLoading: false)
            } else {
                let placemark = placemarks?.first
                
                if let placemark = placemark {
                    self.coordinate = (placemark.location?.coordinate)!
                    self.locationName = placemark.name!
                    
                    self.performSegue(withIdentifier: "sendData", sender: self)
                    
                } else {
                    self.showAlert(msg:"No matches were found")
                }
            }
        }
    }
    
    func showAlert(msg: String) {
        let alertVC = UIAlertController(title: "Search Failed", message: msg, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendData"{
        let destVC : ViewLocationViewController = segue.destination as! ViewLocationViewController
        destVC.coordinate = self.coordinate
        destVC.locationName = self.locationName
        destVC.link = self.linkTextField.text!
        }
    }

}

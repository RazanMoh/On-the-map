//
//  ViewController.swift
//  On The Map
//
//  Created by Razan on 26/03/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var loginUser: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         activityIndicator.isHidden = true
        showLoadingState(isLoading: false)
        emailTextField.text = ""
        passwordTextField.text = ""
    }

    @IBAction func onLogin(_ sender: Any) {
        guard let email = emailTextField.text , !email.isEmpty else {
            showLoadingState(isLoading: false)
            displayLoginFailure(msg: "The email is empty :(")
            return
        }
        
        guard let password = passwordTextField.text , !password.isEmpty else {
            showLoadingState(isLoading: false)
            displayLoginFailure(msg: "The password is empty :(")
            return
        }
        showLoadingState(isLoading: true)
        
        UdacityClient.login(email: email, password: password) { (accountKey, sessionId, success, error) in
             if success {
                DispatchQueue.main.async {self.performSegue(withIdentifier: "login", sender: self)}
            }
             else {
                DispatchQueue.main.async {self.showAlert(msg: error!)}
                self.showLoadingState(isLoading: false)
            }
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        if let link = URL(string: "https://www.udacity.com/account/auth#!/signup") {
            UIApplication.shared.open(link)
        }
    }
    
    func displayLoginFailure(msg: String) {
        let alertVC = UIAlertController(title: "Login Failed", message: msg, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
    
    private func showLoadingState(isLoading: Bool) {
        loginButton.isEnabled = !isLoading
        activityIndicator.isHidden = !isLoading
        
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "login"{
            let tabCtrl: UITabBarController = segue.destination as! UITabBarController
            let destinationVC = tabCtrl.viewControllers![0] as! MapViewController
        }
    }
    
    func showAlert(msg: String) {
        let alertVC = UIAlertController(title: "Load Failed", message: msg, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        show(alertVC, sender: nil)
    }
}

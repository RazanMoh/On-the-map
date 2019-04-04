//
//  TableViewController.swift
//  On The Map
//
//  Created by Razan on 26/03/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var table: UITableView!
    
    var studentsLocations = [StudentLocation]()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadStudentsLocations()
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
            
            self.studentsLocations = data.studentLocations
            self.table.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return self.studentsLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell =  table.dequeueReusableCell(withIdentifier: "locationCell") as! TableViewCell
        let studentLocation = self.studentsLocations[(indexPath as NSIndexPath).row]
        print(studentLocation.firstName)
        
        cell.label.text = studentLocation.firstName+" "+studentLocation.lastName
        cell.link.text = studentLocation.mediaURL
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRow = tableView.cellForRow(at: indexPath) as! TableViewCell
        if let toOpen = selectedRow.link.text,
            let url = URL(string: toOpen), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        else{
            self.showAlert(msg: "Incorrect URL")
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
        UdacityClient.logout() { (success, error) in
            if success {
                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
                {
                    self.present(vc, animated: true, completion: nil)
                }

            } else {
                self.showAlert(msg: error!)
            }
        }
    }
}

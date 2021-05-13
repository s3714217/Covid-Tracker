//
//  ViewController.swift
//  CovidApp
//
//  Created by Thien Nguyen on 3/8/20.
//  Copyright © 2020 A1_Group_3. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UITabBarDelegate{
    
    @IBOutlet weak var dataNotify: UILabel!
    private var country: [String] = []
    private var cellReuseIdentifier = "cell"
    private var blurEffect : UIBlurEffect = .init()
    private var blurEffectView : UIVisualEffectView = .init()
    
    
    @IBOutlet private weak var titleBar: UINavigationBar!
    @IBOutlet private weak var popOver: UIView! //pop over window
    @IBOutlet private weak var internetPopOver: UIView!
    @IBOutlet private weak var noInternetNoBackupPopOver: UIView!
    @IBOutlet private weak var tabBar: UITabBar! // nav bar
    @IBOutlet private weak var tableView: UITableView! // subscription list
    @IBOutlet weak var refresh: UIBarButtonItem!
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        //update country list with subscribe countries
        self.country = []
        for report in UD.subscribed_report{
            self.country.append(report.country)
        }
        //Register the cell to table View
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tabBar.delegate = self
        //darkMode()
        
        
        if !appHasLoaded{
            // Check if either internetIsOn and/or serverIsOn is false
            if !internetIsOn && usingBackupData{
                // Backup data is avilable and will be used instead of fresh data
                blurEffect = UIBlurEffect(style: .dark)
                blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.frame = self.view.bounds
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                blurEffectView.backgroundColor = .clear
                view.addSubview(blurEffectView)
                internetPopOver.layer.cornerRadius = 30
                //adding the popover and blur effect
                self.view.addSubview(internetPopOver)
                self.internetPopOver.center = self.view.center
                // 'Cannot connect to server, will continue using the app with Backup'
            }
                // If no internet, no coredata
            else if !internetIsOn && !defaults.bool(forKey: "Backup"){
                // A connection error occured please try again
                
                blurEffect = UIBlurEffect(style: .dark)
                blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.frame = self.view.bounds
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                blurEffectView.backgroundColor = .clear
                view.addSubview(blurEffectView)
                noInternetNoBackupPopOver.layer.cornerRadius = 30
                //adding the popover and blur effect
                self.view.addSubview(noInternetNoBackupPopOver)
                self.noInternetNoBackupPopOver.center = self.view.center
                
            }
        }
        
        appHasLoaded = true

    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.country.count
    }
    
    
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)!
        cell.textLabel?.text = "\(UD.getFlagIcon(country: self.country[indexPath.row])) \(self.country[indexPath.row])"
        cell.backgroundColor = .clear
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .darkGray
        return cell
        //setting the label for each cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewing_country = country[indexPath.row]
        lastPage = "home"
        self.performSegue(withIdentifier: "toProfile", sender: self)
        //take user to the profile page when a country is selected
    }
    
    internal func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //allow user to delete a country from the list quickly
        if editingStyle == .delete {
            UD.unsubscribe(country:country[indexPath.row])
            country.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
   
    
    internal func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    //Tab bar navigation button action
    
    if item.title == "Ranking"{
        self.performSegue(withIdentifier: "toRank", sender: self)
    }
    else if item.title == "Search"{
        self.performSegue(withIdentifier: "toSearch", sender: self)
    }

    else if item.title == "Stats Map"{
        self.performSegue(withIdentifier: "toMap", sender: self)
    }
   }
  
    @IBAction private func disappear(_ sender: Any) {
        //Removing all effect and popover when the done button is loaded
        self.popOver.removeFromSuperview()
        blurEffectView.removeFromSuperview()
    }
    @IBAction func `continue`(_ sender: UIButton) {
        self.internetPopOver.removeFromSuperview()
        blurEffectView.removeFromSuperview()
    }

    
    @IBAction func tryAgainButton(_ sender: UIButton) {
        UD.createDefaultReport()
        
        self.noInternetNoBackupPopOver.removeFromSuperview()
        blurEffectView.removeFromSuperview()
        
    }
    
    
    @IBAction private func refresh(_ sender: Any) {
       
        UD.update()
        blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.backgroundColor = .clear
        view.addSubview(blurEffectView)
        popOver.layer.cornerRadius = 30
        //adding the popover and blur effect
        self.view.addSubview(popOver)
        self.popOver.center = self.view.center
        
        if !serverIsOn || !internetIsOn{
            self.dataNotify.text = "Update Failed"
        }
       
    }
    
 
    @IBAction func viewCredit(_ sender: Any) {
        self.performSegue(withIdentifier: "toCredits", sender: self)
    }
}


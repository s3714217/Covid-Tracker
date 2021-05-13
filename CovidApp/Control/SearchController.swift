//
//  SearchController.swift
//  CovidApp
//
//  Created by Thien Nguyen on 22/8/20.
//  Copyright © 2020 A1_Group_3. All rights reserved.
//

import UIKit

class SearchController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate, UITabBarDelegate{
    
    private var country: [String] = []
    private var cellReuseIdentifier = "cell"
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var tabBar: UITabBar!
    @IBOutlet private var titleBar: UINavigationBar!
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        //Getting all report from Model
        for report in UD.all_report{
            country.append(report.country)
        }
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        tabBar.delegate = self
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.country.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)!
        cell.textLabel?.text = "\(UD.getFlagIcon(country: self.country[indexPath.row])) \(self.country[indexPath.row])"
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .darkGray
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewing_country = country[indexPath.row]
        self.performSegue(withIdentifier: "toProfile", sender: self)
        lastPage = "search"
        
    }
    
    internal func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
     
     
     if item.title == "Home"{
         self.performSegue(withIdentifier: "toHome", sender: self)
     }
     else if item.title == "Ranking"{
         self.performSegue(withIdentifier: "toRank", sender: self)
     }
     else if item.title == "Stats Map"{
        self.performSegue(withIdentifier: "toMap", sender: self)
    }
     
    }
    
    internal func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //Search functionality
        country = []
        for result in UD.all_report{
            if result.country.lowercased().contains(searchText.lowercased()){
                country.append(result.country)
            }
        }
        tableView.reloadData()
    }
    
    
    
}

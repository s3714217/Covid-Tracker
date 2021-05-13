//
//  CreditsController.swift
//  CovidApp
//
//  Created by Thien Nguyen on 6/9/20.
//  Copyright © 2020 A1_Group_3. All rights reserved.
//

import UIKit

class CreditsController: UIViewController, UITabBarDelegate {

    @IBOutlet weak var titleBar: UINavigationBar!
    @IBOutlet weak var tabBar: UITabBar!
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        tabBar.delegate = self
       
       
    }
    internal func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        
       if item.title == "Home"{
            self.performSegue(withIdentifier: "toHome", sender: self)
        }
        else if item.title == "Ranking"{
            self.performSegue(withIdentifier: "toRank", sender: self)
        }
        else if item.title == "Search"{
            self.performSegue(withIdentifier: "toSearch", sender: self)
        }
        else if item.title == "Stats Map"{
            self.performSegue(withIdentifier: "toMap", sender: self)
        }
    }
    
    @IBAction func onPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "toHome", sender: self)
        
    }
    
}

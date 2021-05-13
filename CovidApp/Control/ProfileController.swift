//
//  ProfileController.swift
//  CovidApp
//
//  Created by Thien Nguyen on 17/8/20.
//  Copyright © 2020 A1_Group_3. All rights reserved.
//

import UIKit
import Charts

class ProfileController: UIViewController, UITabBarDelegate{

    @IBOutlet private weak var pieChart: PieChartView!
    @IBOutlet private weak var tabBar: UITabBar!
    @IBOutlet private weak var titleBar: UINavigationBar!
    @IBOutlet private weak var Country: UILabel!
    @IBOutlet private weak var Subscribe: UIButton!
    @IBOutlet private weak var Total: UILabel!
    @IBOutlet private weak var Recovered: UILabel!
    @IBOutlet private weak var Death: UILabel!
    @IBOutlet private weak var Active: UILabel!
    
    private var custom_green = UIColor.init(displayP3Red: 0, green: 0.7, blue: 0, alpha: 1)
    private var custom_cyan = UIColor.init(displayP3Red: 0, green: 0.7, blue: 0.7, alpha: 1)
    
    private var subbed = false
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        tabBar.delegate = self
        if viewing_country.count == 0{
            //Set the default country to Australia
            Country.text = "No country selected"
            Subscribe.setTitle("", for: .normal)
            Subscribe.isEnabled = false
        }
        else
        {
            let report = UD.get_report(country: viewing_country)
            Country.text = "\(UD.getFlagIcon(country: report.country_code)) \(viewing_country)"
            if UD.isSubscribed(country: viewing_country){
                //Displaying subscribe or unsubscribe button
                Subscribe.setTitle("Unsubscribe", for: .normal)
                subbed = true
            }
            //Setting the statistic for the profile page
            let active = report.total_confirmed - report.total_deaths - report.total_recovered
            Death.text = "Deaths: \(report.total_deaths) cases"
            Death.backgroundColor = .darkGray
            Death.layer.cornerRadius = 30
            Recovered.text = "Recovered: \(report.total_recovered) cases"
            Recovered.backgroundColor = self.custom_green
            Active.text = "Active: \(active) cases"
            Active.backgroundColor = .red
            
            let variables = ["Deaths", "Recovered", "Active"]
            let total = [Double(report.total_deaths),Double(report.total_recovered),Double(active)]
            
            setChart(dataPoints: variables, values: total)
        }
    }
    
    @IBAction private func pressedSubscribe(_ sender: Any) {
        if subbed{
            UD.unsubscribe(country: viewing_country)
        }
        else{
            UD.subscribe(report: UD.get_report(country: viewing_country))
        }
        self.performSegue(withIdentifier: "toHome", sender: self)
    }
    private func setChart(dataPoints: [String], values: [Double]) {
        //Configuring Pie Chart
        self.pieChart.legend.enabled = false
        self.pieChart.animate(xAxisDuration: 2)
        
        var dataEntries: [ChartDataEntry] = []
        var total :Double = 0.0
        
        for i in 0..<dataPoints.count {
          let dataEntry1 = PieChartDataEntry(value: values[i], label: dataPoints[i], data:  dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry1)
            total += values[i]
        }
        //Setting the confirmed cases
        
        Total.text = "Confirmed: \(Int(total)) cases"
        
        Total.backgroundColor = self.custom_cyan
        Total.layer.cornerRadius = 20
        
        let pieChartDataSet = PieChartDataSet(entries: dataEntries)
        //Configuring Pie Chart Data
        pieChartDataSet.sliceSpace = 5
        pieChartDataSet.drawValuesEnabled = false
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChart.data = pieChartData
        pieChart.drawEntryLabelsEnabled = false
        let colors: [UIColor] = [UIColor.darkGray, self.custom_green, UIColor.red]
        pieChartDataSet.colors = colors
    }
    
    
    internal func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
     
     if item.title == "Home"{
         self.performSegue(withIdentifier: "toHome", sender: self)
         viewing_country = ""
     }
     else if item.title == "Search"{
         self.performSegue(withIdentifier: "toSearch", sender: self)
         viewing_country = ""
     }
     else if item.title == "Ranking"{
         self.performSegue(withIdentifier: "toRank", sender: self)
         viewing_country = ""
     }
     else if item.title == "Stats Map"{
        self.performSegue(withIdentifier: "toMap", sender: self)
        viewing_country = ""
    }
     
  }
    @IBAction func onPressed(_ sender: UIBarButtonItem) {
        if lastPage == "home" {
            self.performSegue(withIdentifier: "toHome", sender: self)
        }
        else if lastPage == "search"{
            self.performSegue(withIdentifier: "toSearch", sender: self)
        }
        else if lastPage == "rank"{
            self.performSegue(withIdentifier: "toRank", sender: self)
        }
        
    }
    
}

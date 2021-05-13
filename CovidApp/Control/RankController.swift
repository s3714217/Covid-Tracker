//
//  RankController.swift
//  CovidApp
//
//  Created by Thien Nguyen on 4/8/20.
//  Copyright © 2020 A1_Group_3. All rights reserved.
//

import UIKit
import Charts
class RankController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {
    
    @IBOutlet private weak var barChartView: BarChartView!
    @IBOutlet private weak var tabBar: UITabBar!
    @IBOutlet private weak var rankingTable: UITableView!
    @IBOutlet private weak var titleBar: UINavigationBar!
    
    private var cellReuseIdentifier = "cell"
    private var country: [String] = []
    private var value: [Double] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //Register the Table cell
        self.rankingTable.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.rankingTable.delegate = self
        self.rankingTable.dataSource = self
        self.tabBar.delegate = self
        let top_10 = UD.get_top10()
        //Getting top 10 countries from the Model
        for x in 0...9{
            self.value.append(Double(top_10[x].total_confirmed))
            self.country.append(top_10[x].country)
       }
        //darkMode()
        self.setChart()
        //Setting the bar chart
    }
    
    
    private func setChart() {
        
        //Configuring bar chart
        self.barChartView.xAxis.enabled = false
        self.barChartView.rightAxis.enabled = false
        self.barChartView.leftAxis.drawGridLinesEnabled = false
        self.barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        self.barChartView.legend.enabled = false
        self.barChartView.leftAxis.labelTextColor = .darkGray
        var dataEntries: [BarChartDataEntry] = []
        var DataSet : [BarChartDataSet] = []
        
        //Configuring and passing data to the BarChartDataSet
        for i in 0...9{
            dataEntries.append(BarChartDataEntry(x: Double(i+1), y:value[i] ))
            let set :  BarChartDataSet = BarChartDataSet(entries: dataEntries, label: country[i])
            set.setColor(UIColor.red)
            set.valueTextColor = .darkGray
            DataSet.append(set)
        }
        
        let chartData = BarChartData(dataSets: DataSet)
        //chartData.drawValuesEnabled = true
    
        barChartView.data = chartData
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.country.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.rankingTable.dequeueReusableCell(withIdentifier: cellReuseIdentifier)!
        cell.textLabel?.textAlignment = .center
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .darkGray
        cell.textLabel?.text = " \(indexPath.row+1). \(UD.getFlagIcon(country: self.country[indexPath.row])) \(self.country[indexPath.row])"
        //Configuring the cell
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewing_country = country[indexPath.row]
        lastPage = "rank"
        self.performSegue(withIdentifier: "toProfile", sender: self)
        //Performing segue when a country is selected
    }
    
    internal func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
     
    //Performing segue when an item on the nav bar is selected
     if item.title == "Home"{
         self.performSegue(withIdentifier: "toHome", sender: self)
     }
     else if item.title == "Search"{
         self.performSegue(withIdentifier: "toSearch", sender: self)
     }
     
     else if item.title == "Stats Map"{
        self.performSegue(withIdentifier: "toMap", sender: self)
       
     }
    }
   
 
}

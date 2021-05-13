//
//  UserData.swift
//  CovidApp
//
//  Created by Thien Nguyen on 21/8/20.
//  Copyright © 2020 A1_Group_3. All rights reserved.
//

import Foundation

public class UserData {
    
    public var all_report: [Report] = []
    public var subscribed_report: [Report] = [] //ignore this for now
    private var top_10: [Report] = []
    public var cds:CoreDataService = CoreDataService()
    public let defaults = UserDefaults.standard
    
    public init() {
        self.getJsonResponse()
        self.subscribed_report = cds.loadReport()
        
        if internetIsOn && self.all_report.count < 1{
            serverIsOn = false
        }
        
        if self.all_report.count == 0 && self.cds.loadBackupReport().count != 0 {
            print ("Loading BackupData")
            usingBackupData = true
            self.all_report = cds.loadBackupReport()
        }
    }
    
    public func subscribe(report :Report){
        subscribed_report.append(report)
        cds.addReport(report:report)
    }
    
    //todo: unit testing
    public func unsubscribe(country :String) {
        //unsub a country (remove from sub list)
        let range = self.subscribed_report.count-1
        for x in 0...range{
            if self.subscribed_report[x].country == country{
                self.subscribed_report.remove(at: x)
                break
            }
            
        }
        cds.deleteReport(report: self.get_report(country: country))
    }

    //todo: unit testing
    public func isSubscribed(country:String) ->Bool{
        for report in self.subscribed_report{
            if report.country == country{
                return true
            }
        }
        return false
    }
    
    //todo: unit testing
    public func get_report(country :String) ->Report{
        //get report based on country name
        for report in self.all_report{
            if report.country == country{
                return report
            }
        }
        let empty = Report()
        return empty
    }
    
    //todo: unit testing
    public func getFlagIcon(country: String) ->String{
        var proc_code = ""
        if country.count > 2{
        //find the code when a country name was passed instead
            for report in all_report{
                if report.country == country{
                   proc_code = report.country_code
                    break
                }
            }
        }
        else{
            proc_code = country
        }
        //translate to unicode symbol
        let base = 127397
        var usv = String.UnicodeScalarView()
        for i in proc_code.utf16 {
            usv.append(UnicodeScalar(base + Int(i))!)
        }
        return String(usv)
    }
    
    //todo: unit testing
    public func get_top10() -> [Report]{
        if self.top_10.count != 10{
            self.sort()
        }
        return self.top_10
    }
    
    //todo: implementing/ unit testing
    
    public func update(){
        let backup_report = self.all_report
        self.all_report = []
        self.subscribed_report = []
        self.top_10 = []
        
        self.getJsonResponse()
        
        if all_report.count < 1{
            if internetIsOn{
                serverIsOn = false
            }
            all_report = backup_report
        }
        
        self.subscribed_report = cds.loadReport()
    }
    
    
    //todo: unit testing
    public func getJsonResponse(){
        let semaphore = DispatchSemaphore (value: 0)
        var request = URLRequest(url: URL(string: "https://api.covid19api.com/summary")!,timeoutInterval: 5.0)
        request.addValue("http://localhost", forHTTPHeaderField: "Origin")
        request.httpMethod = "GET"
        
        var isBackedUp = false
        
        if self.cds.loadBackupReport().count != 0 {
            isBackedUp = true
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            guard let data = data else {
                print(String(describing: error))
                semaphore.signal()
                internetIsOn = false
                return
            }
            internetIsOn = true
            if let json = (try? JSONSerialization.jsonObject(with: data)) as? Dictionary<String,Any> {
                if let list = json["Countries"] as? [Any]{
                    for x in 0...list.count-1 {
                        if let temp = list[x] as? Dictionary<String,Any>{
                            let temp_report = Report(country:temp["Country"] as! String,
                                                     country_code:temp["CountryCode"] as! String,
                                                     slug:temp["Slug"] as! String,
                                                     new_confirmed:temp["NewConfirmed"] as! Int64,
                                                     total_confirmed:temp["TotalConfirmed"] as! Int64,
                                                     new_deaths:temp["NewDeaths"] as! Int64,
                                                     total_deaths:temp["TotalDeaths"] as! Int64,
                                                     new_recovered:temp["NewRecovered"] as! Int64,
                                                     total_recovered:temp["TotalRecovered"] as! Int64,
                                                     date:temp["Date"] as! String)
                            self.all_report.append(temp_report)
                            
                            if isBackedUp {
                                self.cds.updateBackupReport(report: temp_report)
                            }
                            else{
                                self.cds.addBackupReport(report: temp_report)
                                self.defaults.set(true, forKey: "Backup")
                            }
                        }
            
                    }
                }
               
            }
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
    }
    
    private func sort(){
        var temp:[Report] = self.all_report
        var currentHighestTotal:Int64
        var reportNumber:Int = 0
        while top_10.count < 10{
            currentHighestTotal = 0
            for x in 0...temp.count-1{
                if(temp[x].total_confirmed > currentHighestTotal){
                    currentHighestTotal = temp[x].total_confirmed
                    reportNumber = x
                }
            }
            
            self.top_10.append(temp[reportNumber])
            temp.remove(at: reportNumber)
            
        }
    }
    
    public func createDefaultReport(){
        let report1 = Report(country:"Australia",
                            country_code:"AU",
                            slug:"australia",
                            new_confirmed:25,
                            total_confirmed:27206,
                            new_deaths:0,
                            total_deaths:897,
                            new_recovered:22,
                            total_recovered:24937,
                            date:"2020-10-08T14:56:21Z")
        
        let report2 = Report(country:"China",
                             country_code:"CN",
                             slug:"china",
                             new_confirmed:20,
                             total_confirmed:90687,
                             new_deaths:0,
                             total_deaths:4739,
                             new_recovered:22,
                             total_recovered:85588,
                             date:"2020-10-08T14:56:21Z")
        
        let report3 = Report(country:"Denmark",
                             country_code:"DK",
                             slug:"denmark",
                             new_confirmed:333,
                             total_confirmed:31201,
                             new_deaths:0,
                             total_deaths:663,
                             new_recovered:585,
                             total_recovered:24706,
                             date:"2020-10-08T14:56:21Z")
        
        let report4 = Report(country:"Germany",
                             country_code:"DE",
                             slug:"germany",
                             new_confirmed:4010,
                             total_confirmed:311137,
                             new_deaths:16,
                             total_deaths:9582,
                             new_recovered:1975,
                             total_recovered:269722,
                             date:"2020-10-08T14:56:21Z")
        
        let report5 = Report(country:"India",
                             country_code:"IN",
                             slug:"india",
                             new_confirmed:78524,
                             total_confirmed:6835655,
                             new_deaths:971,
                             total_deaths:105526,
                             new_recovered:83011,
                             total_recovered:5827704,
                             date:"2020-10-08T14:56:21Z")
        
        let report6 = Report(country:"Japan",
                             country_code:"JP",
                             slug:"japan",
                             new_confirmed:499,
                             total_confirmed:87039,
                             new_deaths:5,
                             total_deaths:1614,
                             new_recovered:602,
                             total_recovered:79123,
                             date:"2020-10-08T14:56:21Z")
        
        let report7 = Report(country:"Thailand",
                             country_code:"TH",
                             slug:"thailand",
                             new_confirmed:7,
                             total_confirmed:3622,
                             new_deaths:0,
                             total_deaths:59,
                             new_recovered:48,
                             total_recovered:3439,
                             date:"2020-10-08T14:56:21Z")
        
        let report8 = Report(country:"Viet Nam",
                             country_code:"VN",
                             slug:"vietnam",
                             new_confirmed:1,
                             total_confirmed:1099,
                             new_deaths:0,
                             total_deaths:35,
                             new_recovered:0,
                             total_recovered:1023,
                             date:"2020-10-08T14:56:21Z")
        
        let report9 = Report(country:"United Kingdom",
                             country_code:"GB",
                             slug:"united-kingdom",
                             new_confirmed:14173,
                             total_confirmed:546952,
                             new_deaths:70,
                             total_deaths:42605,
                             new_recovered:8,
                             total_recovered:2425,
                             date:"2020-10-08T14:56:21Z")
        
        let report10 = Report(country:"United States of America",
                             country_code:"US",
                             slug:"united-states",
                             new_confirmed:50341,
                             total_confirmed:7549682,
                             new_deaths:915,
                             total_deaths:211801,
                             new_recovered:47505,
                             total_recovered:2999895,
                             date:"2020-10-08T14:56:21Z")
        
        
        
        
        
        
        
        
        
        all_report.append(report1)
        all_report.append(report2)
        all_report.append(report3)
        all_report.append(report4)
        all_report.append(report5)
        all_report.append(report6)
        all_report.append(report7)
        all_report.append(report8)
        all_report.append(report9)
        all_report.append(report10)


    }
}

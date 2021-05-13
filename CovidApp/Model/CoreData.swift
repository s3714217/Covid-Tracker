//
//  CoreData.swift
//  CovidApp
//
//  Created by Thien Nguyen on 27/9/20.
//  Copyright © 2020 A1_Group_3. All rights reserved.
//

import UIKit
import Foundation
import CoreData

public class CoreDataService{
    
    var context : NSManagedObjectContext
    
    init(){
      self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    public func addReport(report: Report){
        
        let newReport = CoreDataReport(context: self.context)
        newReport.country = report.country
        newReport.country_code = report.country_code
        newReport.slug = report.slug
        newReport.new_confirmed = report.new_confirmed
        newReport.total_confirmed = report.total_confirmed
        newReport.new_deaths = report.new_deaths
        newReport.total_deaths = report.total_deaths
        newReport.new_recovered = report.new_recovered
        newReport.total_recovered = report.total_recovered
        newReport.date = report.date
        do{
            try self.context.save()
            print("New Report Saved!")
        }
        catch{
            print("Error when saving")
        }
    }
    
    public func deleteReport(report:Report){
        do{
            let report_list = try self.context.fetch(CoreDataReport.fetchRequest()) as! [CoreDataReport]
            for r in report_list{
                if r.country! == report.country{
                    self.context.delete(r)
                    try self.context.save()
                    break
                }
            }
        }
        catch{
            print("Error when deleting")
        }
        
    }
    
    public func loadReport() -> [Report]{
        var newReport_Arr : [Report] = []
        do{
            let report = try self.context.fetch(CoreDataReport.fetchRequest()) as! [CoreDataReport]
            for r in report{
                let newReport = Report(country: r.country!, country_code: r.country_code!, slug: r.slug!, new_confirmed: r.new_confirmed, total_confirmed: r.total_confirmed, new_deaths: r.new_deaths, total_deaths: r.total_deaths, new_recovered: r.new_recovered, total_recovered: r.total_recovered, date: r.date!)
                newReport_Arr.append(newReport)
            }
            
        }
        catch{
            print("Error when fetching data")
        }
        
        return newReport_Arr
    }
    
    
    // Below are the functions which deal with the backup data reports, copies of the most-recently retrieved data
    public func addBackupReport(report: Report){
        
        let newReport = BackupDataReport(context: self.context)
        newReport.country = report.country
        newReport.country_code = report.country_code
        newReport.slug = report.slug
        newReport.new_confirmed = report.new_confirmed
        newReport.total_confirmed = report.total_confirmed
        newReport.new_deaths = report.new_deaths
        newReport.total_deaths = report.total_deaths
        newReport.new_recovered = report.new_recovered
        newReport.total_recovered = report.total_recovered
        newReport.date = report.date
        do{
            try self.context.save()
        }
        catch{
            print("Error when saving")
        }
    }
    
    public func updateBackupReport(report:Report){
        do{
            let report_list = try self.context.fetch(BackupDataReport.fetchRequest()) as! [BackupDataReport]
            for r in report_list{
                if r.country! == report.country{
                    r.country = report.country
                    r.country_code = report.country_code
                    r.slug = report.slug
                    r.new_confirmed = report.new_confirmed
                    r.total_confirmed = report.total_confirmed
                    r.new_deaths = report.new_deaths
                    r.total_deaths = report.total_deaths
                    r.new_recovered = report.new_recovered
                    r.total_recovered = report.total_recovered
                    r.date = report.date
                    try self.context.save()
                    break
                }
            }
        }
        catch{
            print("Error when updating backup data")
        }
        
    }
    
    public func loadBackupReport() -> [Report]{
        var newReport_Arr : [Report] = []
        do{
            let report = try self.context.fetch(BackupDataReport.fetchRequest()) as! [BackupDataReport]
            
            
            for r in report{
                let newReport = Report(country: r.country!, country_code: r.country_code!, slug: r.slug!, new_confirmed: r.new_confirmed, total_confirmed: r.total_confirmed, new_deaths: r.new_deaths, total_deaths: r.total_deaths, new_recovered: r.new_recovered, total_recovered: r.total_recovered, date: r.date!)
                newReport_Arr.append(newReport)
            }
            
        }
        catch{
            print("Error when fetching backup data")
        }
        
        return newReport_Arr
    }
    
}

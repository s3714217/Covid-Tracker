//
//  CovidAppTests.swift
//  CovidAppTests
//
//  Created by Tingyu Song on 19/9/20.
//  Copyright © 2020 A1_Group_3. All rights reserved.
//

import XCTest
import CoreData
@testable import CovidApp

class CovidAppTests: XCTestCase {
    
    // declare testing object variables
    var coreDataUT:CoreDataService!
    var sut:UserData!
    
    let testData:[String:String]! = [
        "country":"Australia",
        "country_code":"AU",
        "slug":"australia",
        "emoji_flag": "🇦🇺"
    ]
    
    var testCountry:Report! = Report(country:"Australia" ,
                                     country_code:"AU" ,
                                     slug:"australia" ,
                                     new_confirmed:26 ,
                                     total_confirmed:26980 ,
                                     new_deaths:7 ,
                                     total_deaths:861 ,
                                     new_recovered:11 ,
                                     total_recovered:24446 ,
                                     date:"2020-09-24T08:37:59Z" )
    
    let totalCountryCount = 188
    let testTopTenCountryCode:[String]! = [
        "US", "IN", "BR", "RU", "CO", "PE", "MX", "ES", "ZA", "AR"
    ]
    
    override func setUp() {
        // set up testing object
        
        sut = UserData()
        coreDataUT = sut.cds
        continueAfterFailure = false
        
    }
    
    override func tearDown() {
        // reset after each testing case to ensure all testing cases are executed under same context
        do{
            let report_list = try coreDataUT.context.fetch(CoreDataReport.fetchRequest()) as! [CoreDataReport]
            for r in report_list{
                    coreDataUT.context.delete(r)
                    try coreDataUT.context.save()
            }
        }
        catch{
            print("Error when deleting")
        }
        
        sut = nil
        coreDataUT = nil
    }
    
    func testIsSubscribeFunction() {
        // the subscribed report should be empty at the beginning
        // so no country should show as subscribed
        XCTAssert(sut.subscribed_report.count==0)
        // append the test country report to the subscribed list
        sut.subscribed_report.append(testCountry)
        // then it should tell the country is subscribed
        XCTAssert(sut.isSubscribed(country: testCountry.country))
    }
    
    func testUnSubscribeFunction() {
        
        // put test country to subscribed report
        sut.subscribed_report.append(testCountry)
        // perform unsubscribe action
        sut.unsubscribe(country: testCountry.country)
        // check if the report has gone from subscribed list
        XCTAssert(sut.isSubscribed(country: testCountry.country)==false)
    }
    
    func testGetTopTenFunction() {
        // store the top 10 data in the variable to avoid unnecessary API calls to get data
        let topTen:[Report]! = sut.get_top10()
        // the count of top 10 should be 10
        XCTAssert(topTen.count==10)
        // in a loop, check each country code
        
    }
    
    func testFlagiconFunction() {
        // check if the test data country name would show correct emoji
        XCTAssert(sut.getFlagIcon(country: testData["country"]!)==testData["emoji_flag"])
    }
    
    func testJSONResponseFunction() {
        // set the variable to empty array for later writing action
        sut.all_report = []
        // ensure the start status of the all_report is empty
        XCTAssert(sut.all_report.count == 0)
        // call getJsonResponse(), if it works, the all_report should not be empty
        sut.getJsonResponse()
        // check if the all_report is empty
        XCTAssert(sut.all_report.count > 0)
        
    }
    
    func testGetAllReportFunction() {
        // in setup method, it already call and write data into all_report variable
        // only need to test if the total count of the all_report equals 188 (188 countries in total)
        XCTAssert(sut.all_report.count == totalCountryCount)
    }
    
    func testReadingGeoFile(){
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "allcountries", ofType: "geojson")!)
        XCTAssert(url.scheme!=="file")
    }
    
    
    func testCoreDateReading() {
        var reports:[Report] = coreDataUT.loadReport()
        // before add anything, record entity count.
        let count = reports.count
        coreDataUT.addReport(report: testCountry)
        // after added one, there should be 1 entity.
        reports = coreDataUT.loadReport()
        XCTAssert(reports.count==(count + 1))
        
        // the entity main attributes should be equal to the testCountry
        XCTAssert(testCountry.country==reports[count].country)
        XCTAssert(testCountry.new_confirmed==reports[count].new_confirmed)
        XCTAssert(testCountry.new_deaths==reports[count].new_deaths)
        XCTAssert(testCountry.new_recovered==reports[count].new_recovered)
    }
    
    func testCoreDataAddReport() throws{
        var report = try coreDataUT.context.fetch(CoreDataReport.fetchRequest()) as! [CoreDataReport]
        // before add anything, record the count of report.
        let count = report.count
        coreDataUT.addReport(report: testCountry)
        report = try coreDataUT.context.fetch(CoreDataReport.fetchRequest()) as! [CoreDataReport]
        // after add testCountry, there should be 1 more entity.
        XCTAssert(report.count==(count+1))
    }
    
    func testCoreDataDeletion() throws {
        var report = try coreDataUT.context.fetch(CoreDataReport.fetchRequest()) as! [CoreDataReport]
        // before add anything, there should be 0 entity.
        XCTAssert(report.count==0)
        coreDataUT.addReport(report: testCountry)
        report = try coreDataUT.context.fetch(CoreDataReport.fetchRequest()) as! [CoreDataReport]
        // after add testCountry, there should be 1 entity.
        XCTAssert(report.count==1)
        coreDataUT.deleteReport(report: testCountry)
        report = try coreDataUT.context.fetch(CoreDataReport.fetchRequest()) as! [CoreDataReport]
        
        // after deleting testCountry, there should be 0 entity.
        XCTAssert(report.count==0)
    }
}

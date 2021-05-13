//
//  CovidAppUITests.swift
//  CovidAppUITests
//
//  Created by Tingyu Song on 18/9/20.
//  Copyright © 2020 A1_Group_3. All rights reserved.
//

import XCTest

class CovidAppUITests: XCTestCase {

    // declare variables for testing
    var covidApp: XCUIApplication!
    var navBar: XCUIElementQuery!
    var testCountry1:[String: String] = [:]
    var testCountry2:[String: String] = [:]
    var testCountry3:[String: String] = [:]

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = true

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        
        // initialize the variables for testing
        covidApp = XCUIApplication()
        navBar = covidApp.tabBars
        testCountry1 = ["name":"🇦🇺 Australia", "recovered":"Recovered: 24987 cases", "active":"Active: 1360 cases", "deaths": "Deaths: 897 cases", "confirmed":"Confirmed: 27244 cases"]
        testCountry2 = ["name":"🇨🇳 China", "recovered":"Recovered: 85641 cases", "active":"Active: 371 cases", "deaths": "Deaths: 4739 cases", "confirmed":"Confirmed: 90751 cases"]
        testCountry3 = ["name":"🇺🇸 United States of America", "recovered":"Recovered: 3039089 cases", "active":"Active: 4410452 cases", "deaths": "Deaths: 213752 cases", "confirmed":"Confirmed: 7663293 cases"]
        covidApp.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        XCUIDevice.shared.orientation = UIDeviceOrientation.portrait
        covidApp = nil
        navBar = nil
    }
    
    func testSearch(){
        // Go to "search" in tab bar
        covidApp.tabBars.buttons["Search"].tap()
        
        // Tab on search field
        covidApp.searchFields["Australia"].tap()
        
        // Type Mexico, it should exist on the table field
        covidApp.searchFields.element.typeText("Mexico")
        XCTAssertTrue(covidApp.tables.staticTexts["🇲🇽 Mexico"].exists)
        
    }
    
    func testSubscribe(){
        // Go to "search" in tab bar
        covidApp.tabBars.buttons["Search"].tap()
        
        // Tab on search field
        covidApp.searchFields["Australia"].tap()
        
        // Type Mexico
        covidApp.searchFields.element.typeText("China")
        
        // Tab on Mexico and tab subscribe
        covidApp.tables.staticTexts["🇨🇳 China"].tap()
        covidApp.buttons["Subscribe"].tap()
        
        // Check if Mexico exists in the table
        XCTAssertTrue(covidApp.tables.staticTexts["🇨🇳 China"].exists)
        
        // Check if you can see Unsubscribe button
        covidApp.tables.staticTexts["🇨🇳 China"].tap()
        XCTAssertTrue(covidApp.buttons["Unsubscribe"].exists)
        
        // unsubscribe the country to ensure same status
        covidApp.buttons["Unsubscribe"].tap()
        
    }
    
    func testUnsubscribe(){
        // Go to "search" in tab bar
        covidApp.tabBars.buttons["Search"]/*@START_MENU_TOKEN@*/.tap()/*[[".tap()",".press(forDuration: 2.1);"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/
        
        // Subscribe to Mexico
        let mexicoStaticText = covidApp.tables.staticTexts["🇲🇽 Mexico"]
        mexicoStaticText.tap()
        covidApp/*@START_MENU_TOKEN@*/.buttons["Subscribe"]/*[[".scrollViews.buttons[\"Subscribe\"]",".buttons[\"Subscribe\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        print("Tapped subscribe button")
        //Tab on Mexico to unsubscribe
        mexicoStaticText.tap()
        covidApp/*@START_MENU_TOKEN@*/.buttons["Unsubscribe"]/*[[".scrollViews.buttons[\"Unsubscribe\"]",".buttons[\"Unsubscribe\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        //Check if Mexico doesn't exist in the table
        XCTAssertTrue(!covidApp.tables.staticTexts["🇲🇽 Mexico"].exists)
    }

    func testNavTabToEachPage() {
    
        // wait 3 seconds and check if "Ranking" tab button exists
        XCTAssertTrue(navBar.buttons["Ranking"].waitForExistence(timeout: 3))
        // tab ranking tab button
        navBar.buttons["Ranking"].tap()
        
        // the ranking page's label is "Most Confirmed Cased"
        XCTAssert(covidApp.navigationBars.otherElements.firstMatch.label=="Most Confirmed Cased")
        print("Navigate to Ranking Page successfully")
        
        // tap "Home" tab
        navBar.buttons["Home"].tap()
        
        // wait 3 seconds and check if the title is "Your Subscribtion"
        XCTAssert(covidApp.navigationBars.otherElements.firstMatch.label=="Your Subscribtion")
        
        print("Navigate to Home/Subscribtion Page successfully")
        
        // tap "Search" tab
        navBar.buttons["Search"].tap()
        // wait 3 seconds and check if the title is "Search"
        XCTAssert(covidApp.navigationBars.otherElements.firstMatch.label=="Search")
        
        print("Navigate to Ranking Page successfully")
        
        // tap "Ranking" tab
        navBar.buttons["Ranking"].tap()
       
        // tap first item in the top ten table
        covidApp.tables.cells.firstMatch.tap()
        
        // now it should be in profile page and the label should be "Profile"
        XCTAssert(covidApp.navigationBars.otherElements.firstMatch.label=="Profile")
        
        print("Navigate to Profile Page successfully")
        
        // go to "Home" page
        navBar.buttons["Home"].tap()
       
        // click "Development Team" button
        covidApp.navigationBars.buttons["Item"].tap()
        // "Development Team" page should appear
        print("Tap Development team button")
        let label:String! = covidApp.navigationBars.otherElements.firstMatch.label;
        print(label!)
        XCTAssert(label=="Development Team")

        print("Navigate to Credits Page successfully")
        print("Navigation Bar tests all passed.")
        
    }
    
    func testRankingPage() {
        // tap "Ranking" tab
        navBar.buttons["Ranking"].tap()
        
        // check if there are USA element
        XCTAssertTrue(covidApp.scrollViews.tables.cells.staticTexts[" 1. 🇺🇸 United States of America"].exists)
        
        print("Ranking Page test passed.")
                
    }

    
    
    func testCreditButton() {
        // go to home page
        navBar.buttons["Home"].tap()
        // wait 3 seconds and check if home button exists
        XCTAssertTrue(covidApp.navigationBars.buttons["Item"].waitForExistence(timeout: 3))
    }
    
    func testRefreshButton() {
        // go to home page
        navBar.buttons["Home"].tap()
        // wait 3 seconds and check if home button exists
        XCTAssertTrue(covidApp.navigationBars.buttons["Refresh"].waitForExistence(timeout: 3))
    }
    
    
 
    
}

//
//  AIChatUITests.swift
//  AIChatUITests
//
//  Created by Desmond Fitch on 3/22/25.
//

import XCTest

@MainActor
final class AIChatUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        
    }

    func testOnboardingFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
        
        app.buttons["StartButton"].tap()
        app.buttons["Continue"].tap()
        
        let colorCircles = app.otherElements.matching(identifier: "ColorCircle")
        let randomIndex = Int.random(in: 0 ..< colorCircles.count)
        let colorCircle = colorCircles.element(boundBy: randomIndex)
        colorCircle.tap()
        
        app.buttons["Continue"].tap()
        app.buttons["FinishButton"].tap()
        
        let exploreExists = app.navigationBars["Explore"].waitForExistence(timeout: 2)
        XCTAssertTrue(exploreExists)
    }
    
    func testOnboardingFlowWithCommunityScreen() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "ONBCMMTEST"]
        app.launch()
        
        // Welcome View
        app.buttons["StartButton"].tap()
        
        // Onboarding Intro View
        app.buttons["Continue"].tap()
        
        // Onboarding Community View
        app.buttons["OnboardingCommunityContinueButton"].tap()
        
        let colorCircles = app.otherElements.matching(identifier: "ColorCircle")
        let randomIndex = Int.random(in: 0 ..< colorCircles.count)
        let colorCircle = colorCircles.element(boundBy: randomIndex)
        colorCircle.tap()
        
        app.buttons["Continue"].tap()
        app.buttons["FinishButton"].tap()
        
        let exploreExists = app.navigationBars["Explore"].waitForExistence(timeout: 2)
        XCTAssertTrue(exploreExists)
    }
    
    func testTabBarFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SIGNED_IN"]
        app.launch()
        
        let tabBar = app.tabBars["Tab Bar"]

        // Explore View
        let exploreExists = app.navigationBars["Explore"].exists
        XCTAssertTrue(exploreExists)
        
        // Click hero cell
        app.collectionViews.scrollViews.otherElements.buttons.firstMatch.tap()
        
        // Chat View
        let textFieldExists = app.textFields["ChatTextField"].exists
        XCTAssertTrue(textFieldExists)

        app.navigationBars.buttons.firstMatch.tap()
        let exploreExists2 = app.navigationBars["Explore"].exists
        XCTAssertTrue(exploreExists2)
               
        tabBar.buttons["Chats"].tap()
        let chatsExists = app.navigationBars["Chats"].exists
        XCTAssertTrue(chatsExists)
        
        app.collectionViews.scrollViews.otherElements.buttons.firstMatch.tap()
        
        let textFieldExists2 = app.textFields["ChatTextField"].exists
        XCTAssertTrue(textFieldExists2)

        app.navigationBars.buttons.firstMatch.tap()
        let chatsExists2 = app.navigationBars["Chats"].exists
        XCTAssertTrue(chatsExists2)

        tabBar.buttons["Profile"].tap()
        let profileExists = app.navigationBars["Profile"].exists
        XCTAssertTrue(profileExists)

        app.collectionViews.buttons.element(boundBy: 1).tap()
        
        let textFieldExists3 = app.textFields["ChatTextField"].exists
        XCTAssertTrue(textFieldExists3)

        app.navigationBars.buttons.firstMatch.tap()
        
        let profileExists2 = app.navigationBars["Profile"].exists
        XCTAssertTrue(profileExists2)

        tabBar.buttons["Explore"].tap()
        let exploreExists3 = app.navigationBars["Explore"].exists
        XCTAssertTrue(exploreExists3)
    }
    
    func testSignOutFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SIGNED_IN"]
        app.launch()
        
        let exploreExists = app.navigationBars["Explore"].waitForExistence(timeout: 2)
        XCTAssertTrue(exploreExists)
        
        let tabBar = app.tabBars["Tab Bar"]
        
        tabBar.buttons["Profile"].tap()
        let profileExists = app.navigationBars["Profile"].exists
        XCTAssertTrue(profileExists)
        
        app.navigationBars["Profile"]/*@START_MENU_TOKEN@*/.buttons["gear"]/*[[".otherElements[\"Settings\"]",".buttons[\"Settings\"]",".buttons[\"gear\"]",".otherElements[\"gear\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.collectionViews/*@START_MENU_TOKEN@*/.buttons["Sign Out"]/*[[".cells.buttons[\"Sign Out\"]",".buttons[\"Sign Out\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let startButtonExists = app.buttons["StartButton"].waitForExistence(timeout: 4)
        XCTAssertTrue(startButtonExists)
    }
    
    func testCreateAvatarScreen() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SIGNED_IN", "STARTSCREEN_CREATEAVATAR"]
        app.launch()
        
        let screenExists = app.navigationBars["Create Avatar"].exists
        XCTAssertTrue(screenExists)
    }
}

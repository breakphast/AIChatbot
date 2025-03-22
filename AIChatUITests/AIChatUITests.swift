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
        app.buttons["ContinueButton"].tap()
        
        let colorCircles = app.otherElements.matching(identifier: "ColorCircle")
        let randomIndex = Int.random(in: 0 ..< colorCircles.count)
        let colorCircle = colorCircles.element(boundBy: randomIndex)
        colorCircle.tap()
        
        app.buttons["ContinueButton"].tap()
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
        app.buttons["ContinueButton"].tap()
        
        // Onboarding Community View
        app.buttons["OnboardingCommunityContinueButton"].tap()
        
        let colorCircles = app.otherElements.matching(identifier: "ColorCircle")
        let randomIndex = Int.random(in: 0 ..< colorCircles.count)
        let colorCircle = colorCircles.element(boundBy: randomIndex)
        colorCircle.tap()
        
        app.buttons["ContinueButton"].tap()
        app.buttons["FinishButton"].tap()
        
        let exploreExists = app.navigationBars["Explore"].waitForExistence(timeout: 2)
        XCTAssertTrue(exploreExists)
    }
    
    func testTabBarFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SIGNED_IN"]
        app.launch()
        
        var exploreExists = app.navigationBars["Explore"].waitForExistence(timeout: 2)
        XCTAssertTrue(exploreExists)
        
        let tabBar = app.tabBars["Tab Bar"]
        
        tabBar.buttons["Chats"].tap()
        let chatsExists = app.navigationBars["Chats"].exists
        XCTAssertTrue(chatsExists)
        
        tabBar.buttons["Profile"].tap()
        let profileExists = app.navigationBars["Profile"].exists
        XCTAssertTrue(profileExists)
        
        tabBar.buttons["Explore"].tap()
        exploreExists = app.navigationBars["Explore"].exists
        XCTAssertTrue(exploreExists)
        
        app.collectionViews/*@START_MENU_TOKEN@*/.scrollViews/*[[".cells.scrollViews",".scrollViews"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.otherElements.buttons.firstMatch.tap()
        let chatTextFieldExists = app.textFields["ChatTextField"].exists
        XCTAssertTrue(chatTextFieldExists)
        
        let alphaNavigationBar = app.navigationBars["Alpha"]
        alphaNavigationBar.buttons["Explore"].tap()
        
        tabBar.buttons["Chats"].tap()
        app.collectionViews.children(matching: .cell).element(boundBy: 3).firstMatch.tap()
        alphaNavigationBar.buttons["Chats"].tap()
        XCTAssertTrue(chatsExists)
        
        tabBar.buttons["Profile"].tap()
        app.collectionViews/*@START_MENU_TOKEN@*/.staticTexts["Alpha"]/*[[".cells",".buttons[\"Alpha\"].staticTexts[\"Alpha\"]",".staticTexts[\"Alpha\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        alphaNavigationBar.firstMatch.tap()
        XCTAssertTrue(profileExists)
    }
    
    func testSignOutFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING", "SIGNED_IN"]
        app.launch()
        
        var exploreExists = app.navigationBars["Explore"].waitForExistence(timeout: 2)
        XCTAssertTrue(exploreExists)
        
        let tabBar = app.tabBars["Tab Bar"]
        
        tabBar.buttons["Profile"].tap()
        let profileExists = app.navigationBars["Profile"].exists
        XCTAssertTrue(profileExists)
        
        app.navigationBars["Profile"]/*@START_MENU_TOKEN@*/.buttons["gear"]/*[[".otherElements[\"Settings\"]",".buttons[\"Settings\"]",".buttons[\"gear\"]",".otherElements[\"gear\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.collectionViews/*@START_MENU_TOKEN@*/.buttons["Sign Out"]/*[[".cells.buttons[\"Sign Out\"]",".buttons[\"Sign Out\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let startButtonExists = app.buttons["StartButton"].waitForExistence(timeout: 2)
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

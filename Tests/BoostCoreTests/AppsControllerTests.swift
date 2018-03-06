//
//  AppsControllerTests.swift
//  BoostCoreTests
//
//  Created by Ondrej Rafaj on 05/03/2018.
//

import Foundation
import XCTest
import Vapor
import VaporTestTools
import FluentTestTools
import ApiCoreTestTools
import BoostTestTools
@testable import ApiCore
@testable import BoostCore


class AppsControllerTests: XCTestCase, AppTestCaseSetup, LinuxTests {
    
    var app: Application!
    
    var user1: User!
    var user2: User!
    
    var team1: Team!
    var team2: Team!
    
    var key1: UploadKey!
    var key2: UploadKey!
    var key3: UploadKey!
    var key4: UploadKey!
    
    var team4: Team!
    
    var app1: App!
    var app2: App!
    
    
    // MARK: Linux
    
    static let allTests: [(String, Any)] = [
        ("testGetAppsOverview", testGetAppsOverview),
        ("testUnobfuscatedApkUploadWithJWTAuth", testUnobfuscatedApkUploadWithJWTAuth),
        ("testObfuscatedApkUploadWithJWTAuth", testObfuscatedApkUploadWithJWTAuth),
        ("testLinuxTests", testLinuxTests)
    ]
    
    func testLinuxTests() {
        doTestLinuxTestsAreOk()
    }
    
    // MARK: Setup
    
    override func setUp() {
        super.setUp()
        
        app = Application.testable.newBoostTestApp()
        
        app.testable.delete(allFor: Token.self)
        
        setupApps()
    }
    
    override func tearDown() {
        deleteAllFiles()
        
        super.tearDown()
    }
    
    // MARK: Tests
    
    func testGetAppsOverview() {
        let count = app.testable.count(allFor: App.self)
        XCTAssertEqual(count, 107, "There should be right amount of apps to begin with")
        
        let req = HTTPRequest.testable.get(uri: "/apps", authorizedUser: user1, on: app)
        let res = app.testable.response(to: req)
        
        res.testable.debug()
        
        let keys = res.testable.content(as: Apps.self)!
        
        XCTAssertEqual(keys.count, 100, "There should be right amount of apps")
        
        XCTAssertTrue(res.testable.has(statusCode: .ok), "Wrong status code")
        XCTAssertTrue(res.testable.has(contentType: "application/json; charset=utf-8"), "Missing content type")
    }
    
    func testUnobfuscatedApkUploadWithJWTAuth() {
        var count = app.testable.count(allFor: App.self)
        XCTAssertEqual(count, 107, "There should be right amount of apps to begin with")
        
        let apkUrl = Application.testable.paths.resourcesUrl.appendingPathComponent("Demo/app.apk")
        let postData = try! Data(contentsOf: apkUrl)
        let req = try! HTTPRequest.testable.post(uri: "/teams/\(team1.id!.uuidString)/apps?tags=tagging_like_crazy".makeURI(), data: postData, headers: [
            "Content-Type": "application/ocet-stream"
            ], authorizedUser: user1, on: app
        )
        let res = app.testable.response(to: req)
        
        res.testable.debug()
        
        let object = res.testable.content(as: App.self)!
        
        // TODO: Make another app!!!!!!!!!
        doTest(app: object, platform: .android, name: "Bytecheck", identifier: "cz.vhrdina.bytecheck.ByteCheckApplication", version: "7.1.1", build: "25")
        
        count = app.testable.count(allFor: App.self)
        XCTAssertEqual(count, 108, "There should be right amount of apps to begin with")
    }
    
    func testObfuscatedApkUploadWithJWTAuth() {
        var count = app.testable.count(allFor: App.self)
        XCTAssertEqual(count, 107, "There should be right amount of apps to begin with")
        
        let apkUrl = Application.testable.paths.resourcesUrl.appendingPathComponent("Demo/app-obfuscated.apk")
        let postData = try! Data(contentsOf: apkUrl)
        let req = try! HTTPRequest.testable.post(uri: "/teams/\(team1.id!.uuidString)/apps?tags=tagging_like_crazy".makeURI(), data: postData, headers: [
            "Content-Type": "application/ocet-stream"
            ], authorizedUser: user1, on: app
        )
        let res = app.testable.response(to: req)
        
        res.testable.debug()
        
        let object = res.testable.content(as: App.self)!
        
        doTest(app: object, platform: .android, name: "BoostTest", identifier: "io.liveui.boosttest")
        
        count = app.testable.count(allFor: App.self)
        XCTAssertEqual(count, 108, "There should be right amount of apps to begin with")
    }
    
}


extension AppsControllerTests {
    
    private func doTest(app object: App, platform: App.Platform, name: String, identifier: String, version: String? = nil, build: String? = nil) {
        XCTAssertEqual(object.platform, platform.rawValue, "Wrong platform")
        XCTAssertEqual(object.name, name, "Wrong name")
        XCTAssertEqual(object.identifier, identifier, "Wrong identifier")
        XCTAssertEqual(object.version, version ?? "0.0", "Wrong version")
        XCTAssertEqual(object.build, build ?? "0", "Wrong build")
        
        // TODO: Test all files have been deleted!!!!!
    }
    
}



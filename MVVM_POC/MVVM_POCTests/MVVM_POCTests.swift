//
//  MVVM_POCTests.swift
//  MVVM_POCTests
//
//  Created by Moayad Al kouz on 7/10/19.
//  Copyright © 2019 Moayad Al kouz. All rights reserved.
//

import XCTest
@testable import MVVM_POC
class MVVM_POCTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        let searchRepoViewModel = ReposListViewModel()
        
        searchRepoViewModel.serachRepos(queryString: "listpl", success: {

            XCTAssert(true, "Success")

        }) { (error) in
            
            XCTAssert(false, error?.localizedDescription ?? "")
        }
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

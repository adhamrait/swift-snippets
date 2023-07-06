//
//  LimitedConcurrentQueueWorkItemTests.swift
//  
//
//  Created by Arjun Dhamrait on 7/6/23.
//

import XCTest

@testable import swift_snippets

class LimitedConcurrentQueueWorkItemTests: XCTestCase {

    func testCancel() {
        let item = LimitedConcurrentQueueWorkItem({})
        XCTAssertFalse(item.isCancelled)
        item.isCancelled = true
        XCTAssertTrue(item.isCancelled)
        item.isCancelled = false
        XCTAssertTrue(item.isCancelled)
    }
    
    func testPerform() {
        var performed = false
        let item = LimitedConcurrentQueueWorkItem {
            performed = true
        }
        XCTAssertFalse(performed)
        item.perform()
        XCTAssertTrue(performed)
    }

}

//
//  LimitedConcurrentQueueTest.swift
//  
//
//  Created by Arjun Dhamrait on 7/6/23.
//

import XCTest
import swift_snippets

class LimitedConcurrentQueueTests: XCTestCase {
    
    func testOneItem() throws {
        let queue = LimitedConcurrentQueue(width: 1)
        let exp = expectation(description: "block completed")
        queue.add {
            exp.fulfill()
        }
        waitForExpectations(timeout: 0.01)
    }
    
    func testSynchronousQueue() throws {
        let queue = LimitedConcurrentQueue(width: 1)
        var lastToFinish = -1
        let exp1 = expectation(description: "first block")
        let exp2 = expectation(description: "second block")
        
        queue.add {
            defer { exp1.fulfill() }
            sleep(1)
            lastToFinish = 1
        }
        
        queue.add {
            defer { exp2.fulfill() }
            lastToFinish = 2
        }
        
        waitForExpectations(timeout: 1.01)
        XCTAssertEqual(lastToFinish, 2)
    }
    
    func testAsynchronous() throws {
        let queue = LimitedConcurrentQueue(width: 2)
        var lastToFinish = -1
        let exp1 = expectation(description: "first block")
        let exp2 = expectation(description: "second block")
        
        queue.add {
            defer { exp1.fulfill() }
            sleep(1)
            lastToFinish = 1
        }
        
        queue.add {
            defer { exp2.fulfill() }
            lastToFinish = 2
        }
        
        waitForExpectations(timeout: 1.01)
        XCTAssertEqual(lastToFinish, 1)
    }

    func testCancel() throws {
        let queue = LimitedConcurrentQueue(width: 1)
        var lastToFinish = -1
        let exp1 = expectation(description: "first block")
        let exp2 = expectation(description: "second block")
        exp2.isInverted = true
        let exp3 = expectation(description: "third block")
        
        queue.add {
            defer { exp1.fulfill() }
            sleep(1)
            lastToFinish = 1
        }
        
        let item2 = queue.add {
            defer { exp2.fulfill() }
            lastToFinish = 2
        }
        
        queue.add {
            defer { exp3.fulfill() }
            lastToFinish = 3
        }
        
        item2.isCancelled = true
        
        waitForExpectations(timeout: 1.01)
        XCTAssertEqual(lastToFinish, 3)
    }
}

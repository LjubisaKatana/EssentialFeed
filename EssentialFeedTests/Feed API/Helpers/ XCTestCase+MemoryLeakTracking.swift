//
//   XCTestCase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Ljubisa Katana on 5.4.23..
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(instance: AnyObject,
                                     file: StaticString = #filePath,
                                     line: UInt = #line) {
        
        addTeardownBlock { [weak instance] in // run after each test
            XCTAssertNil(instance, "Instance should have been deallocated, Potential memory leak", file: file, line: line)
        }
    }
}

 

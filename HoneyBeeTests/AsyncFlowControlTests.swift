//
//  AsyncFlowControlTests.swift
//  HoneyBeeTests
//
//  Created by Alex Lynch on 12/26/19.
//  Copyright © 2019 IAM Apps. All rights reserved.
//

import Foundation
import XCTest
import HoneyBee

class AsyncFlowControlTests: XCTestCase {

    override func setUp() {

    }

    override func tearDown() {

    }

    func testSimpleControlFlow() {
        func testValue(_ value: Int) {
            let hb = HoneyBee.start(on: MainDispatchQueue())
            let int = value >> hb
            if_ (int == 0) {
                XCTAssert(value == 0, "\(value) is not zero")
            }.else {
                XCTAssert(value != 0, "\(value) is zero")
            }

            if_ (int > 0) {
                XCTAssert(value > 0, "\(value) is not positive")
            }.else_if (int < 0) {
                XCTAssert(value < 0, "\(value) is not negative")
            }.else {
                XCTAssert(value == 0, "\(value) is not zero")
            }
        }

        testValue(3)
        testValue(-1)
        testValue(0)
        testValue(20)
        testValue(5)
    }

    func testNonEvaluation() {
        func testValue(_ value: Int) {
            let hb = HoneyBee.start(on: MainDispatchQueue())
            let int = value >> hb

            if_ (int == 0) {
                XCTAssert(value == 0, "\(value) is not zero")
            }.else_if (int.drop.chain(fail).insert(true)) {
                XCTFail()
            }.else_if (int.drop.chain(fail).insert(true)) {
                XCTFail()
            }.else {
                XCTFail()
            }

            if_ (int == 0) {
                XCTAssert(value == 0, "\(value) is not zero")
            }.else {
                XCTFail()
            }
        }

        testValue(0)
    }



    func testChainedAccess() {
        let zero = self.expectation(description: "zero")
        let one = self.expectation(description: "one")
        let two = self.expectation(description: "two")

        func testValue(_ value: String) {
            let hb = HoneyBee.start(on: MainDispatchQueue())
            let string = value >> hb

            if_ (string.count == 0) {
                XCTAssert(value.count == 0)
                zero.fulfill()
            }

            if_ (string.utf16.underestimatedCount == 1) {
                XCTAssert(value.utf16.underestimatedCount == 1)
                one.fulfill()
            }

            if_ (string.lowercased().capitalized.count == 2) {
                XCTAssert(value.lowercased().capitalized.count == 2)
                two.fulfill()
            }
        }

        testValue("")
        testValue("a")
        testValue("aa")

        self.waitForExpectations(timeout: 1)
    }
}

extension String {
    var lowercased: ZeroArgFunction<String, Never> { async0(self.lowercased) }
}

//
//  HoneyBeeTests.swift
//  HoneyBeeTests
//
//  Created by Alex Lynch on 4/11/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import XCTest
import HoneyBee

class SinglePathTests: XCTestCase {
    let funcContainer = TestingFunctions()
	
	override func setUp() {
		super.setUp()
		
		HoneyBee.functionOvercallResponse = .fail
		HoneyBee.functionUndercallResponse = .fail
		HoneyBee.internalFailureResponse = .fail
		HoneyBee.mismatchedConjoinResponse = .fail
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testCompletionHandler() {
		let expect1 = expectation(description: "Chain 1 should complete")

		func completionHandler(_ error: Error?) {
			if let error = error {
				fail(on: error)
			} else {
				XCTAssert(Thread.current.isMainThread)
				expect1.fulfill()
			}
		}
		
		HoneyBee.start(on: DispatchQueue.main) { root in
			root.setCompletionHandler(completionHandler)
				.setBlockPerformer(DispatchQueue.global())
				.insert(4)
				.chain(self.funcContainer.intToString)
				.chain(self.funcContainer.stringToInt)
				.chain(self.funcContainer.multiplyInt)
				.chain(assertEquals =<< 8)
		}
		
		let expect2 = expectation(description: "Simple chain 2 should complete")
		
		func completionHandler2(_ error: Error?) {
			if let error = error {
				fail(on: error)
			} else {
				XCTAssert(!Thread.current.isMainThread)
				expect2.fulfill()
			}
		}
		
		HoneyBee.start()
				.setCompletionHandler(completionHandler2)
				.insert(self.funcContainer)
				.setBlockPerformer(DispatchQueue.main)
				.chain(TestingFunctions.noop)
				.chain(TestingFunctions.voidFunc)
				.chain(assertEquals =<< self.funcContainer)

		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}

	func testOptionally() {
		let expect = expectation(description: "Expect should be reached")
		let optionalExpect = expectation(description: "Optional expect should be reached")

		var optionallyCompleted = false

		HoneyBee.start(on: DispatchQueue.main) { root in
			root.setErrorHandler(fail)
				.insert(Optional(7))
				.optionally { link in
					link.chain(assertEquals =<< 7)
						.chain(optionalExpect.fulfill)
						.chain{ optionallyCompleted = true }
				}
				.drop()
				.chain{ XCTAssert(optionallyCompleted, "Optionally chain should have completed by now") }
				.chain(expect.fulfill)
		}

		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}

	func testOptionallylNegative() {
		let expect = expectation(description: "Expect should be reached")
		let optionalExpect = expectation(description: "Optional expect should not be reached")
		optionalExpect.isInverted = true

		HoneyBee.start(on: DispatchQueue.main) { root in
			root.setErrorHandler(fail)
				.insert(Optional<Int>(nilLiteral: ()))
				.optionally { link in
					link.drop()
						.chain(optionalExpect.fulfill)
				}
				.drop()
				.chain(expect.fulfill)
		}

		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
		
	func testMultipleCallback() {
		let finishExpectation = expectation(description: "Should finish chain")
		
		HoneyBee.functionOvercallResponse = .custom(handler: { (message) in
			//ignore
		})
		
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.chain{ (callback: (FailableResult<Int>) -> Void) in
					callback(.success(1))
					callback(.success(2))
					callback(.failure(NSError(domain: "Purposeful error", code: 3, userInfo: nil)))
					callback(.failure(NSError(domain: "Purposeful error", code: 4, userInfo: nil)))
				}
				.chain(assertEquals =<< 1)
				.chain(finishExpectation.fulfill)
		}
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testQueueChange() {
		let expect = expectation(description: "Simple chain should complete")
		
		func assertThreadIsMain(_ isMain: Bool){
			XCTAssert(Thread.isMainThread == isMain, "Thead-mainness expected to be \(isMain) but is \(Thread.isMainThread)")
		}
		
		HoneyBee.start(on: DispatchQueue.main) { root in
			root.setErrorHandler(fail)
				.insert(4)
				.chain(self.funcContainer.intToString)
				.drop()
				.chain(assertThreadIsMain =<< true)
				.setBlockPerformer(DispatchQueue.global())
				.chain(assertThreadIsMain =<< false)
				.setBlockPerformer(DispatchQueue.main)
				.chain(assertThreadIsMain =<< true)
				.chain(expect.fulfill)
		}
		
		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testFailableResultChains() {
		let expect1 = expectation(description: "Chain 1 should complete")
		let expect2 = expectation(description: "Chain 2 should complete")
		
		let generator = FibonaciGenerator()
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.insert(generator)
				.chain(FibonaciGenerator.ready)
				.chain(assertEquals =<< true)
				.chain(expect1.fulfill)
		}
		
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.insert(generator)
				.chain(FibonaciGenerator.next)
				.chain(assertEquals =<< 1)
				.chain(expect2.fulfill)
		}
		
		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testTunnel() {
		let expectFinal = expectation(description: "Chain should complete")
		let expectTunnel = expectation(description: "Tunnel chain should complete")
		
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.insert(4)
				.tunnel { link in
					link.chain(self.funcContainer.intToString)
						.chain(assertEquals =<< "4")
						.chain(expectTunnel.fulfill)
				}
				.chain(self.funcContainer.multiplyInt)
				.chain(assertEquals =<< 8)
				.chain(expectFinal.fulfill)
		}
		
		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}

#if swift(>=4.0)
	func testKeyPath() {
		let expect1 = expectation(description: "KeyPath chain should complete")
		
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.insert("catdog")
				.chain(\String.utf16.count)
				.chain(assertEquals =<< 6)
				.chain(expect1.fulfill)
		}
		
		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
#endif
}

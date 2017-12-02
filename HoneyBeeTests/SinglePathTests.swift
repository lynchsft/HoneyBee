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
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testSimpleChain() {
		let expect1 = expectation(description: "Simple chain 1 should complete")

		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.insert(4)
				.chain(self.funcContainer.intToString)
				.chain(self.funcContainer.stringToInt)
				.chain(self.funcContainer.multiplyInt)
				.chain(assertEquals =<< 8)
				.chain(expect1.fulfill)
		}
		
		let expect2 = expectation(description: "Simple chain 2 should complete")
		
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.insert(self.funcContainer)
				.chain(TestingFunctions.noop)
				.chain(TestingFunctions.voidFunc)
				.chain(assertEquals =<< self.funcContainer)
				.drop()
				.chain(expect2.fulfill)
		}

		waitForExpectations(timeout: 2) { error in
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
	
	func testFinally() {
		var counter = 0 // do not make this Atomic. HoneyBee should perform the entire chane below serailly (though not liearlly of course). 
		let incrementCounter = { counter += 1 }
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.finally { link in
					link.chain { XCTAssert(counter == 6, "counter should be 6: was actually \(counter)") }
						.chain(incrementCounter)
				}.finally { link in
					link.chain { XCTAssert(counter == 7, "counter should be 7: was actually \(counter)") }
						.chain(incrementCounter)
				}.finally { link in
					link.chain { () -> Void in XCTAssert(counter == 8, "counter should be 8: was actually \(counter)") ; finishExpectation.fulfill() }
				}
				.chain{ XCTAssert(counter == 0, "counter should be 0") }
				.finally { link in
					link.chain { XCTAssert(counter == 5, "counter should be 5: was actually \(counter)") }
						.chain(incrementCounter)
				}
				.chain(incrementCounter)
				.chain{ XCTAssert(counter == 1, "counter should be 1") }
				.finally { link in
					link.chain { XCTAssert(counter == 4, "counter should be 4: was actually \(counter)") }
						.chain(incrementCounter)
				}
				.chain(incrementCounter)
				.chain{ XCTAssert(counter == 2, "counter should be 2") }
				.finally { link in
					link.chain { XCTAssert(counter == 3, "counter should be 3: was actually \(counter)") }
						.chain(incrementCounter)
				}
				.chain(incrementCounter)
		}
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	

	
	func testMultipleCallback() {
		let finishExpectation = expectation(description: "Should finish chain")
		
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

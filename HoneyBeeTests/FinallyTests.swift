//
//  FinallyTests.swift
//  HoneyBeeTests
//
//  Created by Alex Lynch on 12/2/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import XCTest
import HoneyBee

class FinallyTests: XCTestCase {
    let funcContainer = TestingFunctions()
	
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
	func testFinallyOrdering() {
		var counter = 0 // do not make this Atomic. HoneyBee should perform the entire chane below serailly (though not liearlly of course).
		let incrementCounter = { counter += 1 }
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		HoneyBee.start { root in
			root.setErrorHandler(fail)
				.finally { link in
					link.chain { XCTAssert(counter == 4, "counter should be 4: was actually \(counter)") }
						.chain(incrementCounter)
				}.finally { link in
					link.chain { XCTAssert(counter == 5, "counter should be 5: was actually \(counter)") }
						.chain(finishExpectation.fulfill)
				}
				.chain{ XCTAssert(counter == 0, "counter should be 0") }
				.finally { link in
					link.chain { XCTAssert(counter == 3, "counter should be 3: was actually \(counter)") }
						.chain(incrementCounter)
				}
				.chain(incrementCounter)
				.chain{ XCTAssert(counter == 1, "counter should be 1") }
				.finally { link in
					link.chain { XCTAssert(counter == 2, "counter should be 2: was actually \(counter)") }
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
	
	func testFinallyContent() {
		
		let unreachableExpectation = expectation(description: "Should not reach the end of the chain")
		unreachableExpectation.isInverted = true
		let reachableExpectation = expectation(description: "Should reach this finally")
		let errorExpectation = expectation(description: "chain should error")
		
		HoneyBee.start { root in
			let _ = root.setErrorHandler { _ in errorExpectation.fulfill() }
						.chain(self.funcContainer.constantString)
						.finally { link in
							link.chain(assertEquals =<< "lamb")
								.chain(reachableExpectation.fulfill)
						}
						.chain(self.funcContainer.explode)
						.finally { link in
							link.drop()
								.chain(unreachableExpectation.fulfill)
						}
			//^^ The "let _" suppresses the warning that you get when discarding finally's result
		}
		
		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testFinallyError() {
		var counter = 0
		let incrementCounter = { counter += 1 }
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		func handleError(_ error: Error, arg: Any) {} // we cause an error on purpose
		
		HoneyBee.start { root in
			root.setErrorHandler(fail) // this is just to start off with. We update the error handler below
				.finally { link in
					link.chain { () -> Void in XCTAssert(counter == 2, "counter should be 2") ; finishExpectation.fulfill() }
				}
				.chain{ XCTAssert(counter == 0, "counter should be 0") }
				.chain(incrementCounter)
				.chain{ XCTAssert(counter == 1, "counter should be 1") }
				.chain(incrementCounter)
				.setErrorHandler(handleError)
				.chain({ throw NSError(domain: "An expected error", code: -1, userInfo: nil) })
				.chain(incrementCounter)
		}
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testFinallyWithRetry() {
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		let finallyExpectation = expectation(description: "Should reach the finally")
		
		
		HoneyBee.start(on: DispatchQueue.main) { root in
			root.setErrorHandler(fail)
				.finally { link in
					link.chain(finallyExpectation.fulfill)
				}
				.retry(1) { link in
					link.chain(self.funcContainer.constantInt)
				}
				.chain(self.funcContainer.multiplyInt)
				.drop()
				.chain(finishExpectation.fulfill)
		}
		
		
		waitForExpectations(timeout: 141) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
}
